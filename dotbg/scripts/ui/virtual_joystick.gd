extends Control

class_name VirtualJoystick

# Virtual joystick for mobile movement controls
# Optimized for epic 50+ hour mobile campaigns

# Joystick components
@onready var joystick_base: Control
@onready var joystick_knob: Control

# Joystick state
var is_active: bool = false
var touch_id: int = -1
var center_position: Vector2
var current_position: Vector2
var input_vector: Vector2 = Vector2.ZERO

# Configuration for epic campaigns
var joystick_radius: float = 100.0
var knob_radius: float = 30.0
var dead_zone: float = 0.2
var sensitivity: float = 1.0
var return_speed: float = 10.0

# Visual configuration
var base_color: Color = Color(1, 1, 1, 0.3)
var knob_color: Color = Color(1, 1, 1, 0.6)
var active_color: Color = Color(0.8, 0.9, 1.0, 0.8)

# Mobile optimization
var haptic_feedback: bool = true
var visual_feedback: bool = true
var smooth_return: bool = true

# Epic campaign integration
var sanity_distortion: float = 0.0
var act_modifier: float = 1.0

# Signals for epic system coordination
signal movement_started()
signal movement_changed(input_vector: Vector2)
signal movement_ended()

func _ready() -> void:
	# Create joystick visual components
	_create_joystick_visuals()
	
	# Connect to epic systems
	_connect_epic_systems()
	
	# Configure for mobile
	_configure_mobile_settings()
	
	print("VirtualJoystick: Epic mobile joystick initialized")

func _create_joystick_visuals() -> void:
	# Create base circle
	joystick_base = Control.new()
	joystick_base.name = "JoystickBase"
	joystick_base.custom_minimum_size = Vector2(joystick_radius * 2, joystick_radius * 2)
	joystick_base.anchor_left = 0.5
	joystick_base.anchor_top = 0.5
	joystick_base.anchor_right = 0.5
	joystick_base.anchor_bottom = 0.5
	joystick_base.offset_left = -joystick_radius
	joystick_base.offset_top = -joystick_radius
	joystick_base.offset_right = joystick_radius
	joystick_base.offset_bottom = joystick_radius
	add_child(joystick_base)
	
	# Create knob
	joystick_knob = Control.new()
	joystick_knob.name = "JoystickKnob"
	joystick_knob.custom_minimum_size = Vector2(knob_radius * 2, knob_radius * 2)
	joystick_knob.anchor_left = 0.5
	joystick_knob.anchor_top = 0.5
	joystick_knob.anchor_right = 0.5
	joystick_knob.anchor_bottom = 0.5
	joystick_knob.offset_left = -knob_radius
	joystick_knob.offset_top = -knob_radius
	joystick_knob.offset_right = knob_radius
	joystick_knob.offset_bottom = knob_radius
	joystick_base.add_child(joystick_knob)
	
	# Connect drawing
	joystick_base.draw.connect(_draw_joystick_base)
	joystick_knob.draw.connect(_draw_joystick_knob)
	
	# Set initial position
	center_position = joystick_base.size / 2
	current_position = center_position

func _connect_epic_systems() -> void:
	# Connect to InputManager for touch coordination
	if InputManager:
		InputManager.touch_started.connect(_on_touch_started)
		InputManager.touch_moved.connect(_on_touch_moved)
		InputManager.touch_ended.connect(_on_touch_ended)
	
	# Connect to SanityManager for distortion effects
	if SanityManager:
		SanityManager.reality_distortion_triggered.connect(_on_reality_distortion)
		SanityManager.sanity_level_changed.connect(_on_sanity_level_changed)
	
	# Connect to GameManager for act-specific modifications
	if GameManager:
		GameManager.act_changed.connect(_on_act_changed)

func _configure_mobile_settings() -> void:
	# Optimize for mobile touch screens
	if OS.has_feature("mobile"):
		joystick_radius = 120.0  # Larger for touch
		knob_radius = 35.0
		dead_zone = 0.15  # Smaller dead zone for precision
		sensitivity = 1.2  # Slightly more sensitive

func _input(event: InputEvent) -> void:
	# Handle direct input events if InputManager isn't available
	if not InputManager:
		if event is InputEventScreenTouch:
			_handle_direct_touch(event)
		elif event is InputEventScreenDrag:
			_handle_direct_drag(event)

func _handle_direct_touch(event: InputEventScreenTouch) -> void:
	if not is_inside_tree():
		return
	
	# TODO: Fix to_local() method - temporarily use global position
	# var local_pos = to_local(event.position)
	var local_pos = event.position - global_position
	
	if event.pressed:
		if _is_point_in_joystick(local_pos):
			_start_joystick_input(event.index, local_pos)
	else:
		if touch_id == event.index:
			_end_joystick_input()

