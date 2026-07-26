extends Node

# Campaign and run state.
#
# Ownership boundary: sanity belongs to SanityManager, player stats to
# PlayerStats. This node holds progression, currency and the game state
# machine only — it does not duplicate either.

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
	LOADING,
	SAVING
}

# CANON.md §8 — v1.0 ships Act I only. This is the current gameplay entry point;
# it is a test space, not the real Act I level.
const FIRST_GAMEPLAY_SCENE := "res://scenes/test_3d_complete.tscn"

var current_game_state: GameState = GameState.MENU

# Campaign progression (CANON.md §2)
var current_act: int = 1
var current_level: int = 1

# Currencies (CANON.md §3). Void Shards are secondary and unused in v1.0.
var blood_echoes: int = 0
var void_shards: int = 0

signal game_state_changed(old_state: GameState, new_state: GameState)
signal new_game_started()

func _ready() -> void:
	print("GameManager: loaded")

func change_game_state(new_state: GameState) -> void:
	if new_state == current_game_state:
		return

	var old_state := current_game_state
	current_game_state = new_state
	game_state_changed.emit(old_state, new_state)
	print("GameManager: state %s -> %s" % [
		GameState.keys()[old_state],
		GameState.keys()[new_state]
	])

# Resets everything a fresh run owns. Delegates to the systems that own their
# own state rather than reaching into them.
func reset_run_state() -> void:
	current_act = 1
	current_level = 1
	blood_echoes = 0
	void_shards = 0
	PlayerStats.reset_stats()
	SanityManager.reset_sanity_system()
	print("GameManager: run state reset")

# Returns false if the gameplay scene could not be loaded, leaving the caller on
# the menu. Callers must check — silently failing to start is how this project
# shipped a menu whose start button did nothing.
func start_new_game() -> bool:
	reset_run_state()
	change_game_state(GameState.LOADING)

	var err := get_tree().change_scene_to_file(FIRST_GAMEPLAY_SCENE)
	if err != OK:
		push_error("GameManager: could not load %s (error %d)" % [FIRST_GAMEPLAY_SCENE, err])
		change_game_state(GameState.MENU)
		return false

	change_game_state(GameState.PLAYING)
	new_game_started.emit()
	return true
