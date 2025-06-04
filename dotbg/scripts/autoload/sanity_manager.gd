extends Node

# Sanity level thresholds for epic campaign
enum SanityLevel {
	HIGH,    # 75-100%: Stable reality
	MEDIUM,  # 50-74%: Minor distortions
	LOW,     # 25-49%: Major corruption
	ZERO     # 0-24%: Complete breakdown
}

# Current sanity state
var current_sanity: float = 100.0
var max_sanity: float = 100.0
var sanity_level: SanityLevel = SanityLevel.HIGH

# Sanity change tracking for epic campaigns
var sanity_history: Array[Dictionary] = []
var corruption_intensity: float = 0.0
var reality_distortion_active: bool = false

# Epic campaign sanity thresholds
const SANITY_THRESHOLDS = {
	SanityLevel.HIGH: 75.0,
	SanityLevel.MEDIUM: 50.0,
	SanityLevel.LOW: 25.0,
	SanityLevel.ZERO: 0.0
}

# Sanity effects configuration for mobile optimization
var corruption_effects_enabled: bool = true
var ui_corruption_intensity: float = 0.0
var save_corruption_probability: float = 0.0

# Signals for hybrid system coordination
signal sanity_changed(new_value: float, max_value: float, level: SanityLevel)
signal sanity_level_changed(old_level: SanityLevel, new_level: SanityLevel)
signal corruption_intensity_changed(intensity: float)
signal reality_distortion_triggered(distortion_type: String, intensity: float)
signal sanity_effect_applied(effect_type: String, target: Node)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect to GameManager for integration
	# TODO: Fix signal connections after autoload initialization
	# if GameManager:
	#	GameManager.sanity_changed.connect(_on_game_manager_sanity_changed)
	
	# Initialize sanity tracking
	_update_sanity_level()
	_log_sanity_event("sanity_manager_initialized", {"initial_sanity": current_sanity})

func _on_game_manager_sanity_changed(new_value: float, max_value: float) -> void:
	# Sync with GameManager sanity changes
	set_sanity(new_value, max_value)

func set_sanity(new_value: float, new_max: float = max_sanity) -> void:
	var old_level = sanity_level
	var old_sanity = current_sanity
	
	current_sanity = clamp(new_value, 0.0, new_max)
	max_sanity = new_max
	
	_update_sanity_level()
	_update_corruption_intensity()
	
	# Log sanity change for epic campaign tracking
	_log_sanity_event("sanity_changed", {
		"old_sanity": old_sanity,
		"new_sanity": current_sanity,
		"old_level": old_level,
		"new_level": sanity_level
	})
	
	# Emit signals for system coordination
	sanity_changed.emit(current_sanity, max_sanity, sanity_level)
	
	if old_level != sanity_level:
		sanity_level_changed.emit(old_level, sanity_level)
		_apply_sanity_level_effects(sanity_level)

func modify_sanity(amount: float, reason: String = "unknown") -> void:
	var old_sanity = current_sanity
	set_sanity(current_sanity + amount)
	
	# Log the modification for debugging
	_log_sanity_event("sanity_modified", {
		"amount": amount,
		"reason": reason,
		"old_sanity": old_sanity,
		"new_sanity": current_sanity
	})

func _update_sanity_level() -> void:
	var sanity_percentage = (current_sanity / max_sanity) * 100.0
	
	if sanity_percentage >= SANITY_THRESHOLDS[SanityLevel.HIGH]:
		sanity_level = SanityLevel.HIGH
	elif sanity_percentage >= SANITY_THRESHOLDS[SanityLevel.MEDIUM]:
		sanity_level = SanityLevel.MEDIUM
	elif sanity_percentage >= SANITY_THRESHOLDS[SanityLevel.LOW]:
		sanity_level = SanityLevel.LOW
	else:
		sanity_level = SanityLevel.ZERO

func _update_corruption_intensity() -> void:
	var old_intensity = corruption_intensity
	
	# Calculate corruption intensity based on sanity level
	match sanity_level:
		SanityLevel.HIGH:
			corruption_intensity = 0.0
			ui_corruption_intensity = 0.0
			save_corruption_probability = 0.0
		SanityLevel.MEDIUM:
			corruption_intensity = 0.25
			ui_corruption_intensity = 0.1
			save_corruption_probability = 0.05
		SanityLevel.LOW:
			corruption_intensity = 0.6
			ui_corruption_intensity = 0.4
			save_corruption_probability = 0.2
		SanityLevel.ZERO:
			corruption_intensity = 1.0
			ui_corruption_intensity = 0.8
			save_corruption_probability = 0.5
	
	if old_intensity != corruption_intensity:
		corruption_intensity_changed.emit(corruption_intensity)

