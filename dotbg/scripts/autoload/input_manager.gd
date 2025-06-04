extends Node

# Core touch input handling system for epic mobile campaigns
# Optimized for 50+ hour gameplay sessions with <50ms latency

# Touch input state tracking
var active_touches: Dictionary = {}
var touch_history: Array[Dictionary] = []
var max_touch_history: int = 100

# Gesture detection
var gesture_detector: GestureDetector
var input_buffer: InputBuffer
var haptic_controller: HapticController

# Mobile performance optimization
var touch_pool: Array[TouchData] = []
var max_pooled_touches: int = 10
var performance_mode: bool = false

# Input settings for epic campaigns
var touch_sensitivity: float = 1.0
var gesture_threshold: float = 50.0  # pixels
var hold_duration: float = 0.5  # seconds
var double_tap_window: float = 0.3  # seconds

# Global haptic feedback settings (CRITICAL ACCESSIBILITY)
var haptic_feedback_enabled: bool = true
var haptic_intensity: float = 1.0

# Debug and development
var debug_visualization: bool = false
var input_logging: bool = false
var debug_overlay: CanvasLayer

# Signals for epic system coordination
signal touch_started(touch_data: TouchData)
signal touch_moved(touch_data: TouchData)
signal touch_ended(touch_data: TouchData)
signal gesture_detected(gesture_type: String, gesture_data: Dictionary)
signal input_buffered(action: String, data: Dictionary)
@warning_ignore("unused_signal")
signal haptic_settings_changed(enabled: bool, intensity: float)

# Touch data class for efficient memory management
class TouchData:
	var id: int
	var position: Vector2
	var start_position: Vector2
	var start_time: float
	var last_position: Vector2
	var velocity: Vector2
	var pressure: float
	var is_active: bool
	
	func _init(touch_id: int, pos: Vector2):
		id = touch_id
		position = pos
		start_position = pos
		last_position = pos
		start_time = Time.get_unix_time_from_system()
		pressure = 1.0
		is_active = true
		velocity = Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initialize touch input subsystems
	_initialize_input_subsystems()
	
	# Set up mobile optimization
	_configure_mobile_optimization()
	
	# Connect to epic campaign systems
	_connect_epic_systems()
	
	print("InputManager: Epic mobile touch system initialized")

func _initialize_input_subsystems() -> void:
	# Initialize gesture detection
	gesture_detector = GestureDetector.new()
	add_child(gesture_detector)
	
	# Initialize input buffering for combat
	input_buffer = InputBuffer.new()
	add_child(input_buffer)
	
	# Initialize haptic feedback
	haptic_controller = HapticController.new()
	add_child(haptic_controller)
	
	# Connect subsystem signals
	gesture_detector.gesture_recognized.connect(_on_gesture_recognized)
	input_buffer.action_buffered.connect(_on_action_buffered)

func _configure_mobile_optimization() -> void:
	# Pre-allocate touch data pool for performance
	for i in range(max_pooled_touches):
		var touch_data = TouchData.new(0, Vector2.ZERO)
		touch_data.is_active = false
		touch_pool.append(touch_data)
	
	# Configure for mobile performance
	if OS.has_feature("mobile"):
		performance_mode = true
		max_touch_history = 50  # Reduce for mobile memory
		gesture_threshold = 75.0  # Larger threshold for touch screens

func _connect_epic_systems() -> void:
	# Connect to SanityManager for sanity-influenced input
	# TODO: Fix signal connections after autoload initialization
	# if SanityManager:
	#	SanityManager.reality_distortion_triggered.connect(_on_reality_distortion)
	
	# Connect to GameManager for act-specific input handling
	# TODO: Fix signal connections after autoload initialization
	# if GameManager:
	#	GameManager.act_changed.connect(_on_act_changed)
	
	pass  # Placeholder until autoload connections are fixed

