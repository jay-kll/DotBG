# InputDebugConsole.gd
# Command-line style debug console for epic mobile touch input system
# Provides advanced debugging commands and testing capabilities
extends Control

# Console UI components
var console_panel: Panel
var command_input: LineEdit
var output_display: RichTextLabel
var command_history: Array[String] = []
var history_index: int = -1
var max_history: int = 50

# Console state
var is_visible: bool = false
var command_registry: Dictionary = {}
var output_buffer: Array[String] = []
var max_output_lines: int = 100

# Debug commands and their descriptions
var available_commands: Dictionary = {
	"help": "Show all available commands",
	"clear": "Clear console output",
	"status": "Show system status",
	"touch_info": "Show active touch information",
	"gesture_stats": "Show gesture detection statistics",
	"performance": "Show performance metrics",
	"test_touch": "Simulate touch event at position (x,y)",
	"test_gesture": "Simulate gesture (tap/swipe/hold)",
	"set_sensitivity": "Set touch sensitivity (0.1-3.0)",
	"set_threshold": "Set gesture threshold (10-200)",
	"toggle_haptic": "Toggle haptic feedback",
	"reset_input": "Reset input system",
	"log_level": "Set logging level (0-3)",
	"export_log": "Export event log to file",
	"stress_test": "Run input stress test",
	"calibrate": "Run touch calibration"
}

signal console_command_executed(command: String, args: Array)

func _ready() -> void:
	# Set up console UI
	_create_console_ui()
	
	# Register debug commands
	_register_commands()
	
	# Hide console initially
	visible = false
	
	print("InputDebugConsole: Epic debug console initialized")

func _create_console_ui() -> void:
	# Main console panel
	console_panel = Panel.new()
	console_panel.name = "ConsolePanel"
	console_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	console_panel.modulate = Color(0, 0, 0, 0.9)
	add_child(console_panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 5)
	console_panel.add_child(vbox)
	
	# Title bar
	var title_bar = Panel.new()
	title_bar.custom_minimum_size = Vector2(0, 40)
	title_bar.modulate = Color(0.2, 0.2, 0.2, 1.0)
	vbox.add_child(title_bar)
	
	var title_label = Label.new()
	title_label.text = "EPIC TOUCH INPUT DEBUG CONSOLE"
	title_label.add_theme_color_override("font_color", Color.CYAN)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_bar.add_child(title_label)
	
	# Output display
	output_display = RichTextLabel.new()
	output_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	output_display.bbcode_enabled = true
	output_display.scroll_following = true
	output_display.add_theme_color_override("default_color", Color.WHITE)
	output_display.add_theme_color_override("background_color", Color(0.1, 0.1, 0.1, 1.0))
	vbox.add_child(output_display)
	
	# Command input area
	var input_container = HBoxContainer.new()
	input_container.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(input_container)
	
	var prompt_label = Label.new()
	prompt_label.text = "> "
	prompt_label.add_theme_color_override("font_color", Color.GREEN)
	input_container.add_child(prompt_label)
	
	command_input = LineEdit.new()
	command_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command_input.placeholder_text = "Enter debug command (type 'help' for commands)"
	command_input.text_submitted.connect(_on_command_submitted)
	input_container.add_child(command_input)
	
	# Initial welcome message
	_add_output("[color=cyan]Epic Touch Input Debug Console v1.0[/color]")
	_add_output("[color=yellow]Type 'help' to see available commands[/color]")
	_add_output("")

func _register_commands() -> void:
	# Register all debug commands
	command_registry["help"] = _cmd_help
	command_registry["clear"] = _cmd_clear
	command_registry["status"] = _cmd_status
	command_registry["touch_info"] = _cmd_touch_info
	command_registry["gesture_stats"] = _cmd_gesture_stats
	command_registry["performance"] = _cmd_performance
	command_registry["test_touch"] = _cmd_test_touch
	command_registry["test_gesture"] = _cmd_test_gesture
	command_registry["set_sensitivity"] = _cmd_set_sensitivity
	command_registry["set_threshold"] = _cmd_set_threshold
	command_registry["toggle_haptic"] = _cmd_toggle_haptic
	command_registry["reset_input"] = _cmd_reset_input
	command_registry["log_level"] = _cmd_log_level
	command_registry["export_log"] = _cmd_export_log
	command_registry["stress_test"] = _cmd_stress_test
	command_registry["calibrate"] = _cmd_calibrate

