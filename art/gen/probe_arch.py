"""Capability probe: can Blender produce a kit piece Godot can actually use?

    tools\\blender.ps1 -Script art\\gen\\probe_arch.py

Builds a solid, closed, UV-mapped Gothic arch at exact nominal dimensions and
writes it into the engine project at dotbg/assets/probe/arch.glb. The Godot half
of the proof is tests/asset_pipeline_test.gd, which imports it and asserts what
survived the trip.

This is not the kit. It is the smallest artefact exercising every step the kit
depends on: parametric geometry, real thickness and depth, UVs, exact
dimensions, glTF export, engine import. If a link here is broken, Phase 3 is not
startable, and that is worth knowing now rather than at week eight.

Built entirely from mesh data, with no bpy.ops except the exporter. The first
version used the modifier stack and smart UV projection, and both failed in
background mode — solidify on an edge-only mesh yields zero polygons, and
uv.smart_project has no valid context without a window. Operators assume a
running editor. Data does not, which is what makes this reproducible in CI.
"""

import math
import os
import sys

import bpy

SPAN = 2.0          # opening between the two springing points
RISE = 2.4          # springing line to apex
THICKNESS = 0.22    # radial thickness of the arch band
DEPTH = 0.35        # extrusion along Y, the wall thickness
SEGMENTS = 24
UV_TILES_PER_METRE = 0.5

OUT_REL = os.path.join("dotbg", "assets", "probe", "arch.glb")


def log(msg):
    print("  " + msg)


def arch_profile(span, rise, thickness, segments):
    """Ordered (outer, inner) point pairs from left springing to right.

    A two-centred Gothic arch: two circular arcs whose centres sit on the
    springing line, inside the span, which is what makes the apex a point.
    Given span S and rise h, requiring each arc to pass through both its far
    springing point and the apex gives:

        c = (h^2 - S^2/4) / S        R = S/2 + c

    The inner curve is struck from the same centres at R - thickness, so the
    band has constant radial thickness — the property that lets two pieces meet
    without a step.
    """
    c = (rise * rise - span * span / 4.0) / span
    r = span / 2.0 + c
    theta = math.acos(max(-1.0, min(1.0, c / r)))

    def left(t):
        return ((c - r * math.cos(t), r * math.sin(t)),
                (c - (r - thickness) * math.cos(t), (r - thickness) * math.sin(t)))

    def right(t):
        return ((-c + r * math.cos(t), r * math.sin(t)),
                (-c + (r - thickness) * math.cos(t), (r - thickness) * math.sin(t)))

    pairs = [left(theta * i / segments) for i in range(segments + 1)]
    pairs += [right(theta * i / segments) for i in range(segments - 1, -1, -1)]
    return pairs, r, c


def build_arch():
    pairs, radius, centre = arch_profile(SPAN, RISE, THICKNESS, SEGMENTS)
    n = len(pairs)

    verts = []
    for (ox, oz), (ix, iz) in pairs:            # front ring, y = 0
        verts.append((ox, 0.0, oz))
        verts.append((ix, 0.0, iz))
    for (ox, oz), (ix, iz) in pairs:            # back ring, y = DEPTH
        verts.append((ox, DEPTH, oz))
        verts.append((ix, DEPTH, iz))

    def fo(i):  # front outer
        return i * 2

    def fi(i):  # front inner
        return i * 2 + 1

    def bo(i):
        return n * 2 + i * 2

    def bi(i):
        return n * 2 + i * 2 + 1

    faces = []
    for i in range(n - 1):
        faces.append((fo(i), fi(i), fi(i + 1), fo(i + 1)))          # front band
        faces.append((bo(i + 1), bi(i + 1), bi(i), bo(i)))          # back band
        faces.append((fo(i + 1), fi(i + 1), bi(i + 1), bo(i + 1)))  # ...stitched
        faces.append((fo(i), bo(i), bo(i + 1), fo(i + 1)))          # outer wall
        faces.append((fi(i + 1), bi(i + 1), bi(i), fi(i)))          # inner wall
    faces.append((fo(0), bo(0), bi(0), fi(0)))                      # springing caps
    faces.append((fi(n - 1), bi(n - 1), bo(n - 1), fo(n - 1)))

    # Drop the redundant stitch quads: they duplicate the walls and would leave
    # interior faces inside a solid piece.
    faces = [f for k, f in enumerate(faces) if not (k % 5 == 2 and k < (n - 1) * 5)]

    mesh = bpy.data.meshes.new("GothicArch")
    mesh.from_pydata(verts, [], faces)
    mesh.validate()
    mesh.update()
    return mesh, pairs, radius, centre


