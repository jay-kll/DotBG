extends Node

# Hybrid generation approach: Handcrafted foundations + Procedural details
# Base world elements = Handcrafted
# Dungeon interiors, enemy variants, item modifiers = Procedural
# Lore fragments = Semi-procedural from hand-written pools

# Core hybrid managers
var handcrafted_manager: HandcraftedManager
var procedural_manager: ProceduralManager
var tag_system: TagSystem
var template_system: TemplateSystem
var safety_checker: SafetyChecker

# Generation state for epic campaigns
var current_generation_context: Dictionary = {}
var generation_history: Array[Dictionary] = []
var hybrid_content_cache: Dictionary = {}

# Mobile performance optimization
var max_concurrent_generations: int = 3
var current_generations: int = 0
var generation_queue: Array[Dictionary] = []

# Epic campaign configuration
var epic_mode_enabled: bool = true
var act_specific_generation: bool = true
var sanity_influenced_generation: bool = true

# Signals for hybrid coordination
signal hybrid_generation_started(content_type: String, context: Dictionary)
signal hybrid_generation_completed(content_type: String, result: Dictionary)
signal hybrid_generation_failed(content_type: String, error: String)
signal handcrafted_template_loaded(template_id: String, template_data: Dictionary)
signal procedural_details_generated(base_id: String, details: Dictionary)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initialize hybrid subsystems
	_initialize_hybrid_systems()
	
	# Connect to epic campaign systems
	_connect_epic_systems()
	
	print("HybridGenerator: Epic hybrid procedural system initialized")

func _initialize_hybrid_systems() -> void:
	# Initialize core hybrid components
	handcrafted_manager = HandcraftedManager.new()
	procedural_manager = ProceduralManager.new()
	tag_system = TagSystem.new()
	template_system = TemplateSystem.new()
	safety_checker = SafetyChecker.new()
	
	# Add as children for proper lifecycle management
	add_child(handcrafted_manager)
	add_child(procedural_manager)
	add_child(tag_system)
	add_child(template_system)
	add_child(safety_checker)
	
	# Configure for mobile performance
	_configure_mobile_optimization()

func _configure_mobile_optimization() -> void:
	# Adjust generation limits for mobile devices
	max_concurrent_generations = 2  # Conservative for mobile
	
	# Configure subsystems for mobile
	if procedural_manager:
		procedural_manager.set_mobile_mode(true)
	if template_system:
		template_system.set_cache_limit(50)  # Limit template cache

func _connect_epic_systems() -> void:
	# Connect to SanityManager for sanity-influenced generation
	# TODO: Fix signal connections after autoload initialization
	# if SanityManager:
	#	SanityManager.sanity_level_changed.connect(_on_sanity_level_changed)
	#	SanityManager.reality_distortion_triggered.connect(_on_reality_distortion)
	
	# Connect to GameManager for act-specific generation
	# TODO: Fix signal connections after autoload initialization
	# if GameManager:
	#	GameManager.act_changed.connect(_on_act_changed)
	#	GameManager.area_changed.connect(_on_area_changed)
	
	pass  # Placeholder until autoload connections are fixed

func _on_sanity_level_changed(old_level: SanityManager.SanityLevel, new_level: SanityManager.SanityLevel) -> void:
	if sanity_influenced_generation:
		_update_generation_context_for_sanity(new_level)

func _on_reality_distortion(distortion_type: String, intensity: float) -> void:
	# Apply reality distortion to ongoing generations
	_apply_distortion_to_generation(distortion_type, intensity)

func _on_act_changed(new_act: int) -> void:
	if act_specific_generation:
		_update_generation_context_for_act(new_act)

func _on_area_changed(area_id: String) -> void:
	# Update generation context for new areas
	_update_generation_context_for_area(area_id)

# Core hybrid generation methods
func generate_hybrid_content(content_type: String, base_template_id: String, context: Dictionary = {}) -> Dictionary:
	# Main hybrid generation entry point
	hybrid_generation_started.emit(content_type, context)
	
	var generation_id = _create_generation_id()
	var generation_context = _prepare_generation_context(content_type, base_template_id, context)
	
	# Check if we can generate now or need to queue
	if current_generations >= max_concurrent_generations:
		_queue_generation(generation_id, content_type, base_template_id, generation_context)
		return {"status": "queued", "generation_id": generation_id}
	
	return _execute_hybrid_generation(generation_id, content_type, base_template_id, generation_context)

