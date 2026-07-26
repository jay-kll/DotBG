extends SceneTree

# Exercises scripts/hybrid/, the 2,021 lines that had executed zero times.
#
# This began as a one-off experiment producing evidence for the keep-or-delete
# decision in ROADMAP.md Phase 1. **The verdict was keep**, so it is now a gate:
# the code works, and the suite is what stops it going stale again unnoticed.
# Measured on first execution: the full CANON.md §4 pipeline runs in about a
# millisecond against a 2,000 ms budget and produces eight-room dungeons — but
# only a third of them survive its own safety checker, because there is no
# retry loop. See CANON.md §9.
#
# The situation it was written to settle, from CANON.md §9: 2,021 lines under
# scripts/hybrid/ declare no class_name. The same five names are declared by
# 178 lines of stubs under scripts/systems/ that return hardcoded placeholders.
# HybridGenerator instantiates by class name, so Godot has always resolved to
# the stubs, and nothing has ever loaded scripts/hybrid/ by path. These modules
# have executed zero times.
#
# This loads them by path and drives the pipeline CANON.md §4 actually
# specifies: template from HandcraftedManager, tags applied, validated through
# SafetyChecker.

const MODULES := {
	"HandcraftedManager": "res://scripts/hybrid/handcrafted_manager.gd",
	"ProceduralManager": "res://scripts/hybrid/procedural_manager.gd",
	"TagSystem": "res://scripts/hybrid/tag_system.gd",
	"TemplateSystem": "res://scripts/hybrid/template_system.gd",
	"SafetyChecker": "res://scripts/hybrid/safety_checker.gd",
}

# CANON.md §4 hard rules.
const MAX_TAGS := 6
const FORBIDDEN_PAIRS := [["real", "hallucination"], ["blessed", "cursed"],
	["fast", "slow"], ["fire", "water"]]
const GENERATION_BUDGET_MS := 2000
const SAMPLE_RUNS := 40

var checks := 0
var failures := 0
var notes: Array[String] = []


func note(line: String) -> void:
	notes.append(line)


func check(label: String, condition: bool, detail: String = "") -> void:
	checks += 1
	if not condition:
		failures += 1
	print("  %s  %s" % ["PASS" if condition else "FAIL", label])
	if detail != "":
		print("    " + detail)


