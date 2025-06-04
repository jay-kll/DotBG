extends Node

# Manages template processing and caching for hybrid generation

# Modular room templates (e.g. "altar room", "flooded corridor")
# Manages template loading, caching, and combination

# Template storage and caching
var template_cache: Dictionary = {}
var template_metadata: Dictionary = {}
var cache_limit: int = 100

# Template categories
var template_types: Dictionary = {
	"room": ["altar_room", "corridor", "chamber", "flooded_corridor", "shrine_room"],
	"layout": ["linear", "branching", "circular", "maze", "hub"],
	"feature": ["water_feature", "altar", "pillar_array", "pit", "platform"],
	"connection": ["door", "archway", "stairs", "ladder", "portal"]
}

# Mobile optimization
var mobile_mode: bool = false
var simplified_templates: bool = false

func _ready() -> void:
	_initialize_template_metadata()
	print("TemplateSystem: Initialized for epic hybrid generation")

func _initialize_template_metadata() -> void:
	# Initialize metadata for all template types
	template_metadata = {
		"altar_room": {
			"size": "medium",
			"complexity": "high",
			"features": ["altar", "candles", "ritual_circle"],
			"connections": ["north", "south"],
			"atmosphere": "sacred",
			"mobile_friendly": true
		},
		"corridor": {
			"size": "small",
			"complexity": "low",
			"features": ["basic_lighting"],
			"connections": ["north", "south", "east", "west"],
			"atmosphere": "neutral",
			"mobile_friendly": true
		},
		"chamber": {
			"size": "large",
			"complexity": "medium",
			"features": ["pillars", "elevated_platform"],
			"connections": ["north", "south", "east"],
			"atmosphere": "imposing",
			"mobile_friendly": true
		},
		"flooded_corridor": {
			"size": "medium",
			"complexity": "medium",
			"features": ["water", "drainage", "slippery_floor"],
			"connections": ["north", "south"],
			"atmosphere": "damp",
			"mobile_friendly": false  # More complex for mobile
		},
		"shrine_room": {
			"size": "small",
			"complexity": "high",
			"features": ["shrine", "offerings", "blessed_area"],
			"connections": ["south"],
			"atmosphere": "holy",
			"mobile_friendly": true
		}
	}

func load_template(template_id: String, template_type: String = "room") -> Dictionary:
	# Load a template with caching
	var cache_key = template_type + "_" + template_id
	
	# Check cache first
	if template_cache.has(cache_key):
		return template_cache[cache_key].duplicate(true)
	
	# Generate or load template
	var template_data = _generate_template(template_id, template_type)
	
	# Cache the template
	_cache_template(cache_key, template_data)
	
	return template_data

func _generate_template(template_id: String, template_type: String) -> Dictionary:
	# Generate template data based on ID and type
	match template_type:
		"room":
			return _generate_room_template(template_id)
		"layout":
			return _generate_layout_template(template_id)
		"feature":
			return _generate_feature_template(template_id)
		"connection":
			return _generate_connection_template(template_id)
		_:
			return _generate_generic_template(template_id, template_type)

func _generate_room_template(template_id: String) -> Dictionary:
	# Generate room template based on ID
	var metadata = template_metadata.get(template_id, {})
	
	match template_id:
		"altar_room":
			return _create_altar_room_template(metadata)
		"corridor":
			return _create_corridor_template(metadata)
		"chamber":
			return _create_chamber_template(metadata)
		"flooded_corridor":
			return _create_flooded_corridor_template(metadata)
		"shrine_room":
			return _create_shrine_room_template(metadata)
		_:
			return _create_generic_room_template(template_id, metadata)

