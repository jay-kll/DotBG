extends CharacterBody2D

enum PlayerState {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	ATTACKING,
	DODGING,
	STUNNED,
	DEAD
}

# Node references
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var hurtbox: Area2D = $Hurtbox
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var dodge_timer: Timer = $DodgeTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var attack_combo_timer: Timer = $AttackComboTimer
@onready var touch_controls: CanvasLayer = $TouchControls

# State machine
var current_state: PlayerState = PlayerState.IDLE
var previous_state: PlayerState = PlayerState.IDLE

# Movement variables
var input_direction: Vector2 = Vector2.ZERO
var facing_right: bool = true
var can_move: bool = true
var is_invincible: bool = false
var coyote_jump: bool = false
var jumps_left: int = 1
var want_to_jump: bool = false

# Combat variables
var current_combo: int = 0
var is_attacking: bool = false
var can_attack: bool = true
var attack_direction: Vector2 = Vector2.RIGHT
var want_to_attack: bool = false
var want_to_dodge: bool = false

# Constants
const GRAVITY: float = 980.0
const JUMP_BUFFER_TIME: float = 0.1
const DODGE_STAMINA_COST: float = 25.0
const ATTACK_STAMINA_COST: float = 15.0

func _ready() -> void:
	# Connect signals
	dodge_timer.timeout.connect(_on_dodge_timer_timeout)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)
	coyote_timer.timeout.connect(_on_coyote_timer_timeout)
	attack_combo_timer.timeout.connect(_on_attack_combo_timer_timeout)
	
	# Connect touch control signals
	touch_controls.joystick_input.connect(_on_joystick_input)
	touch_controls.jump_pressed.connect(_on_jump_button_pressed)
	touch_controls.jump_released.connect(_on_jump_button_released)
	touch_controls.attack_pressed.connect(_on_attack_button_pressed)
	touch_controls.attack_released.connect(_on_attack_button_released)
	touch_controls.dodge_pressed.connect(_on_dodge_button_pressed)
	touch_controls.dodge_released.connect(_on_dodge_button_released)
	
	# Initialize stats
	jumps_left = PlayerStats.max_jumps

func _physics_process(delta: float) -> void:
	match current_state:
		PlayerState.IDLE, PlayerState.RUNNING:
			_handle_movement(delta)
			_handle_combat()
		PlayerState.JUMPING, PlayerState.FALLING:
			_handle_air_movement(delta)
			_handle_combat()
		PlayerState.ATTACKING:
			_handle_attack_movement(delta)
		PlayerState.DODGING:
			_handle_dodge_movement(delta)
		PlayerState.STUNNED:
			_apply_gravity(delta)
		PlayerState.DEAD:
			pass
	
	move_and_slide()
	_update_animation()
	_update_facing()

func _handle_movement(delta: float) -> void:
	if not can_move:
		return
	
	# Apply movement
	velocity.x = move_toward(
		velocity.x,
		input_direction.x * PlayerStats.get_movement_speed(),
		PlayerStats.acceleration * delta
	)
	
	# Apply gravity
	_apply_gravity(delta)
	
	# Handle jumping
	if want_to_jump:
		_try_jump()
	
	# Handle dodge roll
	if want_to_dodge:
		_try_dodge()
	
	# Update state
	if not is_on_floor():
		if velocity.y < 0:
			_change_state(PlayerState.JUMPING)
		else:
			_change_state(PlayerState.FALLING)
	else:
		jumps_left = PlayerStats.max_jumps
		if abs(velocity.x) > 10:
			_change_state(PlayerState.RUNNING)
		else:
			_change_state(PlayerState.IDLE)

func _handle_air_movement(delta: float) -> void:
	if not can_move:
		return
	
	# Apply air movement with reduced control
	velocity.x = move_toward(
		velocity.x,
		input_direction.x * PlayerStats.get_movement_speed() * PlayerStats.air_control,
		PlayerStats.acceleration * PlayerStats.air_control * delta
	)
	
	# Apply gravity
	_apply_gravity(delta)
	
	# Handle double jump
	if want_to_jump:
		_try_jump()
	
	# Update state
	if is_on_floor():
		jumps_left = PlayerStats.max_jumps
		if abs(velocity.x) > 10:
			_change_state(PlayerState.RUNNING)
		else:
			_change_state(PlayerState.IDLE)
	elif velocity.y >= 0:
		_change_state(PlayerState.FALLING)

func _handle_attack_movement(delta: float) -> void:
	# Reduced movement during attacks
	if can_move:
		velocity.x = move_toward(
			velocity.x,
			input_direction.x * PlayerStats.get_movement_speed() * 0.5,
			PlayerStats.acceleration * 0.5 * delta
		)
	
	_apply_gravity(delta)

