extends CharacterBody2D

# Constants
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

var debug_offset_down := false



func _physics_process(delta: float) -> void:

	if Input.is_key_pressed(KEY_H):
		debug_offset_down = true
	else:
		debug_offset_down = false

	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	var move := Vector2.ZERO
	
	# --- Isometric movement mapping ---
	# Up arrow -> move top-left (isometric)
	if input == Vector2.UP:
		move = Vector2.LEFT + Vector2.UP * 0.5
	# Down arrow -> move bottom-right
	elif input == Vector2.DOWN:
		move = Vector2.RIGHT + Vector2.DOWN * 0.5
	# Left arrow -> move bottom-left
	elif input == Vector2.LEFT:
		move = Vector2.LEFT + Vector2.DOWN * 0.5
	# Right arrow -> move top-right
	elif input == Vector2.RIGHT:
		move = Vector2.RIGHT + Vector2.UP * 0.5
	# Diagonal top-right -> move straight up
	elif input == Vector2(1, -1):
		move = Vector2.UP
	# Diagonal top-left -> move straight left
	elif input == Vector2(-1, -1):
		move = Vector2.LEFT
	# Diagonal bottom-right -> move straight right
	elif input == Vector2(1, 1):
		move = Vector2.RIGHT
	# Diagonal bottom-left -> move straight down
	elif input == Vector2(-1, 1):
		move = Vector2.DOWN
	
	move = move.normalized()
	
	if move != Vector2.ZERO:
		facing_direction = move
	
	# --- Dash mechanic ---
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
	
	# --- Jump & gravity ---
	var want_jump := Input.is_action_just_pressed("ui_accept")
	
	if want_jump and height == 0:
		vertical_velocity = JUMP_FORCE
	
	vertical_velocity -= GRAVITY * delta
	height += vertical_velocity * delta
	
	if height < 0:
		height = 0
		vertical_velocity = 0
	
	# --- Visual height offset for isometric ---
	var iso_offset := Vector2(
		facing_direction.x - facing_direction.y,
		(facing_direction.x + facing_direction.y) * 0.5
	).normalized()

	var extra_offset := 0.0
	if debug_offset_down:
		extra_offset = 10.0
	
	sprite.position = Vector2(
		iso_offset.x * height * 0.15,
		-height + extra_offset
	)
	
	# --- Animation ---
	if velocity.length() > 0:
		sprite.speed_scale = 1.8 if Input.is_key_pressed(KEY_SHIFT) else 1.0
		sprite.play("default")
	else:
		sprite.stop()
