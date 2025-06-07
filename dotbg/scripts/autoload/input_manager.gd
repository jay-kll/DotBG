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
var event_propagation: EventPropagationSystem

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
	
	# Initialize event propagation system
	event_propagation = EventPropagationSystem.new()
	add_child(event_propagation)
	
	# Connect subsystem signals
	gesture_detector.gesture_recognized.connect(_on_gesture_recognized)
	input_buffer.action_buffered.connect(_on_action_buffered)
	input_buffer.action_debounced.connect(_on_action_debounced)

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
	
	# Trigger touch end haptic feedback
	haptic_controller.trigger_touch_end_feedback()
	
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
	# Emit legacy signal for backwards compatibility
	gesture_detected.emit(gesture_type, gesture_data)
	
	# Use event propagation system for modern event handling
	var handled = event_propagation.propagate_touch_event(gesture_type, gesture_data)
	
	# Buffer combat actions if not handled by specific targets
	if not handled and gesture_type in ["tap", "swipe", "hold"]:
		input_buffer.buffer_action(gesture_type, gesture_data)

func _on_action_buffered(action: String, data: Dictionary) -> void:
	input_buffered.emit(action, data)

func _on_action_debounced(action: String, reason: String) -> void:
	# Log debounced actions for debugging
	if input_logging:
		print("InputManager: Action '%s' debounced - %s" % [action, reason])
	
	# Track debounced actions for analytics
	_log_debounced_action(action, reason)

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

# Enhanced buffering API for combat systems
func get_next_buffered_action() -> Dictionary:
	if input_buffer:
		return input_buffer.get_next_action()
	return {}

func consume_buffered_action() -> Dictionary:
	if input_buffer:
		return input_buffer.consume_action()
	return {}

func consume_action_type(action_type: String) -> Dictionary:
	if input_buffer:
		return input_buffer.consume_action_type(action_type)
	return {}

func peek_action_type(action_type: String) -> Dictionary:
	if input_buffer:
		return input_buffer.peek_action_type(action_type)
	return {}

func clear_input_buffer() -> void:
	if input_buffer:
		input_buffer.clear_buffer()

func set_action_debounce_threshold(action: String, threshold: float) -> void:
	if input_buffer:
		input_buffer.set_debounce_threshold(action, threshold)

func enable_debug_visualization(enabled: bool) -> void:
	debug_visualization = enabled
	if enabled and not debug_overlay:
		_create_debug_overlay()
	elif not enabled and debug_overlay:
		debug_overlay.queue_free()
		debug_overlay = null

func enable_input_logging(enabled: bool) -> void:
	input_logging = enabled

# Enhanced haptic feedback API for epic systems
func set_haptic_enabled(enabled: bool) -> void:
	haptic_feedback_enabled = enabled
	if haptic_controller:
		haptic_controller.set_haptic_enabled(enabled)

func set_haptic_intensity(intensity: float) -> void:
	haptic_intensity = clamp(intensity, 0.0, 1.0)
	if haptic_controller:
		haptic_controller.set_feedback_intensity(intensity)

func trigger_haptic_pattern(pattern_name: String) -> void:
	if haptic_controller:
		haptic_controller._trigger_pattern_feedback(pattern_name)

func add_custom_haptic_pattern(pattern_name: String, duration: int, intensity_scale: float) -> void:
	if haptic_controller:
		haptic_controller.add_custom_pattern(pattern_name, duration, intensity_scale)

func set_sanity_corruption_level(corruption: float) -> void:
	if haptic_controller:
		haptic_controller.set_sanity_corruption(corruption)

func enable_haptic_battery_saver(enabled: bool) -> void:
	if haptic_controller:
		haptic_controller.enable_battery_saver(enabled)

# Event Propagation API for epic systems
func register_ui_event_target(node: Node) -> void:
	if event_propagation:
		event_propagation.register_ui_node(node)

func register_game_event_target(node: Node) -> void:
	if event_propagation:
		event_propagation.register_game_node(node)

func register_world_event_target(node: Node) -> void:
	if event_propagation:
		event_propagation.register_world_node(node)

