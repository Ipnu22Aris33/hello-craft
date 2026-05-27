extends CharacterBody2D

const SPEED := 150.0

const JUMP_FORCE := 220.0
const GRAVITY := 500.0

@onready var sprite_root := $Sprite2D

var height := 0.0
var vertical_velocity := 0.0

func _physics_process(delta):
	# ------------------------------------------------
	# MOVE
	# ------------------------------------------------
	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	var iso := Vector2(
		input.x - input.y,
		(input.x + input.y) * 0.5
	)

	if iso.length() > 0:
		iso = iso.normalized()

	velocity = iso * SPEED

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

	# VISUAL OFFSET
	sprite_root.position.y = - height
