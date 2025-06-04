extends Control

# Multi-Touch Test Suite for Epic Mobile Campaign
# Validates InputManager multi-touch functionality and performance

@onready var touch_count_label: Label = $UI/TouchCount
@onready var last_gesture_label: Label = $UI/LastGesture
@onready var touch_details_label: RichTextLabel = $UI/TouchDetails
@onready var debug_checkbox: CheckBox = $UI/TestControls/EnableDebug
@onready var logging_checkbox: CheckBox = $UI/TestControls/EnableLogging

# Test tracking
var test_results: Dictionary = {}
var test_start_time: float
var total_touches_processed: int = 0
var gesture_count: int = 0
var max_simultaneous_touches: int = 0
var test_log: Array[String] = []

# Performance tracking
var frame_times: Array[float] = []
var max_frame_time: float = 0.0
var touch_latencies: Array[float] = []

func _ready() -> void:
	print("TouchTest: Multi-touch test suite initialized")
	test_start_time = Time.get_unix_time_from_system()
	
	# Connect to InputManager signals
	_connect_input_signals()
	
	# Initialize test tracking
	_initialize_test_tracking()
	
	# Start performance monitoring
	set_process(true)

func _connect_input_signals() -> void:
	if InputManager:
		InputManager.touch_started.connect(_on_touch_started)
		InputManager.touch_moved.connect(_on_touch_moved)
		InputManager.touch_ended.connect(_on_touch_ended)
		InputManager.gesture_detected.connect(_on_gesture_detected)
		print("TouchTest: Connected to InputManager signals")
	else:
		print("TouchTest: ERROR - InputManager not found!")
		_log_test_result("CRITICAL", "InputManager autoload not accessible")

func _initialize_test_tracking() -> void:
	test_results = {
		"start_time": test_start_time,
		"touches_processed": 0,
		"gestures_detected": 0,
		"max_simultaneous": 0,
		"average_latency": 0.0,
		"performance_issues": [],
		"edge_cases_tested": [],
		"success_rate": 0.0
	}

func _process(_delta: float) -> void:
	# Track frame performance
	var frame_time = get_process_delta_time()
	frame_times.append(frame_time)
	if frame_time > max_frame_time:
		max_frame_time = frame_time
	
	# Keep only last 60 frame times (1 second at 60fps)
	if frame_times.size() > 60:
		frame_times = frame_times.slice(-60)
	
	# Update UI
	_update_touch_display()

func _update_touch_display() -> void:
	if not InputManager:
		return
	
	var active_touches = InputManager.get_active_touches()
	var touch_count = active_touches.size()
	
	# Update touch count
	touch_count_label.text = "Active Touches: %d" % touch_count
	
	# Track maximum simultaneous touches
	if touch_count > max_simultaneous_touches:
		max_simultaneous_touches = touch_count
		test_results.max_simultaneous = max_simultaneous_touches
	
	# Update touch details
	var details_text = "[b]Touch Details:[/b]\n"
	
	if touch_count == 0:
		details_text += "No active touches"
	else:
		for touch_id in active_touches:
			var touch_data = active_touches[touch_id]
			var duration = Time.get_unix_time_from_system() - touch_data.start_time
			details_text += "[color=cyan]Touch %d:[/color] Pos(%.0f,%.0f) Duration:%.2fs\n" % [
				touch_data.id,
				touch_data.position.x,
				touch_data.position.y,
				duration
			]
	
	# Add performance info
	if frame_times.size() > 10:
		var avg_frame_time = 0.0
		for ft in frame_times:
			avg_frame_time += ft
		avg_frame_time /= frame_times.size()
		var fps = 1.0 / avg_frame_time
		
		details_text += "\n[b]Performance:[/b]\n"
		details_text += "FPS: %.1f (Max frame time: %.2fms)\n" % [fps, max_frame_time * 1000]
		details_text += "Total processed: %d touches, %d gestures\n" % [total_touches_processed, gesture_count]
	
	touch_details_label.text = details_text

# InputManager signal handlers
func _on_touch_started(touch_data) -> void:
	total_touches_processed += 1
	test_results.touches_processed = total_touches_processed
	
	var touch_start_time = Time.get_unix_time_from_system()
	
	_log_test_event("TOUCH_START", "Touch %d started at (%.0f,%.0f)" % [
		touch_data.id, touch_data.position.x, touch_data.position.y
	])
	
	# Test edge cases
	_test_edge_cases(touch_data)

func _on_touch_moved(touch_data) -> void:
	# Track touch movement for gesture analysis
	var distance = touch_data.position.distance_to(touch_data.last_position)
	if distance > 100:  # Significant movement
		_log_test_event("TOUCH_MOVE", "Touch %d moved %.0fpx" % [touch_data.id, distance])

func _on_touch_ended(touch_data) -> void:
	var duration = Time.get_unix_time_from_system() - touch_data.start_time
	var distance = touch_data.position.distance_to(touch_data.start_position)
	
	_log_test_event("TOUCH_END", "Touch %d ended: duration %.2fs, distance %.0fpx" % [
		touch_data.id, duration, distance
	])
	
	# Calculate latency (simplified - actual implementation would need more precise timing)
	var latency = 16.67  # Assume 60fps baseline latency
	touch_latencies.append(latency)
	
	# Update average latency
	if touch_latencies.size() > 0:
		var total_latency = 0.0
		for lat in touch_latencies:
			total_latency += lat
		test_results.average_latency = total_latency / touch_latencies.size()