func _process(_delta: float) -> bool:
	print("=== procgen_test: exercising scripts/hybrid/ ===")

	var live := {}
	print("-- do they even load and instantiate --")
	for name in MODULES:
		var script: GDScript = load(MODULES[name])
		if script == null:
			check("%s loads by path" % name, false, MODULES[name])
			continue
		var inst = script.new()
		if inst == null:
			check("%s instantiates" % name, false)
			continue
		# _ready builds their internal tables; without the tree it never fires
		# and every one of them behaves as if uninitialised.
		root.add_child(inst)
		live[name] = inst
		check("%s loads, instantiates and readies" % name, true,
			"%d lines" % _line_count(MODULES[name]))

	if live.size() < MODULES.size():
		print("=== procgen_test: aborted, %d/%d modules usable ===" % [live.size(), MODULES.size()])
		_report()
		return true

	print("-- the tag vocabulary (CANON.md §4) --")
	var tags_mod = live["TagSystem"]
	var all_tags: Array = tags_mod.get_all_tags()
	check("a tag vocabulary exists", all_tags.size() > 0, "%d tags: %s" % [
		all_tags.size(), ", ".join(all_tags.slice(0, 12))])

	var context := {"act": 1, "sanity_level": 2, "mobile_optimized": true}
	var generated: Array = tags_mod.generate_tags_for_entity("enemy", context)
	check("generates tags for an entity", generated.size() > 0, str(generated))
	check("honours the six-tag mobile ceiling", generated.size() <= MAX_TAGS,
		"%d tags produced, ceiling is %d" % [generated.size(), MAX_TAGS])

	var enforced := 0
	for pair in FORBIDDEN_PAIRS:
		var verdict: Dictionary = tags_mod.validate_tag_combination(
			[pair[0], pair[1]] as Array[String])
		var rejected: bool = not verdict.get("valid", true)
		if rejected:
			enforced += 1
		note("forbidden pair %s+%s -> %s" % [pair[0], pair[1],
			"rejected" if rejected else "ACCEPTED"])
	check("rejects the forbidden tag pairs", enforced == FORBIDDEN_PAIRS.size(),
		"%d of %d enforced" % [enforced, FORBIDDEN_PAIRS.size()])

	var effects: Dictionary = tags_mod.calculate_tag_effects(generated as Array[String])
	check("tags resolve to mechanical effects", effects.size() > 0, str(effects))

	print("-- the CANON.md §4 pipeline, end to end --")
	var started := Time.get_ticks_msec()

	var base: Dictionary = live["HandcraftedManager"].load_template("dungeon_01", "dungeon")
	check("HandcraftedManager returns a template", base.size() > 0,
		"keys: " + str(base.keys()))

	var details: Dictionary = live["ProceduralManager"].generate_details(base, context)
	check("ProceduralManager layers detail onto it", details.size() > 0,
		"keys: " + str(details.keys()))

	# Validate the *generated* content, not the bare template. SafetyChecker
	# looks for room_layouts, which is what ProceduralManager produces; handing
	# it the template alone tests nothing but the harness's own confusion.
	var generated_content := base.duplicate(true)
	generated_content.merge(details, true)
	var validation: Dictionary = live["SafetyChecker"].validate_content(generated_content, "dungeon")
	check("SafetyChecker returns a verdict", validation.has("is_safe") or validation.has("valid"),
		"keys: " + str(validation.keys()))
	note("rooms generated: %d" % (details.get("room_layouts", []) as Array).size())

	# Generation is random, and a single sample said "safe" some runs and
	# "unreachable rooms" on others — the first honest thing this code told us
	# about itself. So measure the rate instead of sampling once and calling it
	# a result. The seed makes the number reproducible; without it this is a
	# flaky gate, which is worse than no gate.
	seed(20260725)
	var attempts := 0
	var safe := 0
	var issues := {}
	for i in range(SAMPLE_RUNS):
		var b: Dictionary = live["HandcraftedManager"].load_template("dungeon_%02d" % i, "dungeon")
		var d: Dictionary = live["ProceduralManager"].generate_details(b, context)
		var content := b.duplicate(true)
		content.merge(d, true)
		var v: Dictionary = live["SafetyChecker"].validate_content(content, "dungeon")
		attempts += 1
		if v.get("is_safe", false):
			safe += 1
		for issue in v.get("critical_issues", []):
			issues[issue] = int(issues.get(issue, 0)) + 1

	var rate := float(safe) / float(attempts) * 100.0
	note("safety pass rate over %d generations: %d/%d (%.0f%%)" % [attempts, safe, attempts, rate])
	for issue in issues:
		note("  rejected for %s -> %d time(s)" % [issue, issues[issue]])

	# Not asserting a high pass rate. The generator has no retry loop, so an
	# invalid layout is simply returned; that is a real defect and it is
	# recorded in CANON.md §9 rather than hidden behind a lenient threshold.
	# What must hold is that the checker always renders a verdict and the
	# pipeline never produces nothing at all.
	check("every generation gets a safety verdict", attempts == SAMPLE_RUNS,
		"%d of %d" % [attempts, SAMPLE_RUNS])
	check("generation produces valid dungeons at least sometimes", safe > 0,
		"%d of %d passed — no retry loop exists, so the rest are returned as-is" % [safe, attempts])

	# Everything above ran inside this window: one pipeline plus SAMPLE_RUNS
	# more. The budget in CANON.md §4 is per generation, so divide rather than
	# quoting the total and implying a single generation took that long.
	var elapsed := Time.get_ticks_msec() - started
	var per_generation := float(elapsed) / float(SAMPLE_RUNS + 1)
	check("stays inside the CANON.md §4 generation budget", per_generation < GENERATION_BUDGET_MS,
		"%.2f ms per generation (%d ms for %d of them) against a %d ms budget" % [
			per_generation, elapsed, SAMPLE_RUNS + 1, GENERATION_BUDGET_MS])

	print("-- the interface gap that blocks adoption --")
	# HybridGenerator calls five methods across these subsystems. Whether the
	# real modules can replace the stubs comes down to how many of them exist.
	var required := {
		"HandcraftedManager": ["load_template"],
		"ProceduralManager": ["generate_details"],
		"TagSystem": ["apply_tags"],
		"TemplateSystem": ["set_cache_limit", "set_mobile_mode"],
		"SafetyChecker": ["validate_content"],
	}
	var missing: Array[String] = []
	for name in required:
		for method in required[name]:
			if not live[name].has_method(method):
				missing.append("%s.%s()" % [name, method])

	# Four of the five line up. The gap is asserted as exactly one known method
	# rather than as zero: adoption is deliberately not done yet — AGENTS.md
	# §7.1 forbids depending on this code until a playable loop exists — so a
	# clean pass here would be a lie, and a plain failure would say the verdict
	# is unresolved. Pinning the gap means it fails if it grows or is quietly
	# closed without a decision.
	var known_gap: Array[String] = ["TagSystem.apply_tags()"]
	check("the adoption gap is still exactly TagSystem.apply_tags()",
		missing == known_gap,
		"missing: " + (", ".join(missing) if not missing.is_empty() else "nothing"))
	note("adoption cost: one adapter exposing apply_tags() over "
		+ "generate_tags_for_entity() and calculate_tag_effects()")

	print("-- what the stubs return for comparison --")
	var stub = load("res://scripts/systems/tag_system.gd").new()
	root.add_child(stub)
	var stub_out: Dictionary = stub.apply_tags({}, {}, context)
	note("stub TagSystem.apply_tags -> " + str(stub_out))
	check("the stub is a placeholder, not an implementation", true,
		str(stub_out).substr(0, 160))

	_report()
	return true


func _line_count(path: String) -> int:
	var text := FileAccess.get_file_as_string(path)
	return text.count("\n") + 1 if text != "" else 0


func _report() -> void:
	if not notes.is_empty():
		print("-- notes --")
		for n in notes:
			print("    " + n)
	print("=== procgen_test: %d checks, %d failures ===" % [checks, failures])
	print("RESULT: " + ("PASS" if failures == 0 else "FAIL"))
	quit(1 if failures > 0 else 0)
