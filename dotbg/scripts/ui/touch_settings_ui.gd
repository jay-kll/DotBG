# TouchSettingsUI.gd
# Simple touch settings interface for the epic mobile campaign
# Provides user-friendly interface to configure InputManager basic settings
extends Control

# UI Node references - matching actual scene structure
var main_container: VBoxContainer
var touch_sensitivity_slider: HSlider
var touch_sensitivity_label: Label
var tap_sensitivity_slider: HSlider
var tap_sensitivity_label: Label
var swipe_sensitivity_slider: HSlider
var swipe_sensitivity_label: Label
var drag_sensitivity_slider: HSlider
var drag_sensitivity_label: Label

# Threshold controls
var swipe_distance_slider: HSlider
var swipe_distance_label: Label
var tap_distance_slider: HSlider
var tap_distance_label: Label

# Additional controls (if they exist)
var haptic_enabled_toggle: CheckBox
var haptic_intensity_slider: HSlider
var haptic_intensity_label: Label

# Buttons (if they exist)
var reset_button: Button
var save_button: Button
var back_button: Button

signal settings_changed
signal back_pressed

func _ready() -> void:
	if not InputManager:
		push_error("TouchSettingsUI: InputManager not available")
		return
	
	_get_ui_nodes()
	_setup_controls()
	_load_current_settings()

func _get_ui_nodes() -> void:
	# Get main container
	main_container = get_node_or_null("MainContainer")
	if not main_container:
		push_error("TouchSettingsUI: MainContainer not found")
		return
	
	# Get sensitivity controls based on actual scene structure
	touch_sensitivity_slider = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/SensitivityContainer/TouchSensitivity/Slider")
	touch_sensitivity_label = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/SensitivityContainer/TouchSensitivity/ValueLabel")
	
	tap_sensitivity_slider = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/SensitivityContainer/TapSensitivity/Slider")
	tap_sensitivity_label = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/SensitivityContainer/TapSensitivity/ValueLabel")
	
	swipe_sensitivity_slider = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/SensitivityContainer/SwipeSensitivity/Slider")
	swipe_sensitivity_label = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/SensitivityContainer/SwipeSensitivity/ValueLabel")
	
	drag_sensitivity_slider = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/SensitivityContainer/DragSensitivity/Slider")
	drag_sensitivity_label = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/SensitivityContainer/DragSensitivity/ValueLabel")
	
	# Get threshold controls
	swipe_distance_slider = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/ThresholdContainer/SwipeDistance/Slider")
	swipe_distance_label = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/ThresholdContainer/SwipeDistance/ValueLabel")
	
	tap_distance_slider = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/ThresholdContainer/TapDistance/Slider")
	tap_distance_label = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/ThresholdContainer/TapDistance/ValueLabel")
	
	# Get haptic controls (these might not exist in the current scene)
	haptic_enabled_toggle = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/HapticContainer/HapticEnabled/Toggle")
	haptic_intensity_slider = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/HapticContainer/HapticIntensity/Slider")
	haptic_intensity_label = get_node_or_null("MainContainer/ScrollContainer/VBoxContainer/HapticContainer/HapticIntensity/ValueLabel")
	
	# Get buttons (these might not exist in the current scene)
	reset_button = get_node_or_null("MainContainer/ButtonContainer/ResetButton")
	save_button = get_node_or_null("MainContainer/ButtonContainer/SaveButton")
	back_button = get_node_or_null("MainContainer/ButtonContainer/BackButton")

func _setup_controls() -> void:
	# Setup touch sensitivity
	if touch_sensitivity_slider:
		touch_sensitivity_slider.value_changed.connect(_on_touch_sensitivity_changed)
	
	if tap_sensitivity_slider:
		tap_sensitivity_slider.value_changed.connect(_on_tap_sensitivity_changed)
	
	if swipe_sensitivity_slider:
		swipe_sensitivity_slider.value_changed.connect(_on_swipe_sensitivity_changed)
	
	if drag_sensitivity_slider:
		drag_sensitivity_slider.value_changed.connect(_on_drag_sensitivity_changed)
	
	# Setup threshold controls
	if swipe_distance_slider:
		swipe_distance_slider.value_changed.connect(_on_swipe_distance_changed)
	
	if tap_distance_slider:
		tap_distance_slider.value_changed.connect(_on_tap_distance_changed)
	
	# Setup haptic controls (if they exist)
	if haptic_enabled_toggle:
		haptic_enabled_toggle.toggled.connect(_on_haptic_enabled_toggled)
	
	if haptic_intensity_slider:
		haptic_intensity_slider.value_changed.connect(_on_haptic_intensity_changed)
	
	# Connect buttons (if they exist)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	
	if save_button:
		save_button.pressed.connect(_on_save_pressed)
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _load_current_settings() -> void:
	# Load from InputManager with safe node checks
	if touch_sensitivity_slider:
		touch_sensitivity_slider.value = InputManager.touch_sensitivity
	
	if tap_sensitivity_slider:
		tap_sensitivity_slider.value = InputManager.touch_sensitivity
	
	if swipe_sensitivity_slider:
		swipe_sensitivity_slider.value = InputManager.touch_sensitivity
	
	if drag_sensitivity_slider:
		drag_sensitivity_slider.value = InputManager.touch_sensitivity
	
	if swipe_distance_slider:
		swipe_distance_slider.value = InputManager.gesture_threshold
	
	if tap_distance_slider:
		tap_distance_slider.value = InputManager.gesture_threshold
	
	if haptic_enabled_toggle:
		haptic_enabled_toggle.button_pressed = InputManager.haptic_feedback_enabled
	
	if haptic_intensity_slider:
		haptic_intensity_slider.value = InputManager.haptic_intensity
	
	_update_labels()