func _handle_direct_drag(event: InputEventScreenDrag) -> void:
	if not is_inside_tree():
		return
		
	if touch_id == event.index and is_active:
		# TODO: Fix to_local() method - temporarily use global position
		# var local_pos = to_local(event.position)
		var local_pos = event.position - global_position
		_update_joystick_input(local_pos)

func _on_touch_started(touch_data: InputManager.TouchData) -> void:
	if is_active or not is_inside_tree():
		return  # Already handling a touch or not ready
	
	# TODO: Fix to_local() method - temporarily use global position
	# var local_pos = to_local(touch_data.position)
	var local_pos = touch_data.position - global_position
	if _is_point_in_joystick(local_pos):
		_start_joystick_input(touch_data.id, local_pos)

func _on_touch_moved(touch_data: InputManager.TouchData) -> void:
	if not is_inside_tree():
		return
		
	if touch_id == touch_data.id and is_active:
		# TODO: Fix to_local() method - temporarily use global position
		# var local_pos = to_local(touch_data.position)
		var local_pos = touch_data.position - global_position
		_update_joystick_input(local_pos)

func _on_touch_ended(touch_data: InputManager.TouchData) -> void:
	if touch_id == touch_data.id and is_active:
		_end_joystick_input()

func _is_point_in_joystick(local_pos: Vector2) -> bool:
	var distance = local_pos.distance_to(center_position)
	return distance <= joystick_radius

func _start_joystick_input(id: int, local_pos: Vector2) -> void:
	is_active = true
	touch_id = id
	current_position = local_pos
	
	# Update input vector
	_calculate_input_vector()
	
	# Visual feedback
	if visual_feedback:
		joystick_base.queue_redraw()
		joystick_knob.queue_redraw()
	
	# Haptic feedback
	if haptic_feedback and InputManager and InputManager.haptic_controller:
		InputManager.haptic_controller.trigger_touch_feedback()
	
	# Emit signal
	movement_started.emit()
	
	print("VirtualJoystick: Movement started")

func _update_joystick_input(local_pos: Vector2) -> void:
	if not is_active:
		return
	
	# Clamp position to joystick radius
	var offset = local_pos - center_position
	var distance = offset.length()
	
	if distance > joystick_radius:
		offset = offset.normalized() * joystick_radius
		current_position = center_position + offset
	else:
		current_position = local_pos
	
	# Update input vector
	_calculate_input_vector()
	
	# Visual feedback
	if visual_feedback:
		joystick_knob.queue_redraw()
	
	# Emit signal
	movement_changed.emit(input_vector)

func _end_joystick_input() -> void:
	if not is_active:
		return
	
	is_active = false
	touch_id = -1
	
	# Return knob to center
	if smooth_return:
		_animate_knob_return()
	else:
		current_position = center_position
		input_vector = Vector2.ZERO
	
	# Visual feedback
	if visual_feedback:
		joystick_base.queue_redraw()
		joystick_knob.queue_redraw()
	
	# Emit signal
	movement_ended.emit()
	
	print("VirtualJoystick: Movement ended")

func _animate_knob_return() -> void:
	# Smooth return animation
	var tween = create_tween()
	tween.tween_method(_update_knob_position, current_position, center_position, 0.2)
	tween.tween_callback(_on_return_complete)

func _update_knob_position(pos: Vector2) -> void:
	current_position = pos
	_calculate_input_vector()
	
	if visual_feedback:
		joystick_knob.queue_redraw()
	
	movement_changed.emit(input_vector)

func _on_return_complete() -> void:
	input_vector = Vector2.ZERO
	movement_changed.emit(input_vector)

func _calculate_input_vector() -> void:
	var offset = current_position - center_position
	var distance = offset.length()
	
	if distance < dead_zone * joystick_radius:
		input_vector = Vector2.ZERO
	else:
		# Normalize and apply sensitivity
		var normalized_distance = (distance - dead_zone * joystick_radius) / (joystick_radius - dead_zone * joystick_radius)
		input_vector = offset.normalized() * normalized_distance * sensitivity
		
		# Apply epic campaign modifiers
		input_vector *= act_modifier
		
		# Apply sanity distortion
		if sanity_distortion > 0.0:
			_apply_sanity_distortion()
	
	# Clamp to ensure we don't exceed maximum
	input_vector = input_vector.limit_length(1.0)

func _apply_sanity_distortion() -> void:
	# Apply sanity-based input distortion
	if sanity_distortion > 0.5:
		# High distortion - add random drift
		var drift = Vector2(
			randf_range(-0.1, 0.1) * sanity_distortion,
			randf_range(-0.1, 0.1) * sanity_distortion
		)
		input_vector += drift
	
	if sanity_distortion > 0.7:
		# Very high distortion - occasional input reversal
		if randf() < 0.1:
			input_vector *= -1

