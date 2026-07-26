"""Capability probe: can Blender author a rigged, animated character headless?

    tools\\blender.ps1 -Script art\\gen\\probe_rig.py

CANON.md §5.4 rests the full-3D decision on "model once, rig once, five
animation clips — the camera generates every angle for free." That claim has
never been tested. This builds the smallest thing that tests all of it: a mesh
skinned to a two-bone armature with a keyframed action, exported as glTF, for
tests/asset_pipeline_test.gd to import and play.

It is deliberately not a character. Whether a CC0 character from a free library
is usable is a separate question with a separate answer; this one is about
whether the authoring path exists at all, so that the project is not hostage to
a particular download staying available.

Skinning and posing do need bpy.ops — armature edit bones are only reachable
through edit mode. Unlike uv.smart_project, mode_set works in background, so
the rule from probe_arch.py holds with one qualification: prefer data, and where
an operator is unavoidable, verify it headless rather than assuming.
"""

import math
import os
import sys

import bpy

CLIP_NAME = "idle"
FRAMES = 24
OUT_REL = os.path.join("dotbg", "assets", "probe", "rigged.glb")


def log(msg):
    print("  " + msg)


def build_mesh():
    """A two-segment capsule-ish body: eight rings, so there is something for
    the upper bone to bend that the lower bone holds still."""
    verts, faces = [], []
    rings = 8
    radius = 0.25
    height = 2.0
    for r in range(rings + 1):
        z = height * r / rings
        for s in range(8):
            a = math.tau * s / 8
            verts.append((radius * math.cos(a), radius * math.sin(a), z))
    for r in range(rings):
        for s in range(8):
            a = r * 8 + s
            b = r * 8 + (s + 1) % 8
            c = (r + 1) * 8 + (s + 1) % 8
            d = (r + 1) * 8 + s
            faces.append((a, b, c, d))

    mesh = bpy.data.meshes.new("Body")
    mesh.from_pydata(verts, [], faces)
    mesh.validate()
    mesh.update()
    return mesh, rings


def main():
    print("=== probe_rig: start ===")
    bpy.ops.wm.read_factory_settings(use_empty=True)

    mesh, rings = build_mesh()
    body = bpy.data.objects.new("Body", mesh)
    bpy.context.collection.objects.link(body)
    log("mesh: %d verts, %d polygons" % (len(mesh.vertices), len(mesh.polygons)))

    armature = bpy.data.armatures.new("Rig")
    rig = bpy.data.objects.new("Rig", armature)
    bpy.context.collection.objects.link(rig)
    bpy.context.view_layer.objects.active = rig
    rig.select_set(True)

    bpy.ops.object.mode_set(mode="EDIT")
    lower = armature.edit_bones.new("lower")
    lower.head = (0.0, 0.0, 0.0)
    lower.tail = (0.0, 0.0, 1.0)
    upper = armature.edit_bones.new("upper")
    upper.head = (0.0, 0.0, 1.0)
    upper.tail = (0.0, 0.0, 2.0)
    upper.parent = lower
    bpy.ops.object.mode_set(mode="OBJECT")
    log("armature: %s" % [b.name for b in armature.bones])

    # Weights by data rather than automatic weighting: deterministic, and the
    # kit's whole argument is that a rerun produces the same bytes.
    g_lower = body.vertex_groups.new(name="lower")
    g_upper = body.vertex_groups.new(name="upper")
    per_ring = 8
    for r in range(rings + 1):
        t = r / float(rings)
        w_upper = max(0.0, min(1.0, (t - 0.35) / 0.3))
        indices = [r * per_ring + s for s in range(per_ring)]
        g_upper.add(indices, w_upper, "REPLACE")
        g_lower.add(indices, 1.0 - w_upper, "REPLACE")

    body.parent = rig
    body.modifiers.new(name="Armature", type="ARMATURE").object = rig
    log("vertex groups: %s" % [g.name for g in body.vertex_groups])

    # A sway on the upper bone. Enough that a test can see the skeleton move.
    rig.animation_data_create()
    action = bpy.data.actions.new(name=CLIP_NAME)
    rig.animation_data.action = action

    pose_bone = rig.pose.bones["upper"]
    pose_bone.rotation_mode = "XYZ"
    for frame, angle in ((1, 0.0), (FRAMES // 2, math.radians(18.0)), (FRAMES, 0.0)):
        pose_bone.rotation_euler = (angle, 0.0, 0.0)
        pose_bone.keyframe_insert(data_path="rotation_euler", frame=frame)

    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = FRAMES

    # Blender 4.4 replaced Action.fcurves with slotted actions: curves now live
    # in a channelbag belonging to the slot assigned on the animation data.
    # Reaching for the old attribute raises AttributeError, which is a good
    # reminder that this project is on 5.2 and the API moved under it.
    from bpy_extras import anim_utils
    channelbag = anim_utils.animdata_get_channelbag_for_assigned_slot(rig.animation_data)
    fcurve_count = len(channelbag.fcurves) if channelbag is not None else 0
    log("action '%s': %d frames, %d fcurves" % (action.name, FRAMES, fcurve_count))
    if fcurve_count == 0:
        print("FAIL: no keyframes were recorded")
        sys.exit(1)

    repo = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    out = os.path.join(repo, OUT_REL)
    os.makedirs(os.path.dirname(out), exist_ok=True)

    for o in bpy.context.scene.objects:
        o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=out, export_format="GLB",
                              export_animations=True, export_skins=True)

    size = os.path.getsize(out) if os.path.exists(out) else 0
    log("wrote %s (%d bytes)" % (out, size))
    if size < 1000:
        print("FAIL: export is empty or trivially small")
        sys.exit(1)

    print("=== probe_rig: OK ===")
    sys.exit(0)


if __name__ == "__main__":
    main()
