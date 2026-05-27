extends CharacterBody2D

const SPEED := 100.0
const JUMP_FORCE := -200.0
const GRAVITY := 500.0

func _physics_process(delta: float) -> void:
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

	velocity.x = iso.x * SPEED
	velocity.y += GRAVITY * delta

	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE

	move_and_slide()