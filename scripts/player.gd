extends CharacterBody2D

const WALK_SPEED := 150.0
const RUN_SPEED := 260.0

const DASH_SPEED := 700.0
const DASH_TIME := 0.15

const JUMP_FORCE := 220.0
const GRAVITY := 500.0


# ------------------------------------------------
# JUMP
# ------------------------------------------------

var height := 0.0
var vertical_velocity := 0.0

# ------------------------------------------------
# DASH
# ------------------------------------------------

var dash_timer := 0.0
var dash_direction := Vector2.ZERO

# arah terakhir player
var facing_direction := Vector2.RIGHT

func _physics_process(delta):
	# ------------------------------------------------
	# INPUT
	# ------------------------------------------------
	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	# ------------------------------------------------
	# ISOMETRIC
	# ------------------------------------------------

	var iso := Vector2(
		input.x - input.y,
		(input.x + input.y) * 0.5
	)

	if iso.length() > 0:
		iso = iso.normalized()

		# simpan arah terakhir
		facing_direction = iso

	# ------------------------------------------------
	# DASH START
	# ------------------------------------------------

	if Input.is_action_just_pressed("ui_focus_next"):
		dash_timer = DASH_TIME
		dash_direction = facing_direction

	# ------------------------------------------------
	# DASH MOVE
	# ------------------------------------------------

	if dash_timer > 0:
		dash_timer -= delta

		velocity = dash_direction * DASH_SPEED

	# ------------------------------------------------
	# NORMAL MOVE
	# ------------------------------------------------

	else:
		var speed := WALK_SPEED

		# RUN
		if Input.is_key_pressed(KEY_SHIFT):
			speed = RUN_SPEED

		velocity = iso * speed

	# ------------------------------------------------
	# MOVE
	# ------------------------------------------------

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

	# ------------------------------------------------
	# VISUAL HEIGHT
	# ------------------------------------------------

	$Sprite2D.position.y = - height