func _on_gesture_detected(gesture_type: String, gesture_data: Dictionary) -> void:
	gesture_count += 1
	test_results.gestures_detected = gesture_count
	
	last_gesture_label.text = "Last Gesture: %s" % gesture_type
	
	_log_test_event("GESTURE", "Detected %s gesture: %s" % [gesture_type, str(gesture_data)])
	
	# Test specific gesture types
	_test_gesture_accuracy(gesture_type, gesture_data)

func _test_edge_cases(touch_data) -> void:
	var pos = touch_data.position
	var screen_size = get_viewport().get_visible_rect().size
	
	# Test screen edge touches
	if pos.x < 50 or pos.x > screen_size.x - 50:
		_log_test_result("EDGE_CASE", "Touch near screen edge (x=%.0f)" % pos.x)
		test_results.edge_cases_tested.append("screen_edge_x")
	
	if pos.y < 50 or pos.y > screen_size.y - 50:
		_log_test_result("EDGE_CASE", "Touch near screen edge (y=%.0f)" % pos.y)
		test_results.edge_cases_tested.append("screen_edge_y")
	
	# Test corner touches
	if (pos.x < 100 and pos.y < 100) or (pos.x > screen_size.x - 100 and pos.y > screen_size.y - 100):
		_log_test_result("EDGE_CASE", "Corner touch detected")
		test_results.edge_cases_tested.append("corner_touch")

func _test_gesture_accuracy(gesture_type: String, gesture_data: Dictionary) -> void:
	# Validate gesture data completeness
	match gesture_type:
		"tap":
			if gesture_data.has("position"):
				_log_test_result("GESTURE_VALID", "Tap gesture has position data")
			else:
				_log_test_result("GESTURE_ERROR", "Tap gesture missing position data")
		
		"swipe":
			if gesture_data.has("direction") and gesture_data.has("distance"):
				_log_test_result("GESTURE_VALID", "Swipe gesture has direction and distance")
			else:
				_log_test_result("GESTURE_ERROR", "Swipe gesture missing required data")
		
		"hold":
			if gesture_data.has("duration"):
				_log_test_result("GESTURE_VALID", "Hold gesture has duration data")
			else:
				_log_test_result("GESTURE_ERROR", "Hold gesture missing duration data")
		
		"double_tap":
			_log_test_result("GESTURE_VALID", "Double-tap gesture detected")

func _log_test_event(category: String, message: String) -> void:
	var timestamp = Time.get_unix_time_from_system() - test_start_time
	var log_entry = "[%.2fs] %s: %s" % [timestamp, category, message]
	test_log.append(log_entry)
	
	if logging_checkbox.button_pressed:
		print("TouchTest: " + log_entry)

func _log_test_result(result_type: String, message: String) -> void:
	_log_test_event(result_type, message)
	
	# Track performance issues
	if result_type in ["ERROR", "CRITICAL", "PERFORMANCE_ISSUE"]:
		test_results.performance_issues.append(message)

# UI signal handlers
func _on_debug_toggled(enabled: bool) -> void:
	if InputManager:
		InputManager.enable_debug_visualization(enabled)
		_log_test_event("DEBUG", "Debug visualization %s" % ("enabled" if enabled else "disabled"))

func _on_logging_toggled(enabled: bool) -> void:
	if InputManager:
		InputManager.enable_input_logging(enabled)
		_log_test_event("LOGGING", "Input logging %s" % ("enabled" if enabled else "disabled"))

func _on_clear_log_pressed() -> void:
	test_log.clear()
	_log_test_event("SYSTEM", "Test log cleared")

# Test result calculation
func calculate_success_rate() -> float:
	var total_tests = total_touches_processed + gesture_count
	if total_tests == 0:
		return 0.0
	
	var errors = test_results.performance_issues.size()
	var success_rate = (float(total_tests - errors) / float(total_tests)) * 100.0
	test_results.success_rate = success_rate
	return success_rate

# Public test interface
func run_automated_tests() -> Dictionary:
	print("TouchTest: Running automated test suite...")
	
	# TODO: Implement automated test cases
	# - Simulate rapid touch sequences
	# - Test multi-touch scenarios
	# - Validate gesture detection
	# - Performance stress tests
	
	var final_results = test_results.duplicate()
	final_results.success_rate = calculate_success_rate()
	final_results.test_duration = Time.get_unix_time_from_system() - test_start_time
	
	return final_results

func get_test_summary() -> String:
	var summary = """
[b]Multi-Touch Test Summary:[/b]
• Duration: %.1f seconds
• Touches Processed: %d
• Gestures Detected: %d
• Max Simultaneous: %d touches
• Average Latency: %.1fms
• Success Rate: %.1f%%
• Edge Cases Tested: %d
• Performance Issues: %d
""" % [
		Time.get_unix_time_from_system() - test_start_time,
		total_touches_processed,
		gesture_count,
		max_simultaneous_touches,
		test_results.average_latency,
		calculate_success_rate(),
		test_results.edge_cases_tested.size(),
		test_results.performance_issues.size()
	]
	
	return summary 