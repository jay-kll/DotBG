extends Node

# Manages tag-based content modification for hybrid generation

# Tag system for enemies and items (e.g. [fast], [deformed], [fire])
# Enables flexible procedural combinations

# Core tag categories
var tag_categories: Dictionary = {
	"behavior": ["fast", "slow", "aggressive", "defensive", "erratic", "cunning"],
	"physical": ["large", "small", "deformed", "armored", "fragile", "nimble"],
	"elemental": ["fire", "ice", "poison", "electric", "void", "corruption"],
	"mental": ["intelligent", "mindless", "psychic", "resistant", "vulnerable"],
	"origin": ["ancient", "corrupted", "blessed", "artificial", "natural", "otherworldly"],
	"rarity": ["common", "uncommon", "rare", "epic", "legendary", "cursed"]
}

# Tag combinations and their effects
var tag_synergies: Dictionary = {}
var tag_conflicts: Dictionary = {}

# Mobile optimization
var max_tags_per_entity: int = 5
var mobile_mode: bool = false

func _ready() -> void:
	_initialize_tag_synergies()
	_initialize_tag_conflicts()
	print("TagSystem: Initialized for epic hybrid generation")

func _initialize_tag_synergies() -> void:
	# Define tag combinations that work well together
	tag_synergies = {
		["fast", "aggressive"]: {"damage_bonus": 1.2, "speed_bonus": 1.3},
		["large", "slow"]: {"health_bonus": 1.5, "damage_bonus": 1.1},
		["fire", "aggressive"]: {"fire_damage": true, "rage_chance": 0.3},
		["ice", "defensive"]: {"slow_aura": true, "armor_bonus": 1.2},
		["corrupted", "void"]: {"sanity_damage": true, "reality_distortion": 0.2},
		["blessed", "ancient"]: {"sanity_restore": true, "wisdom_bonus": 1.3},
		["deformed", "corrupted"]: {"horror_factor": 1.5, "unpredictable": true},
		["small", "fast"]: {"evasion_bonus": 1.4, "stealth_bonus": 1.2},
		["psychic", "intelligent"]: {"mind_attacks": true, "strategy_bonus": 1.3},
		["poison", "cunning"]: {"poison_traps": true, "ambush_bonus": 1.2}
	}

func _initialize_tag_conflicts() -> void:
	# Define tags that conflict with each other
	tag_conflicts = {
		"fast": ["slow"],
		"large": ["small"],
		"aggressive": ["defensive"],
		"intelligent": ["mindless"],
		"blessed": ["corrupted", "cursed"],
		"fire": ["ice"],
		"ancient": ["artificial"],
		"common": ["rare", "epic", "legendary"]
	}

func generate_tags_for_entity(entity_type: String, context: Dictionary, constraints: Dictionary = {}) -> Array[String]:
	# Generate appropriate tags for an entity based on context
	var tags: Array[String] = []
	
	# Base tags from entity type
	tags.append_array(_get_base_tags_for_type(entity_type))
	
	# Context-influenced tags
	tags.append_array(_get_context_tags(context))
	
	# Random additional tags
	tags.append_array(_get_random_tags(entity_type, context))
	
	# Apply constraints and conflicts
	tags = _resolve_tag_conflicts(tags)
	tags = _apply_constraints(tags, constraints)
	
	# Limit for mobile performance
	if mobile_mode and tags.size() > max_tags_per_entity:
		tags = tags.slice(0, max_tags_per_entity)
	
	return tags

func _get_base_tags_for_type(entity_type: String) -> Array[String]:
	# Return base tags that are common for entity types
	match entity_type:
		"enemy":
			return ["hostile"]
		"weapon":
			return ["equipment"]
		"armor":
			return ["equipment", "protective"]
		"consumable":
			return ["usable"]
		"lore":
			return ["readable"]
		_:
			return []

