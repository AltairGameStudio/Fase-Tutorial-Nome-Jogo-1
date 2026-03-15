extends CharacterBody2D

const JUMP_VELOCITY = -300.0

func _physics_process(delta: float) -> void:
	
	velocity += get_gravity() * delta

	
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	
	velocity.x = 200

	move_and_slide()