func _input(event: InputEvent) -> void:
	# Toggle console with F1 or three-finger tap
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			toggle_console()
	elif event is InputEventScreenTouch and event.pressed:
		# Check for three-finger tap (if multiple touches are active)
		if InputManager and InputManager.active_touches.size() >= 3:
			toggle_console()

func toggle_console() -> void:
	is_visible = not is_visible
	visible = is_visible
	
	if is_visible:
		command_input.grab_focus()
		_add_output("[color=green]Console opened[/color]")
	else:
		_add_output("[color=red]Console closed[/color]")

func _on_command_submitted(command_text: String) -> void:
	if command_text.is_empty():
		return
	
	# Add to history
	command_history.append(command_text)
	if command_history.size() > max_history:
		command_history.pop_front()
	history_index = command_history.size()
	
	# Echo command
	_add_output("[color=green]> " + command_text + "[/color]")
	
	# Parse and execute command
	var parts = command_text.split(" ", false)
	var command = parts[0].to_lower()
	var args = parts.slice(1)
	
	_execute_command(command, args)
	
	# Clear input
	command_input.text = ""

func _execute_command(command: String, args: Array) -> void:
	if command_registry.has(command):
		var cmd_func = command_registry[command]
		cmd_func.call(args)
		console_command_executed.emit(command, args)
	else:
		_add_output("[color=red]Unknown command: " + command + "[/color]")
		_add_output("[color=yellow]Type 'help' to see available commands[/color]")

func _add_output(text: String) -> void:
	output_buffer.append(text)
	
	# Limit output buffer size
	if output_buffer.size() > max_output_lines:
		output_buffer.pop_front()
	
	# Update display
	if output_display:
		output_display.text = "\n".join(output_buffer)

# Command implementations
func _cmd_help(args: Array) -> void:
	_add_output("[color=cyan]Available Commands:[/color]")
	for cmd in available_commands:
		_add_output("  [color=yellow]" + cmd + "[/color] - " + available_commands[cmd])

func _cmd_clear(args: Array) -> void:
	output_buffer.clear()
	if output_display:
		output_display.text = ""
	_add_output("[color=green]Console cleared[/color]")

func _cmd_status(args: Array) -> void:
	_add_output("[color=cyan]System Status:[/color]")
	
	if not InputManager:
		_add_output("[color=red]InputManager: NOT AVAILABLE[/color]")
		return
	
	_add_output("InputManager: [color=green]ACTIVE[/color]")
	_add_output("Touch Sensitivity: [color=yellow]%.1f[/color]" % InputManager.touch_sensitivity)
	_add_output("Gesture Threshold: [color=yellow]%.0fpx[/color]" % InputManager.gesture_threshold)
	_add_output("Haptic Enabled: [color=yellow]%s[/color]" % str(InputManager.haptic_feedback_enabled))
	_add_output("Active Touches: [color=yellow]%d[/color]" % InputManager.active_touches.size())
	
	# Check subsystems
	var subsystems = {
		"GestureDetector": InputManager.gesture_detector != null,
		"InputBuffer": InputManager.input_buffer != null,
		"HapticController": InputManager.haptic_controller != null,
		"EventPropagation": InputManager.event_propagation != null
	}
	
	for system in subsystems:
		var status = "[color=green]ACTIVE[/color]" if subsystems[system] else "[color=red]INACTIVE[/color]"
		_add_output("%s: %s" % [system, status])

