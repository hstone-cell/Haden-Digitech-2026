extends CharacterBody2D

var health: = 5
var speed: float = 150
var JUMP_VELOCITY: = -500
var gravity: float = 900
var player: CharacterBody2D
var player_head: Node2D
var sight_duration: float = 0.0
@export var reaction_time: float = 0.4
@export var lose_sight_time: float = 3.0
@export var retreat_distance: float = 900.0
@export var retreat_max_duration: float = 4.0
@export var detection_range: float = 800.0
@export var stop_distance: float = 600.0
@export var idle_wait_time: float = 1.5
@export var bullet_scene: PackedScene
@export var bullet_spawn: Marker2D
@export var bullet_timer: Timer
@export var visuals: Node2D
@export var sight_ray: RayCast2D
@export var sight_timer: Timer
@export var enemy_legs: AnimatedSprite2D
@export var enemy_torso: AnimatedSprite2D
@export var shoot_animation_timer: Timer
@export var accuracy_spread: float = 6.0

var lost_sight_timer: float = 0.0
var retreat_timer: float = 0.0
var can_shoot = true
var can_see_player = false
var direction
enum State { IDLE, CHASING, SETTLED, RETREAT }
var state: State = State.IDLE
var settle_timer: float = 0.0

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		player = node
	if player:
		player_head = player.get_node("Head")
	sight_timer.start()
	sight_ray.enabled = true
	sight_ray.collide_with_bodies = true
	sight_ray.collide_with_areas = false

	

	

func _physics_process(delta: float) -> void:
	
	_update_enemy(delta)
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_on_floor():
		if direction == 1 or direction == -1:
			velocity.x = direction * speed
			if direction != visuals.scale.x and direction != 0:
				visuals.scale.x = direction
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			
	_update_animations()
			
	move_and_slide()
	
func _update_animations() -> void:
	if direction != 0:
		if enemy_legs.animation != "enemy-legs-walking":
			enemy_legs.play("enemy-legs-walking")
	else:
		if enemy_legs.animation != "enemy-legs-idle":
			enemy_legs.play("enemy-legs-idle")
	
	if enemy_torso.animation != "enemy-torso-shooting":
		if direction != 0:
			if enemy_torso.animation != "enemy-torso-walking":
				enemy_torso.play("enemy-torso-walking")
		else:
			if enemy_torso.animation != "enemy-torso-idle":
				enemy_torso.play("enemy-torso-idle")
			
func _update_enemy(delta):
		if player == null:
			return
		var relative_position = player.global_position - global_position
		var distance = relative_position.length()
		
		if state == State.CHASING or state == State.SETTLED:
			if can_see_player:
				lost_sight_timer = 0.0
				sight_duration += delta
			else: 
				lost_sight_timer += delta
				sight_duration = 0.0
				if lost_sight_timer >= lose_sight_time:
					state = State.RETREAT
					retreat_timer = retreat_max_duration
					lost_sight_timer = 0.0
					
				
		
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
				if can_shoot and can_see_player and sight_duration >= reaction_time:
					_shoot()
				if settle_timer <= 0 and distance > stop_distance:
					state = State.CHASING
				if distance >= detection_range:
					state = State.IDLE
					
			State.RETREAT:
				direction = 1 if relative_position.x < 0 else -1
				retreat_timer -= delta
				if distance >= retreat_distance or retreat_timer <= 0:
					direction = 0
					state = State.IDLE
				if can_see_player:
					direction = -1
					state = State.CHASING
				

			
		
func _shoot() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	bullet.look_at(player_head.global_position)
	bullet.rotation += deg_to_rad(randf_range(-accuracy_spread, accuracy_spread))
	bullet.firing_origin = self
	enemy_torso.play("enemy-torso-shooting")
	add_sibling(bullet)
	can_shoot = false
	bullet_timer.start()
	shoot_animation_timer.start()
	
func _on_sight_timer_timeout() -> void:
	if player == null or player_head == null:
		can_see_player = false
		return
	sight_ray.target_position = to_local(player.player_head.global_position)
	sight_ray.force_raycast_update()
	if sight_ray.is_colliding():
		can_see_player = sight_ray.get_collider() == player
	else:
		can_see_player = false


func _bullet_timer() -> void:
	can_shoot = true
	
	
func take_damage(damage: int) -> void:
	if health > damage:
		health -= damage
	else:
		queue_free()


func _on_shoot_animation_timer_timeout() -> void:
	if direction != 0:
		enemy_torso.play("enemy-torso-walking")
	else:
		enemy_torso.play("enemy-torso-idle")