func _create_altar_room_template(metadata: Dictionary) -> Dictionary:
	return {
		"id": "altar_room",
		"type": "room",
		"dimensions": {"width": 12, "height": 12},
		"features": [
			{
				"type": "altar",
				"position": Vector2(0.5, 0.3),
				"size": Vector2(2, 1),
				"interactive": true,
				"properties": ["ritual_site", "sanity_restore"]
			},
			{
				"type": "candles",
				"position": Vector2(0.2, 0.2),
				"count": 4,
				"lighting": "warm"
			},
			{
				"type": "ritual_circle",
				"position": Vector2(0.5, 0.7),
				"radius": 2.0,
				"properties": ["magical", "protective"]
			}
		],
		"connections": [
			{"direction": "north", "position": Vector2(0.5, 0.0)},
			{"direction": "south", "position": Vector2(0.5, 1.0)}
		],
		"lighting": {
			"base_level": 0.7,
			"sources": ["candles", "altar_glow"],
			"atmosphere": "sacred"
		},
		"spawn_points": [
			{"position": Vector2(0.8, 0.8), "type": "enemy", "probability": 0.3},
			{"position": Vector2(0.2, 0.8), "type": "loot", "probability": 0.6}
		],
		"mobile_optimized": true,
		"complexity_score": 3
	}

func _create_corridor_template(metadata: Dictionary) -> Dictionary:
	return {
		"id": "corridor",
		"type": "room",
		"dimensions": {"width": 8, "height": 16},
		"features": [
			{
				"type": "basic_lighting",
				"position": Vector2(0.5, 0.5),
				"intensity": 0.6
			}
		],
		"connections": [
			{"direction": "north", "position": Vector2(0.5, 0.0)},
			{"direction": "south", "position": Vector2(0.5, 1.0)},
			{"direction": "east", "position": Vector2(1.0, 0.5)},
			{"direction": "west", "position": Vector2(0.0, 0.5)}
		],
		"lighting": {
			"base_level": 0.5,
			"sources": ["overhead"],
			"atmosphere": "neutral"
		},
		"spawn_points": [
			{"position": Vector2(0.3, 0.5), "type": "enemy", "probability": 0.4},
			{"position": Vector2(0.7, 0.5), "type": "enemy", "probability": 0.4}
		],
		"mobile_optimized": true,
		"complexity_score": 1
	}

func _create_chamber_template(metadata: Dictionary) -> Dictionary:
	return {
		"id": "chamber",
		"type": "room",
		"dimensions": {"width": 20, "height": 20},
		"features": [
			{
				"type": "pillars",
				"positions": [
					Vector2(0.25, 0.25), Vector2(0.75, 0.25),
					Vector2(0.25, 0.75), Vector2(0.75, 0.75)
				],
				"properties": ["structural", "cover"]
			},
			{
				"type": "elevated_platform",
				"position": Vector2(0.5, 0.3),
				"size": Vector2(4, 2),
				"height": 1.0,
				"properties": ["elevated", "strategic"]
			}
		],
		"connections": [
			{"direction": "north", "position": Vector2(0.5, 0.0)},
			{"direction": "south", "position": Vector2(0.5, 1.0)},
			{"direction": "east", "position": Vector2(1.0, 0.5)}
		],
		"lighting": {
			"base_level": 0.6,
			"sources": ["overhead", "pillar_torches"],
			"atmosphere": "imposing"
		},
		"spawn_points": [
			{"position": Vector2(0.5, 0.7), "type": "enemy", "probability": 0.7},
			{"position": Vector2(0.2, 0.2), "type": "loot", "probability": 0.4},
			{"position": Vector2(0.8, 0.8), "type": "loot", "probability": 0.4}
		],
		"mobile_optimized": true,
		"complexity_score": 2
	}

