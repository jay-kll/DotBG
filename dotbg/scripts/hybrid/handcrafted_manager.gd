extends Node

# Manages handcrafted foundation templates for hybrid generation
# Base world elements = Handcrafted foundations

# Template storage
var loaded_templates: Dictionary = {}
var template_cache: Dictionary = {}

# Template categories for epic campaign
var template_categories: Dictionary = {
	"dungeon": "res://data/templates/dungeons/",
	"room": "res://data/templates/rooms/",
	"enemy": "res://data/templates/enemies/",
	"item": "res://data/templates/items/",
	"lore": "res://data/templates/lore/",
	"area": "res://data/templates/areas/"
}

# Mobile optimization
var max_cache_size: int = 50
var cache_enabled: bool = true

func _ready() -> void:
	print("HandcraftedManager: Initialized for epic hybrid generation")

func load_template(template_id: String, content_type: String) -> Dictionary:
	# Load handcrafted foundation template
	var cache_key = content_type + "_" + template_id
	
	# Check cache first
	if cache_enabled and template_cache.has(cache_key):
		return template_cache[cache_key].duplicate(true)
	
	# Load from file system
	var template_path = _get_template_path(content_type, template_id)
	var template_data = _load_template_file(template_path)
	
	if not template_data.is_empty():
		# Cache for performance
		if cache_enabled:
			_cache_template(cache_key, template_data)
	
	return template_data

func _get_template_path(content_type: String, template_id: String) -> String:
	var base_path = template_categories.get(content_type, "res://data/templates/")
	return base_path + template_id + ".json"

func _load_template_file(path: String) -> Dictionary:
	# For now, return placeholder data
	# In full implementation, this would load from JSON files
	return _get_placeholder_template(path)

func _get_placeholder_template(path: String) -> Dictionary:
	# Placeholder templates for development
	if "dungeon" in path:
		return _get_dungeon_template()
	elif "room" in path:
		return _get_room_template()
	elif "enemy" in path:
		return _get_enemy_template()
	elif "item" in path:
		return _get_item_template()
	else:
		return {}

func _get_dungeon_template() -> Dictionary:
	return {
		"type": "dungeon",
		"layout": {
			"width": 20,
			"height": 20,
			"room_count": 8,
			"connection_style": "branching"
		},
		"theme": "corrupted_city",
		"difficulty_base": 1.0,
		"room_templates": ["entrance", "corridor", "chamber", "boss_room"],
		"required_rooms": ["entrance", "boss_room"],
		"optional_rooms": ["treasure", "shrine", "secret"],
		"environmental_hazards": ["corruption_pools", "unstable_floors"],
		"lore_fragments": 3
	}

func _get_room_template() -> Dictionary:
	return {
		"type": "room",
		"dimensions": {"width": 10, "height": 10},
		"entrance_points": ["north", "south"],
		"furniture": ["altar", "pillar"],
		"lighting": "dim",
		"atmosphere": "oppressive",
		"spawn_points": 4,
		"loot_spots": 2
	}

func _get_enemy_template() -> Dictionary:
	return {
		"type": "enemy",
		"base_stats": {
			"health": 100,
			"damage": 25,
			"speed": 1.0,
			"defense": 10
		},
		"behavior": "aggressive",
		"ai_type": "melee_rusher",
		"size": "medium",
		"tags": ["corrupted", "humanoid"],
		"abilities": ["basic_attack"],
		"loot_table": "common_enemy"
	}

func _get_item_template() -> Dictionary:
	return {
		"type": "item",
		"category": "weapon",
		"base_stats": {
			"damage": 50,
			"durability": 100,
			"weight": 2.5
		},
		"rarity": "common",
		"tags": ["melee", "blade"],
		"requirements": {"strength": 10},
		"description_base": "A worn blade"
	}

func _cache_template(cache_key: String, template_data: Dictionary) -> void:
	if template_cache.size() >= max_cache_size:
		_cleanup_cache()
	
	template_cache[cache_key] = template_data.duplicate(true)

func _cleanup_cache() -> void:
	# Remove oldest entries (simple FIFO for now)
	var keys_to_remove = template_cache.keys().slice(0, max_cache_size / 2)
	for key in keys_to_remove:
		template_cache.erase(key)

func get_available_templates(content_type: String) -> Array[String]:
	# Return list of available templates for a content type
	# Placeholder implementation
	match content_type:
		"dungeon":
			return ["city_ruins", "underground_passage", "corrupted_building"]
		"room":
			return ["altar_room", "corridor", "chamber", "flooded_room"]
		"enemy":
			return ["corrupted_citizen", "shadow_beast", "void_priest"]
		"item":
			return ["rusty_blade", "corrupted_armor", "void_shard"]
		_:
			return []

func clear_cache() -> void:
	template_cache.clear()

func get_cache_stats() -> Dictionary:
	return {
		"cached_templates": template_cache.size(),
		"max_cache_size": max_cache_size,
		"cache_enabled": cache_enabled
	} 