func _execute_hybrid_generation(generation_id: String, content_type: String, base_template_id: String, context: Dictionary) -> Dictionary:
	current_generations += 1
	
	var result = {}
	
	# Step 1: Load handcrafted foundation
	var handcrafted_base = handcrafted_manager.load_template(base_template_id, content_type)
	if handcrafted_base.is_empty():
		var error_msg = "Failed to load handcrafted template: " + base_template_id
		print("HybridGenerator Error: " + error_msg)
		result = {"status": "error", "error": error_msg, "generation_id": generation_id}
		hybrid_generation_failed.emit(content_type, error_msg)
		current_generations -= 1
		_process_generation_queue()
		return result
	
	handcrafted_template_loaded.emit(base_template_id, handcrafted_base)
	
	# Step 2: Generate procedural details
	var procedural_details = procedural_manager.generate_details(handcrafted_base, context)
	if procedural_details.is_empty():
		var error_msg = "Failed to generate procedural details"
		print("HybridGenerator Error: " + error_msg)
		result = {"status": "error", "error": error_msg, "generation_id": generation_id}
		hybrid_generation_failed.emit(content_type, error_msg)
		current_generations -= 1
		_process_generation_queue()
		return result
	
	procedural_details_generated.emit(base_template_id, procedural_details)
	
	# Step 3: Apply tag system modifications
	var tagged_content = tag_system.apply_tags(handcrafted_base, procedural_details, context)
	
	# Step 4: Safety validation
	var safety_result = safety_checker.validate_content(tagged_content, content_type)
	if not safety_result.is_safe:
		print("HybridGenerator: Safety check failed, regenerating...")
		# Attempt regeneration with safety constraints
		procedural_details = procedural_manager.generate_details(handcrafted_base, context, safety_result.constraints)
		tagged_content = tag_system.apply_tags(handcrafted_base, procedural_details, context)
	
	# Step 5: Finalize hybrid content
	result = _finalize_hybrid_content(handcrafted_base, procedural_details, tagged_content, context)
	result["generation_id"] = generation_id
	result["status"] = "success"
	
	# Cache for performance
	_cache_hybrid_content(generation_id, result)
	
	# Log generation for epic campaign tracking
	_log_generation(generation_id, content_type, base_template_id, context, result)
	
	hybrid_generation_completed.emit(content_type, result)
	
	current_generations -= 1
	_process_generation_queue()
	
	return result

func _finalize_hybrid_content(handcrafted_base: Dictionary, procedural_details: Dictionary, tagged_content: Dictionary, context: Dictionary) -> Dictionary:
	var final_content = {}
	
	# Merge handcrafted foundation with procedural details
	final_content = handcrafted_base.duplicate(true)
	
	# Apply procedural modifications
	for key in procedural_details:
		if key in final_content:
			# Merge or replace based on content type
			if typeof(final_content[key]) == TYPE_DICTIONARY and typeof(procedural_details[key]) == TYPE_DICTIONARY:
				final_content[key].merge(procedural_details[key])
			else:
				final_content[key] = procedural_details[key]
		else:
			final_content[key] = procedural_details[key]
	
	# Apply tag modifications
	if tagged_content.has("tag_modifications"):
		_apply_tag_modifications(final_content, tagged_content.tag_modifications)
	
	# Apply epic campaign context
	if epic_mode_enabled:
		_apply_epic_context(final_content, context)
	
	return final_content

func _apply_tag_modifications(content: Dictionary, modifications: Dictionary) -> void:
	# Apply tag-based modifications to content
	for mod_key in modifications:
		var modification = modifications[mod_key]
		if modification.has("target_path") and modification.has("value"):
			_set_nested_value(content, modification.target_path, modification.value)

func _apply_epic_context(content: Dictionary, context: Dictionary) -> void:
	# Apply epic campaign specific modifications
	if context.has("act"):
		_apply_act_specific_modifications(content, context.act)
	
	if context.has("sanity_level"):
		_apply_sanity_modifications(content, context.sanity_level)
	
	if context.has("player_mutations"):
		_apply_mutation_modifications(content, context.player_mutations)

func _apply_act_specific_modifications(content: Dictionary, act: int) -> void:
	# Modify content based on current act
	match act:
		1:  # The Descending City
			_apply_city_modifications(content)
		2:  # The Drowning Depths
			_apply_depths_modifications(content)
		3:  # The Dream Realm
			_apply_dream_modifications(content)

func _apply_sanity_modifications(content: Dictionary, sanity_level: SanityManager.SanityLevel) -> void:
	# Modify content based on sanity level
	match sanity_level:
		SanityManager.SanityLevel.HIGH:
			# Stable, accurate content
			pass
		SanityManager.SanityLevel.MEDIUM:
			# Minor distortions
			_apply_minor_distortions(content)
		SanityManager.SanityLevel.LOW:
			# Major corruption
			_apply_major_corruption(content)
		SanityManager.SanityLevel.ZERO:
			# Complete lies
			_apply_complete_corruption(content)

