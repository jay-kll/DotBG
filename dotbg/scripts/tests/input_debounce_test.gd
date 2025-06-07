extends Control

# Input Buffering and Debouncing Test Suite
# Validates enhanced InputManager buffering and debouncing functionality

@onready var buffer_stats_label: Label = $UI/Statistics/BufferStats
@onready var debounced_stats_label: Label = $UI/Statistics/DebouncedStats
@onready var noise_detected_label: Label = $UI/Statistics/NoiseDetected
@onready var last_action_label: Label = $UI/Statistics/LastAction
@onready var action_log: RichTextLabel = $UI/ActionLog
@onready var stress_test_btn: Button = $UI/TestControls/TestButtons/StressTest
@onready var clear_log_btn: Button = $UI/TestControls/TestButtons/ClearLog
@onready var toggle_logging_cb: CheckBox = $UI/TestControls/TestButtons/ToggleLogging
@onready var tap_threshold_slider: HSlider = $UI/TestControls/DebounceSettings/TapThresholdSlider
@onready var tap_threshold_value: Label = $UI/TestControls/DebounceSettings/TapThresholdValue
@onready var test_area: ColorRect = $TestArea

# Test tracking variables
var test_start_time: float
var total_actions_attempted: int = 0
var total_actions_buffered: int = 0
var total_actions_debounced: int = 0
var hardware_noise_detected: int = 0
var action_history: Array[Dictionary] = []
var stress_test_running: bool = false

# Performance tracking
var frame_times: Array[float] = []
var buffer_response_times: Array[float] = []

func _ready() -> void:
	print("InputDebounceTest: Enhanced input buffering test initialized")
	test_start_time = Time.get_unix_time_from_system()
	
	# Connect UI signals
	_connect_ui_signals()
	
	# Connect InputManager signals
	_connect_input_signals()
	
	# Initialize test area input handling
	_setup_test_area()
	
	# Start monitoring
	set_process(true)

func _connect_ui_signals() -> void:
	stress_test_btn.pressed.connect(_run_stress_test)
	clear_log_btn.pressed.connect(_clear_action_log)
	toggle_logging_cb.toggled.connect(_toggle_input_logging)
	tap_threshold_slider.value_changed.connect(_update_tap_threshold)

func _connect_input_signals() -> void:
	if InputManager:
		# Connect to enhanced buffering signals
		InputManager.input_buffer.action_buffered.connect(_on_action_buffered)
		InputManager.input_buffer.action_debounced.connect(_on_action_debounced)
		InputManager.gesture_detected.connect(_on_gesture_detected)
		print("InputDebounceTest: Connected to InputManager signals")
	else:
		_log_error("InputManager not available")

func _setup_test_area() -> void:
	# Make test area respond to touch inputs
	test_area.gui_input.connect(_on_test_area_input)

func _process(_delta: float) -> void:
	# Update UI display
	_update_statistics_display()
	
	# Track frame performance
	frame_times.append(_delta)
	if frame_times.size() > 60:
		frame_times = frame_times.slice(-60)

func _update_statistics_display() -> void:
	if not InputManager or not InputManager.input_buffer:
		return
	
	var buffer_stats = InputManager.input_buffer.get_buffer_statistics()
	
	# Update statistics labels
	buffer_stats_label.text = "Buffer Size: %d / %d" % [
		buffer_stats.buffer_size, 
		InputManager.input_buffer.max_buffer_size
	]
	
	debounced_stats_label.text = "Actions Debounced: %d (%.1f%%)" % [
		total_actions_debounced,
		_calculate_debounce_percentage()
	]
	
	noise_detected_label.text = "Hardware Noise Detected: %d" % hardware_noise_detected

func _calculate_debounce_percentage() -> float:
	if total_actions_attempted == 0:
		return 0.0
	return (float(total_actions_debounced) / float(total_actions_attempted)) * 100.0

# Input event handlers
func _on_test_area_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_simulate_user_action("tap", {"position": event.position})
	elif event is InputEventMouseButton and event.pressed:
		_simulate_user_action("tap", {"position": event.position})

func _simulate_user_action(action: String, data: Dictionary) -> void:
	total_actions_attempted += 1
	
	# Record the attempt
	var attempt_time = Time.get_unix_time_from_system()
	
	# Try to buffer the action through InputManager
	if InputManager and InputManager.input_buffer:
		InputManager.input_buffer.buffer_action(action, data)

func _on_gesture_detected(gesture_type: String, gesture_data: Dictionary) -> void:
	_simulate_user_action(gesture_type, gesture_data)

func _on_action_buffered(action: String, data: Dictionary) -> void:
	total_actions_buffered += 1
	last_action_label.text = "Last Action: %s (BUFFERED)" % action.to_upper()
	
	_log_action_event("BUFFERED", action, data, Color.GREEN)
	
	# Measure response time
	var response_time = Time.get_unix_time_from_system()
	buffer_response_times.append(response_time)

func _on_action_debounced(action: String, reason: String) -> void:
	total_actions_debounced += 1
	last_action_label.text = "Last Action: %s (DEBOUNCED - %s)" % [action.to_upper(), reason]
	
	if reason == "hardware_noise":
		hardware_noise_detected += 1
	
	_log_action_event("DEBOUNCED", action, {"reason": reason}, Color.ORANGE)

