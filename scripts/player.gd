extends CharacterBody2D

const WALK_SPEED := 150.0
const RUN_SPEED := 260.0

const DASH_SPEED := 700.0
const DASH_TIME := 0.15

const JUMP_FORCE := 220.0
const GRAVITY := 500.0

@onready var sprite := $AnimatedSprite2D

var height := 0.0
var vertical_velocity := 0.0

var dash_timer := 0.0
var dash_direction := Vector2.ZERO
var facing_direction := Vector2.DOWN

func _physics_process(delta: float) -> void:
	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	var move := Vector2.ZERO

	# ------------------------------------------------
	# SINGLE DIRECTION
	# ------------------------------------------------

	# UP = 
	if input == Vector2.UP:
		move = Vector2.LEFT + Vector2.UP * 0.5

	# DOWN
	elif input == Vector2.DOWN:
		move = Vector2.RIGHT + Vector2.DOWN * 0.5

	# LEFT
	elif input == Vector2.LEFT:
		move = Vector2.LEFT + Vector2.DOWN * 0.5

	# RIGHT
	elif input == Vector2.RIGHT:
		move = Vector2.RIGHT + Vector2.UP * 0.5

	# RIGHT + UP = lurus atas
	elif input == Vector2(1, -1):
		move = Vector2.UP

	# LEFT + UP = lurus kiri
	elif input == Vector2(-1, -1):
		move = Vector2.LEFT

	# RIGHT + DOWN = lurus kanan
	elif input == Vector2(1, 1):
		move = Vector2.RIGHT

	# LEFT + DOWN = lurus bawah
	elif input == Vector2(-1, 1):
		move = Vector2.DOWN

	move = move.normalized()

	if move != Vector2.ZERO:
		facing_direction = move

	# ------------------------------------------------
	# DASH
	# ------------------------------------------------

	if Input.is_action_just_pressed("ui_focus_next"):
		dash_timer = DASH_TIME
		dash_direction = facing_direction

	if dash_timer > 0:
		dash_timer -= delta

		velocity = dash_direction * DASH_SPEED

	else:
		var speed := WALK_SPEED

		if Input.is_key_pressed(KEY_SHIFT):
			speed = RUN_SPEED

		velocity = move * speed

	move_and_slide()

	# ------------------------------------------------
	# JUMP
	# ------------------------------------------------

	if Input.is_action_just_pressed("ui_accept") and height == 0:
		vertical_velocity = JUMP_FORCE

	vertical_velocity -= GRAVITY * delta

	height += vertical_velocity * delta

	if height < 0:
		height = 0
		vertical_velocity = 0

	sprite.position.y = - height

	# ------------------------------------------------
	# ANIMATION
	# ------------------------------------------------

	if velocity.length() > 0:
		sprite.speed_scale = (
			1.8
			if Input.is_key_pressed(KEY_SHIFT)
			else 1.0
		)

		sprite.play("default")

	else:
		sprite.stop()