func _create_flooded_corridor_template(metadata: Dictionary) -> Dictionary:
	var template = {
		"id": "flooded_corridor",
		"type": "room",
		"dimensions": {"width": 10, "height": 16},
		"features": [
			{
				"type": "water",
				"position": Vector2(0.5, 0.6),
				"size": Vector2(8, 6),
				"depth": 0.5,
				"properties": ["slowing", "splashing"]
			},
			{
				"type": "drainage",
				"position": Vector2(0.1, 0.9),
				"properties": ["functional", "sound_source"]
			}
		],
		"connections": [
			{"direction": "north", "position": Vector2(0.5, 0.0)},
			{"direction": "south", "position": Vector2(0.5, 1.0)}
		],
		"lighting": {
			"base_level": 0.4,
			"sources": ["dim_overhead"],
			"atmosphere": "damp",
			"reflections": true
		},
		"spawn_points": [
			{"position": Vector2(0.5, 0.3), "type": "enemy", "probability": 0.5}
		],
		"environmental_effects": [
			{"type": "water_splash", "trigger": "movement"},
			{"type": "echo", "intensity": 1.2}
		],
		"mobile_optimized": false,  # More complex water effects
		"complexity_score": 3
	}
	
	# Simplify for mobile if needed
	if mobile_mode:
		template["features"][0]["properties"] = ["slowing"]  # Remove splashing
		template["environmental_effects"] = []  # Remove complex effects
		template["mobile_optimized"] = true
		template["complexity_score"] = 2
	
	return template

func _create_shrine_room_template(metadata: Dictionary) -> Dictionary:
	return {
		"id": "shrine_room",
		"type": "room",
		"dimensions": {"width": 10, "height": 10},
		"features": [
			{
				"type": "shrine",
				"position": Vector2(0.5, 0.2),
				"size": Vector2(2, 1),
				"interactive": true,
				"properties": ["holy", "sanity_restore", "blessing"]
			},
			{
				"type": "offerings",
				"position": Vector2(0.5, 0.4),
				"count": 3,
				"properties": ["lootable", "blessed"]
			},
			{
				"type": "blessed_area",
				"position": Vector2(0.5, 0.5),
				"radius": 3.0,
				"properties": ["protective", "sanity_boost"]
			}
		],
		"connections": [
			{"direction": "south", "position": Vector2(0.5, 1.0)}
		],
		"lighting": {
			"base_level": 0.8,
			"sources": ["divine_light", "shrine_glow"],
			"atmosphere": "holy"
		},
		"spawn_points": [
			{"position": Vector2(0.8, 0.8), "type": "loot", "probability": 0.8}
		],
		"special_properties": [
			{"type": "sanity_restoration", "rate": 0.1},
			{"type": "enemy_deterrent", "radius": 5.0}
		],
		"mobile_optimized": true,
		"complexity_score": 3
	}

func _create_generic_room_template(template_id: String, metadata: Dictionary) -> Dictionary:
	return {
		"id": template_id,
		"type": "room",
		"dimensions": {"width": 12, "height": 12},
		"features": [],
		"connections": [
			{"direction": "north", "position": Vector2(0.5, 0.0)},
			{"direction": "south", "position": Vector2(0.5, 1.0)}
		],
		"lighting": {
			"base_level": 0.5,
			"sources": ["basic"],
			"atmosphere": "neutral"
		},
		"spawn_points": [],
		"mobile_optimized": true,
		"complexity_score": 1
	}

func _generate_layout_template(template_id: String) -> Dictionary:
	# Generate layout templates for dungeon structure
	match template_id:
		"linear":
			return {
				"id": "linear",
				"type": "layout",
				"pattern": "sequential",
				"room_count": {"min": 5, "max": 8},
				"connections": "single_path",
				"complexity": "low"
			}
		"branching":
			return {
				"id": "branching",
				"type": "layout",
				"pattern": "tree",
				"room_count": {"min": 8, "max": 12},
				"connections": "multiple_paths",
				"complexity": "medium"
			}
		"hub":
			return {
				"id": "hub",
				"type": "layout",
				"pattern": "central_hub",
				"room_count": {"min": 6, "max": 10},
				"connections": "hub_and_spoke",
				"complexity": "medium"
			}
		_:
			return {"id": template_id, "type": "layout", "pattern": "generic"}

