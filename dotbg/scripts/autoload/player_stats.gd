extends Node

enum PlayerClass {
	CULTIST,
	WARRIOR,
	SCHOLAR
}

# Base Stats
var player_class: PlayerClass = PlayerClass.WARRIOR
var level: int = 1
var experience: int = 0
var experience_required: int = 100

# Core Stats
var max_health: float = 100.0
var current_health: float = 100.0
var attack_power: float = 10.0
var defense: float = 5.0

# Movement Stats
var base_speed: float = 200.0  # Base movement speed
var current_speed: float = 200.0  # Modified by equipment/status
var acceleration: float = 1000.0  # How quickly we reach max speed
var air_control: float = 0.7  # Multiplier for air movement (0-1)
var jump_force: float = 400.0
var max_jumps: int = 1

# Combat Stats
var attack_speed: float = 1.0  # Attack animation speed multiplier
var combo_limit: int = 2  # Starting with 2-hit combos
var dodge_distance: float = 300.0  # Base dodge roll distance
var dodge_speed: float = 600.0  # How fast the dodge executes
var dodge_iframes: float = 0.2  # Invincibility frame duration
var dodge_recovery: float = 0.8  # Time before next action
var stamina_max: float = 100.0
var stamina_current: float = 100.0
var stamina_regen: float = 20.0  # Per second

# Class-specific stats
var sanity_resistance: float = 0.0  # Cultist specialty
var physical_resistance: float = 0.0  # Warrior specialty
var item_identification: bool = false  # Scholar specialty

# Progression tracking
var max_level: int = 50
var total_kills: int = 0
var areas_cleared: int = 0
var bosses_defeated: int = 0

# Equipment and Mutations
var active_mutations: Array[String] = []
var available_mutation_slots: int = 3
var equipped_weapon: String = ""
var equipped_armor: String = ""
var equipped_artifacts: Array[String] = []

# Signals
signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal level_up_achieved(new_level: int)
signal mutation_added(mutation_id: String)
signal stats_updated()
signal combo_updated(new_limit: int)
signal movement_stats_updated()

func _ready() -> void:
	reset_stats()

func reset_stats() -> void:
	match player_class:
		PlayerClass.CULTIST:
			max_health = 80.0
			sanity_resistance = 0.5
			attack_power = 8.0
			defense = 3.0
			base_speed = 220.0  # Faster but fragile
			stamina_max = 120.0  # Better stamina management
			dodge_iframes = 0.25  # Better at avoiding damage
			
		PlayerClass.WARRIOR:
			max_health = 120.0
			physical_resistance = 0.3
			attack_power = 12.0
			defense = 7.0
			base_speed = 180.0  # Slower but tougher
			stamina_max = 100.0  # Standard stamina
			dodge_distance = 250.0  # Shorter dodge
			
		PlayerClass.SCHOLAR:
			max_health = 70.0
			item_identification = true
			attack_power = 7.0
			defense = 2.0
			base_speed = 200.0  # Standard speed
			stamina_max = 90.0  # Lower stamina
			dodge_recovery = 0.7  # Quicker recovery
	
	current_health = max_health
	stamina_current = stamina_max
	current_speed = base_speed
	health_changed.emit(current_health, max_health)
	stamina_changed.emit(stamina_current, stamina_max)

func calculate_experience_required(target_level: int) -> int:
	return int(100 * pow(1.15, target_level - 1))

func add_experience(amount: int) -> void:
	if level >= max_level:
		return
		
	experience += amount
	while experience >= experience_required and level < max_level:
		level_up()

func level_up() -> void:
	level += 1
	experience -= experience_required
	experience_required = calculate_experience_required(level + 1)
	
	# Base stat increases
	max_health += 5.0 + (level / 10.0)  # More health per level as we progress
	attack_power += 1.0 + (level / 20.0)  # Damage scales with level
	defense += 0.5 + (level / 25.0)  # Gradual defense increase
	
	# Movement improvements
	if level % 5 == 0:  # Every 5 levels
		base_speed *= 1.05  # 5% speed increase
		acceleration *= 1.05
		current_speed = base_speed
		movement_stats_updated.emit()
	
	# Combat improvements
	if level == 10:
		combo_limit = 3
		dodge_recovery *= 0.8
		combo_updated.emit(combo_limit)
	elif level == 20:
		combo_limit = 4
		dodge_iframes += 0.1
		dodge_recovery *= 0.8
		combo_updated.emit(combo_limit)
	elif level == 30:
		combo_limit = 5
		dodge_iframes += 0.1
		dodge_recovery *= 0.8
		combo_updated.emit(combo_limit)
	
	# Stamina improvements
	stamina_max += 2.0
	stamina_regen += 0.5
	
	current_health = max_health
	stamina_current = stamina_max
	
	health_changed.emit(current_health, max_health)
	stamina_changed.emit(stamina_current, stamina_max)
	level_up_achieved.emit(level)
	stats_updated.emit()

func modify_stamina(amount: float) -> bool:
	if amount < 0 and stamina_current < abs(amount):
		return false
		
	stamina_current = clamp(stamina_current + amount, 0, stamina_max)
	stamina_changed.emit(stamina_current, stamina_max)
	return true

func _process(delta: float) -> void:
	if stamina_current < stamina_max:
		stamina_current = min(stamina_max, stamina_current + stamina_regen * delta)
		stamina_changed.emit(stamina_current, stamina_max)

func take_damage(amount: float) -> void:
	var actual_damage = amount * (1.0 - (defense / (defense + 100.0)))
	if player_class == PlayerClass.WARRIOR:
		actual_damage *= (1.0 - physical_resistance)
	
	current_health = max(0.0, current_health - actual_damage)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()

func heal(amount: float) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func add_mutation(mutation_id: String) -> bool:
	if active_mutations.size() < available_mutation_slots:
		active_mutations.append(mutation_id)
		mutation_added.emit(mutation_id)
		return true
	return false

func die() -> void:
	# TODO: Fix GameManager state management after autoload setup
	# GameManager.change_game_state(GameManager.GameState.GAME_OVER)
	print("PlayerStats: Player died - TODO: Handle game over state")

# Combat stat calculations
func get_total_attack() -> float:
	return attack_power
	# TODO: Add weapon and mutation modifiers

func get_total_defense() -> float:
	return defense
	# TODO: Add armor and mutation modifiers

func get_movement_speed() -> float:
	return current_speed
	# TODO: Add status effect modifiers

# Equipment management
func equip_weapon(weapon_id: String) -> void:
	equipped_weapon = weapon_id
	# TODO: Apply weapon stats

func equip_armor(armor_id: String) -> void:
	equipped_armor = armor_id
	# TODO: Apply armor stats

func add_artifact(artifact_id: String) -> bool:
	if equipped_artifacts.size() < 3:  # Max 3 artifacts
		equipped_artifacts.append(artifact_id)
		return true
	return false

func remove_artifact(artifact_id: String) -> bool:
	var index = equipped_artifacts.find(artifact_id)
	if index >= 0:
		equipped_artifacts.remove_at(index)
		return true
	return false

func get_dodge_stats() -> Dictionary:
	return {
		"distance": dodge_distance,
		"speed": dodge_speed,
		"iframes": dodge_iframes,
		"recovery": dodge_recovery
	}

func get_combo_data() -> Dictionary:
	return {
		"limit": combo_limit,
		"attack_speed": attack_speed
	} 
