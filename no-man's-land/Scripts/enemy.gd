extends CharacterBody2D

var speed: float = 150
var JUMP_VELOCITY: = -500
var gravity: float = 900
var player: CharacterBody2D
@export var detection_range: float = 1000.0
@export var stop_distance: float = 400.0
@export var idle_wait_time: float = 1.5
@export var bullet_scene: PackedScene
@export var bullet_spawn: Marker2D
@export var bullet_timer: Timer

var direction
enum State { IDLE, CHASING, SETTLED }
var state: State = State.IDLE
var settle_timer: float = 0.0

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		player = node
	

func _physics_process(delta: float) -> void:
	
	_update_enemy(delta)
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_on_floor():
		if direction == 1 or direction == -1:
			velocity.x = direction * speed
			if direction != scale.x:
				scale.x = direction
				
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			
	move_and_slide()
	

			
func _update_enemy(delta):
	
		var relative_position = player.global_position - global_position
		var distance = relative_position.length()
		
		match state:
			State.IDLE:
				direction = 0
				if distance < detection_range:
					state = State.CHASING
					
			State.CHASING:
				direction = -1 if relative_position.x < 0 else 1
				
				if distance <= stop_distance:
					direction = 0 
					state = State.SETTLED
					settle_timer = idle_wait_time
					
			State.SETTLED:
				direction = 0 
				settle_timer -= delta
				if can_shoot:
					_shoot()
				if settle_timer <= 0.0 and distance > stop_distance:
					state = State.CHASING
				if distance >= detection_range:
					state = State.IDLE
			
var can_shoot = true
		
func _shoot() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	bullet.look_at(player.global_position)
	add_sibling(bullet)
	can_shoot = false
	bullet_timer.start()
	
