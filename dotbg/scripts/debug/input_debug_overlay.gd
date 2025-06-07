# InputDebugOverlay.gd
# Comprehensive debug tools for epic mobile touch input system
# Provides real-time visualization and monitoring for 50+ hour campaigns
extends CanvasLayer

# Debug visualization components
var debug_panel: Control
var touch_visualizer: Control
var performance_monitor: Control
var gesture_log: Control
var system_status: Control

# Touch visualization
var active_touch_indicators: Dictionary = {}
var touch_trail_points: Dictionary = {}
var max_trail_points: int = 50

# Performance tracking
var frame_times: Array[float] = []
var input_latencies: Array[float] = []
var max_performance_samples: int = 60

# Debug settings
var show_touch_points: bool = true
var show_touch_trails: bool = true
var show_gesture_zones: bool = true
var show_performance_stats: bool = true
var show_system_status: bool = true
var show_event_log: bool = true

# Colors for epic visual debugging
var touch_color: Color = Color.CYAN
var trail_color: Color = Color.YELLOW
var gesture_zone_color: Color = Color.GREEN
var error_color: Color = Color.RED
var warning_color: Color = Color.ORANGE

# Event logging
var event_log: Array[Dictionary] = []
var max_log_entries: int = 100

# UI References
var toggle_button: Button
var settings_panel: Control
var stats_labels: Dictionary = {}

signal debug_settings_changed

func _ready() -> void:
	# Set up debug overlay layer
	layer = 100  # Top layer for debug overlay
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create debug UI
	_create_debug_ui()
	
	# Connect to InputManager if available
	_connect_input_manager()
	
	# Start performance monitoring
	_start_performance_monitoring()
	
	print("InputDebugOverlay: Epic debug tools initialized")

func _create_debug_ui() -> void:
	# Main debug panel
	debug_panel = Control.new()
	debug_panel.name = "DebugPanel"
	debug_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	debug_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(debug_panel)
	
	# Touch visualizer (for drawing touch points and trails)
	touch_visualizer = Control.new()
	touch_visualizer.name = "TouchVisualizer"
	touch_visualizer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	touch_visualizer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_visualizer.draw.connect(_draw_touch_visualization)
	debug_panel.add_child(touch_visualizer)
	
	# Performance monitor panel
	_create_performance_monitor()
	
	# Gesture log panel
	_create_gesture_log()
	
	# System status panel
	_create_system_status()
	
	# Debug toggle button
	_create_toggle_button()
	
	# Settings panel
	_create_settings_panel()

func _create_performance_monitor() -> void:
	performance_monitor = Panel.new()
	performance_monitor.name = "PerformanceMonitor"
	performance_monitor.position = Vector2(10, 10)
	performance_monitor.size = Vector2(300, 200)
	performance_monitor.modulate = Color(1, 1, 1, 0.8)
	debug_panel.add_child(performance_monitor)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 2)
	performance_monitor.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "PERFORMANCE MONITOR"
	title.add_theme_color_override("font_color", Color.CYAN)
	vbox.add_child(title)
	
	# Performance stats
	var stats = [
		"fps", "input_latency", "touch_events", "gesture_events",
		"memory_usage", "active_touches", "buffered_actions"
	]
	
	for stat in stats:
		var label = Label.new()
		label.name = stat + "_label"
		label.text = stat.capitalize() + ": 0"
		stats_labels[stat] = label
		vbox.add_child(label)

func _create_gesture_log() -> void:
	gesture_log = Panel.new()
	gesture_log.name = "GestureLog"
	gesture_log.position = Vector2(320, 10)
	gesture_log.size = Vector2(300, 400)
	gesture_log.modulate = Color(1, 1, 1, 0.8)
	debug_panel.add_child(gesture_log)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gesture_log.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "EVENT LOG"
	title.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(title)
	
	# Scrollable log area
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	var log_container = VBoxContainer.new()
	log_container.name = "LogContainer"
	log_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(log_container)

