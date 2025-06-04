extends Node

# Game States
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	DIALOG,
	GAME_OVER
}

# Current game state
var current_state: GameState = GameState.MENU

# Game progression
var current_act: int = 1
var current_level: int = 1
var discovered_areas: Array[String] = []
var defeated_bosses: Array[String] = []

# Player progression
var blood_echoes: int = 0
var void_shards: int = 0
var current_sanity: float = 100.0
var max_sanity: float = 100.0

# Signals
signal game_state_changed(new_state: GameState)
signal sanity_changed(new_value: float, max_value: float)
signal currency_changed(echoes: int, shards: int)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_game_state(new_state: GameState) -> void:
	current_state = new_state
	game_state_changed.emit(new_state)
	
	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
		GameState.PLAYING:
			get_tree().paused = false
		GameState.GAME_OVER:
			get_tree().paused = true
			# TODO: Show game over screen
		_:
			pass

func modify_sanity(amount: float) -> void:
	current_sanity = clamp(current_sanity + amount, 0, max_sanity)
	sanity_changed.emit(current_sanity, max_sanity)
	
	# TODO: Trigger sanity effects when below certain thresholds

func add_currency(echoes: int = 0, shards: int = 0) -> void:
	blood_echoes += echoes
	void_shards += shards
	currency_changed.emit(blood_echoes, void_shards)

func spend_currency(echoes: int = 0, shards: int = 0) -> bool:
	if blood_echoes >= echoes and void_shards >= shards:
		blood_echoes -= echoes
		void_shards -= shards
		currency_changed.emit(blood_echoes, void_shards)
		return true
	return false

func record_boss_defeat(boss_id: String) -> void:
	if not defeated_bosses.has(boss_id):
		defeated_bosses.append(boss_id)
		# TODO: Trigger any relevant progression events

func discover_area(area_id: String) -> void:
	if not discovered_areas.has(area_id):
		discovered_areas.append(area_id)
		# TODO: Update map and progression 