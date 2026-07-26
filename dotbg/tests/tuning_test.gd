extends SceneTree

# Asserts the signed numeric contract in scripts/config/tuning.gd.
#
# Run it through the repo harness — see AGENTS.md §2:
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_tests.ps1
#
# The point is not that these numbers are right. A test cannot know whether 3.6
# m/s feels deliberate; only a playtest can. The point is that they cannot
# change by accident. A tuning value edited in passing, or a class modifier
# quietly reintroducing a pixels-per-second number, fails here and says so.
#
# The last block is a scale sentinel. The defining symptom of the abandoned 2D
# branch was 200.0 read as a speed on a 2 m capsule, and it survived thirteen
# months because nothing ever asserted that a speed had to be plausible.

var checks := 0
var failures := 0


func check(label: String, condition: bool, detail: String = "") -> void:
	checks += 1
	if not condition:
		failures += 1
	print("  %s  %s" % ["PASS" if condition else "FAIL", label])
	if detail != "":
		print("    " + detail)


func near(a: float, b: float, epsilon: float = 0.0001) -> bool:
	return absf(a - b) < epsilon


func _process(_delta: float) -> bool:
	# Autoloads do not exist yet in _init — the tree has not been built. Same
	# reason boot_test.gd defers its checks to the first frame.
	_run()
	return true


