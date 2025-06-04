extends Node

# Validates generated content for safety and consistency

# Failsafe checkers for softlocks and debug logging
# Ensures generated content is playable and safe

# Safety validation rules
var validation_rules: Dictionary = {}
var critical_checks: Array[String] = []
var warning_checks: Array[String] = []

# Debug logging
var debug_logging_enabled: bool = true
var log_history: Array[Dictionary] = []
var max_log_entries: int = 1000

# Mobile optimization
var mobile_mode: bool = false
var simplified_checks: bool = false

func _ready() -> void:
	_initialize_validation_rules()
	_initialize_check_categories()
	print("SafetyChecker: Initialized for epic hybrid generation")

func _initialize_validation_rules() -> void:
	# Define validation rules for different content types
	validation_rules = {
		"dungeon": {
			"required_rooms": ["entrance"],
			"max_rooms": 20,
			"min_rooms": 3,
			"connectivity_required": true,
			"exit_required": true,
			"max_dead_ends": 3
		},
		"room": {
			"min_connections": 1,
			"max_connections": 4,
			"required_spawn_area": true,
			"max_enemies_per_room": 8,
			"min_walkable_area": 0.3
		},
		"enemy": {
			"max_health_multiplier": 5.0,
			"min_health_multiplier": 0.1,
			"max_damage_multiplier": 3.0,
			"min_damage_multiplier": 0.1,
			"required_ai_behavior": true
		},
		"item": {
			"max_stat_multiplier": 2.0,
			"min_stat_multiplier": 0.1,
			"required_category": true,
			"max_special_properties": 5
		}
	}

func _initialize_check_categories() -> void:
	# Categorize checks by severity
	critical_checks = [
		"connectivity_check",
		"exit_accessibility",
		"spawn_area_validation",
		"softlock_prevention",
		"infinite_loop_detection"
	]
	
	warning_checks = [
		"performance_impact",
		"balance_validation",
		"mobile_compatibility",
		"complexity_assessment"
	]

func validate_content(content: Dictionary, content_type: String) -> Dictionary:
	# Main validation entry point
	var validation_result = {
		"is_safe": true,
		"critical_issues": [],
		"warnings": [],
		"constraints": {},
		"suggestions": [],
		"performance_score": 1.0
	}
	
	# Log validation start
	_log_validation("validation_started", {
		"content_type": content_type,
		"content_id": content.get("id", "unknown")
	})
	
	# Run content-specific validation
	match content_type:
		"dungeon":
			validation_result = _validate_dungeon(content, validation_result)
		"room":
			validation_result = _validate_room(content, validation_result)
		"enemy":
			validation_result = _validate_enemy(content, validation_result)
		"item":
			validation_result = _validate_item(content, validation_result)
		_:
			validation_result = _validate_generic(content, validation_result)
	
	# Run universal checks
	validation_result = _run_universal_checks(content, validation_result)
	
	# Mobile-specific validation
	if mobile_mode:
		validation_result = _validate_mobile_compatibility(content, validation_result)
	
	# Log validation result
	_log_validation("validation_completed", {
		"content_type": content_type,
		"is_safe": validation_result.is_safe,
		"critical_issues": validation_result.critical_issues.size(),
		"warnings": validation_result.warnings.size()
	})
	
	return validation_result

