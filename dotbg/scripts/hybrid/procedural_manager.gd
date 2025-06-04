extends Node

# Manages procedural detail generation for hybrid system

# Generates procedural details for hybrid content
# Dungeon interiors, enemy variants, item modifiers = Procedural

# Mobile optimization settings
var mobile_mode: bool = false
var generation_complexity: float = 1.0

func _ready() -> void:
	print("ProceduralManager: Initialized for epic procedural generation")

func set_mobile_mode(enabled: bool) -> void:
	mobile_mode = enabled
	if mobile_mode:
		generation_complexity = 0.7  # Reduce complexity for mobile

func generate_details(handcrafted_base: Dictionary, context: Dictionary, constraints: Dictionary = {}) -> Dictionary:
	# Generate procedural details based on handcrafted foundation
	var details = {}
	
	match handcrafted_base.get("type", ""):
		"dungeon":
			details = _generate_dungeon_details(handcrafted_base, context, constraints)
		"room":
			details = _generate_room_details(handcrafted_base, context, constraints)
		"enemy":
			details = _generate_enemy_details(handcrafted_base, context, constraints)
		"item":
			details = _generate_item_details(handcrafted_base, context, constraints)
		_:
			details = _generate_generic_details(handcrafted_base, context, constraints)
	
	return details

func _generate_dungeon_details(base: Dictionary, context: Dictionary, constraints: Dictionary) -> Dictionary:
	var details = {}
	
	# Generate room layouts
	details["room_layouts"] = _generate_room_layouts(base, context)
	
	# Generate enemy placements
	details["enemy_spawns"] = _generate_enemy_spawns(base, context)
	
	# Generate loot distribution
	details["loot_distribution"] = _generate_loot_distribution(base, context)
	
	# Generate environmental details
	details["environmental_details"] = _generate_environmental_details(base, context)
	
	return details

func _generate_room_layouts(base: Dictionary, context: Dictionary) -> Array:
	var layouts = []
	var room_count = base.get("layout", {}).get("room_count", 5)
	
	for i in range(room_count):
		var room_layout = {
			"id": "room_" + str(i),
			"type": _select_random_room_type(base),
			"connections": _generate_room_connections(i, room_count),
			"size_modifier": randf_range(0.8, 1.2),
			"special_features": _generate_room_features(context)
		}
		layouts.append(room_layout)
	
	return layouts

func _select_random_room_type(base: Dictionary) -> String:
	var room_templates = base.get("room_templates", ["corridor", "chamber"])
	return room_templates[randi() % room_templates.size()]

func _generate_room_connections(room_index: int, total_rooms: int) -> Array:
	var connections = []
	
	# Ensure connectivity
	if room_index > 0:
		connections.append(room_index - 1)
	if room_index < total_rooms - 1 and randf() > 0.3:
		connections.append(room_index + 1)
	
	# Add random connections
	if randf() > 0.7:
		var random_room = randi() % total_rooms
		if random_room != room_index and not connections.has(random_room):
			connections.append(random_room)
	
	return connections

func _generate_room_features(context: Dictionary) -> Array:
	var features = []
	
	# Act-specific features
	var current_act = context.get("act", 1)
	match current_act:
		1:  # Descending City
			if randf() > 0.7:
				features.append("broken_window")
			if randf() > 0.8:
				features.append("graffiti")
		2:  # Drowning Depths
			if randf() > 0.6:
				features.append("water_puddle")
			if randf() > 0.9:
				features.append("flooded_section")
		3:  # Dream Realm
			if randf() > 0.5:
				features.append("reality_distortion")
			if randf() > 0.8:
				features.append("impossible_geometry")
	
	return features

func _generate_enemy_spawns(base: Dictionary, context: Dictionary) -> Array:
	var spawns = []
	var spawn_count = randi_range(3, 8)
	
	if mobile_mode:
		spawn_count = min(spawn_count, 5)  # Limit for mobile performance
	
	for i in range(spawn_count):
		var spawn = {
			"enemy_type": _select_enemy_type(base, context),
			"position": Vector2(randf_range(0, 1), randf_range(0, 1)),
			"level_modifier": randf_range(0.8, 1.2),
			"behavior_variant": _select_behavior_variant(context)
		}
		spawns.append(spawn)
	
	return spawns

func _select_enemy_type(base: Dictionary, context: Dictionary) -> String:
	# Select based on context and sanity level
	var sanity_level = context.get("sanity_level", 0)
	var base_enemies = ["corrupted_citizen", "shadow_beast", "void_priest"]
	
	# Add sanity-influenced enemies
	match sanity_level:
		2, 3:  # Low/Zero sanity
			base_enemies.append("hallucinated_enemy")
			base_enemies.append("false_ally")
	
	return base_enemies[randi() % base_enemies.size()]

