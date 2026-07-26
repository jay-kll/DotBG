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


var started := false
var spawned: Array[Node] = []


# The run is a coroutine because the shader probe has to wait for frames to be
# drawn between setting a uniform and reading the pixels back. _process cannot
# await — it would return at the first suspension and the summary would print
# before the work finished — so it launches the run once and never quits itself.
func _process(_delta: float) -> bool:
	if not started:
		started = true
		_run()
	return false


func _run() -> void:
	for key in SCENES:
		var packed: PackedScene = load(SCENES[key])
		if packed == null:
			print("  FAIL  scene loads: %s" % SCENES[key])
			failures += 1
			checks += 1
			continue
		var instance := packed.instantiate()
		spawned.append(instance)
		root.add_child(instance)

	for i in range(WARMUP_FRAMES):
		await process_frame

	print("=== golden_render: start ===")
	print("  driver=%s display=%s" % [
		ProjectSettings.get_setting("rendering/renderer/rendering_method", "?"),
		DisplayServer.get_name()
	])

	DirAccess.make_dir_recursive_absolute(out_dir)

	for key in SCENES:
		_capture_and_compare(key)

	await _probe_corruption_shader()

	print("=== golden_render: %d checks, %d failures ===" % [checks, failures])
	print("RESULT: " + ("PASS" if failures == 0 else "FAIL"))
	quit(1 if failures > 0 else 0)


## Proves the corruption shader compiles and visibly does something.
##
## CANON.md §5 specifies four discrete visual tiers driven by one 0–1 parameter,
## and §5.4 rests the entire full-3D decision on that being a shader rather than
## a repaint. Nothing had ever confirmed it was buildable. A compile check alone
## would not: a shader that compiles and changes no pixels passes it happily.
## So this renders the same geometry at full sanity and at zero and requires the
## images to differ.
func _probe_corruption_shader() -> void:
	print("-- corruption shader (CANON.md §5) --")

	# Clear the gameplay scenes first. Left in, they fill most of the frame and
	# the arch changes a few hundred pixels out of 230,000 — the measurement
	# comes back as 0.006 and reads as "the shader does nothing", when what it
	# actually measured was how little of the screen the subject occupied.
	for node in spawned:
		if is_instance_valid(node):
			node.free()
	spawned.clear()

	var shader: Shader = load("res://shaders/corruption.gdshader")
	checks += 1
	if shader == null:
		failures += 1
		print("  FAIL  the corruption shader loads")
		return
	print("  PASS  the corruption shader loads")

	var packed: PackedScene = load("res://assets/probe/arch.glb")
	var subject: Node3D
	if packed != null:
		subject = packed.instantiate()
	else:
		subject = MeshInstance3D.new()
		(subject as MeshInstance3D).mesh = SphereMesh.new()

	var stage := Node3D.new()
	root.add_child(stage)
	stage.add_child(subject)

	var mesh_instance := _first_mesh(subject)
	checks += 1
	if mesh_instance == null:
		failures += 1
		print("  FAIL  found geometry to apply it to")
		stage.queue_free()
		return
	print("  PASS  found geometry to apply it to")

	var material := ShaderMaterial.new()
	material.shader = shader
	mesh_instance.material_override = material

	var cam := Camera3D.new()
	stage.add_child(cam)
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 4.0
	cam.global_position = Vector3(3.0, 3.0, 3.0)
	cam.look_at(Vector3(0.0, 1.2, 0.0), Vector3.UP)
	cam.make_current()

	var light := DirectionalLight3D.new()
	stage.add_child(light)
	light.rotation_degrees = Vector3(-45.0, -35.0, 0.0)

	var healthy := await _render_at(material, 1.0, "corruption-sanity-100")
	var ruined := await _render_at(material, 0.0, "corruption-sanity-000")

	checks += 1
	if healthy == null or ruined == null:
		failures += 1
		print("  FAIL  rendered the shader at both extremes")
		stage.queue_free()
		return
	print("  PASS  rendered the shader at both extremes")

	# Deliberately not the mean used for drift detection. Averaged over the whole
	# frame, a total repaint of the arch reads as 0.017 simply because the arch
	# is a sixth of the image — that number measures how much screen the subject
	# occupies, not how much it changed. Drift detection wants the mean; "did
	# the shader do anything" wants to know how many pixels moved, and by how
	# much. Same two images, different questions.
	var changed := _changed_fraction(healthy, ruined, 0.1)
	var mean := _mean_abs_diff(healthy, ruined)
	checks += 1
	if changed > 0.05:
		print("  PASS  full corruption looks different from full sanity")
		print("    %.1f%% of pixels changed by more than 0.1 (frame mean %.5f)" % [
			changed * 100.0, mean])
	else:
		failures += 1
		print("  FAIL  the shader compiles but changes almost nothing")
		print("    only %.1f%% of pixels moved — a shader that renders identically is not a shader"
			% (changed * 100.0))

	stage.queue_free()


func _render_at(material: ShaderMaterial, sanity: float, name: String) -> Image:
	material.set_shader_parameter("sanity", sanity)
	# Let the frame actually be drawn with the new parameter before grabbing it.
	for i in range(4):
		await process_frame
	var tex := root.get_texture()
	if tex == null:
		return null
	var img := tex.get_image()
	if img != null:
		img.save_png(out_dir.path_join("%s.png" % name))
	return img


func _first_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := _first_mesh(child)
		if found != null:
			return found
	return null


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


## Share of sampled pixels that moved by more than `threshold` on any channel.
##
## Insensitive to how much of the frame the subject fills, which is exactly what
## the mean is not.
func _changed_fraction(a: Image, b: Image, threshold: float) -> float:
	var moved := 0
	var samples := 0
	for x in range(0, a.get_width(), 4):
		for y in range(0, a.get_height(), 4):
			var pa := a.get_pixel(x, y)
			var pb := b.get_pixel(x, y)
			var delta := maxf(maxf(absf(pa.r - pb.r), absf(pa.g - pb.g)), absf(pa.b - pb.b))
			if delta > threshold:
				moved += 1
			samples += 1
	return (float(moved) / float(samples)) if samples > 0 else 0.0


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
