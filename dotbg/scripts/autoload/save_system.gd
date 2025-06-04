extends Node

const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".save"
var current_save_slot: int = 1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_save_directory()
	
	# Connect to save/load requests
	EventBus.save_game_requested.connect(save_game)
	EventBus.load_game_requested.connect(load_game)

func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)

func get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_" + str(slot) + SAVE_EXTENSION

func save_game(slot: int = current_save_slot) -> void:
	var save_path = get_save_path(slot)
	var save_data = {
		"timestamp": Time.get_unix_time_from_system(),
		"version": ProjectSettings.get_setting("application/config/version", "1.0.0"),
		
		# Game State - TODO: Add these properties to GameManager
		# "current_act": GameManager.current_act,
		# "current_level": GameManager.current_level,
		# "discovered_areas": GameManager.discovered_areas,
		# "defeated_bosses": GameManager.defeated_bosses,
		# "blood_echoes": GameManager.blood_echoes,
		# "void_shards": GameManager.void_shards,
		# "current_sanity": GameManager.current_sanity,
		# "max_sanity": GameManager.max_sanity,
		"current_act": 1,  # Placeholder
		"current_level": "tutorial",  # Placeholder
		"discovered_areas": [],  # Placeholder
		"defeated_bosses": [],  # Placeholder
		"blood_echoes": 0,  # Placeholder
		"void_shards": 0,  # Placeholder
		"current_sanity": 100.0,  # Placeholder
		"max_sanity": 100.0,  # Placeholder
		
		# Player Stats
		"player_class": PlayerStats.player_class,
		"level": PlayerStats.level,
		"experience": PlayerStats.experience,
		"experience_required": PlayerStats.experience_required,
		"max_health": PlayerStats.max_health,
		"current_health": PlayerStats.current_health,
		"attack_power": PlayerStats.attack_power,
		"defense": PlayerStats.defense,
		"base_speed": PlayerStats.base_speed,
		"current_speed": PlayerStats.current_speed,
		"active_mutations": PlayerStats.active_mutations,
		"equipped_weapon": PlayerStats.equipped_weapon,
		"equipped_armor": PlayerStats.equipped_armor,
		"equipped_artifacts": PlayerStats.equipped_artifacts
	}
	
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	if save_file == null:
		push_error("Could not open save file: " + save_path)
		return
		
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)

func load_game(slot: int = current_save_slot) -> bool:
	var save_path = get_save_path(slot)
	if not FileAccess.file_exists(save_path):
		push_error("Save file does not exist: " + save_path)
		return false
	
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	if save_file == null:
		push_error("Could not open save file: " + save_path)
		return false
	
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Could not parse save file")
		return false
	
	var save_data = json.get_data()
	
	# Load Game State
	# GameManager.current_act = save_data.current_act
	# GameManager.current_level = save_data.current_level
	# GameManager.discovered_areas = save_data.discovered_areas
	# GameManager.defeated_bosses = save_data.defeated_bosses
	# GameManager.blood_echoes = save_data.blood_echoes
	# GameManager.void_shards = save_data.void_shards
	# GameManager.current_sanity = save_data.current_sanity
	# GameManager.max_sanity = save_data.max_sanity
	
	# Load Player Stats
	PlayerStats.player_class = save_data.player_class
	PlayerStats.level = save_data.level
	PlayerStats.experience = save_data.experience
	PlayerStats.experience_required = save_data.experience_required
	PlayerStats.max_health = save_data.max_health
	PlayerStats.current_health = save_data.current_health
	PlayerStats.attack_power = save_data.attack_power
	PlayerStats.defense = save_data.defense
	PlayerStats.base_speed = save_data.get("base_speed", PlayerStats.base_speed)
	PlayerStats.current_speed = save_data.get("current_speed", PlayerStats.current_speed)
	PlayerStats.active_mutations = save_data.active_mutations
	PlayerStats.equipped_weapon = save_data.equipped_weapon
	PlayerStats.equipped_armor = save_data.equipped_armor
	PlayerStats.equipped_artifacts = save_data.equipped_artifacts
	
	return true

func get_save_info(slot: int) -> Dictionary:
	var save_path = get_save_path(slot)
	if not FileAccess.file_exists(save_path):
		return {}
	
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	if save_file == null:
		return {}
	
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return {}
	
	var save_data = json.get_data()
	return {
		"timestamp": save_data.timestamp,
		"version": save_data.version,
		"player_level": save_data.level,
		"current_act": save_data.current_act,
		"play_time": "TODO" # TODO: Add play time tracking
	}

func delete_save(slot: int) -> bool:
	var save_path = get_save_path(slot)
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open(SAVE_DIR)
		if dir != null:
			return dir.remove(save_path.get_file()) == OK
	return false

func get_all_save_slots() -> Array:
	var saves = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir != null:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(SAVE_EXTENSION):
				var slot = file_name.trim_suffix(SAVE_EXTENSION).trim_prefix("save_")
				if slot.is_valid_int():
					saves.append(int(slot))
			file_name = dir.get_next()
	return saves 