func _apply_sanity_level_effects(level: SanityLevel) -> void:
	if not corruption_effects_enabled:
		return
	
	# Coordinate with other epic systems
	match level:
		SanityLevel.HIGH:
			_apply_high_sanity_effects()
		SanityLevel.MEDIUM:
			_apply_medium_sanity_effects()
		SanityLevel.LOW:
			_apply_low_sanity_effects()
		SanityLevel.ZERO:
			_apply_zero_sanity_effects()

func _apply_high_sanity_effects() -> void:
	# Stable reality - no corruption
	reality_distortion_active = false
	
	# Notify other systems to reset corruption
	EventBus.emit_signal("sanity_corruption_reset")
	_log_sanity_event("high_sanity_effects", {"message": "Reality stable"})

func _apply_medium_sanity_effects() -> void:
	# Minor distortions - whispers, visual flickers
	reality_distortion_active = true
	
	# Trigger minor UI corruption
	if randf() < 0.3:  # 30% chance
		_trigger_reality_distortion("minor_ui_flicker", 0.2)
	
	# Occasional false audio
	if randf() < 0.1:  # 10% chance
		_trigger_reality_distortion("whispers", 0.3)
	
	_log_sanity_event("medium_sanity_effects", {"corruption_intensity": corruption_intensity})

func _apply_low_sanity_effects() -> void:
	# Major corruption - UI lies, false enemies
	reality_distortion_active = true
	
	# Trigger UI corruption
	if randf() < 0.6:  # 60% chance
		_trigger_reality_distortion("ui_corruption", 0.6)
	
	# Spawn hallucinated enemies
	if randf() < 0.3:  # 30% chance
		_trigger_reality_distortion("false_enemies", 0.5)
	
	# Map corruption
	if randf() < 0.4:  # 40% chance
		_trigger_reality_distortion("map_lies", 0.4)
	
	_log_sanity_event("low_sanity_effects", {"corruption_intensity": corruption_intensity})

func _apply_zero_sanity_effects() -> void:
	# Complete breakdown - everything lies
	reality_distortion_active = true
	
	# Guaranteed UI corruption
	_trigger_reality_distortion("complete_ui_breakdown", 1.0)
	
	# Save system lies
	_trigger_reality_distortion("save_corruption", 0.8)
	
	# Reality questioning
	_trigger_reality_distortion("reality_breakdown", 1.0)
	
	_log_sanity_event("zero_sanity_effects", {"message": "Complete reality breakdown"})

func _trigger_reality_distortion(distortion_type: String, intensity: float) -> void:
	reality_distortion_triggered.emit(distortion_type, intensity)
	
	# Log for debugging epic campaigns
	_log_sanity_event("reality_distortion", {
		"type": distortion_type,
		"intensity": intensity,
		"sanity_level": sanity_level
	})

func _log_sanity_event(event_type: String, data: Dictionary) -> void:
	var log_entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"event": event_type,
		"sanity": current_sanity,
		"level": sanity_level,
		"data": data
	}
	
	sanity_history.append(log_entry)
	
	# Keep history manageable for mobile memory
	if sanity_history.size() > 1000:
		sanity_history = sanity_history.slice(500)  # Keep last 500 entries

# Epic campaign sanity recovery methods
func recover_sanity_slowly(amount: float) -> void:
	# Gradual sanity recovery for epic campaigns
	modify_sanity(amount, "slow_recovery")

func lose_sanity_from_horror(amount: float, horror_source: String) -> void:
	# Sanity loss from horror encounters
	modify_sanity(-amount, "horror_" + horror_source)

func apply_sanity_mutation_effect(mutation_id: String, effect_amount: float) -> void:
	# Mutation effects on sanity for epic progression
	modify_sanity(effect_amount, "mutation_" + mutation_id)

# Utility functions for other systems
func get_sanity_percentage() -> float:
	return (current_sanity / max_sanity) * 100.0

func is_sanity_critical() -> bool:
	return sanity_level == SanityLevel.ZERO

func is_corruption_active() -> bool:
	return reality_distortion_active

func get_corruption_intensity() -> float:
	return corruption_intensity

func get_ui_corruption_intensity() -> float:
	return ui_corruption_intensity

func get_save_corruption_probability() -> float:
	return save_corruption_probability

# Debug and development functions
func force_sanity_level(level: SanityLevel) -> void:
	match level:
		SanityLevel.HIGH:
			set_sanity(90.0)
		SanityLevel.MEDIUM:
			set_sanity(60.0)
		SanityLevel.LOW:
			set_sanity(35.0)
		SanityLevel.ZERO:
			set_sanity(10.0)

func get_sanity_history() -> Array[Dictionary]:
	return sanity_history.duplicate()

func reset_sanity_system() -> void:
	current_sanity = max_sanity
	sanity_level = SanityLevel.HIGH
	corruption_intensity = 0.0
	reality_distortion_active = false
	sanity_history.clear()
	_log_sanity_event("system_reset", {"message": "Sanity system reset"}) 