func unregister_event_target(node: Node) -> void:
	if event_propagation:
		event_propagation.unregister_node(node)

func get_event_propagation_stats() -> Dictionary:
	if event_propagation:
		return event_propagation.get_performance_stats()
	return {}

func clear_all_event_targets() -> void:
	if event_propagation:
		event_propagation.clear_all_targets()

func _log_debounced_action(action: String, reason: String) -> void:
	var log_entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"action": action,
		"reason": reason,
		"type": "debounced"
	}
	touch_history.append(log_entry)

func get_input_statistics() -> Dictionary:
	var stats = {
		"active_touches": active_touches.size(),
		"touch_history_size": touch_history.size(),
		"pooled_touches": touch_pool.size(),
		"performance_mode": performance_mode,
		"touch_sensitivity": touch_sensitivity,
		"gesture_threshold": gesture_threshold,
		"haptic_enabled": haptic_feedback_enabled,
		"haptic_intensity": haptic_intensity
	}
	
	# Add buffer statistics if available
	if input_buffer:
		stats.merge(input_buffer.get_buffer_statistics())
	
	# Add haptic controller statistics if available
	if haptic_controller:
		var haptic_stats = haptic_controller.get_haptic_statistics()
		for key in haptic_stats:
			stats["haptic_" + key] = haptic_stats[key]
	
	# Add event propagation statistics
	if event_propagation:
		var event_stats = event_propagation.get_performance_stats()
		for key in event_stats:
			stats["event_" + key] = event_stats[key]
	
	return stats

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
				# Trigger haptic feedback for double tap
				get_parent().haptic_controller.trigger_gesture_feedback("double_tap")
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
			# Trigger haptic feedback for swipe
			get_parent().haptic_controller.trigger_gesture_feedback("swipe")
	
	func _finalize_gesture_detection(touch_data: TouchData) -> void:
		var duration = Time.get_unix_time_from_system() - touch_data.start_time
		var distance = touch_data.position.distance_to(touch_data.start_position)
		
		# Detect hold gesture
		if duration > 0.5 and distance < 50:
			gesture_recognized.emit("hold", {
				"position": touch_data.position,
				"duration": duration
			})
			# Trigger haptic feedback for hold
			get_parent().haptic_controller.trigger_gesture_feedback("hold")
		# Detect tap gesture
		elif duration < 0.3 and distance < 30:
			gesture_recognized.emit("tap", {"position": touch_data.position})
			# Trigger haptic feedback for tap
			get_parent().haptic_controller.trigger_gesture_feedback("tap")
	
	func set_corruption_level(level: float) -> void:
		corruption_level = clamp(level, 0.0, 1.0)

