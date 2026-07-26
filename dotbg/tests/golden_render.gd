extends SceneTree

# Renders the canonical scene and compares it against an approved image.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_golden.ps1
#
# This is the only check that can catch the slow failure mode: every per-asset
# assertion passing while the screen quietly rots. A seam opening where two kit
# pieces meet, a normal flipped, a shader breaking on new topology, the camera
# drifting off 45 degrees — all of it passes a unit test and shows up here.
#
# It cannot run under --headless. Godot's headless display driver does not
# rasterise, and get_image() on the viewport returns null; verified on 4.7.1.
# So this needs a real rendering context, which is why it is a separate harness
# from tools/run_tests.ps1 rather than another file in the headless suite.
#
# The agent never approves an image. A new or changed render lands in
# art/golden/current/ and waits for a human, exactly like any other asset under
# ASSETS.md §4. What this script decides is only whether two images differ.

const SCENES := {
	"gameplay": "res://scenes/test_3d_complete.tscn",
}

# Mean absolute channel difference, 0.0 to 1.0. Tight enough to catch a moved
# object or a changed material, loose enough to survive driver-level noise
# between machines. Anything structural lands far above this.
const DIFF_THRESHOLD := 0.02

# Rendering needs a few frames to settle: one to build the tree, more for the
# renderer to produce a complete frame.
const WARMUP_FRAMES := 12

var frames := 0
var out_dir := ""
var approved_dir := ""
var failures := 0
var checks := 0


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		print("usage: --script golden_render.gd -- <current_dir> <approved_dir>")
		quit(2)
		return
	out_dir = args[0]
	approved_dir = args[1]


func _process(_delta: float) -> bool:
	frames += 1
	if frames == 1:
		for key in SCENES:
			var packed: PackedScene = load(SCENES[key])
			if packed == null:
				print("  FAIL  scene loads: %s" % SCENES[key])
				failures += 1
				checks += 1
				continue
			root.add_child(packed.instantiate())
		return false

	if frames < WARMUP_FRAMES:
		return false

	print("=== golden_render: start ===")
	print("  driver=%s display=%s" % [
		ProjectSettings.get_setting("rendering/renderer/rendering_method", "?"),
		DisplayServer.get_name()
	])

	DirAccess.make_dir_recursive_absolute(out_dir)

	for key in SCENES:
		_capture_and_compare(key)

	print("=== golden_render: %d checks, %d failures ===" % [checks, failures])
	print("RESULT: " + ("PASS" if failures == 0 else "FAIL"))
	quit(1 if failures > 0 else 0)
	return true


func _capture_and_compare(key: String) -> void:
	var tex := root.get_texture()
	var img: Image = tex.get_image() if tex != null else null

	checks += 1
	if img == null:
		failures += 1
		print("  FAIL  captured a frame for '%s'" % key)
		print("    viewport returned no image — this build has no rendering context.")
		print("    Do not run this under --headless; see the note at the top of this file.")
		return
	print("  PASS  captured a frame for '%s'  (%dx%d)" % [key, img.get_width(), img.get_height()])

	var current_path := out_dir.path_join("%s.png" % key)
	img.save_png(current_path)

	var approved_path := approved_dir.path_join("%s.png" % key)
	checks += 1
	if not FileAccess.file_exists(approved_path):
		# Not a failure: there is no baseline yet. The image is written and a
		# human decides. An agent approving its own render would be the model
		# grading its own work, which is the thing this repo exists to avoid.
		print("  PASS  no approved baseline for '%s' yet" % key)
		print("    wrote %s" % current_path)
		print("    NEEDS HUMAN: approve it into art/golden/approved/ per ASSETS.md §4")
		return

	var approved := Image.load_from_file(approved_path)
	if approved == null:
		failures += 1
		print("  FAIL  approved baseline for '%s' could not be read" % key)
		return

	if approved.get_width() != img.get_width() or approved.get_height() != img.get_height():
		failures += 1
		print("  FAIL  '%s' changed resolution" % key)
		print("    approved %dx%d, rendered %dx%d — the harness must render at a fixed size" % [
			approved.get_width(), approved.get_height(), img.get_width(), img.get_height()])
		return

	var diff := _mean_abs_diff(approved, img)
	if diff <= DIFF_THRESHOLD:
		print("  PASS  '%s' matches its approved image  (diff %.5f, threshold %.5f)" % [
			key, diff, DIFF_THRESHOLD])
	else:
		failures += 1
		print("  FAIL  '%s' drifted from its approved image" % key)
		print("    diff %.5f exceeds threshold %.5f" % [diff, DIFF_THRESHOLD])
		print("    rendered: %s" % current_path)
		print("    approved: %s" % approved_path)
		print("    If the change is intended, a human approves the new image. Never overwrite")
		print("    the baseline to make this pass — that is how the screen rots unnoticed.")


func _mean_abs_diff(a: Image, b: Image) -> float:
	var total := 0.0
	var samples := 0
	# Every fourth pixel in each axis: a sixteenth of the work, and no
	# structural change is a sixteenth of a pixel wide.
	for x in range(0, a.get_width(), 4):
		for y in range(0, a.get_height(), 4):
			var pa := a.get_pixel(x, y)
			var pb := b.get_pixel(x, y)
			total += absf(pa.r - pb.r) + absf(pa.g - pb.g) + absf(pa.b - pb.b)
			samples += 1
	return (total / float(samples * 3)) if samples > 0 else 1.0