func _select_behavior_variant(context: Dictionary) -> String:
	var variants = ["normal", "aggressive", "defensive", "erratic"]
	return variants[randi() % variants.size()]

func _generate_loot_distribution(base: Dictionary, context: Dictionary) -> Array:
	var loot = []
	var loot_count = randi_range(2, 6)
	
	for i in range(loot_count):
		var loot_item = {
			"type": _select_loot_type(context),
			"position": Vector2(randf_range(0, 1), randf_range(0, 1)),
			"rarity_modifier": randf_range(0.5, 1.5),
			"hidden": randf() > 0.7
		}
		loot.append(loot_item)
	
	return loot

func _select_loot_type(context: Dictionary) -> String:
	var loot_types = ["blood_echoes", "consumable", "equipment", "lore_fragment"]
	return loot_types[randi() % loot_types.size()]

func _generate_environmental_details(base: Dictionary, context: Dictionary) -> Dictionary:
	return {
		"lighting_variation": randf_range(0.7, 1.3),
		"corruption_intensity": randf_range(0.0, 1.0),
		"atmospheric_effects": _generate_atmospheric_effects(context),
		"interactive_objects": _generate_interactive_objects(context)
	}

func _generate_atmospheric_effects(context: Dictionary) -> Array:
	var effects = []
	var current_act = context.get("act", 1)
	
	match current_act:
		1:  # City
			if randf() > 0.6: effects.append("dust_particles")
			if randf() > 0.8: effects.append("distant_screams")
		2:  # Depths
			if randf() > 0.5: effects.append("water_drips")
			if randf() > 0.7: effects.append("echo_sounds")
		3:  # Dream
			if randf() > 0.4: effects.append("reality_flicker")
			if randf() > 0.6: effects.append("whispers")
	
	return effects

func _generate_interactive_objects(context: Dictionary) -> Array:
	var objects = []
	var object_count = randi_range(1, 4)
	
	for i in range(object_count):
		var obj = {
			"type": _select_object_type(context),
			"position": Vector2(randf_range(0, 1), randf_range(0, 1)),
			"interaction_type": _select_interaction_type()
		}
		objects.append(obj)
	
	return objects

func _select_object_type(context: Dictionary) -> String:
	var objects = ["lever", "chest", "altar", "book", "mirror"]
	return objects[randi() % objects.size()]

func _select_interaction_type() -> String:
	var interactions = ["activate", "examine", "loot", "read", "touch"]
	return interactions[randi() % interactions.size()]

func _generate_room_details(base: Dictionary, context: Dictionary, constraints: Dictionary) -> Dictionary:
	return {
		"furniture_placement": _generate_furniture_placement(base),
		"lighting_details": _generate_lighting_details(base, context),
		"texture_variations": _generate_texture_variations(context),
		"sound_ambience": _generate_sound_ambience(context)
	}

func _generate_furniture_placement(base: Dictionary) -> Array:
	var furniture = base.get("furniture", [])
	var placements = []
	
	for item in furniture:
		var placement = {
			"type": item,
			"position": Vector2(randf(), randf()),
			"rotation": randf() * 360,
			"scale": randf_range(0.8, 1.2)
		}
		placements.append(placement)
	
	return placements

func _generate_lighting_details(base: Dictionary, context: Dictionary) -> Dictionary:
	var base_lighting = base.get("lighting", "dim")
	return {
		"base_type": base_lighting,
		"intensity_modifier": randf_range(0.7, 1.3),
		"color_tint": _generate_color_tint(context),
		"flicker_chance": randf()
	}

func _generate_color_tint(context: Dictionary) -> Color:
	var current_act = context.get("act", 1)
	match current_act:
		1:  # City - orange/red tints
			return Color(1.0, randf_range(0.6, 0.9), randf_range(0.3, 0.7))
		2:  # Depths - blue/green tints
			return Color(randf_range(0.3, 0.7), randf_range(0.6, 1.0), randf_range(0.7, 1.0))
		3:  # Dream - purple/pink tints
			return Color(randf_range(0.7, 1.0), randf_range(0.3, 0.7), randf_range(0.8, 1.0))
		_:
			return Color.WHITE

func _generate_texture_variations(context: Dictionary) -> Dictionary:
	return {
		"wear_level": randf(),
		"corruption_spread": randf_range(0.0, 0.8),
		"detail_density": randf_range(0.5, 1.5)
	}

func _generate_sound_ambience(context: Dictionary) -> Array:
	var sounds = []
	var current_act = context.get("act", 1)
	
	match current_act:
		1:  # City sounds
			sounds = ["wind", "distant_traffic", "creaking"]
		2:  # Depths sounds
			sounds = ["water_drops", "echoes", "grinding"]
		3:  # Dream sounds
			sounds = ["whispers", "distortion", "silence"]
	
	return sounds