func _validate_dungeon(content: Dictionary, result: Dictionary) -> Dictionary:
	var rules = validation_rules.get("dungeon", {})
	
	# Check room count
	var room_layouts = content.get("room_layouts", [])
	if room_layouts.size() < rules.get("min_rooms", 3):
		result.critical_issues.append("Insufficient rooms: " + str(room_layouts.size()))
		result.is_safe = false
	
	if room_layouts.size() > rules.get("max_rooms", 20):
		result.warnings.append("Too many rooms for optimal performance: " + str(room_layouts.size()))
		result.performance_score *= 0.8
	
	# Check connectivity
	if rules.get("connectivity_required", true):
		var connectivity_result = _check_dungeon_connectivity(room_layouts)
		if not connectivity_result.is_connected:
			result.critical_issues.append("Dungeon has unreachable rooms")
			result.is_safe = false
			result.constraints["fix_connectivity"] = connectivity_result.isolated_rooms
	
	# Check for entrance and exit
	var has_entrance = false
	var has_exit = false
	
	for room in room_layouts:
		var room_type = room.get("type", "")
		if room_type == "entrance":
			has_entrance = true
		if room_type == "boss_room" or room_type == "exit":
			has_exit = true
	
	if not has_entrance:
		result.critical_issues.append("No entrance room found")
		result.is_safe = false
	
	if not has_exit:
		result.warnings.append("No clear exit/boss room found")
	
	# Check for excessive dead ends
	var dead_ends = _count_dead_ends(room_layouts)
	if dead_ends > rules.get("max_dead_ends", 3):
		result.warnings.append("Too many dead ends: " + str(dead_ends))
		result.suggestions.append("Consider adding more connections between rooms")
	
	return result

func _validate_room(content: Dictionary, result: Dictionary) -> Dictionary:
	var rules = validation_rules.get("room", {})
	
	# Check connections
	var connections = content.get("connections", [])
	if connections.size() < rules.get("min_connections", 1):
		result.critical_issues.append("Room has no connections")
		result.is_safe = false
	
	if connections.size() > rules.get("max_connections", 4):
		result.warnings.append("Room has many connections: " + str(connections.size()))
	
	# Check spawn points
	var spawn_points = content.get("spawn_points", [])
	var enemy_spawns = 0
	
	for spawn in spawn_points:
		if spawn.get("type", "") == "enemy":
			enemy_spawns += 1
	
	if enemy_spawns > rules.get("max_enemies_per_room", 8):
		result.warnings.append("Too many enemy spawns: " + str(enemy_spawns))
		result.performance_score *= 0.9
	
	# Check walkable area
	var walkable_area = _calculate_walkable_area(content)
	if walkable_area < rules.get("min_walkable_area", 0.3):
		result.critical_issues.append("Insufficient walkable area: " + str(walkable_area))
		result.is_safe = false
	
	# Check for spawn area
	if rules.get("required_spawn_area", true):
		if not _has_valid_spawn_area(content):
			result.critical_issues.append("No valid player spawn area")
			result.is_safe = false
	
	return result

func _validate_enemy(content: Dictionary, result: Dictionary) -> Dictionary:
	var rules = validation_rules.get("enemy", {})
	
	# Check stat modifiers
	var stat_modifiers = content.get("stat_modifiers", {})
	
	for stat in stat_modifiers:
		var modifier = stat_modifiers[stat]
		if modifier > rules.get("max_" + stat + "_multiplier", 3.0):
			result.warnings.append("High " + stat + " modifier: " + str(modifier))
		if modifier < rules.get("min_" + stat + "_multiplier", 0.1):
			result.warnings.append("Low " + stat + " modifier: " + str(modifier))
	
	# Check AI behavior
	if rules.get("required_ai_behavior", true):
		var behavior_modifiers = content.get("behavior_modifiers", {})
		if behavior_modifiers.is_empty():
			result.warnings.append("No AI behavior defined")
	
	# Check special abilities
	var special_abilities = content.get("special_abilities", [])
	if special_abilities.size() > 5:
		result.warnings.append("Too many special abilities: " + str(special_abilities.size()))
		result.performance_score *= 0.9
	
	return result

