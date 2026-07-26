extends SceneTree

# Automated headless boot test.
#
# Run it through the repo harness, which resolves the Godot binary (it is not on
# PATH on the maintainer's machine) — see AGENTS.md §2:
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1
#
# Exits 0 on pass, 1 on failure, so CI and agents can trust the result rather
# than reading a screenshot. This is the harness AGENTS.md §2 requires: a claim
# that the game boots must be checkable by something other than the model that
# wrote the code.

const REQUIRED_AUTOLOADS := [
	"EventBus",
	"GameManager",
	"PlayerStats",
	"SaveSystem",
	"InputManager",
	"SanityManager",
	"HybridGenerator",
]

var _frame := 0
var _phase := 0
var _failures: Array[String] = []
var _checks := 0

func _initialize() -> void:
	print("=== boot_test: start ===")

func _process(_delta: float) -> bool:
	_frame += 1

	match _phase:
		0:
			_check_autoloads()
			_phase = 1
		1:
			if _frame > 5:
				_start_new_game()
				_phase = 2
		2:
			# change_scene_to_file is deferred; give it frames to land and let
			# physics run so the player is actually simulated, not just parented.
			if _frame > 45:
				_check_gameplay_scene()
				_phase = 3
		3:
			return _report()

	return false

func _ok(label: String) -> void:
	_checks += 1
	print("  PASS  %s" % label)

func _fail(label: String) -> void:
	_checks += 1
	_failures.append(label)
	print("  FAIL  %s" % label)

func _check(condition: bool, label: String) -> void:
	if condition:
		_ok(label)
	else:
		_fail(label)

func _check_autoloads() -> void:
	print("-- autoloads --")
	for name in REQUIRED_AUTOLOADS:
		_check(root.get_node_or_null(NodePath(name)) != null, "autoload present: %s" % name)

func _start_new_game() -> void:
	print("-- start_new_game --")
	var gm := root.get_node_or_null(NodePath("GameManager"))
	if gm == null:
		_fail("GameManager missing, cannot start game")
		return

	var started: bool = gm.start_new_game()
	_check(started, "GameManager.start_new_game() returned true")
	_check(gm.current_act == 1, "run state reset: current_act == 1")
	_check(gm.blood_echoes == 0, "run state reset: blood_echoes == 0")

	var sanity := root.get_node_or_null(NodePath("SanityManager"))
	if sanity != null:
		_check(sanity.current_sanity == sanity.max_sanity, "sanity reset to max")

func _check_gameplay_scene() -> void:
	print("-- gameplay scene --")

	var scene := current_scene
	if scene == null:
		_fail("current_scene is null after start_new_game()")
		return

	_check(
		scene.scene_file_path == "res://scenes/test_3d_complete.tscn",
		"loaded expected scene (got: %s)" % scene.scene_file_path
	)

	var player := _find_first(scene, "CharacterBody3D")
	if player == null:
		_fail("no CharacterBody3D found in the loaded scene")
		return

	_ok("3D player present in scene tree: %s" % player.name)
	_check(player.is_inside_tree(), "player is inside the tree")

	# The player stands on a StaticBody3D floor. If physics never ran, or the
	# floor is missing, the body falls — this catches a scene that parents
	# correctly but is not actually simulated.
	_check(is_finite(player.global_position.y), "player position is finite")
	_check(
		player.global_position.y > -50.0,
		"player has not fallen out of the world (y=%.2f)" % player.global_position.y
	)

	_check_camera(scene)

# CANON.md §1 requires a fixed orthogonal camera at ~45°. Asserting it here is
# what stops that spec from being prose nobody checks.
const CANON_CAMERA_PITCH_DEGREES := 45.0
const CAMERA_PITCH_TOLERANCE := 5.0

func _check_camera(scene: Node) -> void:
	print("-- camera (CANON.md §1) --")

	var cam := _find_first(scene, "Camera3D") as Camera3D
	if cam == null:
		_fail("no Camera3D found in the loaded scene")
		return

	_ok("Camera3D present: %s" % cam.name)
	_check(
		cam.projection == Camera3D.PROJECTION_ORTHOGONAL,
		"camera is orthogonal, not perspective"
	)

	# Forward is -Z of the camera basis. Pitch is the angle below the horizon.
	var forward: Vector3 = -cam.global_transform.basis.z
	var pitch_deg: float = rad_to_deg(asin(clampf(-forward.y, -1.0, 1.0)))

	print("    measured: forward=%s pitch=%.2f deg size=%.1f" % [
		str(forward.snappedf(0.001)), pitch_deg, cam.size
	])

	_check(
		absf(pitch_deg - CANON_CAMERA_PITCH_DEGREES) <= CAMERA_PITCH_TOLERANCE,
		"camera pitch is %.1f±%.1f deg (measured %.2f)" % [
			CANON_CAMERA_PITCH_DEGREES, CAMERA_PITCH_TOLERANCE, pitch_deg
		]
	)

func _find_first(node: Node, type_name: String) -> Node:
	if node.is_class(type_name):
		return node
	for child in node.get_children():
		var found := _find_first(child, type_name)
		if found != null:
			return found
	return null

func _report() -> bool:
	print("=== boot_test: %d checks, %d failures ===" % [_checks, _failures.size()])
	if _failures.is_empty():
		print("RESULT: PASS")
		quit(0)
	else:
		for f in _failures:
			print("  failed: %s" % f)
		print("RESULT: FAIL")
		quit(1)
	return true
