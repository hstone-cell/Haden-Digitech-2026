extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -700.0
var facing_direction = 1 
var health: int = 5





func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
		
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir != 0:
		facing_direction = input_dir
		

	move_and_slide()

func take_damage() -> void:
	if health > 1:
		health -= 1
	else:
		get_tree().call_deferred("reload_current_scene")
		

			

		