func _validate_item(content: Dictionary, result: Dictionary) -> Dictionary:
	var rules = validation_rules.get("item", {})
	
	# Check stat modifiers
	var stat_modifiers = content.get("stat_modifiers", {})
	
	for stat in stat_modifiers:
		var modifier = stat_modifiers[stat]
		if modifier > rules.get("max_stat_multiplier", 2.0):
			result.warnings.append("High item stat modifier: " + str(modifier))
		if modifier < rules.get("min_stat_multiplier", 0.1):
			result.warnings.append("Low item stat modifier: " + str(modifier))
	
	# Check category
	if rules.get("required_category", true):
		if not content.has("category"):
			result.warnings.append("Item has no category defined")
	
	# Check special properties
	var special_properties = content.get("special_properties", [])
	if special_properties.size() > rules.get("max_special_properties", 5):
		result.warnings.append("Too many special properties: " + str(special_properties.size()))
	
	return result

func _validate_generic(content: Dictionary, result: Dictionary) -> Dictionary:
	# Generic validation for unknown content types
	if not content.has("type"):
		result.warnings.append("Content has no type defined")
	
	if not content.has("id"):
		result.warnings.append("Content has no ID defined")
	
	return result

func _run_universal_checks(content: Dictionary, result: Dictionary) -> Dictionary:
	# Run checks that apply to all content types
	
	# Check for infinite loops in generation
	if _detect_infinite_loop_potential(content):
		result.critical_issues.append("Potential infinite loop detected")
		result.is_safe = false
	
	# Check performance impact
	var complexity_score = _calculate_complexity_score(content)
	if complexity_score > 8.0:
		result.warnings.append("High complexity score: " + str(complexity_score))
		result.performance_score *= 0.7
	
	# Check for softlock potential
	if _detect_softlock_potential(content):
		result.critical_issues.append("Potential softlock detected")
		result.is_safe = false
	
	return result

func _validate_mobile_compatibility(content: Dictionary, result: Dictionary) -> Dictionary:
	# Mobile-specific validation
	
	# Check complexity for mobile
	var mobile_optimized = content.get("mobile_optimized", false)
	if not mobile_optimized:
		result.warnings.append("Content not optimized for mobile")
		result.performance_score *= 0.8
	
	# Check feature count for mobile performance
	var features = content.get("features", [])
	if features.size() > 5:
		result.warnings.append("Too many features for mobile: " + str(features.size()))
		result.suggestions.append("Consider reducing feature count for mobile")
	
	# Check environmental effects
	var environmental_effects = content.get("environmental_effects", [])
	if environmental_effects.size() > 2:
		result.warnings.append("Too many environmental effects for mobile")
		result.constraints["max_environmental_effects"] = 2
	
	return result

func _check_dungeon_connectivity(room_layouts: Array) -> Dictionary:
	# Check if all rooms are reachable
	if room_layouts.is_empty():
		return {"is_connected": false, "isolated_rooms": []}
	
	var visited = {}
	var to_visit = [0]  # Start from first room
	
	# Simple connectivity check using room connections
	while not to_visit.is_empty():
		var current_room_index = to_visit.pop_front()
		if visited.has(current_room_index):
			continue
		
		visited[current_room_index] = true
		
		# Add connected rooms to visit list
		if current_room_index < room_layouts.size():
			var room = room_layouts[current_room_index]
			var connections = room.get("connections", [])
			for connection in connections:
				if not visited.has(connection):
					to_visit.append(connection)
	
	# Check if all rooms were visited
	var isolated_rooms = []
	for i in range(room_layouts.size()):
		if not visited.has(i):
			isolated_rooms.append(i)
	
	return {
		"is_connected": isolated_rooms.is_empty(),
		"isolated_rooms": isolated_rooms
	}

func _count_dead_ends(room_layouts: Array) -> int:
	var dead_ends = 0
	
	for room in room_layouts:
		var connections = room.get("connections", [])
		if connections.size() <= 1:
			dead_ends += 1
	
	return dead_ends