func _get_context_tags(context: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	
	# Act-specific tags
	var current_act = context.get("act", 1)
	match current_act:
		1:  # Descending City
			if randf() > 0.7:
				tags.append("corrupted")
			if randf() > 0.8:
				tags.append("urban")
		2:  # Drowning Depths
			if randf() > 0.6:
				tags.append("aquatic")
			if randf() > 0.7:
				tags.append("ancient")
		3:  # Dream Realm
			if randf() > 0.5:
				tags.append("otherworldly")
			if randf() > 0.6:
				tags.append("psychic")
	
	# Sanity-influenced tags
	var sanity_level = context.get("sanity_level", 0)
	match sanity_level:
		2:  # Low sanity
			if randf() > 0.7:
				tags.append("disturbing")
		3:  # Zero sanity
			if randf() > 0.5:
				tags.append("nightmarish")
			if randf() > 0.6:
				tags.append("impossible")
	
	# Player level scaling
	var player_level = context.get("player_level", 1)
	if player_level >= 10:
		if randf() > 0.8:
			tags.append("elite")
	if player_level >= 20:
		if randf() > 0.9:
			tags.append("legendary")
	
	return tags

func _get_random_tags(entity_type: String, context: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var tag_count = randi_range(1, 3)
	
	if mobile_mode:
		tag_count = min(tag_count, 2)  # Limit for mobile
	
	# Select random tags from different categories
	var available_categories = tag_categories.keys()
	
	for i in range(tag_count):
		var category = available_categories[randi() % available_categories.size()]
		var category_tags = tag_categories[category]
		var random_tag = category_tags[randi() % category_tags.size()]
		
		if not tags.has(random_tag):
			tags.append(random_tag)
	
	return tags

func _resolve_tag_conflicts(tags: Array[String]) -> Array[String]:
	var resolved_tags: Array[String] = []
	
	for tag in tags:
		var has_conflict = false
		
		# Check if this tag conflicts with any already added tags
		for existing_tag in resolved_tags:
			if _tags_conflict(tag, existing_tag):
				has_conflict = true
				break
		
		if not has_conflict:
			resolved_tags.append(tag)
	
	return resolved_tags

func _tags_conflict(tag1: String, tag2: String) -> bool:
	# Check if two tags conflict with each other
	if tag_conflicts.has(tag1):
		return tag_conflicts[tag1].has(tag2)
	if tag_conflicts.has(tag2):
		return tag_conflicts[tag2].has(tag1)
	return false

func _apply_constraints(tags: Array[String], constraints: Dictionary) -> Array[String]:
	var constrained_tags = tags.duplicate()
	
	# Required tags
	if constraints.has("required_tags"):
		for required_tag in constraints["required_tags"]:
			if not constrained_tags.has(required_tag):
				constrained_tags.append(required_tag)
	
	# Forbidden tags
	if constraints.has("forbidden_tags"):
		for forbidden_tag in constraints["forbidden_tags"]:
			constrained_tags.erase(forbidden_tag)
	
	# Maximum tags
	if constraints.has("max_tags"):
		var max_tags = constraints["max_tags"]
		if constrained_tags.size() > max_tags:
			constrained_tags = constrained_tags.slice(0, max_tags)
	
	return constrained_tags

func calculate_tag_effects(tags: Array[String]) -> Dictionary:
	# Calculate the combined effects of all tags
	var effects = {
		"stat_modifiers": {},
		"special_abilities": [],
		"visual_modifiers": {},
		"behavior_modifiers": {},
		"description_modifiers": []
	}
	
	# Individual tag effects
	for tag in tags:
		var tag_effect = _get_individual_tag_effect(tag)
		effects = _merge_effects(effects, tag_effect)
	
	# Synergy effects
	var synergy_effects = _calculate_synergy_effects(tags)
	effects = _merge_effects(effects, synergy_effects)
	
	return effects

func _get_individual_tag_effect(tag: String) -> Dictionary:
	# Define individual tag effects
	var tag_effects = {
		"fast": {
			"stat_modifiers": {"speed": 1.3, "evasion": 1.2},
			"behavior_modifiers": {"movement_speed": 1.3}
		},
		"slow": {
			"stat_modifiers": {"speed": 0.7, "health": 1.2},
			"behavior_modifiers": {"movement_speed": 0.7}
		},
		"aggressive": {
			"stat_modifiers": {"damage": 1.2, "defense": 0.9},
			"behavior_modifiers": {"aggression": 1.4}
		},
		"defensive": {
			"stat_modifiers": {"defense": 1.3, "damage": 0.9},
			"behavior_modifiers": {"aggression": 0.7}
		},
		"large": {
			"stat_modifiers": {"health": 1.4, "speed": 0.8},
			"visual_modifiers": {"size": 1.3}
		},
		"small": {
			"stat_modifiers": {"health": 0.8, "evasion": 1.3},
			"visual_modifiers": {"size": 0.7}
		},
		"fire": {
			"special_abilities": ["fire_damage"],
			"visual_modifiers": {"fire_effects": true}
		},
		"ice": {
			"special_abilities": ["ice_damage", "slow_effect"],
			"visual_modifiers": {"ice_effects": true}
		},
		"poison": {
			"special_abilities": ["poison_damage"],
			"visual_modifiers": {"poison_effects": true}
		},
		"corrupted": {
			"special_abilities": ["sanity_damage"],
			"visual_modifiers": {"corruption_effects": true},
			"description_modifiers": ["twisted", "unnatural"]
		},
		"blessed": {
			"special_abilities": ["sanity_restore"],
			"visual_modifiers": {"holy_effects": true},
			"description_modifiers": ["pure", "radiant"]
		},
		"deformed": {
			"stat_modifiers": {"horror_factor": 1.3},
			"visual_modifiers": {"deformation_effects": true},
			"description_modifiers": ["grotesque", "malformed"]
		},
		"ancient": {
			"stat_modifiers": {"wisdom": 1.2, "durability": 1.3},
			"description_modifiers": ["ancient", "weathered"]
		},
		"intelligent": {
			"stat_modifiers": {"strategy": 1.3},
			"behavior_modifiers": {"ai_complexity": 1.2}
		},
		"psychic": {
			"special_abilities": ["mind_attack", "telepathy"],
			"visual_modifiers": {"psychic_effects": true}
		}
	}
	
	return tag_effects.get(tag, {})

func _calculate_synergy_effects(tags: Array[String]) -> Dictionary:
	var synergy_effects = {}
	
	# Check all possible tag combinations for synergies
	for synergy_combo in tag_synergies:
		var combo_tags = synergy_combo
		var has_all_tags = true
		
		for combo_tag in combo_tags:
			if not tags.has(combo_tag):
				has_all_tags = false
				break
		
		if has_all_tags:
			var synergy_effect = tag_synergies[synergy_combo]
			synergy_effects = _merge_effects(synergy_effects, {"synergy_effects": synergy_effect})
	
	return synergy_effects

func _merge_effects(base_effects: Dictionary, new_effects: Dictionary) -> Dictionary:
	var merged = base_effects.duplicate(true)
	
	for category in new_effects:
		if not merged.has(category):
			merged[category] = {}
		
		match category:
			"stat_modifiers":
				for stat in new_effects[category]:
					if merged[category].has(stat):
						# Multiply modifiers
						merged[category][stat] *= new_effects[category][stat]
					else:
						merged[category][stat] = new_effects[category][stat]
			
			"special_abilities":
				for ability in new_effects[category]:
					if not merged[category].has(ability):
						merged[category].append(ability)
			
			"description_modifiers":
				for modifier in new_effects[category]:
					if not merged[category].has(modifier):
						merged[category].append(modifier)
			
			_:
				# For other categories, merge dictionaries
				if typeof(new_effects[category]) == TYPE_DICTIONARY:
					for key in new_effects[category]:
						merged[category][key] = new_effects[category][key]
				else:
					merged[category] = new_effects[category]
	
	return merged

func get_tag_description(tag: String) -> String:
	# Return human-readable description for tags
	var descriptions = {
		"fast": "Moves with supernatural speed",
		"slow": "Lumbering and deliberate in movement",
		"aggressive": "Attacks with relentless fury",
		"defensive": "Cautious and protective",
		"large": "Imposing and massive in size",
		"small": "Compact and nimble",
		"fire": "Wreathed in flames",
		"ice": "Radiates freezing cold",
		"poison": "Drips with toxic substances",
		"corrupted": "Twisted by dark forces",
		"blessed": "Touched by divine power",
		"deformed": "Grotesquely malformed",
		"ancient": "Bearing the weight of ages",
		"intelligent": "Possesses cunning intellect",
		"psychic": "Manipulates minds and reality"
	}
	
	return descriptions.get(tag, "Unknown property")

func validate_tag_combination(tags: Array[String]) -> Dictionary:
	# Validate a tag combination and return issues
	var validation = {
		"valid": true,
		"conflicts": [],
		"warnings": [],
		"suggestions": []
	}
	
	# Check for conflicts
	for i in range(tags.size()):
		for j in range(i + 1, tags.size()):
			if _tags_conflict(tags[i], tags[j]):
				validation["valid"] = false
				validation["conflicts"].append([tags[i], tags[j]])
	
	# Check for too many tags
	if tags.size() > max_tags_per_entity:
		validation["warnings"].append("Too many tags for optimal performance")
	
	# Suggest synergies
	for synergy_combo in tag_synergies:
		var combo_tags = synergy_combo
		var matching_tags = 0
		
		for combo_tag in combo_tags:
			if tags.has(combo_tag):
				matching_tags += 1
		
		if matching_tags == combo_tags.size() - 1:  # Missing one tag for synergy
			for combo_tag in combo_tags:
				if not tags.has(combo_tag):
					validation["suggestions"].append("Add '" + combo_tag + "' for synergy bonus")
	
	return validation

func get_random_tag_from_category(category: String) -> String:
	if tag_categories.has(category):
		var category_tags = tag_categories[category]
		return category_tags[randi() % category_tags.size()]
	return ""

func get_all_tags() -> Array[String]:
	var all_tags: Array[String] = []
	for category in tag_categories:
		all_tags.append_array(tag_categories[category])
	return all_tags

func set_mobile_mode(enabled: bool) -> void:
	mobile_mode = enabled
	if mobile_mode:
		max_tags_per_entity = 3  # Reduce for mobile performance

func get_tag_stats() -> Dictionary:
	return {
		"total_categories": tag_categories.size(),
		"total_tags": get_all_tags().size(),
		"synergies_defined": tag_synergies.size(),
		"conflicts_defined": tag_conflicts.size(),
		"mobile_mode": mobile_mode,
		"max_tags_per_entity": max_tags_per_entity
	} 