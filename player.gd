# player.gd
extends CharacterBody2D

const WALK_SPEED = 80.0
const RUN_SPEED = 100.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		velocity = direction * WALK_SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	global_position = global_position.round()