func _input(event: InputEvent) -> void:
	# Main input processing entry point
	if event is InputEventScreenTouch:
		_handle_touch_event(event)
	elif event is InputEventScreenDrag:
		_handle_drag_event(event)

func _handle_touch_event(event: InputEventScreenTouch) -> void:
	var touch_id = event.index
	var position = event.position
	
	if event.pressed:
		_start_touch(touch_id, position)
	else:
		_end_touch(touch_id, position)

func _handle_drag_event(event: InputEventScreenDrag) -> void:
	var touch_id = event.index
	var position = event.position
	
	_update_touch(touch_id, position, event.velocity)

func _start_touch(touch_id: int, position: Vector2) -> void:
	# Get touch data from pool or create new
	var touch_data = _get_pooled_touch_data(touch_id, position)
	
	# Store active touch
	active_touches[touch_id] = touch_data
	
	# Log for epic campaign tracking
	_log_touch_event("touch_started", touch_data)
	
	# Emit signal for system coordination
	touch_started.emit(touch_data)
	
	# Send to gesture detector
	gesture_detector.process_touch_start(touch_data)
	
	# Trigger haptic feedback
	haptic_controller.trigger_touch_feedback()

func _update_touch(touch_id: int, position: Vector2, velocity: Vector2) -> void:
	if not active_touches.has(touch_id):
		return
	
	var touch_data = active_touches[touch_id]
	touch_data.last_position = touch_data.position
	touch_data.position = position
	touch_data.velocity = velocity
	
	# Emit signal for system coordination
	touch_moved.emit(touch_data)
	
	# Send to gesture detector
	gesture_detector.process_touch_move(touch_data)

func _end_touch(touch_id: int, position: Vector2) -> void:
	if not active_touches.has(touch_id):
		return
	
	var touch_data = active_touches[touch_id]
	touch_data.position = position
	touch_data.is_active = false
	
	# Log for epic campaign tracking
	_log_touch_event("touch_ended", touch_data)
	
	# Emit signal for system coordination
	touch_ended.emit(touch_data)
	
	# Send to gesture detector
	gesture_detector.process_touch_end(touch_data)
	
	# Return to pool and remove from active
	_return_touch_to_pool(touch_data)
	active_touches.erase(touch_id)

func _get_pooled_touch_data(touch_id: int, position: Vector2) -> TouchData:
	# Try to get from pool first
	for touch_data in touch_pool:
		if not touch_data.is_active:
			# Reset and reuse
			touch_data.id = touch_id
			touch_data.position = position
			touch_data.start_position = position
			touch_data.last_position = position
			touch_data.start_time = Time.get_unix_time_from_system()
			touch_data.velocity = Vector2.ZERO
			touch_data.pressure = 1.0
			touch_data.is_active = true
			return touch_data
	
	# Create new if pool exhausted
	return TouchData.new(touch_id, position)

func _return_touch_to_pool(touch_data: TouchData) -> void:
	touch_data.is_active = false
	# Touch data remains in pool for reuse

func _log_touch_event(event_type: String, touch_data: TouchData) -> void:
	if not input_logging:
		return
	
	var log_entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"event": event_type,
		"touch_id": touch_data.id,
		"position": touch_data.position,
		"duration": Time.get_unix_time_from_system() - touch_data.start_time
	}
	
	touch_history.append(log_entry)
	
	# Manage history size for mobile memory
	if touch_history.size() > max_touch_history:
		@warning_ignore("integer_division")
		touch_history = touch_history.slice(max_touch_history / 2)

# Epic campaign event handlers
func _on_reality_distortion(distortion_type: String, intensity: float) -> void:
	# Apply sanity-based input distortion
	match distortion_type:
		"input_lag":
			_apply_input_lag(intensity)
		"false_touches":
			_generate_false_touches(intensity)
		"gesture_corruption":
			gesture_detector.set_corruption_level(intensity)

