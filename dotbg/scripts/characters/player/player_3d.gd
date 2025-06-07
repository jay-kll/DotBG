# Player3D.gd
# Epic 3D player controller for gothic cathedral exploration
# Adapted from 2D system but built for Hades-style perspective
extends CharacterBody3D

# Movement properties for mobile-optimized 3D movement
@export var speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0
@export var dodge_speed: float = 400.0
@export var dodge_duration: float = 0.3

# Combat properties
@export var health: int = 100
@export var max_health: int = 100
@export var attack_damage: int = 25

# State management
enum PlayerState {
	IDLE,
	MOVING,
	ATTACKING,
	DODGING,
	DEAD
}

var current_state: PlayerState = PlayerState.IDLE
var movement_input: Vector2 = Vector2.ZERO
var last_movement_direction: Vector3 = Vector3.ZERO

# Node references
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var attack_hitbox: Area3D = $AttackHitbox
@onready var dodge_timer: Timer = $DodgeTimer
@onready var attack_timer: Timer = $AttackTimer

# Animation and visual effects
var tween: Tween

signal health_changed(new_health: int)
signal player_died
signal attack_performed
signal dodge_performed

func _ready() -> void:
	print("Player3D: Epic 3D gothic warrior initialized")
	
	# Connect to InputManager for touch controls
	if InputManager:
		# Connect movement signals
		if InputManager.has_signal("movement_input"):
			InputManager.movement_input.connect(_on_movement_input)
		
		# Connect action signals  
		if InputManager.has_signal("action_triggered"):
			InputManager.action_triggered.connect(_on_action_triggered)
	
	# Set up timers
	if dodge_timer:
		dodge_timer.timeout.connect(_on_dodge_timer_timeout)
	if attack_timer:
		attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	# Connect to EventBus
	if EventBus:
		EventBus.player_spawned.emit(global_position)

func _physics_process(delta: float) -> void:
	# Handle movement based on current state
	match current_state:
		PlayerState.IDLE, PlayerState.MOVING:
			_handle_movement(delta)
		PlayerState.DODGING:
			_handle_dodge_movement(delta)
		PlayerState.ATTACKING:
			_handle_attack_movement(delta)
		PlayerState.DEAD:
			velocity = Vector3.ZERO
	
	# Apply movement
	move_and_slide()
	
	# Update visual orientation
	_update_visual_orientation()

func _handle_movement(delta: float) -> void:
	# Convert 2D input to 3D movement (Y input becomes Z movement)
	var input_vector = Vector3(movement_input.x, 0, movement_input.y)
	
	if input_vector.length() > 0.1:
		# Moving
		current_state = PlayerState.MOVING
		last_movement_direction = input_vector.normalized()
		
		# Apply acceleration
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		# Idle - apply friction
		current_state = PlayerState.IDLE
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)

func _handle_dodge_movement(delta: float) -> void:
	# Continue dodge movement in last direction
	velocity = last_movement_direction * dodge_speed
	# Y velocity handled by gravity if needed

func _handle_attack_movement(delta: float) -> void:
	# Slow movement during attack
	velocity = velocity.move_toward(Vector3.ZERO, friction * 2.0 * delta)

func _update_visual_orientation() -> void:
	# Rotate player mesh to face movement direction (for 8-directional sprites later)
	if last_movement_direction.length() > 0.1 and mesh_instance:
		var target_rotation = atan2(last_movement_direction.x, last_movement_direction.z)
		mesh_instance.rotation.y = lerp_angle(mesh_instance.rotation.y, target_rotation, 0.1)

# Input handling
func _on_movement_input(input: Vector2) -> void:
	movement_input = input

func _on_action_triggered(action: String, data: Dictionary) -> void:
	match action:
		"attack":
			_perform_attack()
		"dodge":
			_perform_dodge()
		"interact":
			_perform_interact()
		"inventory":
			_toggle_inventory()

# Combat actions
func _perform_attack() -> void:
	if current_state in [PlayerState.IDLE, PlayerState.MOVING]:
		current_state = PlayerState.ATTACKING
		
		# Enable attack hitbox
		if attack_hitbox:
			attack_hitbox.monitoring = true
		
		# Start attack timer
		if attack_timer:
			attack_timer.start(0.5)  # Attack duration
		
		# Visual attack effect
		_play_attack_animation()
		
		attack_performed.emit()
		print("Player3D: Epic attack performed!")

func _perform_dodge() -> void:
	if current_state in [PlayerState.IDLE, PlayerState.MOVING]:
		current_state = PlayerState.DODGING
		
		# Use last movement direction, or forward if standing still
		if last_movement_direction.length() < 0.1:
			last_movement_direction = Vector3(0, 0, -1)  # Default forward
		
		# Start dodge timer
		if dodge_timer:
			dodge_timer.start(dodge_duration)
		
		# Visual dodge effect
		_play_dodge_animation()
		
		dodge_performed.emit()
		print("Player3D: Epic dodge performed!")

func _perform_interact() -> void:
	print("Player3D: Interact action")
	if EventBus:
		EventBus.interaction_attempted.emit(global_position)

func _toggle_inventory() -> void:
	print("Player3D: Inventory toggle")
	if EventBus:
		EventBus.inventory_toggle_requested.emit()

# Animation methods (placeholder for future sprite integration)
func _play_attack_animation() -> void:
	if mesh_instance and tween:
		tween.kill()
	tween = create_tween()
	
	# Scale effect for attack
	var original_scale = mesh_instance.scale
	tween.tween_property(mesh_instance, "scale", original_scale * 1.2, 0.1)
	tween.tween_property(mesh_instance, "scale", original_scale, 0.4)

func _play_dodge_animation() -> void:
	if mesh_instance and tween:
		tween.kill()
	tween = create_tween()
	
	# Flash effect for dodge
	var material = mesh_instance.get_surface_override_material(0)
	if not material:
		material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, material)
	
	# Quick flash
	tween.tween_property(material, "albedo_color", Color.CYAN, 0.1)
	tween.tween_property(material, "albedo_color", Color.WHITE, 0.2)

# Timer callbacks
func _on_attack_timer_timeout() -> void:
	current_state = PlayerState.IDLE
	if attack_hitbox:
		attack_hitbox.monitoring = false

func _on_dodge_timer_timeout() -> void:
	current_state = PlayerState.IDLE

# Health management
func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	health_changed.emit(health)
	
	if health <= 0:
		_die()
	else:
		_play_hurt_animation()

func heal(amount: int) -> void:
	health = min(max_health, health + amount)
	health_changed.emit(health)

func _die() -> void:
	current_state = PlayerState.DEAD
	player_died.emit()
	print("Player3D: Epic warrior has fallen!")

func _play_hurt_animation() -> void:
	if mesh_instance and tween:
		tween.kill()
	tween = create_tween()
	
	# Red flash for damage
	var material = mesh_instance.get_surface_override_material(0)
	if not material:
		material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, material)
	
	tween.tween_property(material, "albedo_color", Color.RED, 0.1)
	tween.tween_property(material, "albedo_color", Color.WHITE, 0.3)

# Utility methods
func get_movement_direction() -> Vector3:
	return last_movement_direction

func get_player_stats() -> Dictionary:
	return {
		"health": health,
		"max_health": max_health,
		"position": global_position,
		"state": PlayerState.keys()[current_state],
		"movement_direction": last_movement_direction
	} 