func _run() -> void:
	print("=== tuning_test: start ===")

	print("-- movement (signed 2026-07-25) --")
	check("walk speed is 1.6 m/s", near(Tuning.WALK_SPEED, 1.6), "%.3f" % Tuning.WALK_SPEED)
	check("run speed is 3.6 m/s", near(Tuning.RUN_SPEED, 3.6), "%.3f" % Tuning.RUN_SPEED)
	check("walking is slower than running", Tuning.WALK_SPEED < Tuning.RUN_SPEED)
	check("acceleration derives from run speed and 0.12 s",
		near(Tuning.acceleration(), 3.6 / 0.12),
		"%.3f m/s^2" % Tuning.acceleration())
	check("stopping is quicker than starting", Tuning.TIME_TO_STOP < Tuning.TIME_TO_FULL_SPEED)

	print("-- dodge --")
	check("invincible window is 0.45 s", near(Tuning.DODGE_IFRAMES, 0.45), "%.3f" % Tuning.DODGE_IFRAMES)
	check("whole roll is 0.75 s", near(Tuning.DODGE_TOTAL, 0.75), "%.3f" % Tuning.DODGE_TOTAL)
	check("roll travels 3.2 m", near(Tuning.DODGE_DISTANCE, 3.2), "%.3f" % Tuning.DODGE_DISTANCE)
	# This is the Soulslike commitment. If the vulnerable tail ever reaches zero
	# the roll becomes free and the combat model is gone, so it is asserted
	# rather than left to a comment.
	check("roll has a vulnerable recovery tail",
		Tuning.dodge_recovery() > 0.0 and near(Tuning.dodge_recovery(), 0.30),
		"%.3f s vulnerable after the invincible window" % Tuning.dodge_recovery())
	check("roll bursts faster than a run", Tuning.dodge_speed() > Tuning.RUN_SPEED,
		"%.3f m/s over the invincible window" % Tuning.dodge_speed())

	print("-- stamina --")
	check("pool is 100", near(Tuning.STAMINA_MAX, 100.0))
	check("regen is 30/s", near(Tuning.STAMINA_REGEN, 30.0))
	check("regen is delayed, so stamina is a resource", Tuning.STAMINA_REGEN_DELAY > 0.0,
		"%.2f s" % Tuning.STAMINA_REGEN_DELAY)
	check("light attack costs 20% of pool",
		near(Tuning.STAMINA_LIGHT_ATTACK / Tuning.STAMINA_MAX, 0.20))
	check("heavy costs more than light", Tuning.STAMINA_HEAVY_ATTACK > Tuning.STAMINA_LIGHT_ATTACK)
	check("dodge costs 25", near(Tuning.DODGE_STAMINA, 25.0))

	print("-- attack commitment --")
	check("light commitment is 0.70 s", near(Tuning.light_commitment(), 0.70),
		"%.3f s of no input" % Tuning.light_commitment())
	check("heavy commits harder than light",
		Tuning.heavy_commitment() > Tuning.light_commitment(),
		"%.3f s vs %.3f s" % [Tuning.heavy_commitment(), Tuning.light_commitment()])
	check("the swing has a windup that outlasts its active frames",
		Tuning.LIGHT_WINDUP > Tuning.LIGHT_ACTIVE)

	print("-- sanity (CANON.md §5) --")
	check("sanity does not drain passively", near(Tuning.SANITY_PASSIVE_DRAIN, 0.0),
		"a per-second drip would turn Act I into a clock")
	check("four corruption tiers, descending from 100 to 0",
		Tuning.SANITY_TIERS.size() == 4
			and Tuning.SANITY_TIERS[0] == 100.0
			and Tuning.SANITY_TIERS[3] == 0.0,
		str(Tuning.SANITY_TIERS))
	check("witnessing horror costs more than eldritch damage",
		Tuning.SANITY_WITNESS_HORROR > Tuning.SANITY_ELDRITCH_DAMAGE)

	print("-- input --")
	check("touch buffers longer than gamepad",
		Tuning.INPUT_BUFFER_TOUCH > Tuning.INPUT_BUFFER_GAMEPAD,
		"%.2f s touch vs %.2f s gamepad" % [Tuning.INPUT_BUFFER_TOUCH, Tuning.INPUT_BUFFER_GAMEPAD])

	print("-- PlayerStats reads the contract --")
	var stats := root.get_node_or_null(NodePath("PlayerStats"))
	if stats == null:
		check("PlayerStats autoload present", false, "cannot check the wiring without it")
		_report()
		return

	var jump_leftovers := ["jump_force", "max_jumps", "air_control"]
	var found: Array[String] = []
	for prop in stats.get_property_list():
		if prop.name in jump_leftovers:
			found.append(prop.name)
	check("no jump stats survive from the 2D branch", found.is_empty(),
		("found: " + str(found)) if not found.is_empty() else "none, as expected under a fixed camera")

	check("PlayerStats speed came from Tuning, not from pixels",
		stats.base_speed > 0.0 and stats.base_speed < 20.0,
		"%.3f m/s" % stats.base_speed)
	check("PlayerStats stamina pool matches the contract scale",
		stats.stamina_max >= Tuning.STAMINA_MAX * 0.5,
		"%.1f" % stats.stamina_max)

	var stats_script: GDScript = load("res://scripts/autoload/player_stats.gd")
	check("v1.0 ships the Cultist (CANON.md §8)",
		stats.player_class == stats_script.PlayerClass.CULTIST,
		"class is " + str(stats_script.PlayerClass.keys()[stats.player_class]))

	print("-- scale sentinel --")
	# Anything here above 20 is almost certainly a pixels-per-second value that
	# wandered back in. A human sprints at about 10 m/s.
	var speeds := {
		"Tuning.WALK_SPEED": Tuning.WALK_SPEED,
		"Tuning.RUN_SPEED": Tuning.RUN_SPEED,
		"Tuning.dodge_speed()": Tuning.dodge_speed(),
		"PlayerStats.base_speed": stats.base_speed,
		"PlayerStats.current_speed": stats.current_speed,
		"PlayerStats.dodge_speed": stats.dodge_speed,
	}
	for name in speeds:
		check("%s is a plausible speed in m/s" % name,
			speeds[name] > 0.0 and speeds[name] < 20.0,
			"%.3f" % speeds[name])

	_report()


func _report() -> void:
	print("=== tuning_test: %d checks, %d failures ===" % [checks, failures])
	print("RESULT: " + ("PASS" if failures == 0 else "FAIL"))
	quit(1 if failures > 0 else 0)
