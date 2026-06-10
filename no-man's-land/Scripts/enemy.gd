extends CharacterBody2D

var speed: float = 150
var JUMP_VELOCITY: = -500
var gravity: float = 900
var shoot_range: float = 300
var player: CharacterBody2D
var health: int = 3


@export var pivot: Node2D
@onready var raycast = $RayCast2D
@export var bullet_spawn: Marker2D
@export var bullet_scene: PackedScene
@export var bullet_timer: Timer

var direction

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		player = node


func _physics_process(delta: float) -> void:
	
	
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_on_floor():
		if direction:
			velocity.x = direction * speed
			if direction != pivot.scale.x:
				pivot.scale.x = direction
				
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		var relative_position = player.global_position - global_position
		if relative_position.x < 0:
			direction = -1
		else:
			direction = 1
		
	move_and_slide()
	
func take_damage() -> void:
	if health > 1:
		health -= 1
	else:
		queue_free()
	


func _damage_player(body: Node2D) -> void:
	if body == player:
		player.take_damage()
		
	


func can_see_player():
	raycast.target_position = player.global_position - global_position
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		return raycast.get_collider().is_in_group("player")
	
	return false
	

@export var shoot_cooldown = 1.5

var can_shoot = true

func _shoot() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	add_sibling(bullet)
	can_shoot = false
	bullet_timer.start()

func _process(delta):
	if player == null:
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance <= shoot_range and can_shoot and can_see_player():
		_shoot()
		

	