func _update_labels() -> void:
	if touch_sensitivity_label and touch_sensitivity_slider:
		touch_sensitivity_label.text = "%.1f" % touch_sensitivity_slider.value
	
	if tap_sensitivity_label and tap_sensitivity_slider:
		tap_sensitivity_label.text = "%.1f" % tap_sensitivity_slider.value
	
	if swipe_sensitivity_label and swipe_sensitivity_slider:
		swipe_sensitivity_label.text = "%.1f" % swipe_sensitivity_slider.value
	
	if drag_sensitivity_label and drag_sensitivity_slider:
		drag_sensitivity_label.text = "%.1f" % drag_sensitivity_slider.value
	
	if swipe_distance_label and swipe_distance_slider:
		swipe_distance_label.text = "%.0fpx" % swipe_distance_slider.value
	
	if tap_distance_label and tap_distance_slider:
		tap_distance_label.text = "%.0fpx" % tap_distance_slider.value
	
	if haptic_intensity_label and haptic_intensity_slider:
		haptic_intensity_label.text = "%.1f" % haptic_intensity_slider.value

# Sensitivity change handlers
func _on_touch_sensitivity_changed(value: float) -> void:
	if touch_sensitivity_label:
		touch_sensitivity_label.text = "%.1f" % value
	InputManager.set_touch_sensitivity(value)
	settings_changed.emit()

func _on_tap_sensitivity_changed(value: float) -> void:
	if tap_sensitivity_label:
		tap_sensitivity_label.text = "%.1f" % value
	InputManager.set_touch_sensitivity(value)  # Use same setting for all touch types
	settings_changed.emit()

func _on_swipe_sensitivity_changed(value: float) -> void:
	if swipe_sensitivity_label:
		swipe_sensitivity_label.text = "%.1f" % value
	InputManager.set_touch_sensitivity(value)  # Use same setting for all touch types
	settings_changed.emit()

func _on_drag_sensitivity_changed(value: float) -> void:
	if drag_sensitivity_label:
		drag_sensitivity_label.text = "%.1f" % value
	InputManager.set_touch_sensitivity(value)  # Use same setting for all touch types
	settings_changed.emit()

# Threshold change handlers
func _on_swipe_distance_changed(value: float) -> void:
	if swipe_distance_label:
		swipe_distance_label.text = "%.0fpx" % value
	InputManager.set_gesture_threshold(value)
	settings_changed.emit()

func _on_tap_distance_changed(value: float) -> void:
	if tap_distance_label:
		tap_distance_label.text = "%.0fpx" % value
	InputManager.set_gesture_threshold(value)  # Use same setting for all gesture types
	settings_changed.emit()

# Haptic handlers (if controls exist)
func _on_haptic_enabled_toggled(enabled: bool) -> void:
	InputManager.set_haptic_enabled(enabled)
	if haptic_intensity_slider:
		haptic_intensity_slider.editable = enabled
	settings_changed.emit()

func _on_haptic_intensity_changed(value: float) -> void:
	if haptic_intensity_label:
		haptic_intensity_label.text = "%.1f" % value
	InputManager.set_haptic_intensity(value)
	settings_changed.emit()

# Button handlers (if buttons exist)
func _on_reset_pressed() -> void:
	# Reset to defaults with safe node checks
	if touch_sensitivity_slider:
		touch_sensitivity_slider.value = 1.0
	if tap_sensitivity_slider:
		tap_sensitivity_slider.value = 1.0
	if swipe_sensitivity_slider:
		swipe_sensitivity_slider.value = 1.0
	if drag_sensitivity_slider:
		drag_sensitivity_slider.value = 1.0
	
	if swipe_distance_slider:
		swipe_distance_slider.value = 100.0
	if tap_distance_slider:
		tap_distance_slider.value = 50.0
	
	if haptic_enabled_toggle:
		haptic_enabled_toggle.button_pressed = true
	if haptic_intensity_slider:
		haptic_intensity_slider.value = 1.0
	
	# Apply to InputManager
	InputManager.set_touch_sensitivity(1.0)
	InputManager.set_gesture_threshold(100.0)
	InputManager.set_haptic_enabled(true)
	InputManager.set_haptic_intensity(1.0)
	
	_update_labels()
	settings_changed.emit()

func _on_save_pressed() -> void:
	# Settings are automatically applied, this could save to file
	print("TouchSettingsUI: Settings saved")

func _on_back_pressed() -> void:
	back_pressed.emit() 
