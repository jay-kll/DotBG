extends Control

# Haptic Feedback Test Scene
# Comprehensive testing for enhanced haptic feedback system

# UI References
@onready var haptic_enabled_label: Label = $MainContainer/StatusPanel/StatusContainer/HapticEnabled
@onready var platform_support_label: Label = $MainContainer/StatusPanel/StatusContainer/PlatformSupport
@onready var current_intensity_label: Label = $MainContainer/StatusPanel/StatusContainer/CurrentIntensity
@onready var battery_saver_label: Label = $MainContainer/StatusPanel/StatusContainer/BatterySaver
@onready var sanity_corruption_label: Label = $MainContainer/StatusPanel/StatusContainer/SanityCorruption

@onready var enable_toggle: CheckBox = $MainContainer/ControlsPanel/ControlsContainer/LeftPanel/EnableToggle
@onready var intensity_slider: HSlider = $MainContainer/ControlsPanel/ControlsContainer/LeftPanel/IntensityContainer/IntensitySlider
@onready var intensity_value: Label = $MainContainer/ControlsPanel/ControlsContainer/LeftPanel/IntensityContainer/IntensityValue
@onready var sanity_slider: HSlider = $MainContainer/ControlsPanel/ControlsContainer/LeftPanel/SanityContainer/SanitySlider
@onready var sanity_value: Label = $MainContainer/ControlsPanel/ControlsContainer/LeftPanel/SanityContainer/SanityValue
@onready var battery_saver_toggle: CheckBox = $MainContainer/ControlsPanel/ControlsContainer/LeftPanel/BatterySaverToggle

@onready var stats_display: RichTextLabel = $MainContainer/StatsPanel/StatsContainer/StatsDisplay
@onready var refresh_stats_button: Button = $MainContainer/StatsPanel/StatsContainer/RefreshStats
@onready var update_timer: Timer = $UpdateTimer

# Gesture test buttons
@onready var tap_test: Button = $MainContainer/ControlsPanel/ControlsContainer/MiddlePanel/TapTest
@onready var double_tap_test: Button = $MainContainer/ControlsPanel/ControlsContainer/MiddlePanel/DoubleTapTest
@onready var hold_test: Button = $MainContainer/ControlsPanel/ControlsContainer/MiddlePanel/HoldTest
@onready var swipe_test: Button = $MainContainer/ControlsPanel/ControlsContainer/MiddlePanel/SwipeTest
@onready var pinch_test: Button = $MainContainer/ControlsPanel/ControlsContainer/MiddlePanel/PinchTest

# Combat test buttons
@onready var attack_test: Button = $MainContainer/ControlsPanel/ControlsContainer/RightPanel/AttackTest
@onready var dodge_test: Button = $MainContainer/ControlsPanel/ControlsContainer/RightPanel/DodgeTest
@onready var block_test: Button = $MainContainer/ControlsPanel/ControlsContainer/RightPanel/BlockTest
@onready var hit_taken_test: Button = $MainContainer/ControlsPanel/ControlsContainer/RightPanel/HitTakenTest
@onready var critical_hit_test: Button = $MainContainer/ControlsPanel/ControlsContainer/RightPanel/CriticalHitTest

# Sanity test buttons
@onready var phantom_test: Button = $MainContainer/SanityTestPanel/SanityContainer/PhantomTest
@onready var false_touch_test: Button = $MainContainer/SanityTestPanel/SanityContainer/FalseTouchTest
@onready var corrupted_test: Button = $MainContainer/SanityTestPanel/SanityContainer/CorruptedTest

# Test statistics
var test_count: int = 0
var last_test_time: float = 0.0
var feedback_history: Array[Dictionary] = []

func _ready() -> void:
	print("HapticFeedbackTest: Starting comprehensive haptic feedback testing")
	
	# Connect UI controls
	_connect_ui_signals()
	
	# Initialize UI state
	_initialize_ui_state()
	
	# Connect to InputManager for monitoring
	_connect_input_manager()
	
	# Start periodic updates
	update_timer.timeout.connect(_update_display)