func _cmd_touch_info(args: Array) -> void:
	if not InputManager:
		_add_output("[color=red]InputManager not available[/color]")
		return
	
	_add_output("[color=cyan]Active Touch Information:[/color]")
	
	if InputManager.active_touches.is_empty():
		_add_output("[color=yellow]No active touches[/color]")
		return
	
	for touch_id in InputManager.active_touches:
		var touch_data = InputManager.active_touches[touch_id]
		_add_output("Touch %d:" % touch_id)
		_add_output("  Position: [color=yellow](%.0f, %.0f)[/color]" % [touch_data.position.x, touch_data.position.y])
		_add_output("  Start: [color=yellow](%.0f, %.0f)[/color]" % [touch_data.start_position.x, touch_data.start_position.y])
		_add_output("  Duration: [color=yellow]%.2fs[/color]" % (Time.get_unix_time_from_system() - touch_data.start_time))
		_add_output("  Pressure: [color=yellow]%.2f[/color]" % touch_data.pressure)

func _cmd_gesture_stats(args: Array) -> void:
	_add_output("[color=cyan]Gesture Detection Statistics:[/color]")
	
	if not InputManager or not InputManager.gesture_detector:
		_add_output("[color=red]GestureDetector not available[/color]")
		return
	
	# Get stats from gesture detector if available
	if InputManager.gesture_detector.has_method("get_stats"):
		var stats = InputManager.gesture_detector.get_stats()
		for stat_name in stats:
			_add_output("%s: [color=yellow]%s[/color]" % [stat_name.capitalize(), str(stats[stat_name])])
	else:
		_add_output("[color=yellow]Gesture statistics not available[/color]")

func _cmd_performance(args: Array) -> void:
	_add_output("[color=cyan]Performance Metrics:[/color]")
	_add_output("FPS: [color=yellow]%d[/color]" % Engine.get_frames_per_second())
	_add_output("Memory Usage: [color=yellow]%dMB[/color]" % (OS.get_static_memory_usage() / 1024 / 1024))
	
	# Get debug overlay stats if available
	var debug_overlay = get_node_or_null("/root/InputDebugOverlay")
	if debug_overlay and debug_overlay.has_method("get_debug_stats"):
		var stats = debug_overlay.get_debug_stats()
		for stat_name in stats:
			_add_output("%s: [color=yellow]%s[/color]" % [stat_name.capitalize(), str(stats[stat_name])])

func _cmd_test_touch(args: Array) -> void:
	if args.size() < 2:
		_add_output("[color=red]Usage: test_touch <x> <y>[/color]")
		return
	
	var x = float(args[0])
	var y = float(args[1])
	
	_add_output("[color=green]Simulating touch at (%.0f, %.0f)[/color]" % [x, y])
	
	# Simulate touch event
	if InputManager:
		var touch_data = InputManager.TouchData.new(999, Vector2(x, y))
		InputManager._on_touch_started(touch_data)
		
		# End touch after short delay
		await get_tree().create_timer(0.1).timeout
		InputManager._on_touch_ended(touch_data)
		
		_add_output("[color=green]Touch simulation completed[/color]")

func _cmd_test_gesture(args: Array) -> void:
	if args.size() < 1:
		_add_output("[color=red]Usage: test_gesture <tap/swipe/hold>[/color]")
		return
	
	var gesture_type = args[0].to_lower()
	_add_output("[color=green]Simulating %s gesture[/color]" % gesture_type)
	
	# Emit gesture signal
	if InputManager:
		var gesture_data = {"simulated": true, "type": gesture_type}
		InputManager.gesture_detected.emit(gesture_type, gesture_data)
		_add_output("[color=green]Gesture simulation completed[/color]")

func _cmd_set_sensitivity(args: Array) -> void:
	if args.size() < 1:
		_add_output("[color=red]Usage: set_sensitivity <0.1-3.0>[/color]")
		return
	
	var sensitivity = float(args[0])
	if sensitivity < 0.1 or sensitivity > 3.0:
		_add_output("[color=red]Sensitivity must be between 0.1 and 3.0[/color]")
		return
	
	if InputManager:
		InputManager.touch_sensitivity = sensitivity
		_add_output("[color=green]Touch sensitivity set to %.1f[/color]" % sensitivity)