# Enhanced Input buffer class for combat actions with debouncing
class InputBuffer extends Node:
	signal action_buffered(action: String, data: Dictionary)
	signal action_debounced(action: String, reason: String)
	
	var buffered_actions: Array[Dictionary] = []
	var buffer_duration: float = 0.2  # 200ms buffer window
	
	# Debouncing settings for mobile optimization
	var debounce_threshold: float = 0.05  # 50ms minimum between same actions
	var rapid_tap_threshold: float = 0.03  # 30ms for detecting hardware noise
	var max_buffer_size: int = 20  # Prevent memory issues on mobile
	
	# Action-specific debouncing rules
	var action_debounce_rules: Dictionary = {
		"tap": 0.08,  # 80ms minimum between taps
		"double_tap": 0.05,  # Allow faster double taps
		"swipe": 0.15,  # 150ms minimum between swipes  
		"hold": 0.2,  # 200ms minimum between holds
		"attack": 0.12,  # 120ms minimum between attacks
		"dodge": 0.25,  # 250ms minimum between dodges
		"jump": 0.18   # 180ms minimum between jumps
	}
	
	# Action history for advanced debouncing
	var action_history: Dictionary = {}  # action_name -> last_timestamp
	var rapid_action_counts: Dictionary = {}  # action_name -> rapid_count
	var noise_detection_window: float = 0.1  # 100ms window for noise detection
	
	# Performance optimization
	var last_cleanup_time: float = 0.0
	var cleanup_interval: float = 0.1  # Clean buffer every 100ms
	
	func buffer_action(action: String, data: Dictionary) -> void:
		var current_time = Time.get_unix_time_from_system()
		
		# Check if action should be debounced
		if _should_debounce_action(action, current_time):
			action_debounced.emit(action, "debounced_duplicate")
			return
		
		# Check for hardware noise
		if _is_hardware_noise(action, current_time):
			action_debounced.emit(action, "hardware_noise")
			return
		
		# Check buffer size limit (mobile memory management)
		if buffered_actions.size() >= max_buffer_size:
			# Remove oldest actions to make space
			buffered_actions = buffered_actions.slice(-max_buffer_size + 5)
		
		# Create buffer entry with enhanced data
		var buffer_entry = {
			"action": action,
			"data": data,
			"timestamp": current_time,
			"processed": false,
			"priority": _get_action_priority(action),
			"sequence_id": _generate_sequence_id()
		}
		
		# Insert in priority order
		_insert_by_priority(buffer_entry)
		
		# Update action history
		action_history[action] = current_time
		
		# Reset rapid action count for successful action
		rapid_action_counts[action] = 0
		
		# Emit buffered signal
		action_buffered.emit(action, data)
		
		# Periodic cleanup to maintain performance
		if current_time - last_cleanup_time > cleanup_interval:
			_clean_buffer()
			last_cleanup_time = current_time
	
	func _should_debounce_action(action: String, current_time: float) -> bool:
		# Check if we have a history for this action
		if not action_history.has(action):
			return false
		
		var last_time = action_history[action]
		var time_diff = current_time - last_time
		
		# Get action-specific debounce threshold
		var threshold = action_debounce_rules.get(action, debounce_threshold)
		
		return time_diff < threshold
	
	func _is_hardware_noise(action: String, current_time: float) -> bool:
		# Track rapid actions that might be hardware noise
		if not rapid_action_counts.has(action):
			rapid_action_counts[action] = 0
		
		# Check if this action happened very recently (potential noise)
		if action_history.has(action):
			var time_diff = current_time - action_history[action]
			if time_diff < rapid_tap_threshold:
				rapid_action_counts[action] += 1
				
				# If we've had multiple rapid actions, likely hardware noise
				if rapid_action_counts[action] >= 3:
					return true
		
		return false
	
	func _get_action_priority(action: String) -> int:
		# Higher priority actions get processed first
		match action:
			"dodge": return 10  # Highest priority for safety
			"attack": return 8
			"jump": return 6
			"hold": return 4
			"swipe": return 3
			"tap": return 2
			"double_tap": return 1
			_: return 0
	
	func _generate_sequence_id() -> int:
		return Time.get_ticks_msec()
	
	func _insert_by_priority(entry: Dictionary) -> void:
		# Insert action in priority order (higher priority first)
		var inserted = false
		for i in range(buffered_actions.size()):
			if entry.priority > buffered_actions[i].priority:
				buffered_actions.insert(i, entry)
				inserted = true
				break
		
		if not inserted:
			buffered_actions.append(entry)
	
	func _clean_buffer() -> void:
		var current_time = Time.get_unix_time_from_system()
		
		# Remove expired entries
		buffered_actions = buffered_actions.filter(
			func(entry): return current_time - entry.timestamp < buffer_duration
		)
		
		# Clean up rapid action counts
		for action in rapid_action_counts.keys():
			if action_history.has(action):
				var time_diff = current_time - action_history[action]
				if time_diff > noise_detection_window:
					rapid_action_counts[action] = 0
	
	# Public API for getting buffered actions
	func get_buffered_actions() -> Array[Dictionary]:
		return buffered_actions.duplicate()
	
	func get_next_action() -> Dictionary:
		_clean_buffer()
		if buffered_actions.size() > 0:
			return buffered_actions[0]
		return {}
	
	func consume_action() -> Dictionary:
		_clean_buffer()
		if buffered_actions.size() > 0:
			var action = buffered_actions.pop_front()
			action.processed = true
			return action
		return {}
	
	func peek_action_type(action_type: String) -> Dictionary:
		for action in buffered_actions:
			if action.action == action_type:
				return action
		return {}
	
	func consume_action_type(action_type: String) -> Dictionary:
		for i in range(buffered_actions.size()):
			if buffered_actions[i].action == action_type:
				var action = buffered_actions.pop_at(i)
				action.processed = true
				return action
		return {}
	
	func clear_buffer() -> void:
		buffered_actions.clear()
	
	func set_debounce_threshold(action: String, threshold: float) -> void:
		action_debounce_rules[action] = clamp(threshold, 0.01, 1.0)
	
	func get_buffer_statistics() -> Dictionary:
		return {
			"buffer_size": buffered_actions.size(),
			"action_history_size": action_history.size(),
			"rapid_counts": rapid_action_counts.duplicate(),
			"buffer_duration": buffer_duration,
			"debounce_rules": action_debounce_rules.duplicate()
		}

