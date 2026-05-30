extends CharacterBody2D

# Constants
const WALK_SPEED := 150.0
const RUN_SPEED := 260.0
const DASH_SPEED := 700.0
const DASH_TIME := 0.15
const JUMP_FORCE := 220.0
const GRAVITY := 500.0

@onready var sprite := $AnimatedSprite2D

# State
var height := 0.0
var vertical_velocity := 0.0
var dash_timer := 0.0
var dash_direction := Vector2.ZERO
var facing_direction := Vector2.DOWN

# Effect state
var has_effect := false
var visual_offset := 0.0
var speed_mult := 1.0

# Debug
var debug_offset_down := false

# World reference
var world: Node2D

# -------------------------------------------------
# APPLY EFFECT DARI BLOCK
# -------------------------------------------------



func apply_block_effect(block: Dictionary) -> void:
	var effect = block.get("effect", {})
	has_effect = not effect.is_empty()
	
	if has_effect:
		speed_mult = effect.get("speed_mult", 1.0)
		visual_offset = effect.get("visual_offset", 0.0)
	else:
		speed_mult = 1.0
		visual_offset = 0.0

# -------------------------------------------------
# PHYSICS
# -------------------------------------------------
func _physics_process(delta: float) -> void:
	debug_offset_down = Input.is_key_pressed(KEY_H)
	
	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	var move := Vector2.ZERO
	
	if input == Vector2.UP:
		move = Vector2.LEFT + Vector2.UP * 0.5
	elif input == Vector2.DOWN:
		move = Vector2.RIGHT + Vector2.DOWN * 0.5
	elif input == Vector2.LEFT:
		move = Vector2.LEFT + Vector2.DOWN * 0.5
	elif input == Vector2.RIGHT:
		move = Vector2.RIGHT + Vector2.UP * 0.5
	elif input == Vector2(1, -1):
		move = Vector2.UP
	elif input == Vector2(-1, -1):
		move = Vector2.LEFT
	elif input == Vector2(1, 1):
		move = Vector2.RIGHT
	elif input == Vector2(-1, 1):
		move = Vector2.DOWN
	
	move = move.normalized()
	
	if move != Vector2.ZERO:
		facing_direction = move
	
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
		
		if has_effect:
			speed *= speed_mult
		
		velocity = move * speed
	
	move_and_slide()
	
	var want_jump := Input.is_action_just_pressed("ui_accept")
	
	if want_jump and height == 0:
		vertical_velocity = JUMP_FORCE
	
	vertical_velocity -= GRAVITY * delta
	height += vertical_velocity * delta
	
	if height < 0:
		height = 0
		vertical_velocity = 0
	
	var iso_offset := Vector2(
		facing_direction.x - facing_direction.y,
		(facing_direction.x + facing_direction.y) * 0.5
	).normalized()
	
	var extra_offset := 0.0
	
	if debug_offset_down:
		extra_offset = 10.0
	
	if has_effect:
		extra_offset += visual_offset
	
	sprite.position = Vector2(
		iso_offset.x * height * 0.15,
		- height + extra_offset
	)
	
	if velocity.length() > 0:
		sprite.speed_scale = 1.8 if Input.is_key_pressed(KEY_SHIFT) else 1.0
		sprite.play("default")
	else:
		sprite.stop()