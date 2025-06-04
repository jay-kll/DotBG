extends CanvasLayer

signal joystick_input(direction: Vector2)
signal jump_pressed
signal jump_released
signal attack_pressed
signal attack_released
signal dodge_pressed
signal dodge_released

@onready var joystick_base: TextureRect = $Left/JoystickBase
@onready var joystick_thumb: TextureRect = $Left/JoystickBase/JoystickThumb
@onready var jump_button: TouchScreenButton = $Right/ActionButtons/JumpButton
@onready var attack_button: TouchScreenButton = $Right/ActionButtons/AttackButton
@onready var dodge_button: TouchScreenButton = $Right/ActionButtons/DodgeButton

var joystick_active: bool = false
var joystick_origin: Vector2
var current_joystick_position: Vector2
var joystick_radius: float = 100.0

func _ready() -> void:
	# Connect button signals
	jump_button.pressed.connect(_on_jump_pressed)
	jump_button.released.connect(_on_jump_released)
	attack_button.pressed.connect(_on_attack_pressed)
	attack_button.released.connect(_on_attack_released)
	dodge_button.pressed.connect(_on_dodge_pressed)
	dodge_button.released.connect(_on_dodge_released)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Check if touch is within joystick area
		var touch_pos = event.position
		var joystick_rect = joystick_base.get_global_rect()
		
		if joystick_rect.has_point(touch_pos):
			joystick_active = true
			joystick_origin = touch_pos
			current_joystick_position = touch_pos
			_update_joystick()
	else:
		if joystick_active:
			joystick_active = false
			joystick_thumb.position = Vector2.ZERO
			joystick_input.emit(Vector2.ZERO)

func _handle_drag(event: InputEventScreenDrag) -> void:
	if joystick_active:
		current_joystick_position = event.position
		_update_joystick()

func _update_joystick() -> void:
	var direction = (current_joystick_position - joystick_origin).limit_length(joystick_radius)
	joystick_thumb.position = direction
	joystick_input.emit(direction / joystick_radius)

func _on_jump_pressed() -> void:
	jump_pressed.emit()

func _on_jump_released() -> void:
	jump_released.emit()

func _on_attack_pressed() -> void:
	attack_pressed.emit()

func _on_attack_released() -> void:
	attack_released.emit()

func _on_dodge_pressed() -> void:
	dodge_pressed.emit()

func _on_dodge_released() -> void:
	dodge_released.emit() 