func _on_act_changed(new_act: int) -> void:
	# Adjust input handling for different acts
	# TODO: Restore proper Act enum after GameManager expansion
	match new_act:
		1:  # GameManager.Act.DESCENDING_CITY:
			gesture_threshold = 50.0  # Normal precision
		2:  # GameManager.Act.DROWNING_DEPTHS:
			gesture_threshold = 60.0  # Slightly less precise (water effects)
		3:  # GameManager.Act.DREAM_REALM:
			gesture_threshold = 40.0  # More sensitive (dream logic)

func _on_gesture_recognized(gesture_type: String, gesture_data: Dictionary) -> void:
	gesture_detected.emit(gesture_type, gesture_data)
	
	# Buffer combat actions
	if gesture_type in ["tap", "swipe", "hold"]:
		input_buffer.buffer_action(gesture_type, gesture_data)

func _on_action_buffered(action: String, data: Dictionary) -> void:
	input_buffered.emit(action, data)

# Public API for epic systems
func get_active_touches() -> Dictionary:
	return active_touches.duplicate()

func get_touch_count() -> int:
	return active_touches.size()

func is_touch_active(touch_id: int) -> bool:
	return active_touches.has(touch_id)

func get_touch_data(touch_id: int) -> TouchData:
	return active_touches.get(touch_id, null)

func set_touch_sensitivity(sensitivity: float) -> void:
	touch_sensitivity = clamp(sensitivity, 0.1, 2.0)

func set_gesture_threshold(threshold: float) -> void:
	gesture_threshold = clamp(threshold, 10.0, 200.0)

func enable_debug_visualization(enabled: bool) -> void:
	debug_visualization = enabled
	if enabled and not debug_overlay:
		_create_debug_overlay()
	elif not enabled and debug_overlay:
		debug_overlay.queue_free()
		debug_overlay = null

func enable_input_logging(enabled: bool) -> void:
	input_logging = enabled

func get_input_statistics() -> Dictionary:
	return {
		"active_touches": active_touches.size(),
		"touch_history_size": touch_history.size(),
		"pooled_touches": touch_pool.size(),
		"performance_mode": performance_mode,
		"touch_sensitivity": touch_sensitivity,
		"gesture_threshold": gesture_threshold
	}

# Debug and development functions
func _create_debug_overlay() -> void:
	debug_overlay = CanvasLayer.new()
	debug_overlay.layer = 100  # Top layer
	add_child(debug_overlay)
	
	# Create debug visualization
	var debug_control = Control.new()
	debug_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	debug_overlay.add_child(debug_control)
	
	# Connect draw signal for touch visualization
	debug_control.draw.connect(_draw_debug_touches.bind(debug_control))

func _draw_debug_touches(control: Control) -> void:
	if not debug_visualization:
		return
	
	# Draw active touches
	for touch_data in active_touches.values():
		# Draw touch point
		control.draw_circle(touch_data.position, 20, Color.RED)
		
		# Draw touch trail
		var trail_length = touch_data.position.distance_to(touch_data.start_position)
		if trail_length > 10:
			control.draw_line(touch_data.start_position, touch_data.position, Color.YELLOW, 3)
		
		# Draw touch ID
		var font = ThemeDB.fallback_font
		control.draw_string(font, touch_data.position + Vector2(25, 0), str(touch_data.id))

func _apply_input_lag(intensity: float) -> void:
	# Apply artificial input lag for sanity effects
	@warning_ignore("unused_variable")
	var lag_amount = intensity * 0.1  # Up to 100ms lag
	# Implementation would delay input processing
	pass

func _generate_false_touches(intensity: float) -> void:
	# Generate false touch events for sanity effects
	if randf() < intensity * 0.1:  # 10% chance at max intensity
		var false_position = Vector2(randf() * 1920, randf() * 1080)
		var false_id = 999  # Special ID for false touches
		_start_touch(false_id, false_position)
		
		# End false touch after short duration
		get_tree().create_timer(0.1).timeout.connect(
			func(): _end_touch(false_id, false_position)
		)