func _connect_ui_signals() -> void:
	# Basic controls
	enable_toggle.toggled.connect(_on_haptic_enabled_toggled)
	intensity_slider.value_changed.connect(_on_intensity_changed)
	sanity_slider.value_changed.connect(_on_sanity_corruption_changed)
	battery_saver_toggle.toggled.connect(_on_battery_saver_toggled)
	
	# Gesture test buttons
	tap_test.pressed.connect(func(): _test_haptic_pattern("tap"))
	double_tap_test.pressed.connect(func(): _test_haptic_pattern("double_tap"))
	hold_test.pressed.connect(func(): _test_haptic_pattern("hold"))
	swipe_test.pressed.connect(func(): _test_haptic_pattern("swipe"))
	pinch_test.pressed.connect(func(): _test_haptic_pattern("pinch"))
	
	# Combat test buttons
	attack_test.pressed.connect(func(): _test_haptic_pattern("attack"))
	dodge_test.pressed.connect(func(): _test_haptic_pattern("dodge"))
	block_test.pressed.connect(func(): _test_haptic_pattern("block"))
	hit_taken_test.pressed.connect(func(): _test_haptic_pattern("hit_taken"))
	critical_hit_test.pressed.connect(func(): _test_haptic_pattern("critical_hit"))
	
	# Sanity test buttons
	phantom_test.pressed.connect(func(): _test_haptic_pattern("sanity_phantom_vibration"))
	false_touch_test.pressed.connect(func(): _test_haptic_pattern("sanity_false_touch"))
	corrupted_test.pressed.connect(func(): _test_haptic_pattern("sanity_corrupted_feedback"))
	
	# Statistics
	refresh_stats_button.pressed.connect(_refresh_statistics)

func _initialize_ui_state() -> void:
	# Set initial values from InputManager
	if InputManager:
		enable_toggle.button_pressed = InputManager.haptic_feedback_enabled
		intensity_slider.value = InputManager.haptic_intensity
		intensity_value.text = "%.1f" % InputManager.haptic_intensity
		sanity_value.text = "0.0"
	
	# Update display immediately
	_update_display()

func _connect_input_manager() -> void:
	# Connect to InputManager signals for real-time monitoring
	if InputManager:
		InputManager.haptic_settings_changed.connect(_on_haptic_settings_changed)
		print("HapticFeedbackTest: Connected to InputManager signals")

func _on_haptic_enabled_toggled(enabled: bool) -> void:
	if InputManager:
		InputManager.set_haptic_enabled(enabled)
		print("HapticFeedbackTest: Haptic feedback %s" % ("enabled" if enabled else "disabled"))

func _on_intensity_changed(value: float) -> void:
	intensity_value.text = "%.1f" % value
	if InputManager:
		InputManager.set_haptic_intensity(value)
		print("HapticFeedbackTest: Intensity set to %.1f" % value)

func _on_sanity_corruption_changed(value: float) -> void:
	sanity_value.text = "%.1f" % value
	if InputManager:
		InputManager.set_sanity_corruption_level(value)
		print("HapticFeedbackTest: Sanity corruption set to %.1f" % value)

func _on_battery_saver_toggled(enabled: bool) -> void:
	if InputManager:
		InputManager.enable_haptic_battery_saver(enabled)
		print("HapticFeedbackTest: Battery saver %s" % ("enabled" if enabled else "disabled"))

func _on_haptic_settings_changed(enabled: bool, intensity: float) -> void:
	# Update UI when settings change externally
	enable_toggle.button_pressed = enabled
	intensity_slider.value = intensity
	intensity_value.text = "%.1f" % intensity

func _test_haptic_pattern(pattern_name: String) -> void:
	if not InputManager:
		print("HapticFeedbackTest: ERROR - InputManager not available")
		return
	
	var current_time = Time.get_unix_time_from_system()
	test_count += 1
	
	# Log test
	var test_entry = {
		"pattern": pattern_name,
		"timestamp": current_time,
		"test_number": test_count,
		"intensity": InputManager.haptic_intensity,
		"sanity_corruption": sanity_slider.value
	}
	
	feedback_history.append(test_entry)
	
	# Trigger the haptic pattern
	InputManager.trigger_haptic_pattern(pattern_name)
	
	print("HapticFeedbackTest: Triggered pattern '%s' (test #%d)" % [pattern_name, test_count])
	last_test_time = current_time
	
	# Limit history size for performance
	if feedback_history.size() > 50:
		feedback_history = feedback_history.slice(-25)  # Keep last 25 entries

func _update_display() -> void:
	if not InputManager:
		_update_error_display()
		return
	
	# Get current statistics
	var stats = InputManager.get_input_statistics()
	
	# Update status labels
	haptic_enabled_label.text = "Haptic Enabled: %s" % ("YES" if stats.get("haptic_enabled", false) else "NO")
	platform_support_label.text = "Platform Support: %s" % ("YES" if stats.get("haptic_platform_support", false) else "NO")
	current_intensity_label.text = "Current Intensity: %.1f" % stats.get("haptic_intensity", 0.0)
	battery_saver_label.text = "Battery Saver: %s" % ("YES" if stats.get("haptic_battery_saver", false) else "NO")
	sanity_corruption_label.text = "Sanity Corruption: %.1f" % stats.get("haptic_sanity_corruption", 0.0)