func _calculate_walkable_area(content: Dictionary) -> float:
	# Calculate percentage of walkable area in room
	var dimensions = content.get("dimensions", {"width": 10, "height": 10})
	var total_area = dimensions.width * dimensions.height
	
	var blocked_area = 0.0
	var features = content.get("features", [])
	
	for feature in features:
		var feature_size = feature.get("size", Vector2(1, 1))
		blocked_area += feature_size.x * feature_size.y
	
	return (total_area - blocked_area) / total_area

func _has_valid_spawn_area(content: Dictionary) -> bool:
	# Check if room has valid area for player spawning
	var walkable_area = _calculate_walkable_area(content)
	return walkable_area >= 0.2  # At least 20% walkable area

func _detect_infinite_loop_potential(content: Dictionary) -> bool:
	# Detect potential infinite loops in content
	
	# Check for circular references in connections
	if content.has("connections"):
		var connections = content.get("connections", [])
		# Simple check - if room connects to itself
		for connection in connections:
			if connection.get("target", "") == content.get("id", ""):
				return true
	
	# Check for recursive generation patterns
	if content.has("generation_rules"):
		var rules = content.get("generation_rules", {})
		if rules.has("recursive") and rules.get("max_depth", 0) > 10:
			return true
	
	return false

func _calculate_complexity_score(content: Dictionary) -> float:
	# Calculate complexity score for performance assessment
	var score = 0.0
	
	# Base complexity from features
	var features = content.get("features", [])
	score += features.size() * 0.5
	
	# Complexity from spawn points
	var spawn_points = content.get("spawn_points", [])
	score += spawn_points.size() * 0.3
	
	# Complexity from special abilities
	var special_abilities = content.get("special_abilities", [])
	score += special_abilities.size() * 0.4
	
	# Complexity from environmental effects
	var environmental_effects = content.get("environmental_effects", [])
	score += environmental_effects.size() * 0.6
	
	# Mobile penalty
	if mobile_mode and not content.get("mobile_optimized", false):
		score *= 1.5
	
	return score

func _detect_softlock_potential(content: Dictionary) -> bool:
	# Detect potential softlock situations
	
	# Check for rooms with no exits
	if content.get("type", "") == "room":
		var connections = content.get("connections", [])
		if connections.is_empty():
			return true
	
	# Check for impossible enemy configurations
	if content.has("stat_modifiers"):
		var stat_modifiers = content.get("stat_modifiers", {})
		if stat_modifiers.get("health_modifier", 1.0) > 10.0:
			return true  # Unkillable enemy
	
	return false

func _log_validation(event_type: String, data: Dictionary) -> void:
	if not debug_logging_enabled:
		return
	
	var log_entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"event": event_type,
		"data": data
	}
	
	log_history.append(log_entry)
	
	# Manage log size for mobile memory
	if log_history.size() > max_log_entries:
		log_history = log_history.slice(max_log_entries / 2)
	
	# Print critical events
	if event_type in ["validation_failed", "critical_issue_detected"]:
		print("SafetyChecker: ", event_type, " - ", data)

# Public API
func set_mobile_mode(enabled: bool) -> void:
	mobile_mode = enabled
	simplified_checks = enabled

func enable_debug_logging(enabled: bool) -> void:
	debug_logging_enabled = enabled

func get_validation_stats() -> Dictionary:
	return {
		"total_validations": log_history.size(),
		"debug_logging": debug_logging_enabled,
		"mobile_mode": mobile_mode,
		"critical_checks": critical_checks.size(),
		"warning_checks": warning_checks.size()
	}

func get_log_history() -> Array[Dictionary]:
	return log_history.duplicate()

func clear_logs() -> void:
	log_history.clear()

func add_custom_rule(content_type: String, rule_name: String, rule_value) -> void:
	if not validation_rules.has(content_type):
		validation_rules[content_type] = {}
	
	validation_rules[content_type][rule_name] = rule_value

func remove_custom_rule(content_type: String, rule_name: String) -> void:
	if validation_rules.has(content_type):
		validation_rules[content_type].erase(rule_name) 