# Gesture detector class
class GestureDetector extends Node:
	signal gesture_recognized(gesture_type: String, gesture_data: Dictionary)
	
	var corruption_level: float = 0.0
	var last_tap_time: float = 0.0
	var tap_count: int = 0
	
	func process_touch_start(touch_data: TouchData) -> void:
		# Detect tap gestures
		_detect_tap_gesture(touch_data)
	
	func process_touch_move(touch_data: TouchData) -> void:
		# Detect swipe gestures
		_detect_swipe_gesture(touch_data)
	
	func process_touch_end(touch_data: TouchData) -> void:
		# Finalize gesture detection
		_finalize_gesture_detection(touch_data)
	
	func _detect_tap_gesture(touch_data: TouchData) -> void:
		var current_time = Time.get_unix_time_from_system()
		
		# Check for double tap
		if current_time - last_tap_time < 0.3:
			tap_count += 1
			if tap_count >= 2:
				gesture_recognized.emit("double_tap", {"position": touch_data.position})
				tap_count = 0
		else:
			tap_count = 1
		
		last_tap_time = current_time
	
	func _detect_swipe_gesture(touch_data: TouchData) -> void:
		var distance = touch_data.position.distance_to(touch_data.start_position)
		if distance > 100:  # Minimum swipe distance
			var direction = (touch_data.position - touch_data.start_position).normalized()
			gesture_recognized.emit("swipe", {
				"direction": direction,
				"distance": distance,
				"start_position": touch_data.start_position,
				"end_position": touch_data.position
			})
	
	func _finalize_gesture_detection(touch_data: TouchData) -> void:
		var duration = Time.get_unix_time_from_system() - touch_data.start_time
		var distance = touch_data.position.distance_to(touch_data.start_position)
		
		# Detect hold gesture
		if duration > 0.5 and distance < 50:
			gesture_recognized.emit("hold", {
				"position": touch_data.position,
				"duration": duration
			})
		# Detect tap gesture
		elif duration < 0.3 and distance < 30:
			gesture_recognized.emit("tap", {"position": touch_data.position})
	
	func set_corruption_level(level: float) -> void:
		corruption_level = clamp(level, 0.0, 1.0)

# Input buffer class for combat actions
class InputBuffer extends Node:
	signal action_buffered(action: String, data: Dictionary)
	
	var buffered_actions: Array[Dictionary] = []
	var buffer_duration: float = 0.2  # 200ms buffer window
	
	func buffer_action(action: String, data: Dictionary) -> void:
		var buffer_entry = {
			"action": action,
			"data": data,
			"timestamp": Time.get_unix_time_from_system()
		}
		
		buffered_actions.append(buffer_entry)
		action_buffered.emit(action, data)
		
		# Clean old entries
		_clean_buffer()
	
	func _clean_buffer() -> void:
		var current_time = Time.get_unix_time_from_system()
		buffered_actions = buffered_actions.filter(
			func(entry): return current_time - entry.timestamp < buffer_duration
		)

# Haptic feedback controller
class HapticController extends Node:
	var haptic_enabled: bool = true
	var feedback_intensity: float = 1.0
	
	func trigger_touch_feedback() -> void:
		if haptic_enabled and OS.has_feature("mobile"):
			Input.vibrate_handheld(50)  # 50ms vibration
	
	func trigger_gesture_feedback(gesture_type: String) -> void:
		if not haptic_enabled:
			return
		
		match gesture_type:
			"tap":
				Input.vibrate_handheld(30)
			"hold":
				Input.vibrate_handheld(100)
			"swipe":
				Input.vibrate_handheld(75)
	
	func set_haptic_enabled(enabled: bool) -> void:
		haptic_enabled = enabled
	
	func set_feedback_intensity(intensity: float) -> void:
		feedback_intensity = clamp(intensity, 0.0, 1.0) 