func _create_system_status() -> void:
	system_status = Panel.new()
	system_status.name = "SystemStatus"
	system_status.position = Vector2(630, 10)
	system_status.size = Vector2(250, 300)
	system_status.modulate = Color(1, 1, 1, 0.8)
	debug_panel.add_child(system_status)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	system_status.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "SYSTEM STATUS"
	title.add_theme_color_override("font_color", Color.GREEN)
	vbox.add_child(title)
	
	# System status indicators
	var systems = [
		"input_manager", "gesture_detector", "input_buffer", 
		"haptic_controller", "event_propagation", "sanity_manager"
	]
	
	for system in systems:
		var label = Label.new()
		label.name = system + "_status"
		label.text = system.capitalize() + ": Unknown"
		stats_labels[system + "_status"] = label
		vbox.add_child(label)

func _create_toggle_button() -> void:
	toggle_button = Button.new()
	toggle_button.text = "DEBUG"
	toggle_button.position = Vector2(10, get_viewport().size.y - 50)
	toggle_button.size = Vector2(80, 40)
	toggle_button.pressed.connect(_toggle_debug_overlay)
	add_child(toggle_button)

func _create_settings_panel() -> void:
	settings_panel = Panel.new()
	settings_panel.name = "SettingsPanel"
	settings_panel.position = Vector2(890, 10)
	settings_panel.size = Vector2(200, 400)
	settings_panel.modulate = Color(1, 1, 1, 0.8)
	settings_panel.visible = false
	debug_panel.add_child(settings_panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "DEBUG SETTINGS"
	title.add_theme_color_override("font_color", Color.MAGENTA)
	vbox.add_child(title)
	
	# Debug toggles
	var toggles = [
		{"name": "show_touch_points", "text": "Touch Points"},
		{"name": "show_touch_trails", "text": "Touch Trails"},
		{"name": "show_gesture_zones", "text": "Gesture Zones"},
		{"name": "show_performance_stats", "text": "Performance"},
		{"name": "show_system_status", "text": "System Status"},
		{"name": "show_event_log", "text": "Event Log"}
	]
	
	for toggle_data in toggles:
		var checkbox = CheckBox.new()
		checkbox.text = toggle_data.text
		checkbox.button_pressed = get(toggle_data.name)
		checkbox.toggled.connect(_on_debug_setting_toggled.bind(toggle_data.name))
		vbox.add_child(checkbox)

func _connect_input_manager() -> void:
	if not InputManager:
		push_warning("InputDebugOverlay: InputManager not available")
		return
	
	# Connect to InputManager signals
	InputManager.touch_started.connect(_on_touch_started)
	InputManager.touch_moved.connect(_on_touch_moved)
	InputManager.touch_ended.connect(_on_touch_ended)
	InputManager.gesture_detected.connect(_on_gesture_detected)
	
	# Register as event target for propagation system
	if InputManager.has_method("register_ui_event_target"):
		InputManager.register_ui_event_target(self)

func _start_performance_monitoring() -> void:
	# Start performance monitoring timer
	var timer = Timer.new()
	timer.wait_time = 0.1  # Update 10 times per second
	timer.timeout.connect(_update_performance_stats)
	timer.autostart = true
	add_child(timer)

func _process(_delta: float) -> void:
	# Update touch visualizer
	if touch_visualizer and (show_touch_points or show_touch_trails):
		touch_visualizer.queue_redraw()
	
	# Update panel visibility
	_update_panel_visibility()

func _update_panel_visibility() -> void:
	if performance_monitor:
		performance_monitor.visible = show_performance_stats
	if gesture_log:
		gesture_log.visible = show_event_log
	if system_status:
		system_status.visible = show_system_status

func _draw_touch_visualization() -> void:
	if not touch_visualizer:
		return
	
	# Draw active touch points
	if show_touch_points:
		for touch_id in active_touch_indicators:
			var touch_data = active_touch_indicators[touch_id]
			_draw_touch_point(touch_data.position, touch_color, 20.0)
	
	# Draw touch trails
	if show_touch_trails:
		for touch_id in touch_trail_points:
			var trail = touch_trail_points[touch_id]
			_draw_touch_trail(trail, trail_color)
	
	# Draw gesture zones (if applicable)
	if show_gesture_zones and InputManager:
		_draw_gesture_zones()

func _draw_touch_point(position: Vector2, color: Color, radius: float) -> void:
	# Draw touch point with pulsing effect
	var pulse = sin(Time.get_time_dict_from_system().second * 5.0) * 0.3 + 0.7
	touch_visualizer.draw_circle(position, radius * pulse, color)
	touch_visualizer.draw_arc(position, radius + 5, 0, TAU, 32, Color.WHITE, 2.0)

func _draw_touch_trail(trail_points: Array, color: Color) -> void:
	if trail_points.size() < 2:
		return
	
	# Draw trail with fading effect
	for i in range(trail_points.size() - 1):
		var alpha = float(i) / float(trail_points.size())
		var trail_color = Color(color.r, color.g, color.b, alpha * 0.8)
		var thickness = 3.0 * alpha
		touch_visualizer.draw_line(trail_points[i], trail_points[i + 1], trail_color, thickness)

func _draw_gesture_zones() -> void:
	# Draw gesture detection zones (example implementation)
	var viewport_size = get_viewport().size
	var zone_color = Color(gesture_zone_color.r, gesture_zone_color.g, gesture_zone_color.b, 0.2)
	
	# Draw swipe zones
	touch_visualizer.draw_rect(Rect2(0, 0, viewport_size.x, 100), zone_color)  # Top swipe zone
	touch_visualizer.draw_rect(Rect2(0, viewport_size.y - 100, viewport_size.x, 100), zone_color)  # Bottom swipe zone

func _update_performance_stats() -> void:
	if not show_performance_stats:
		return
	
	# Update FPS
	if stats_labels.has("fps"):
		stats_labels.fps.text = "FPS: %d" % Engine.get_frames_per_second()
	
	# Update input latency (if available)
	if stats_labels.has("input_latency") and InputManager:
		var latency = _calculate_average_latency()
		stats_labels.input_latency.text = "Input Latency: %.1fms" % latency
	
	# Update touch events count
	if stats_labels.has("touch_events"):
		stats_labels.touch_events.text = "Touch Events: %d" % active_touch_indicators.size()
	
	# Update memory usage
	if stats_labels.has("memory_usage"):
		var memory_mb = OS.get_static_memory_usage() / 1024 / 1024
		stats_labels.memory_usage.text = "Memory: %dMB" % memory_mb
	
	# Update system status
	_update_system_status()

func _update_system_status() -> void:
	var systems = {
		"input_manager": InputManager != null,
		"gesture_detector": InputManager and InputManager.gesture_detector != null,
		"input_buffer": InputManager and InputManager.input_buffer != null,
		"haptic_controller": InputManager and InputManager.haptic_controller != null,
		"event_propagation": InputManager and InputManager.event_propagation != null,
		"sanity_manager": get_node_or_null("/root/SanityManager") != null
	}
	
	for system_name in systems:
		var status_key = system_name + "_status"
		if stats_labels.has(status_key):
			var status = "✅ ACTIVE" if systems[system_name] else "❌ INACTIVE"
			var color = Color.GREEN if systems[system_name] else Color.RED
			stats_labels[status_key].text = system_name.capitalize() + ": " + status
			stats_labels[status_key].add_theme_color_override("font_color", color)

func _calculate_average_latency() -> float:
	if input_latencies.is_empty():
		return 0.0
	
	var total = 0.0
	for latency in input_latencies:
		total += latency
	
	return total / input_latencies.size()

func _log_event(event_type: String, data: Dictionary) -> void:
	var timestamp = Time.get_time_string_from_system()
	var log_entry = {
		"timestamp": timestamp,
		"type": event_type,
		"data": data
	}
	
	event_log.append(log_entry)
	
	# Limit log size for memory management
	if event_log.size() > max_log_entries:
		event_log.pop_front()
	
	# Update log display
	_update_log_display(log_entry)

func _update_log_display(log_entry: Dictionary) -> void:
	if not gesture_log or not show_event_log:
		return
	
	var log_container = gesture_log.get_node_or_null("VBoxContainer/ScrollContainer/LogContainer")
	if not log_container:
		return
	
	# Create log entry label
	var label = Label.new()
	var color = _get_event_color(log_entry.type)
	label.text = "[%s] %s" % [log_entry.timestamp, log_entry.type]
	label.add_theme_color_override("font_color", color)
	log_container.add_child(label)
	
	# Limit displayed entries
	if log_container.get_child_count() > max_log_entries / 2:
		log_container.get_child(0).queue_free()

func _get_event_color(event_type: String) -> Color:
	match event_type:
		"touch_started", "touch_ended":
			return Color.CYAN
		"gesture_detected":
			return Color.YELLOW
		"error":
			return Color.RED
		"warning":
			return Color.ORANGE
		_:
			return Color.WHITE

# Event handlers
func _on_touch_started(touch_data) -> void:
	active_touch_indicators[touch_data.id] = touch_data
	touch_trail_points[touch_data.id] = [touch_data.position]
	
	_log_event("touch_started", {
		"id": touch_data.id,
		"position": touch_data.position,
		"pressure": touch_data.pressure
	})

func _on_touch_moved(touch_data) -> void:
	active_touch_indicators[touch_data.id] = touch_data
	
	# Update trail
	if touch_trail_points.has(touch_data.id):
		var trail = touch_trail_points[touch_data.id]
		trail.append(touch_data.position)
		
		# Limit trail length
		if trail.size() > max_trail_points:
			trail.pop_front()

func _on_touch_ended(touch_data) -> void:
	active_touch_indicators.erase(touch_data.id)
	
	# Keep trail for a moment then fade
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.timeout.connect(_clear_trail.bind(touch_data.id))
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
	_log_event("touch_ended", {
		"id": touch_data.id,
		"position": touch_data.position,
		"duration": Time.get_unix_time_from_system() - touch_data.start_time
	})

func _on_gesture_detected(gesture_type: String, gesture_data: Dictionary) -> void:
	_log_event("gesture_detected", {
		"type": gesture_type,
		"data": gesture_data
	})

func _clear_trail(touch_id: int) -> void:
	touch_trail_points.erase(touch_id)

func _toggle_debug_overlay() -> void:
	debug_panel.visible = not debug_panel.visible
	settings_panel.visible = debug_panel.visible

func _on_debug_setting_toggled(setting_name: String, enabled: bool) -> void:
	set(setting_name, enabled)
	debug_settings_changed.emit()

# Public API for external systems
func log_custom_event(event_type: String, data: Dictionary) -> void:
	_log_event(event_type, data)

func add_performance_sample(sample_type: String, value: float) -> void:
	match sample_type:
		"input_latency":
			input_latencies.append(value)
			if input_latencies.size() > max_performance_samples:
				input_latencies.pop_front()

func get_debug_stats() -> Dictionary:
	return {
		"active_touches": active_touch_indicators.size(),
		"trail_points": touch_trail_points.size(),
		"log_entries": event_log.size(),
		"average_latency": _calculate_average_latency(),
		"fps": Engine.get_frames_per_second()
	}

# Touch event handling for event propagation system
func handle_touch_event(event_type: String, event_data: Dictionary) -> bool:
	# Debug overlay handles all events for monitoring but doesn't consume them
	_log_event("propagated_" + event_type, event_data)
	return false  # Don't consume events, just monitor them 