# Utility methods
func _create_generation_id() -> String:
	return "hybrid_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

func _prepare_generation_context(content_type: String, base_template_id: String, context: Dictionary) -> Dictionary:
	var full_context = context.duplicate()
	
	# Add current epic campaign state
	# TODO: Fix after autoload initialization
	# if GameManager:
	#	full_context["current_act"] = GameManager.current_act
	#	full_context["current_area"] = GameManager.current_area
	
	# TODO: Fix after autoload initialization
	# if SanityManager:
	#	full_context["sanity_level"] = SanityManager.sanity_level
	#	full_context["corruption_intensity"] = SanityManager.get_corruption_intensity()
	
	if PlayerStats:
		full_context["player_mutations"] = PlayerStats.get_active_mutations()
		full_context["player_level"] = PlayerStats.level
	
	full_context["content_type"] = content_type
	full_context["base_template_id"] = base_template_id
	full_context["generation_timestamp"] = Time.get_unix_time_from_system()
	
	return full_context

func _queue_generation(generation_id: String, content_type: String, base_template_id: String, context: Dictionary) -> void:
	generation_queue.append({
		"generation_id": generation_id,
		"content_type": content_type,
		"base_template_id": base_template_id,
		"context": context
	})

func _process_generation_queue() -> void:
	if generation_queue.is_empty() or current_generations >= max_concurrent_generations:
		return
	
	var next_generation = generation_queue.pop_front()
	_execute_hybrid_generation(
		next_generation.generation_id,
		next_generation.content_type,
		next_generation.base_template_id,
		next_generation.context
	)

func _cache_hybrid_content(generation_id: String, content: Dictionary) -> void:
	hybrid_content_cache[generation_id] = content
	
	# Manage cache size for mobile memory
	if hybrid_content_cache.size() > 100:
		var oldest_keys = hybrid_content_cache.keys().slice(0, 50)
		for key in oldest_keys:
			hybrid_content_cache.erase(key)

func _log_generation(generation_id: String, content_type: String, base_template_id: String, context: Dictionary, result: Dictionary) -> void:
	var log_entry = {
		"generation_id": generation_id,
		"content_type": content_type,
		"base_template_id": base_template_id,
		"context": context,
		"result_status": result.get("status", "unknown"),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	generation_history.append(log_entry)
	
	# Keep history manageable for mobile
	if generation_history.size() > 500:
		generation_history = generation_history.slice(250)

# Public API for other systems
func get_cached_content(generation_id: String) -> Dictionary:
	return hybrid_content_cache.get(generation_id, {})

func clear_cache() -> void:
	hybrid_content_cache.clear()

func get_generation_stats() -> Dictionary:
	return {
		"current_generations": current_generations,
		"queued_generations": generation_queue.size(),
		"cached_content": hybrid_content_cache.size(),
		"total_generations": generation_history.size()
	}

# Placeholder methods for subsystem implementations
func _set_nested_value(dict: Dictionary, path: String, value) -> void:
	# Implementation for setting nested dictionary values
	var keys = path.split(".")
	var current = dict
	for i in range(keys.size() - 1):
		if not current.has(keys[i]):
			current[keys[i]] = {}
		current = current[keys[i]]
	current[keys[-1]] = value

func _apply_minor_distortions(content: Dictionary) -> void:
	# Apply minor sanity-based distortions
	pass

func _apply_major_corruption(content: Dictionary) -> void:
	# Apply major sanity-based corruption
	pass

func _apply_complete_corruption(content: Dictionary) -> void:
	# Apply complete sanity breakdown effects
	pass

func _apply_city_modifications(content: Dictionary) -> void:
	# Apply Act 1 specific modifications
	pass

func _apply_depths_modifications(content: Dictionary) -> void:
	# Apply Act 2 specific modifications
	pass

func _apply_dream_modifications(content: Dictionary) -> void:
	# Apply Act 3 specific modifications
	pass

func _apply_mutation_modifications(content: Dictionary, mutations: Array) -> void:
	# Apply player mutation effects to generated content
	pass

func _update_generation_context_for_sanity(sanity_level: SanityManager.SanityLevel) -> void:
	current_generation_context["sanity_level"] = sanity_level

func _update_generation_context_for_act(act: int) -> void:
	current_generation_context["current_act"] = act

func _update_generation_context_for_area(area_id: String) -> void:
	current_generation_context["current_area"] = area_id

func _apply_distortion_to_generation(distortion_type: String, intensity: float) -> void:
	# Apply real-time distortion to ongoing generations
	current_generation_context["active_distortion"] = {
		"type": distortion_type,
		"intensity": intensity
	}

func throw_error(message: String) -> void:
	push_error(message)
	# In a real implementation, this would throw an exception 