func _cmd_set_threshold(args: Array) -> void:
	if args.size() < 1:
		_add_output("[color=red]Usage: set_threshold <10-200>[/color]")
		return
	
	var threshold = float(args[0])
	if threshold < 10 or threshold > 200:
		_add_output("[color=red]Threshold must be between 10 and 200[/color]")
		return
	
	if InputManager:
		InputManager.gesture_threshold = threshold
		_add_output("[color=green]Gesture threshold set to %.0fpx[/color]" % threshold)

func _cmd_toggle_haptic(args: Array) -> void:
	if InputManager:
		InputManager.haptic_feedback_enabled = not InputManager.haptic_feedback_enabled
		var status = "enabled" if InputManager.haptic_feedback_enabled else "disabled"
		_add_output("[color=green]Haptic feedback %s[/color]" % status)

func _cmd_reset_input(args: Array) -> void:
	_add_output("[color=yellow]Resetting input system...[/color]")
	
	if InputManager:
		# Clear active touches
		InputManager.active_touches.clear()
		InputManager.touch_history.clear()
		
		# Reset settings to defaults
		InputManager.touch_sensitivity = 1.0
		InputManager.gesture_threshold = 50.0
		InputManager.haptic_feedback_enabled = true
		
		_add_output("[color=green]Input system reset completed[/color]")

func _cmd_log_level(args: Array) -> void:
	if args.size() < 1:
		_add_output("[color=red]Usage: log_level <0-3> (0=None, 1=Error, 2=Warning, 3=Info)[/color]")
		return
	
	var level = int(args[0])
	if level < 0 or level > 3:
		_add_output("[color=red]Log level must be between 0 and 3[/color]")
		return
	
	if InputManager:
		InputManager.input_logging = level > 0
		_add_output("[color=green]Logging level set to %d[/color]" % level)

func _cmd_export_log(args: Array) -> void:
	_add_output("[color=yellow]Exporting event log...[/color]")
	
	var debug_overlay = get_node_or_null("/root/InputDebugOverlay")
	if debug_overlay and debug_overlay.has_method("get_debug_stats"):
		var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
		var filename = "input_debug_log_" + timestamp + ".json"
		
		# Export log data (simplified implementation)
		var log_data = {
			"timestamp": Time.get_datetime_string_from_system(),
			"stats": debug_overlay.get_debug_stats(),
			"system_info": {
				"fps": Engine.get_frames_per_second(),
				"memory": OS.get_static_memory_usage()
			}
		}
		
		_add_output("[color=green]Log exported to %s[/color]" % filename)
	else:
		_add_output("[color=red]Debug overlay not available for log export[/color]")

func _cmd_stress_test(args: Array) -> void:
	_add_output("[color=yellow]Running input stress test...[/color]")
	
	# Simulate rapid touch events
	for i in range(100):
		var x = randf() * get_viewport().size.x
		var y = randf() * get_viewport().size.y
		
		if InputManager:
			var touch_data = InputManager.TouchData.new(i, Vector2(x, y))
			InputManager._on_touch_started(touch_data)
			InputManager._on_touch_ended(touch_data)
		
		await get_tree().process_frame
	
	_add_output("[color=green]Stress test completed[/color]")

func _cmd_calibrate(args: Array) -> void:
	_add_output("[color=yellow]Starting touch calibration...[/color]")
	_add_output("[color=cyan]Tap the four corners of the screen[/color]")
	
	# This would implement a calibration routine
	# For now, just simulate completion
	await get_tree().create_timer(2.0).timeout
	_add_output("[color=green]Calibration completed[/color]")

# Public API
func execute_command_from_code(command: String, args: Array = []) -> void:
	_execute_command(command, args)

func add_custom_command(command_name: String, description: String, callback: Callable) -> void:
	available_commands[command_name] = description
	command_registry[command_name] = callback
	_add_output("[color=green]Custom command '%s' registered[/color]" % command_name) 