def apply_uvs(mesh, pairs):
    """Analytic UVs: u follows arc length, v crosses the band.

    Generated meshes get whatever unwrap an algorithm decides on. A parametric
    piece can have texel density fixed by construction, which is what keeps
    stonework continuous where two kit pieces meet.
    """
    lengths = [0.0]
    for i in range(1, len(pairs)):
        (ax, az), _ = pairs[i - 1]
        (bx, bz), _ = pairs[i]
        lengths.append(lengths[-1] + math.hypot(bx - ax, bz - az))
    total = lengths[-1] or 1.0

    uv_layer = mesh.uv_layers.new(name="UVMap")
    for poly in mesh.polygons:
        for loop_index in poly.loop_indices:
            vi = mesh.loops[loop_index].vertex_index
            ring_index = (vi % (len(pairs) * 2)) // 2
            is_inner = vi % 2 == 1
            u = lengths[min(ring_index, len(lengths) - 1)] * UV_TILES_PER_METRE
            v = (1.0 if is_inner else 0.0)
            if vi >= len(pairs) * 2:
                v += DEPTH * UV_TILES_PER_METRE
            uv_layer.data[loop_index].uv = (u, v)
    return total


def main():
    print("=== probe_arch: start ===")
    bpy.ops.wm.read_factory_settings(use_empty=True)

    mesh, pairs, radius, centre = build_arch()
    obj = bpy.data.objects.new("GothicArch", mesh)
    bpy.context.collection.objects.link(obj)
    log("geometry: %d verts, %d polygons" % (len(mesh.vertices), len(mesh.polygons)))
    if len(mesh.polygons) == 0:
        print("FAIL: no polygons built")
        sys.exit(1)

    arc_length = apply_uvs(mesh, pairs)
    log("uv layers: %s  (arc length %.3f m)" % (
        [l.name for l in mesh.uv_layers], arc_length))

    mat = bpy.data.materials.new(name="GothicStone")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = (0.29, 0.29, 0.29, 1.0)  # CANON §5 #4a4a4a
        bsdf.inputs["Roughness"].default_value = 0.85
    mesh.materials.append(mat)

    dims = obj.dimensions
    log("dimensions: %.4f x %.4f x %.4f m" % (dims.x, dims.y, dims.z))
    expected_span = SPAN
    if abs(dims.x - expected_span) > 0.01:
        print("FAIL: span is %.4f, expected %.4f" % (dims.x, expected_span))
        sys.exit(1)
    if abs(dims.y - DEPTH) > 0.001:
        print("FAIL: depth is %.4f, expected %.4f" % (dims.y, DEPTH))
        sys.exit(1)

    # art/gen/probe_arch.py -> art/gen -> art -> repo root. Three levels, not
    # two. The first version stopped at art/ and wrote art/dotbg/assets/, while
    # logging the relative path it intended rather than the one it used — so it
    # reported success at a location nothing reads. Log absolute paths.
    repo = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    out = os.path.join(repo, OUT_REL)
    os.makedirs(os.path.dirname(out), exist_ok=True)

    for o in bpy.context.scene.objects:
        o.select_set(False)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=True)

    size = os.path.getsize(out) if os.path.exists(out) else 0
    log("wrote %s (%d bytes)" % (out, size))
    if size < 1000:
        print("FAIL: export is empty or trivially small")
        sys.exit(1)

    print("=== probe_arch: OK ===")
    sys.exit(0)


if __name__ == "__main__":
    main()
