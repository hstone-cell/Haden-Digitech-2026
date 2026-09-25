extends CharacterBody2D

enum State {
	IDLE,
	CHASING,
	SETTLED,
	RETREAT,
}

const ANIM_LEGS_WALKING: String = "enemy-legs-walking"
const ANIM_LEGS_IDLE: String = "enemy-legs-idle"
const ANIM_TORSO_WALKING: String = "enemy-torso-walking"
const ANIM_TORSO_IDLE: String = "enemy-torso-idle"
const ANIM_TORSO_SHOOTING: String = "enemy-torso-shooting"
const DIRECTION_LEFT: int = -1
const DIRECTION_RIGHT: int = 1

@export var reaction_time: float = 1.0
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

var health = 5
var speed: float = 150
var gravity: float = 900
var player: CharacterBody2D
var player_head: Node2D
var sight_duration: float = 0.0
var lost_sight_timer: float = 0.0
var retreat_timer: float = 0.0
var can_shoot = true
var can_see_player = false
var direction: int = 0
var state: State = State.IDLE
var settle_timer: float = 0.0


func _ready() -> void:
	# Finds the player in the scene.
	for node in get_tree().get_nodes_in_group(GameConstants.GROUP_PLAYER):
		player = node
	if player:
		player_head = player.player_head
	# Starts checking line of sight to the player.
	sight_timer.start()
	sight_ray.enabled = true
	sight_ray.collide_with_bodies = true
	sight_ray.collide_with_areas = false


func _physics_process(delta: float) -> void:
	# Decides the enemy's direction and behavior for this frame.
	_update_enemy(delta)
	# Applys gravity while airborne.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Moves horizontally and flip to face the direction of travel.
	if is_on_floor():
		if direction == DIRECTION_RIGHT or direction == DIRECTION_LEFT:
			velocity.x = direction * speed
			if direction != visuals.scale.x and direction != 0:
				visuals.scale.x = direction
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	_update_animations()

	move_and_slide()


func _update_animations() -> void:
	# Plays the walking or idle legs animation.
	if direction != 0:
		if enemy_legs.animation != ANIM_LEGS_WALKING:
			enemy_legs.play(ANIM_LEGS_WALKING)
	else:
		if enemy_legs.animation != ANIM_LEGS_IDLE:
			enemy_legs.play(ANIM_LEGS_IDLE)
	# Plays the walking or idle torso animation, unless currently shooting.
	if enemy_torso.animation != ANIM_TORSO_SHOOTING:
		if direction != 0:
			if enemy_torso.animation != ANIM_TORSO_WALKING:
				enemy_torso.play(ANIM_TORSO_WALKING)
		else:
			if enemy_torso.animation != ANIM_TORSO_IDLE:
				enemy_torso.play(ANIM_TORSO_IDLE)


func _update_enemy(delta: float) -> void:
	if player == null:
		return
	# Works out how far away the player is.
	var relative_position = player.global_position - global_position
	var distance = relative_position.length()
	# Losing sight of the player for too long triggers a retreat.
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
		# Stands still until the player enters detection range.
		State.IDLE:
			direction = 0
			if distance < detection_range:
				state = State.CHASING
		# Moves toward the player until close enough to stop.
		State.CHASING:
			direction = DIRECTION_LEFT if relative_position.x < 0 else DIRECTION_RIGHT
			if distance <= stop_distance:
				direction = 0
				state = State.SETTLED
				settle_timer = idle_wait_time
		# Stays put and shoots once sight has been held long enough.
		State.SETTLED:
			direction = 0
			settle_timer -= delta
			if (
					can_shoot
					and can_see_player
					and sight_duration >= reaction_time
			):
				_shoot()
			if settle_timer <= 0 and distance > stop_distance:
				state = State.CHASING
			if distance >= detection_range:
				state = State.IDLE
		# Backs away until out of range, then returns to idle or resumes chasing.
		State.RETREAT:
			direction = DIRECTION_RIGHT if relative_position.x < 0 else DIRECTION_LEFT
			retreat_timer -= delta
			if distance >= retreat_distance or retreat_timer <= 0:
				direction = 0
				state = State.IDLE
			if can_see_player:
				direction = DIRECTION_LEFT if relative_position.x < 0 else DIRECTION_RIGHT
				state = State.CHASING


func _shoot() -> void:
	# Spawns a bullet aimed at the player's head, with varied accuracy.
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	bullet.look_at(player_head.global_position)
	bullet.rotation += deg_to_rad(randf_range(-accuracy_spread, accuracy_spread))
	bullet.firing_origin = self
	# Plays the shooting animation and starts the cooldown before the next shot.
	enemy_torso.play(ANIM_TORSO_SHOOTING)
	add_sibling(bullet)
	can_shoot = false
	bullet_timer.start()
	shoot_animation_timer.start()


func _on_sight_timer_timeout() -> void:
	if player == null or player_head == null:
		can_see_player = false
		return
	# Casts a ray at the player's head to check for a clear line of sight.
	sight_ray.target_position = to_local(player.player_head.global_position)
	sight_ray.force_raycast_update()
	# Only counts it as sight if the ray hits the player, not something in the way.
	if sight_ray.is_colliding():
		can_see_player = sight_ray.get_collider() == player
	else:
		can_see_player = false


func _bullet_timer() -> void:
	can_shoot = true


func take_damage(damage: int) -> void:
	if damage <= 0:
		return
	# Removes the enemy once its health runs out.
	health -= damage
	if health <= 0:
		queue_free()


func _on_shoot_animation_timer_timeout() -> void:
	if direction != 0:
		enemy_torso.play(ANIM_TORSO_WALKING)
	else:
		enemy_torso.play(ANIM_TORSO_IDLE)
