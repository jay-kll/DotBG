"""Proves the Blender toolchain works end to end, headless.

    tools\\blender.ps1 -Script art\\gen\\smoke.py

This is the art pipeline's equivalent of dotbg/tests/boot_test.gd: it does not
make anything the game uses, it proves the machine can make things at all.
Every assertion here is a capability the parametric Gothic kit depends on —
building mesh from raw vertex data, evaluating modifiers headless, hitting an
exact nominal dimension, and writing a glTF that actually contains geometry.

The last one is the point. The first version of this file asserted that the
exported file was larger than zero bytes, and passed while writing an empty
180-byte glTF, because the modifier was never applied on export. Size is not
evidence of geometry. So the export check is a round trip: write it, wipe the
scene, read it back, and count what came home.

Exits 0 on pass, 1 on failure. Written against Blender 5.2 LTS — the bpy API
moved between 4.x and 5.x, so check the 5.2 docs before assuming a call exists.
"""

import math
import os
import sys
import tempfile

import bpy

CHECKS = []
SPAN = 2.0
RISE = 2.4
SEGMENTS = 16


def check(label, condition, detail=""):
    CHECKS.append((label, bool(condition), detail))
    print(f"  {'PASS' if condition else 'FAIL'}  {label}" + (f"\n    {detail}" if detail else ""))


def pointed_arch(span=SPAN, rise=RISE, segments=SEGMENTS):
    """A two-centred Gothic arch as an open vertex chain.

    Real Gothic arches are struck as two circular arcs whose centres sit on the
    springing line, inside the span — that is what makes the apex a point
    rather than a dome. Given span S and rise h, the centre offset c and radius
    R follow from requiring each arc to pass through both its far springing
    point and the apex:

        (S/2 + c)^2 = c^2 + h^2   ->   c = (h^2 - S^2/4) / S,   R = S/2 + c

    Returned in +X order so the chain is a single open polyline.
    """
    if rise <= span / 2.0:
        raise ValueError(f"rise {rise} must exceed half-span {span / 2.0} for a pointed arch")

    c = (rise * rise - span * span / 4.0) / span
    r = span / 2.0 + c
    theta_apex = math.acos(max(-1.0, min(1.0, c / r)))

    left, right = [], []
    for i in range(segments + 1):
        theta = theta_apex * i / segments
        # right arc is struck from the left centre, and vice versa
        right.append((-c + r * math.cos(theta), 0.0, r * math.sin(theta)))
        left.append((c - r * math.cos(theta), 0.0, r * math.sin(theta)))

    verts = left + list(reversed(right[:-1]))  # apex appears once
    edges = [(i, i + 1) for i in range(len(verts) - 1)]
    return verts, edges, r


def main():
    print("=== blender smoke: start ===")
    print(f"  bpy {bpy.app.version_string}, python {sys.version.split()[0]}")

    bpy.ops.wm.read_factory_settings(use_empty=True)
    check("scene cleared", len(bpy.data.objects) == 0, f"{len(bpy.data.objects)} objects")

    verts, edges, radius = pointed_arch()
    mesh = bpy.data.meshes.new("PointedArch")
    mesh.from_pydata(verts, edges, [])
    mesh.update()
    obj = bpy.data.objects.new("PointedArch", mesh)
    bpy.context.collection.objects.link(obj)
    check("mesh built from raw vertex data", len(mesh.vertices) == len(verts),
          f"{len(mesh.vertices)} verts, {len(mesh.edges)} edges, arc radius {radius:.3f} m")

    # A kit piece has to land on the grid every time, not approximately. This is
    # the whole argument for the parametric path over generated meshes, so the
    # tolerance is millimetres, not centimetres.
    xs = [v[0] for v in verts]
    zs = [v[2] for v in verts]
    span = max(xs) - min(xs)
    rise = max(zs) - min(zs)
    check("arch hits its nominal span and rise", abs(span - SPAN) < 1e-6 and abs(rise - RISE) < 1e-6,
          f"span {span:.6f} m (nominal {SPAN}), rise {rise:.6f} m (nominal {RISE})")

    # Modifiers are how a profile becomes geometry with thickness. If the stack
    # cannot be evaluated headless, the kit has to be built vertex by vertex,
    # which is a materially worse pipeline.
    skin = obj.modifiers.new(name="Skin", type="SKIN")
    skin.use_smooth_shade = True
    for v in obj.data.skin_vertices[0].data:
        v.radius = (0.09, 0.09)

    depsgraph = bpy.context.evaluated_depsgraph_get()
    evaluated = obj.evaluated_get(depsgraph).to_mesh()
    solid_polys = len(evaluated.polygons)
    check("modifier evaluated headless", solid_polys > 0, f"{solid_polys} polygons after skin")

    out_dir = os.path.join(tempfile.gettempdir(), "dotbg_smoke")
    os.makedirs(out_dir, exist_ok=True)
    out = os.path.join(out_dir, "pointed_arch.glb")
    if os.path.exists(out):
        os.remove(out)

    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    # export_apply bakes the modifier stack. Without it the exporter walks the
    # base mesh, finds edges and no faces, and cheerfully writes a file with no
    # primitives in it.
    bpy.ops.export_scene.gltf(
        filepath=out, export_format="GLB", use_selection=True, export_apply=True
    )
    check("glTF file written", os.path.exists(out), f"{out} ({os.path.getsize(out) if os.path.exists(out) else 0} bytes)")

    # The round trip. Everything above can pass on a file Godot would import as
    # nothing at all, so wipe the scene and read the artifact back.
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=out)
    imported = [o for o in bpy.data.objects if o.type == "MESH"]
    round_tripped = sum(len(o.data.polygons) for o in imported)
    check("exported glTF contains real geometry", round_tripped > 0,
          f"{len(imported)} mesh object(s), {round_tripped} polygons read back")

    if imported:
        width = max(o.dimensions.x for o in imported)
        # skin thickness widens the silhouette past the nominal span by roughly
        # one skin diameter, which is expected, not drift
        check("round-tripped geometry keeps its scale", abs(width - SPAN) < 0.3,
              f"{width:.3f} m wide against a {SPAN} m nominal span")

    passed = sum(1 for _, ok, _ in CHECKS if ok)
    failed = len(CHECKS) - passed
    print(f"=== blender smoke: {len(CHECKS)} checks, {failed} failures ===")
    print("RESULT: " + ("PASS" if failed == 0 else "FAIL"))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
