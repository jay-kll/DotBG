extends Node

# Minimal GameManager for testing autoload functionality

# Game state management for epic campaigns
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
	LOADING,
	SAVING
}

var current_game_state: GameState = GameState.MENU

func _ready() -> void:
	print("GameManager: Minimal version loaded successfully")

# Game state management
func change_game_state(new_state: GameState) -> void:
	if new_state == current_game_state:
		return
	
	var old_state = current_game_state
	current_game_state = new_state
	print("GameManager: State changed from ", old_state, " to ", new_state) 