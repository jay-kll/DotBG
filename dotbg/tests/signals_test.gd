extends SceneTree

# Guards the EventBus against the defect class in CANON.md §9, open defect 3:
# a signal that is emitted but never declared. It compiled, it ran, and it did
# nothing at all for thirteen months.
#
# The root cause is `EventBus.emit_signal("name")`. The string form is not
# checked at compile time, so an undeclared or misspelled signal is silently a
# no-op. `EventBus.name.emit()` fails to parse instead, which is the whole
# point. So this test does two things: it forbids the unchecked form outright,
# and for any that survive, it verifies the name is actually declared.
#
# It reads the source rather than the running program because a signal nobody
# emits during a test run is exactly the one that is broken.

const SCAN_DIRS := ["res://scripts", "res://tests"]
const EMIT_PATTERN := "EventBus.emit_signal(\""

var checks := 0
var failures := 0


func check(label: String, condition: bool, detail: String = "") -> void:
	checks += 1
	if not condition:
		failures += 1
	print("  %s  %s" % ["PASS" if condition else "FAIL", label])
	if detail != "":
		print("    " + detail)


func _process(_delta: float) -> bool:
	print("=== signals_test: start ===")

	var bus := root.get_node_or_null(NodePath("EventBus"))
	if bus == null:
		check("EventBus autoload present", false, "nothing else here can be checked")
		_report()
		return true
	check("EventBus autoload present", true)

	var declared := {}
	for s in bus.get_signal_list():
		declared[s.name] = true
	print("    %d signals declared" % declared.size())

	check("sanity_corruption_reset is declared (CANON.md §9, defect 3)",
		declared.has("sanity_corruption_reset"))

	var files := _gd_files()
	# Without this the two checks below pass by scanning nothing, which is how
	# the first version of this test reported success while its directory walk
	# was failing on a type error. A guard that can pass vacuously is not a guard.
	check("the source scan actually found files", files.size() >= 20,
		"%d .gd files under %s" % [files.size(), ", ".join(SCAN_DIRS)])

	var offenders: Array[String] = []
	var undeclared: Array[String] = []
	for path in files:
		var text := FileAccess.get_file_as_string(path)
		if text == "":
			continue
		var from := 0
		while true:
			var at := text.find(EMIT_PATTERN, from)
			if at == -1:
				break
			var start := at + EMIT_PATTERN.length()
			var end := text.find("\"", start)
			var name := text.substr(start, end - start) if end > start else "<unparsed>"
			var line := text.substr(0, at).count("\n") + 1
			offenders.append("%s:%d -> %s" % [path, line, name])
			if not declared.has(name):
				undeclared.append("%s:%d -> %s" % [path, line, name])
			from = at + EMIT_PATTERN.length()

	check("no signal is emitted that EventBus does not declare", undeclared.is_empty(),
		"\n    ".join(undeclared) if not undeclared.is_empty() else "none")

	# CANON.md §9, open defect 2: the cross-autoload wiring sat commented out
	# behind a TODO since the original five-day burst. Asserting the connections
	# exist is the difference between "wired" and "claimed to be wired".
	print("-- cross-autoload wiring (CANON.md §9, defect 2) --")
	var sanity := root.get_node_or_null(NodePath("SanityManager"))
	if sanity == null:
		check("SanityManager autoload present", false)
	else:
		var wiring := {
			"sanity_level_changed": ["HybridGenerator"],
			"reality_distortion_triggered": ["HybridGenerator", "InputManager"],
		}
		for signal_name in wiring:
			var targets: Array[String] = []
			for c in sanity.get_signal_connection_list(signal_name):
				var obj = c["callable"].get_object()
				if obj != null:
					targets.append(str(obj.name))
			for expected in wiring[signal_name]:
				check("SanityManager.%s reaches %s" % [signal_name, expected],
					targets.has(expected), "connected to: " + str(targets))

	var stale := 0
	for path in files:
		if FileAccess.get_file_as_string(path).contains("TODO: Fix signal connections"):
			stale += 1
	check("no connection is still parked behind a TODO", stale == 0,
		"%d file(s) still carry the placeholder" % stale)

	check("nothing uses the unchecked EventBus.emit_signal(\"...\") form",
		offenders.is_empty(),
		("use EventBus.<signal>.emit() instead — it fails to parse when the signal\n"
			+ "    does not exist, which is the only reason this test can be retired:\n    "
			+ "\n    ".join(offenders)) if not offenders.is_empty() else "none")

	_report()
	return true


func _gd_files() -> Array[String]:
	var found: Array[String] = []
	# assign(), not duplicate(): an untyped const Array will not assign straight
	# into an Array[String], and the failure is silent enough to leave the walk
	# returning nothing at all.
	var queue: Array[String] = []
	queue.assign(SCAN_DIRS)
	while not queue.is_empty():
		var dir_path: String = queue.pop_back()
		var dir := DirAccess.open(dir_path)
		if dir == null:
			continue
		dir.list_dir_begin()
		var entry := dir.get_next()
		while entry != "":
			var full := dir_path.path_join(entry)
			if dir.current_is_dir():
				if not entry.begins_with("."):
					queue.append(full)
			elif entry.ends_with(".gd") and full != get_script().resource_path:
				# The scanner has to skip itself: it names the pattern it looks
				# for, so it always matches, and contorting the prose to dodge
				# its own search is worse than one honest carve-out.
				found.append(full)
			entry = dir.get_next()
		dir.list_dir_end()
	return found


func _report() -> void:
	print("=== signals_test: %d checks, %d failures ===" % [checks, failures])
	print("RESULT: " + ("PASS" if failures == 0 else "FAIL"))
	quit(1 if failures > 0 else 0)
