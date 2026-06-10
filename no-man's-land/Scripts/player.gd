extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -700.0
var score: int = 0
var can_shoot: bool = true
var facing_direction = 1 
var health: int = 10

@export var bullet_spawn: Marker2D
@export var bullet_scene: PackedScene
@export var bullet_timer: Timer
@export var health_ui: ProgressBar



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
		
	if Input.is_action_pressed("ui_shoot") and can_shoot:
		_shoot()
		
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir != 0:
		facing_direction = input_dir
		

	move_and_slide()


			

			
func _shoot() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	bullet.position = position + Vector2(20 * facing_direction, 0)
	bullet.direction = facing_direction
	add_sibling(bullet)
	can_shoot = false
	bullet_timer.start()
	

	
	
func _bullet() -> void:
	can_shoot = true
	
func take_damage() -> void:
	if health > 1:
		health -= 1
	else:
		get_tree().call_deferred("reload_current_scene")