func _generate_feature_template(template_id: String) -> Dictionary:
	# Generate feature templates for room elements
	match template_id:
		"altar":
			return {
				"id": "altar",
				"type": "feature",
				"size": Vector2(2, 1),
				"interactive": true,
				"properties": ["ritual_site", "sanity_effect"]
			}
		"water_feature":
			return {
				"id": "water_feature",
				"type": "feature",
				"size": Vector2(3, 3),
				"properties": ["environmental", "movement_modifier"]
			}
		_:
			return {"id": template_id, "type": "feature"}

func _generate_connection_template(template_id: String) -> Dictionary:
	# Generate connection templates for room links
	match template_id:
		"door":
			return {
				"id": "door",
				"type": "connection",
				"width": 1.0,
				"properties": ["openable", "blockable"]
			}
		"portal":
			return {
				"id": "portal",
				"type": "connection",
				"width": 2.0,
				"properties": ["magical", "instant_travel"]
			}
		_:
			return {"id": template_id, "type": "connection"}

func _generate_generic_template(template_id: String, template_type: String) -> Dictionary:
	return {
		"id": template_id,
		"type": template_type,
		"generated": true,
		"timestamp": Time.get_unix_time_from_system()
	}

func combine_templates(base_template: Dictionary, modifier_templates: Array[Dictionary]) -> Dictionary:
	# Combine multiple templates into one
	var combined = base_template.duplicate(true)
	
	for modifier in modifier_templates:
		combined = _merge_template_data(combined, modifier)
	
	return combined

func _merge_template_data(base: Dictionary, modifier: Dictionary) -> Dictionary:
	var merged = base.duplicate(true)
	
	# Merge features
	if modifier.has("features") and base.has("features"):
		merged["features"].append_array(modifier["features"])
	
	# Merge spawn points
	if modifier.has("spawn_points") and base.has("spawn_points"):
		merged["spawn_points"].append_array(modifier["spawn_points"])
	
	# Merge connections (avoid duplicates)
	if modifier.has("connections") and base.has("connections"):
		for new_connection in modifier["connections"]:
			var duplicate = false
			for existing_connection in merged["connections"]:
				if existing_connection["direction"] == new_connection["direction"]:
					duplicate = true
					break
			if not duplicate:
				merged["connections"].append(new_connection)
	
	# Override other properties
	for key in modifier:
		if key not in ["features", "spawn_points", "connections"]:
			merged[key] = modifier[key]
	
	return merged

func get_templates_by_type(template_type: String) -> Array[String]:
	return template_types.get(template_type, [])

func get_template_metadata(template_id: String) -> Dictionary:
	return template_metadata.get(template_id, {})

func is_template_mobile_friendly(template_id: String) -> bool:
	var metadata = get_template_metadata(template_id)
	return metadata.get("mobile_friendly", true)

func get_mobile_friendly_templates(template_type: String) -> Array[String]:
	var templates = get_templates_by_type(template_type)
	var mobile_friendly = []
	
	for template_id in templates:
		if is_template_mobile_friendly(template_id):
			mobile_friendly.append(template_id)
	
	return mobile_friendly

func _cache_template(cache_key: String, template_data: Dictionary) -> void:
	if template_cache.size() >= cache_limit:
		_cleanup_cache()
	
	template_cache[cache_key] = template_data.duplicate(true)

func _cleanup_cache() -> void:
	# Remove oldest entries (simple FIFO)
	var keys_to_remove = template_cache.keys().slice(0, cache_limit / 2)
	for key in keys_to_remove:
		template_cache.erase(key)

func set_cache_limit(limit: int) -> void:
	cache_limit = limit
	if template_cache.size() > cache_limit:
		_cleanup_cache()

func set_mobile_mode(enabled: bool) -> void:
	mobile_mode = enabled
	simplified_templates = enabled

func clear_cache() -> void:
	template_cache.clear()

func get_template_stats() -> Dictionary:
	return {
		"cached_templates": template_cache.size(),
		"cache_limit": cache_limit,
		"template_types": template_types.size(),
		"total_templates": template_metadata.size(),
		"mobile_mode": mobile_mode
	} 