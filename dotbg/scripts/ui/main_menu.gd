extends Control

# Placeholder main menu for testing autoload systems
# Will be expanded for epic campaign later

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var test_button: Button = $VBoxContainer/TestButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

# Reference to loaded TouchSettingsUI
var touch_settings_ui: Control = null

func _ready() -> void:
	print("MainMenu: Epic campaign menu initialized")
	
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	test_button.pressed.connect(_on_test_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Test autoload systems
	_test_autoload_systems()

func _test_autoload_systems() -> void:
	print("MainMenu: Testing autoload systems...")
	
	# Test EventBus
	if EventBus:
		print("✓ EventBus loaded successfully")
	else:
		print("✗ EventBus failed to load")
	
	# Test GameManager
	if GameManager:
		print("✓ GameManager loaded successfully")
	else:
		print("✗ GameManager failed to load")
	
	# Test PlayerStats
	if PlayerStats:
		print("✓ PlayerStats loaded successfully")
	else:
		print("✗ PlayerStats failed to load")
	
	# Test SaveSystem
	if SaveSystem:
		print("✓ SaveSystem loaded successfully")
	else:
		print("✗ SaveSystem failed to load")
	
	# Test InputManager
	if InputManager:
		print("✓ InputManager loaded successfully")
		var stats = InputManager.get_input_statistics()
		print("  - Input stats: %s" % str(stats))
	else:
		print("✗ InputManager failed to load")
	
	# Test SanityManager
	if SanityManager:
		print("✓ SanityManager loaded successfully")
	else:
		print("✗ SanityManager failed to load")
	
	# Test HybridGenerator
	if HybridGenerator:
		print("✓ HybridGenerator loaded successfully")
	else:
		print("✗ HybridGenerator failed to load")

func _on_start_pressed() -> void:
	print("MainMenu: Start game pressed - TODO: Implement game start")
	# TODO: Load first game scene

func _on_options_pressed() -> void:
	print("MainMenu: Loading touch input settings...")
	_load_touch_settings()

func _load_touch_settings() -> void:
	# Load the TouchSettingsUI scene
	var touch_settings_scene = preload("res://scenes/ui/TouchSettingsUI.tscn")
	touch_settings_ui = touch_settings_scene.instantiate()
	
	# Connect the back signal to return to main menu
	touch_settings_ui.back_pressed.connect(_on_settings_back_pressed)
	
	# Add to scene tree and hide main menu
	add_child(touch_settings_ui)
	$VBoxContainer.visible = false
	
	print("MainMenu: Touch settings loaded successfully")

func _on_settings_back_pressed() -> void:
	print("MainMenu: Returning from touch settings...")
	
	# Remove touch settings UI and show main menu
	if touch_settings_ui:
		touch_settings_ui.queue_free()
		touch_settings_ui = null
	
	$VBoxContainer.visible = true
	print("MainMenu: Returned to main menu")

func _on_test_pressed() -> void:
	print("MainMenu: Loading multi-touch test suite...")
	get_tree().change_scene_to_file("res://scenes/tests/touch_test.tscn")

func _on_quit_pressed() -> void:
	print("MainMenu: Quit pressed")
	get_tree().quit() 