func _generate_enemy_details(base: Dictionary, context: Dictionary, constraints: Dictionary) -> Dictionary:
	return {
		"stat_modifiers": _generate_stat_modifiers(base, context),
		"visual_variants": _generate_visual_variants(base, context),
		"behavior_modifiers": _generate_behavior_modifiers(context),
		"special_abilities": _generate_special_abilities(base, context)
	}

func _generate_stat_modifiers(base: Dictionary, context: Dictionary) -> Dictionary:
	var player_level = context.get("player_level", 1)
	var level_scaling = 1.0 + (player_level - 1) * 0.1
	
	return {
		"health_modifier": randf_range(0.8, 1.2) * level_scaling,
		"damage_modifier": randf_range(0.9, 1.1) * level_scaling,
		"speed_modifier": randf_range(0.8, 1.2),
		"defense_modifier": randf_range(0.9, 1.1) * level_scaling
	}

func _generate_visual_variants(base: Dictionary, context: Dictionary) -> Dictionary:
	return {
		"size_modifier": randf_range(0.8, 1.2),
		"color_variant": randi() % 3,
		"corruption_level": randf(),
		"additional_features": _generate_additional_features(context)
	}

func _generate_additional_features(context: Dictionary) -> Array:
	var features = []
	var sanity_level = context.get("sanity_level", 0)
	
	# Sanity-influenced features
	if sanity_level >= 2:  # Low/Zero sanity
		if randf() > 0.7:
			features.append("false_appearance")
		if randf() > 0.8:
			features.append("reality_distortion")
	
	return features

func _generate_behavior_modifiers(context: Dictionary) -> Dictionary:
	return {
		"aggression_modifier": randf_range(0.7, 1.3),
		"detection_range_modifier": randf_range(0.8, 1.2),
		"patrol_pattern": _select_patrol_pattern(),
		"group_behavior": randf() > 0.7
	}

func _select_patrol_pattern() -> String:
	var patterns = ["linear", "circular", "random", "stationary"]
	return patterns[randi() % patterns.size()]

func _generate_special_abilities(base: Dictionary, context: Dictionary) -> Array:
	var abilities = base.get("abilities", []).duplicate()
	
	# Add random abilities based on context
	var possible_abilities = ["charge", "teleport", "summon", "heal", "rage"]
	
	if randf() > 0.8:  # 20% chance for additional ability
		var new_ability = possible_abilities[randi() % possible_abilities.size()]
		if not abilities.has(new_ability):
			abilities.append(new_ability)
	
	return abilities

func _generate_item_details(base: Dictionary, context: Dictionary, constraints: Dictionary) -> Dictionary:
	return {
		"stat_modifiers": _generate_item_stat_modifiers(base, context),
		"visual_modifiers": _generate_item_visual_modifiers(context),
		"special_properties": _generate_item_special_properties(base, context),
		"description_modifiers": _generate_description_modifiers(context)
	}

func _generate_item_stat_modifiers(base: Dictionary, context: Dictionary) -> Dictionary:
	var base_stats = base.get("base_stats", {})
	var modifiers = {}
	
	for stat in base_stats:
		modifiers[stat + "_modifier"] = randf_range(0.8, 1.2)
	
	return modifiers

func _generate_item_visual_modifiers(context: Dictionary) -> Dictionary:
	return {
		"wear_level": randf(),
		"enchantment_glow": randf() > 0.9,
		"corruption_marks": randf() > 0.7,
		"size_modifier": randf_range(0.9, 1.1)
	}

func _generate_item_special_properties(base: Dictionary, context: Dictionary) -> Array:
	var properties = []
	var base_tags = base.get("tags", [])
	
	# Generate properties based on tags
	if "corrupted" in base_tags:
		if randf() > 0.8:
			properties.append("sanity_drain")
	
	if "blessed" in base_tags:
		if randf() > 0.7:
			properties.append("sanity_restore")
	
	return properties

func _generate_description_modifiers(context: Dictionary) -> Dictionary:
	return {
		"condition_adjective": _select_condition_adjective(),
		"origin_hint": _select_origin_hint(context),
		"mysterious_property": randf() > 0.8
	}

func _select_condition_adjective() -> String:
	var adjectives = ["worn", "pristine", "damaged", "ancient", "corrupted", "blessed"]
	return adjectives[randi() % adjectives.size()]

func _select_origin_hint(context: Dictionary) -> String:
	var hints = ["found in ruins", "blessed by priests", "forged in darkness", "touched by void"]
	return hints[randi() % hints.size()]

func _generate_generic_details(base: Dictionary, context: Dictionary, constraints: Dictionary) -> Dictionary:
	return {
		"random_seed": randi(),
		"generation_timestamp": Time.get_unix_time_from_system(),
		"context_hash": str(context.hash()),
		"mobile_optimized": mobile_mode
	} 