# Haptic feedback controller
class HapticController extends Node:
	var haptic_enabled: bool = true
	var feedback_intensity: float = 1.0
	var sanity_corruption_level: float = 0.0
	
	# Haptic pattern library for epic mobile experience
	var haptic_patterns: Dictionary = {
		"touch_start": {"duration": 50, "intensity_scale": 0.6},
		"touch_end": {"duration": 30, "intensity_scale": 0.4},
		"tap": {"duration": 40, "intensity_scale": 0.7},
		"double_tap": {"duration": 60, "intensity_scale": 0.8},
		"hold": {"duration": 120, "intensity_scale": 1.0},
		"swipe": {"duration": 80, "intensity_scale": 0.9},
		"pinch": {"duration": 100, "intensity_scale": 0.8},
		
		# Combat-specific patterns for epic battles
		"attack": {"duration": 90, "intensity_scale": 1.0},
		"dodge": {"duration": 110, "intensity_scale": 1.0},
		"block": {"duration": 70, "intensity_scale": 0.8},
		"hit_taken": {"duration": 150, "intensity_scale": 1.0},
		"critical_hit": {"duration": 200, "intensity_scale": 1.0},
		
		# UI and system feedback for epic interface
		"button_press": {"duration": 35, "intensity_scale": 0.5},
		"menu_navigate": {"duration": 25, "intensity_scale": 0.3},
		"confirmation": {"duration": 80, "intensity_scale": 0.7},
		"error": {"duration": 120, "intensity_scale": 0.9},
		"notification": {"duration": 60, "intensity_scale": 0.6},
		
		# Sanity system feedback (corrupted patterns)
		"sanity_false_touch": {"duration": 75, "intensity_scale": 0.5},
		"sanity_phantom_vibration": {"duration": 200, "intensity_scale": 0.3},
		"sanity_corrupted_feedback": {"duration": 300, "intensity_scale": 0.8}
	}
	
	# Performance optimization for mobile
	var last_feedback_time: float = 0.0
	var min_feedback_interval: float = 0.02  # 20ms minimum between feedback events
	var feedback_queue: Array[Dictionary] = []
	var max_queue_size: int = 5
	
	# Platform-specific optimization
	var platform_supports_haptic: bool = false
	var battery_saver_mode: bool = false
	
	func _ready() -> void:
		# Detect platform haptic support
		platform_supports_haptic = OS.has_feature("mobile") and Input.get_connected_joypads().size() == 0
		
		# Initialize battery optimization
		_configure_battery_optimization()
	
	func _configure_battery_optimization() -> void:
		# Enable battery saver on mobile for epic sessions
		if OS.has_feature("mobile"):
			battery_saver_mode = false  # Default to false, can be enabled by user
			if battery_saver_mode:
				min_feedback_interval = 0.05  # Reduce frequency in battery saver
	
	func trigger_touch_feedback() -> void:
		_trigger_pattern_feedback("touch_start")
	
	func trigger_touch_end_feedback() -> void:
		_trigger_pattern_feedback("touch_end")
	
	func trigger_gesture_feedback(gesture_type: String) -> void:
		# Enhanced gesture-specific feedback
		_trigger_pattern_feedback(gesture_type)
	
	func trigger_combat_feedback(combat_action: String) -> void:
		# Combat-specific haptic feedback for epic battles
		_trigger_pattern_feedback(combat_action)
	
	func trigger_ui_feedback(ui_action: String) -> void:
		# UI interaction feedback for epic interface
		_trigger_pattern_feedback(ui_action)
	
	func trigger_sanity_feedback(corruption_type: String) -> void:
		# Sanity-corrupted haptic feedback
		_trigger_pattern_feedback("sanity_" + corruption_type)
	
	func _trigger_pattern_feedback(pattern_name: String) -> void:
		if not haptic_enabled or not platform_supports_haptic:
			return
		
		# Check feedback throttling for mobile performance
		var current_time = Time.get_unix_time_from_system()
		if current_time - last_feedback_time < min_feedback_interval:
			# Queue feedback if too frequent
			_queue_feedback(pattern_name)
			return
		
		# Apply sanity corruption effects
		if sanity_corruption_level > 0.0:
			_apply_sanity_corruption(pattern_name)
			return
		
		# Execute normal feedback
		_execute_haptic_pattern(pattern_name)
		last_feedback_time = current_time
	
	func _execute_haptic_pattern(pattern_name: String) -> void:
		if not haptic_patterns.has(pattern_name):
			# Fallback to basic touch feedback
			pattern_name = "touch_start"
		
		var pattern = haptic_patterns[pattern_name]
		var duration = int(pattern.duration * feedback_intensity)
		var scaled_intensity = pattern.intensity_scale * feedback_intensity
		
		# Apply battery optimization
		if battery_saver_mode:
			duration = int(duration * 0.7)  # 30% shorter in battery saver
		
		# Ensure minimum viable feedback
		duration = max(duration, 20)  # At least 20ms
		
		# Trigger platform-specific haptic feedback
		if OS.has_feature("android"):
			Input.vibrate_handheld(duration)
		elif OS.has_feature("ios"):
			# iOS-specific haptic feedback would go here
			Input.vibrate_handheld(duration)
		else:
			# Fallback for other platforms
			Input.vibrate_handheld(duration)
	
	func _apply_sanity_corruption(pattern_name: String) -> void:
		# Corrupt haptic feedback based on sanity level
		var corruption_chance = sanity_corruption_level
		var random_value = randf()
		
		if random_value < corruption_chance * 0.3:
			# Generate false phantom vibration
			_execute_haptic_pattern("sanity_phantom_vibration")
		elif random_value < corruption_chance * 0.6:
			# Corrupt the intended feedback
			_execute_haptic_pattern("sanity_corrupted_feedback")
		elif random_value < corruption_chance * 0.8:
			# False touch feedback
			_execute_haptic_pattern("sanity_false_touch")
		else:
			# Random delay before normal feedback
			var delay = randf() * corruption_chance * 0.5  # Up to 500ms delay
			get_tree().create_timer(delay).timeout.connect(
				func(): _execute_haptic_pattern(pattern_name)
			)
	
	func _queue_feedback(pattern_name: String) -> void:
		# Queue feedback for later execution to maintain performance
		if feedback_queue.size() >= max_queue_size:
			feedback_queue.pop_front()  # Remove oldest queued feedback
		
		feedback_queue.append({
			"pattern": pattern_name,
			"timestamp": Time.get_unix_time_from_system()
		})
	
	func _process(delta: float) -> void:
		# Process queued feedback
		if feedback_queue.size() > 0:
			var current_time = Time.get_unix_time_from_system()
			if current_time - last_feedback_time >= min_feedback_interval:
				var queued_feedback = feedback_queue.pop_front()
				_execute_haptic_pattern(queued_feedback.pattern)
				last_feedback_time = current_time
	
	# Public API for epic systems
	func set_haptic_enabled(enabled: bool) -> void:
		haptic_enabled = enabled
		# Emit signal for UI updates
		get_parent().haptic_settings_changed.emit(enabled, feedback_intensity)
	
	func set_feedback_intensity(intensity: float) -> void:
		feedback_intensity = clamp(intensity, 0.0, 1.0) 
		# Emit signal for UI updates
		get_parent().haptic_settings_changed.emit(haptic_enabled, intensity)
	
	func set_sanity_corruption(corruption: float) -> void:
		sanity_corruption_level = clamp(corruption, 0.0, 1.0)
	
	func enable_battery_saver(enabled: bool) -> void:
		battery_saver_mode = enabled
		if enabled:
			min_feedback_interval = 0.05  # Reduce frequency
			max_queue_size = 3  # Smaller queue
		else:
			min_feedback_interval = 0.02  # Normal frequency
			max_queue_size = 5  # Normal queue size
	
	func add_custom_pattern(pattern_name: String, duration: int, intensity_scale: float) -> void:
		# Allow dynamic pattern addition for epic content
		haptic_patterns[pattern_name] = {
			"duration": duration,
			"intensity_scale": clamp(intensity_scale, 0.0, 1.0)
		}
	
	func get_haptic_statistics() -> Dictionary:
		return {
			"enabled": haptic_enabled,
			"intensity": feedback_intensity,
			"platform_support": platform_supports_haptic,
			"battery_saver": battery_saver_mode,
			"queue_size": feedback_queue.size(),
			"pattern_count": haptic_patterns.size(),
			"sanity_corruption": sanity_corruption_level,
			"last_feedback_time": last_feedback_time
		}

