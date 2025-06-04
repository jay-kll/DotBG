extends Node

@onready var main_menu = $UI/MainMenu
@onready var game_viewport = $GameViewport
@onready var new_game_button = $UI/MainMenu/CenterContainer/VBoxContainer/NewGame
@onready var load_game_button = $UI/MainMenu/CenterContainer/VBoxContainer/LoadGame
@onready var settings_button = $UI/MainMenu/CenterContainer/VBoxContainer/Settings
@onready var quit_button = $UI/MainMenu/CenterContainer/VBoxContainer/Quit

func _ready() -> void:
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Show main menu
	show_main_menu()

func _on_new_game_pressed() -> void:
	# TODO: Add class selection screen
	start_new_game()

func _on_load_game_pressed() -> void:
	# TODO: Show load game screen
	pass

func _on_settings_pressed() -> void:
	# TODO: Show settings screen
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

func show_main_menu() -> void:
	main_menu.show()
	game_viewport.hide()
	GameManager.change_game_state(GameManager.GameState.MENU)

func start_new_game() -> void:
	# Hide menu and show game
	main_menu.hide()
	game_viewport.show()
	
	# Reset game state
	GameManager.current_act = 1
	GameManager.current_level = 1
	GameManager.blood_echoes = 0
	GameManager.void_shards = 0
	GameManager.current_sanity = GameManager.max_sanity
	
	# Reset player stats
	PlayerStats.reset_stats()
	
	# Change game state to playing
	GameManager.change_game_state(GameManager.GameState.PLAYING)
	
	# TODO: Load first level
	# TODO: Show tutorial if first time playing 