func _handle_dodge_movement(delta: float) -> void:
	var dodge_stats = PlayerStats.get_dodge_stats()
	velocity = attack_direction * dodge_stats.speed
	
	# Apply minimal gravity during dodge
	_apply_gravity(delta * 0.5)

func _handle_combat() -> void:
	if not can_attack or is_attacking:
		return
	
	if want_to_attack:
		_try_attack()

func _try_jump() -> void:
	if is_on_floor() or coyote_jump:
		_perform_jump()
	elif jumps_left > 0:
		_perform_jump()
		jumps_left -= 1
	want_to_jump = false

func _perform_jump() -> void:
	velocity.y = -PlayerStats.jump_force
	coyote_jump = false
	_change_state(PlayerState.JUMPING)

func _try_dodge() -> void:
	if current_state == PlayerState.DODGING:
		return
		
	if PlayerStats.modify_stamina(-DODGE_STAMINA_COST):
		var dodge_stats = PlayerStats.get_dodge_stats()
		attack_direction = input_direction if input_direction != Vector2.ZERO else Vector2.RIGHT * (-1 if not facing_right else 1)
		
		can_move = false
		is_invincible = true
		dodge_timer.start(dodge_stats.recovery)
		invincibility_timer.start(dodge_stats.iframes)
		_change_state(PlayerState.DODGING)
	
	want_to_dodge = false

func _try_attack() -> void:
	if not PlayerStats.modify_stamina(-ATTACK_STAMINA_COST):
		return
	
	is_attacking = true
	can_move = false
	current_combo = (current_combo + 1) % PlayerStats.get_combo_data().limit
	
	# Set attack timing based on combo
	var attack_duration = 0.2 / PlayerStats.get_combo_data().attack_speed
	attack_timer.start(attack_duration)
	attack_combo_timer.start(0.8) # Window to continue combo
	
	_change_state(PlayerState.ATTACKING)
	want_to_attack = false

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, GRAVITY * 2, GRAVITY * delta)

func _update_facing() -> void:
	if input_direction.x != 0:
		facing_right = input_direction.x > 0
		sprite.flip_h = !facing_right
		attack_hitbox.scale.x = 1 if facing_right else -1

func _update_animation() -> void:
	match current_state:
		PlayerState.IDLE:
			sprite.play("idle")
		PlayerState.RUNNING:
			sprite.play("run")
		PlayerState.JUMPING:
			sprite.play("jump")
		PlayerState.FALLING:
			sprite.play("fall")
		PlayerState.ATTACKING:
			sprite.play("attack" + str(current_combo + 1))
		PlayerState.DODGING:
			sprite.play("dodge")
		PlayerState.STUNNED:
			sprite.play("hurt")
		PlayerState.DEAD:
			sprite.play("dead")

func _change_state(new_state: PlayerState) -> void:
	if new_state == current_state:
		return
	
	previous_state = current_state
	current_state = new_state
	
	# Handle state entry actions
	match new_state:
		PlayerState.FALLING:
			if previous_state != PlayerState.JUMPING:
				coyote_timer.start()
				coyote_jump = true

func take_damage(amount: float, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	if is_invincible:
		return
	
	PlayerStats.take_damage(amount)
	
	if knockback_direction != Vector2.ZERO:
		velocity = knockback_direction * 400
	
	is_invincible = true
	invincibility_timer.start(1.0)
	_change_state(PlayerState.STUNNED)

# Touch control signal handlers
func _on_joystick_input(direction: Vector2) -> void:
	input_direction = direction

func _on_jump_button_pressed() -> void:
	want_to_jump = true

func _on_jump_button_released() -> void:
	want_to_jump = false

func _on_attack_button_pressed() -> void:
	want_to_attack = true

func _on_attack_button_released() -> void:
	want_to_attack = false

func _on_dodge_button_pressed() -> void:
	want_to_dodge = true

func _on_dodge_button_released() -> void:
	want_to_dodge = false

# Timer signal handlers
func _on_dodge_timer_timeout() -> void:
	can_move = true
	_change_state(PlayerState.IDLE)

func _on_attack_timer_timeout() -> void:
	is_attacking = false
	can_move = true
	_change_state(PlayerState.IDLE)

func _on_invincibility_timer_timeout() -> void:
	is_invincible = false

func _on_coyote_timer_timeout() -> void:
	coyote_jump = false

func _on_attack_combo_timer_timeout() -> void:
	current_combo = 0 