# Simple Event Propagation System for Touch/Gesture Events
class EventPropagationSystem extends Node:
	signal event_propagated(event_data: Dictionary)
	signal event_handled(event_data: Dictionary, handler: Node)
	signal propagation_complete(event_data: Dictionary, handled: bool)
	
	# Event target types for prioritization
	enum TargetType {
		UI_ELEMENT,      # UI controls get highest priority
		GAME_OBJECT,     # Game entities in world space
		WORLD_ELEMENT    # Background/world interactions
	}
	
	# Registered event targets
	var ui_targets: Array[Node] = []
	var game_targets: Array[Node] = []
	var world_targets: Array[Node] = []
	
	# Event processing settings
	var enable_ui_priority: bool = true
	var enable_spatial_filtering: bool = true
	var max_propagation_depth: int = 10
	var event_timeout: float = 0.05  # 50ms max per event
	
	# Performance monitoring
	var events_processed: int = 0
	var events_handled: int = 0
	var average_propagation_time: float = 0.0
	
	func propagate_touch_event(event_type: String, event_data: Dictionary) -> bool:
		var start_time = Time.get_unix_time_from_system()
		events_processed += 1
		
		# Create complete event data
		var complete_event = {
			"type": event_type,
			"position": event_data.get("position", Vector2.ZERO),
			"timestamp": Time.get_unix_time_from_system(),
			"handled": false,
			"target": null,
			"custom_data": event_data
		}
		
		# Find and prioritize targets
		var targets = _find_targets_for_event(complete_event)
		var handled = false
		
		# Try each target in priority order
		for target_info in targets:
			var node = target_info.node
			complete_event.target = node
			
			if _dispatch_event_to_node(node, complete_event):
				complete_event.handled = true
				handled = true
				events_handled += 1
				event_handled.emit(complete_event, node)
				break
		
		# Update performance metrics
		var propagation_time = Time.get_unix_time_from_system() - start_time
		average_propagation_time = (average_propagation_time + propagation_time) / 2.0
		
		# Emit completion signal
		propagation_complete.emit(complete_event, handled)
		event_propagated.emit(complete_event)
		
		return handled
	
	func _find_targets_for_event(event_data: Dictionary) -> Array[Dictionary]:
		var targets: Array[Dictionary] = []
		var event_position = event_data.position
		
		# Check UI targets first (highest priority)
		for ui_node in ui_targets:
			if _is_node_valid_target(ui_node, event_data):
				targets.append({
					"node": ui_node,
					"type": TargetType.UI_ELEMENT,
					"priority": 100,
					"distance": _calculate_event_distance(ui_node, event_position)
				})
		
		# Check game objects (medium priority)
		for game_node in game_targets:
			if _is_node_valid_target(game_node, event_data):
				targets.append({
					"node": game_node,
					"type": TargetType.GAME_OBJECT,
					"priority": 50,
					"distance": _calculate_event_distance(game_node, event_position)
				})
		
		# Check world elements (low priority)
		for world_node in world_targets:
			if _is_node_valid_target(world_node, event_data):
				targets.append({
					"node": world_node,
					"type": TargetType.WORLD_ELEMENT,
					"priority": 25,
					"distance": _calculate_event_distance(world_node, event_position)
				})
		
		# Sort by priority (highest first), then by distance (closest first)
		targets.sort_custom(func(a, b): 
			if a.priority != b.priority:
				return a.priority > b.priority
			return a.distance < b.distance
		)
		
		return targets
	
	func _is_node_valid_target(node: Node, event_data: Dictionary) -> bool:
		if not is_instance_valid(node):
			return false
		
		# Check if node has touch event handler
		if not node.has_method("_handle_touch_event") and not node.has_method("_on_touch_event"):
			return false
		
		# Check spatial filtering if enabled
		if enable_spatial_filtering:
			return _is_within_touch_area(node, event_data.position)
		
		return true
	
	func _is_within_touch_area(node: Node, position: Vector2) -> bool:
		# Handle Control nodes (UI)
		if node is Control:
			var control = node as Control
			if not control.visible:
				return false
			var global_rect = Rect2(control.global_position, control.size)
			return global_rect.has_point(position)
		
		# Handle Node2D nodes (game objects)
		if node is Node2D:
			var node2d = node as Node2D
			var distance = node2d.global_position.distance_to(position)
			return distance < 50.0  # 50 pixel touch radius
		
		return false
	
	func _calculate_event_distance(node: Node, position: Vector2) -> float:
		if node is Control:
			var control = node as Control
			var center = control.global_position + control.size / 2
			return position.distance_to(center)
		elif node is Node2D:
			var node2d = node as Node2D
			return position.distance_to(node2d.global_position)
		else:
			return 99999.0
	
	func _dispatch_event_to_node(node: Node, event_data: Dictionary) -> bool:
		if not is_instance_valid(node):
			return false
		
		var handled = false
		var start_time = Time.get_unix_time_from_system()
		
		# Try modern touch event handler first
		if node.has_method("_handle_touch_event"):
			handled = node._handle_touch_event(event_data)
		# Fallback to legacy handler
		elif node.has_method("_on_touch_event"):
			handled = node._on_touch_event(event_data)
		
		# Check for timeout
		var processing_time = Time.get_unix_time_from_system() - start_time
		if processing_time > event_timeout:
			print("EventPropagationSystem: Handler timeout on node: ", node.name)
			handled = false
		
		return handled
	
	# Public API for registering event targets
	func register_ui_node(node: Node) -> void:
		if node and not ui_targets.has(node):
			ui_targets.append(node)
			print("EventPropagationSystem: Registered UI node: ", node.name)
	
	func register_game_node(node: Node) -> void:
		if node and not game_targets.has(node):
			game_targets.append(node)
			print("EventPropagationSystem: Registered game node: ", node.name)
	
	func register_world_node(node: Node) -> void:
		if node and not world_targets.has(node):
			world_targets.append(node)
			print("EventPropagationSystem: Registered world node: ", node.name)
	
	func unregister_node(node: Node) -> void:
		ui_targets.erase(node)
		game_targets.erase(node)
		world_targets.erase(node)
		print("EventPropagationSystem: Unregistered node: ", node.name)
	
	func get_performance_stats() -> Dictionary:
		return {
			"events_processed": events_processed,
			"events_handled": events_handled,
			"average_propagation_time": average_propagation_time,
			"ui_targets": ui_targets.size(),
			"game_targets": game_targets.size(),
			"world_targets": world_targets.size(),
			"handler_efficiency": float(events_handled) / max(1, events_processed)
		}
	
	func clear_all_targets() -> void:
		ui_targets.clear()
		game_targets.clear()
		world_targets.clear()
		print("EventPropagationSystem: All event targets cleared")
 
