extends SceneTree

# Stamina behaviour, against the signed contract in scripts/config/tuning.gd.
#
# Stamina is what makes the combat model in CANON.md §1 methodical rather than
# fast: it gates attacking, dodging and blocking, so a mistake costs the next
# few seconds instead of a few frames. Two rules carry that weight, and both
# were absent before this test:
#
#   - Regeneration pauses after spending. Without the pause, stamina refills
#     while you swing and stops being a resource at all.
#   - An action may be started with any stamina above zero, and may drive the
#     pool negative. That is the Souls bargain: you are allowed to commit to
#     the mistake, and then you pay a longer recovery for it. Refusing the
#     action instead would make the system protect the player from itself.
#
# Time is driven explicitly rather than by frames. The test disables the node's
# own _process first, so nothing else advances the clock underneath it — a
# timing test racing the engine measures the engine.

var checks := 0
var failures := 0


func check(label: String, condition: bool, detail: String = "") -> void:
	checks += 1
	if not condition:
		failures += 1
	print("  %s  %s" % ["PASS" if condition else "FAIL", label])
	if detail != "":
		print("    " + detail)


func near(a: float, b: float, epsilon: float = 0.001) -> bool:
	return absf(a - b) < epsilon


func _process(_delta: float) -> bool:
	print("=== stamina_test: start ===")

	var stats := root.get_node_or_null(NodePath("PlayerStats"))
	if stats == null:
		check("PlayerStats autoload present", false)
		_report()
		return true

	# Take the clock away from the engine for the rest of this test.
	stats.set_process(false)
	stats.stamina_max = Tuning.STAMINA_MAX
	stats.stamina_regen = Tuning.STAMINA_REGEN
	stats.stamina_current = Tuning.STAMINA_MAX
	stats.reset_stamina_cooldown()

	print("-- spending --")
	check("a light attack is affordable at full stamina",
		stats.spend_stamina(Tuning.STAMINA_LIGHT_ATTACK))
	check("it costs exactly what the contract says",
		near(stats.stamina_current, Tuning.STAMINA_MAX - Tuning.STAMINA_LIGHT_ATTACK),
		"%.2f left of %.2f" % [stats.stamina_current, Tuning.STAMINA_MAX])

	print("-- the pause before regeneration --")
	# Start well below the ceiling so a second of regeneration measures the rate
	# rather than the clamp. From full, 30/s would overshoot the pool and the
	# assertion would pass on the maximum regardless of the rate.
	stats.stamina_current = 40.0
	stats.reset_stamina_cooldown()
	stats.spend_stamina(Tuning.STAMINA_LIGHT_ATTACK)
	var after_spend: float = stats.stamina_current

	stats.advance_stamina(Tuning.STAMINA_REGEN_DELAY * 0.5)
	check("nothing regenerates during the pause",
		near(stats.stamina_current, after_spend),
		"%.2f after %.2f s of a %.2f s pause" % [
			stats.stamina_current, Tuning.STAMINA_REGEN_DELAY * 0.5, Tuning.STAMINA_REGEN_DELAY])

	# Half the pause remains, so only the second half of this call regenerates —
	# a long frame must not silently swallow a whole tick of recovery.
	stats.advance_stamina(Tuning.STAMINA_REGEN_DELAY * 0.5 + 1.0)
	check("regeneration runs at the contract rate once the pause ends",
		near(stats.stamina_current, after_spend + Tuning.STAMINA_REGEN),
		"%.2f, expected %.2f after one second at %.1f/s" % [
			stats.stamina_current, after_spend + Tuning.STAMINA_REGEN, Tuning.STAMINA_REGEN])

	print("-- overdraw --")
	stats.stamina_current = 5.0
	stats.reset_stamina_cooldown()
	check("an action can start on a nearly empty pool",
		stats.spend_stamina(Tuning.STAMINA_HEAVY_ATTACK),
		"5.00 available, heavy attack costs %.2f" % Tuning.STAMINA_HEAVY_ATTACK)
	check("and drives it negative rather than being refused",
		stats.stamina_current < 0.0, "%.2f" % stats.stamina_current)

	check("but nothing can start from empty", not stats.spend_stamina(Tuning.STAMINA_LIGHT_ATTACK),
		"at %.2f" % stats.stamina_current)
	check("a refused action costs nothing", stats.stamina_current < 0.0)

	print("-- recovery from overdraw --")
	var owed: float = -stats.stamina_current
	stats.advance_stamina(Tuning.STAMINA_REGEN_DELAY)
	stats.advance_stamina(owed / Tuning.STAMINA_REGEN)
	check("regeneration climbs back through zero", stats.stamina_current >= 0.0,
		"%.2f — the overdraw is paid for in time, which is the point" % stats.stamina_current)

	stats.advance_stamina(100.0)
	check("and stops at the maximum", near(stats.stamina_current, stats.stamina_max),
		"%.2f of %.2f" % [stats.stamina_current, stats.stamina_max])

	print("-- the pool is a real gate --")
	stats.stamina_current = stats.stamina_max
	stats.reset_stamina_cooldown()
	var swings := 0
	while stats.spend_stamina(Tuning.STAMINA_LIGHT_ATTACK):
		swings += 1
		if swings > 50:
			break
	check("a full pool buys a bounded number of swings", swings >= 4 and swings <= 6,
		"%d light attacks at %.0f each from a pool of %.0f" % [
			swings, Tuning.STAMINA_LIGHT_ATTACK, Tuning.STAMINA_MAX])

	stats.set_process(true)
	_report()
	return true


func _report() -> void:
	print("=== stamina_test: %d checks, %d failures ===" % [checks, failures])
	print("RESULT: " + ("PASS" if failures == 0 else "FAIL"))
	quit(1 if failures > 0 else 0)