func _log_action_event(status: String, action: String, data: Dictionary, color: Color) -> void:
	var timestamp = Time.get_unix_time_from_system() - test_start_time
	var log_entry = "[color=#%s][%.2fs] %s: %s[/color]" % [
		color.to_html(),
		timestamp,
		status,
		action.to_upper()
	]
	
	if data.has("reason"):
		log_entry += " (%s)" % data.reason
	
	log_entry += "\n"
	
	# Add to action log
	action_log.append_text(log_entry)
	
	# Keep log size manageable
	var text_lines = action_log.get_parsed_text().split("\n")
	if text_lines.size() > 50:
		# Keep only last 40 lines
		var new_text = "[b]Action Log:[/b]\n"
		for i in range(text_lines.size() - 40, text_lines.size()):
			if i >= 0 and i < text_lines.size():
				new_text += text_lines[i] + "\n"
		action_log.text = new_text

func _log_error(message: String) -> void:
	_log_action_event("ERROR", message, {}, Color.RED)

# UI event handlers
func _run_stress_test() -> void:
	if stress_test_running:
		return
	
	stress_test_running = true
	stress_test_btn.text = "Running..."
	stress_test_btn.disabled = true
	
	_log_action_event("TEST", "Stress test started", {}, Color.CYAN)
	
	# Simulate rapid input sequence
	var stress_actions = ["tap", "swipe", "hold", "double_tap", "attack", "dodge", "jump"]
	var total_stress_actions = 100
	
	for i in range(total_stress_actions):
		var action = stress_actions[i % stress_actions.size()]
		var fake_data = {"stress_test": true, "sequence": i}
		
		_simulate_user_action(action, fake_data)
		
		# Add small random delay to simulate realistic input patterns
		await get_tree().create_timer(randf_range(0.01, 0.05)).timeout
	
	_log_action_event("TEST", "Stress test completed (%d actions)" % total_stress_actions, {}, Color.CYAN)
	
	stress_test_btn.text = "Stress Test"
	stress_test_btn.disabled = false
	stress_test_running = false

func _clear_action_log() -> void:
	action_log.text = "[b]Action Log:[/b]\nLog cleared...\n"
	
	# Reset counters
	total_actions_attempted = 0
	total_actions_buffered = 0
	total_actions_debounced = 0
	hardware_noise_detected = 0
	action_history.clear()
	buffer_response_times.clear()
	
	test_start_time = Time.get_unix_time_from_system()

func _toggle_input_logging(enabled: bool) -> void:
	if InputManager:
		InputManager.enable_input_logging(enabled)
		_log_action_event("SETTING", "Input logging %s" % ("enabled" if enabled else "disabled"), {}, Color.YELLOW)

func _update_tap_threshold(value: float) -> void:
	tap_threshold_value.text = "%dms" % (value * 1000)
	
	if InputManager:
		InputManager.set_action_debounce_threshold("tap", value)
		_log_action_event("SETTING", "Tap threshold set to %.0fms" % (value * 1000), {}, Color.YELLOW)

# Analysis and reporting
func get_test_results() -> Dictionary:
	var avg_response_time = 0.0
	if buffer_response_times.size() > 0:
		for time in buffer_response_times:
			avg_response_time += time
		avg_response_time /= buffer_response_times.size()
	
	var avg_fps = 0.0
	if frame_times.size() > 0:
		for ft in frame_times:
			avg_fps += 1.0 / ft
		avg_fps /= frame_times.size()
	
	return {
		"test_duration": Time.get_unix_time_from_system() - test_start_time,
		"total_attempted": total_actions_attempted,
		"total_buffered": total_actions_buffered,
		"total_debounced": total_actions_debounced,
		"hardware_noise": hardware_noise_detected,
		"debounce_percentage": _calculate_debounce_percentage(),
		"average_response_time": avg_response_time,
		"average_fps": avg_fps,
		"buffer_efficiency": float(total_actions_buffered) / float(max(total_actions_attempted, 1)) * 100.0
	}

func print_detailed_report() -> void:
	var results = get_test_results()
	
	print("\n=== INPUT DEBOUNCING TEST REPORT ===")
	print("Test Duration: %.1f seconds" % results.test_duration)
	print("Total Actions Attempted: %d" % results.total_attempted)
	print("Actions Successfully Buffered: %d (%.1f%%)" % [results.total_buffered, results.buffer_efficiency])
	print("Actions Debounced: %d (%.1f%%)" % [results.total_debounced, results.debounce_percentage])
	print("Hardware Noise Detected: %d" % results.hardware_noise)
	print("Average Response Time: %.2fms" % (results.average_response_time * 1000))
	print("Average FPS: %.1f" % results.average_fps)
	print("====================================\n")

# Automated test interface
func run_automated_debounce_tests() -> Dictionary:
	print("InputDebounceTest: Running automated debounce validation...")
	
	# TODO: Implement comprehensive automated tests
	# - Rapid tap sequences
	# - Mixed gesture patterns
	# - Hardware noise simulation
	# - Performance stress tests
	# - Edge case validation
	
	return get_test_results() 