func _update_error_display() -> void:
	# Display error state when InputManager not available
	haptic_enabled_label.text = "Haptic Enabled: ERROR"
	platform_support_label.text = "Platform Support: ERROR"
	current_intensity_label.text = "Current Intensity: ERROR"
	battery_saver_label.text = "Battery Saver: ERROR"
	sanity_corruption_label.text = "Sanity Corruption: ERROR"

func _refresh_statistics() -> void:
	if not InputManager:
		stats_display.text = "[color=red]ERROR: InputManager not available[/color]"
		return
	
	var stats = InputManager.get_input_statistics()
	var current_time = Time.get_unix_time_from_system()
	
	# Build comprehensive statistics display
	var stats_text = "[b]HAPTIC FEEDBACK SYSTEM STATISTICS[/b]\n\n"
	
	# System Status
	stats_text += "[b]System Status:[/b]\n"
	stats_text += "• Haptic Enabled: %s\n" % ("YES" if stats.get("haptic_enabled", false) else "NO")
	stats_text += "• Platform Support: %s\n" % ("YES" if stats.get("haptic_platform_support", false) else "NO")
	stats_text += "• Current Intensity: %.1f\n" % stats.get("haptic_intensity", 0.0)
	stats_text += "• Battery Saver: %s\n" % ("YES" if stats.get("haptic_battery_saver", false) else "NO")
	stats_text += "• Sanity Corruption: %.1f\n\n" % stats.get("haptic_sanity_corruption", 0.0)
	
	# Performance Metrics
	stats_text += "[b]Performance Metrics:[/b]\n"
	stats_text += "• Queue Size: %d\n" % stats.get("haptic_queue_size", 0)
	stats_text += "• Pattern Count: %d\n" % stats.get("haptic_pattern_count", 0)
	stats_text += "• Last Feedback: %.3fs ago\n" % (current_time - stats.get("haptic_last_feedback_time", current_time))
	
	# Test Statistics
	stats_text += "\n[b]Test Session Statistics:[/b]\n"
	stats_text += "• Total Tests: %d\n" % test_count
	if last_test_time > 0:
		stats_text += "• Last Test: %.1fs ago\n" % (current_time - last_test_time)
	stats_text += "• History Size: %d entries\n" % feedback_history.size()
	
	# Recent Test History
	if feedback_history.size() > 0:
		stats_text += "\n[b]Recent Tests (last 5):[/b]\n"
		var recent_tests = feedback_history.slice(-5)
		for i in range(recent_tests.size() - 1, -1, -1):  # Reverse order (newest first)
			var test = recent_tests[i]
			var time_ago = current_time - test.timestamp
			stats_text += "• #%d: %s (%.1fs ago)\n" % [test.test_number, test.pattern, time_ago]
	
	# Input System Statistics
	stats_text += "\n[b]Input System Integration:[/b]\n"
	stats_text += "• Active Touches: %d\n" % stats.get("active_touches", 0)
	stats_text += "• Touch Sensitivity: %.1f\n" % stats.get("touch_sensitivity", 1.0)
	stats_text += "• Gesture Threshold: %.1f pixels\n" % stats.get("gesture_threshold", 50.0)
	
	# Buffer Statistics
	if stats.has("buffer_size"):
		stats_text += "• Buffer Size: %d actions\n" % stats.get("buffer_size", 0)
		stats_text += "• Buffer Duration: %.1fs\n" % stats.get("buffer_duration", 0.2)
	
	stats_display.text = stats_text

func _input(event: InputEvent) -> void:
	# Handle escape key to return to main menu
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			print("HapticFeedbackTest: Returning to main menu")
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			# Clean up on exit
			print("HapticFeedbackTest: Test session ending - %d tests performed" % test_count)
			get_tree().quit()

# Debug function for manual testing
func debug_trigger_random_patterns() -> void:
	var patterns = ["tap", "hold", "swipe", "attack", "dodge", "critical_hit"]
	var random_pattern = patterns[randi() % patterns.size()]
	_test_haptic_pattern(random_pattern)

# Performance testing function
func stress_test_haptic_system(duration: float = 5.0) -> void:
	print("HapticFeedbackTest: Starting %ds stress test" % duration)
	var start_time = Time.get_unix_time_from_system()
	var stress_count = 0
	
	while Time.get_unix_time_from_system() - start_time < duration:
		debug_trigger_random_patterns()
		stress_count += 1
		await get_tree().process_frame
	
	print("HapticFeedbackTest: Stress test complete - %d patterns triggered" % stress_count) 