# Epic campaign event handlers
func _on_reality_distortion(distortion_type: String, intensity: float) -> void:
	match distortion_type:
		"input_corruption":
			sanity_distortion = intensity
		"joystick_drift":
			_apply_joystick_drift(intensity)
		"false_input":
			_generate_false_input(intensity)

func _on_sanity_level_changed(old_level: SanityManager.SanityLevel, new_level: SanityManager.SanityLevel) -> void:
	# Adjust joystick behavior based on sanity
	match new_level:
		SanityManager.SanityLevel.HIGH:
			sanity_distortion = 0.0
			sensitivity = 1.0
		SanityManager.SanityLevel.MEDIUM:
			sanity_distortion = 0.2
			sensitivity = 0.9
		SanityManager.SanityLevel.LOW:
			sanity_distortion = 0.5
			sensitivity = 0.8
		SanityManager.SanityLevel.ZERO:
			sanity_distortion = 0.8
			sensitivity = 0.6

func _on_act_changed(new_act: int) -> void:
	# Adjust joystick for different acts
	# TODO: Restore proper Act enum after GameManager expansion
	match new_act:
		1:  # GameManager.Act.DESCENDING_CITY:
			act_modifier = 1.0
			base_color = Color(1, 1, 1, 0.3)
		2:  # GameManager.Act.DROWNING_DEPTHS:
			act_modifier = 0.8  # Slower movement in water
			base_color = Color(0.7, 0.9, 1.0, 0.3)
		3:  # GameManager.Act.DREAM_REALM:
			act_modifier = 1.2  # Faster movement in dreams
			base_color = Color(1.0, 0.7, 1.0, 0.3)
	
	# Update visuals
	if visual_feedback:
		joystick_base.queue_redraw()

func _apply_joystick_drift(intensity: float) -> void:
	# Apply drift effect to joystick
	var drift_amount = intensity * 20.0
	var drift_offset = Vector2(
		randf_range(-drift_amount, drift_amount),
		randf_range(-drift_amount, drift_amount)
	)
	current_position += drift_offset
	_calculate_input_vector()

func _generate_false_input(intensity: float) -> void:
	# Generate false input for sanity effects
	if randf() < intensity * 0.05:  # 5% chance at max intensity
		var false_vector = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized() * randf_range(0.3, 0.8)
		
		movement_changed.emit(false_vector)

# Drawing functions
func _draw_joystick_base() -> void:
	var color = active_color if is_active else base_color
	
	# Apply sanity distortion to visuals
	if sanity_distortion > 0.3:
		color.a *= (1.0 - sanity_distortion * 0.5)
	
	# Draw base circle
	draw_circle(center_position, joystick_radius, color)
	
	# Draw border
	draw_arc(center_position, joystick_radius, 0, TAU, 64, Color.WHITE * 0.5, 2.0)

func _draw_joystick_knob() -> void:
	var knob_pos = current_position - center_position
	var color = active_color if is_active else knob_color
	
	# Apply sanity distortion to knob
	if sanity_distortion > 0.5:
		# Distort knob position slightly
		var distortion = Vector2(
			sin(Time.get_unix_time_from_system() * 10) * sanity_distortion * 5,
			cos(Time.get_unix_time_from_system() * 8) * sanity_distortion * 5
		)
		knob_pos += distortion
	
	# Draw knob
	draw_circle(knob_pos, knob_radius, color)
	
	# Draw knob border
	draw_arc(knob_pos, knob_radius, 0, TAU, 32, Color.WHITE * 0.7, 1.5)

# Public API
func get_input_vector() -> Vector2:
	return input_vector

func set_joystick_radius(radius: float) -> void:
	joystick_radius = radius
	_update_joystick_size()

func set_sensitivity(new_sensitivity: float) -> void:
	sensitivity = clamp(new_sensitivity, 0.1, 2.0)

func set_dead_zone(zone: float) -> void:
	dead_zone = clamp(zone, 0.0, 0.5)

func enable_haptic_feedback(enabled: bool) -> void:
	haptic_feedback = enabled

func enable_visual_feedback(enabled: bool) -> void:
	visual_feedback = enabled
	if not enabled:
		joystick_base.queue_redraw()
		joystick_knob.queue_redraw()

func _update_joystick_size() -> void:
	if joystick_base:
		joystick_base.custom_minimum_size = Vector2(joystick_radius * 2, joystick_radius * 2)
		joystick_base.offset_left = -joystick_radius
		joystick_base.offset_top = -joystick_radius
		joystick_base.offset_right = joystick_radius
		joystick_base.offset_bottom = joystick_radius
		center_position = joystick_base.size / 2

func get_joystick_stats() -> Dictionary:
	return {
		"is_active": is_active,
		"input_vector": input_vector,
		"touch_id": touch_id,
		"sanity_distortion": sanity_distortion,
		"act_modifier": act_modifier,
		"sensitivity": sensitivity,
		"dead_zone": dead_zone
	} 