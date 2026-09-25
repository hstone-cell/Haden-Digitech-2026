class_name Player
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -350.0
const BASE_FIRING_DISTANCE: int = 550
const BASE_HEALTH: int = 10
const BASE_DAMAGE: int = 1
const BASE_FIRE_RATE: float = 0.2
const TORSO_PREFIX: String = "torso-"
const WEAPON_SEPARATOR: String = "-"
const ANIM_IDLE: String = "idle"
const ANIM_WALKING: String = "walking"
const ANIM_SHOOTING: String = "shooting"
const ANIM_LEGS_IDLE: String = "legs-idle"
const ANIM_LEGS_WALKING: String = "legs-walking"
const ANIM_LEGS_CROUCHING: String = "legs-crouching"
const DEFAULT_PICKUP_AMMO: int = 10
const FACING_RIGHT: float = 1.0
const HEAD_Y_STANDING: float = -32.0
const HEAD_Y_CROUCHING: float = -14.0
const TORSO_Y_STANDING: float = -20.5
const TORSO_Y_CROUCHING: float = -7.5

@export var health_ui: ProgressBar
@export var bullet_scene: PackedScene
@export var bullet_spawn: Marker2D
@export var bullet_timer: Timer
@export var visuals: Node2D
@export var legs: AnimatedSprite2D
@export var torso: AnimatedSprite2D
@export var stand: CollisionShape2D
@export var crouch: CollisionShape2D
@export var player_head: Marker2D
@export var shoot_animation_timer: Timer

var facing_direction: float = FACING_RIGHT
var health: int = BASE_HEALTH
var can_shoot = true
var current_ammo: int = 0
var current_damage: int = BASE_DAMAGE
var has_pickup_weapon: bool = false
var current_firing_distance: int = BASE_FIRING_DISTANCE
var current_weapon_id: String = ""
var idle_animation: String = TORSO_PREFIX + ANIM_IDLE
var walking_animation: String = TORSO_PREFIX + ANIM_WALKING
var shooting_animation: String = TORSO_PREFIX + ANIM_SHOOTING
var is_dead: bool = false

# Sets the starting animation names and plays the idle animations.
func _ready() -> void:
	_update_animation_names()
	torso.play(idle_animation)
	legs.play(ANIM_LEGS_IDLE)


func _update_animation_names() -> void:
	# Adds the weapon id to the prefix if one is equipped.
	var prefix: String = TORSO_PREFIX
	if not current_weapon_id.is_empty():
		prefix += current_weapon_id + WEAPON_SEPARATOR
	# Rebuilds each animation name from the prefix.
	idle_animation = prefix + ANIM_IDLE
	walking_animation = prefix + ANIM_WALKING
	shooting_animation = prefix + ANIM_SHOOTING


func _physics_process(delta: float) -> void:
	# Applys gravity while airborne.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Jumps when grounded.
	if Input.is_action_just_pressed(GameConstants.ACTION_JUMP) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Moves left/right and play the matching legs and torso animations.
	var direction := Input.get_axis(GameConstants.ACTION_LEFT, GameConstants.ACTION_RIGHT)
	if direction:
		velocity.x = direction * SPEED
		if legs.animation != ANIM_LEGS_WALKING:
			legs.play(ANIM_LEGS_WALKING)
		if torso.animation != shooting_animation:
			if Input.is_action_pressed(GameConstants.ACTION_CROUCH):
				if torso.animation != idle_animation:
					torso.play(idle_animation)
			elif torso.animation != walking_animation:
				torso.play(walking_animation)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if legs.animation != ANIM_LEGS_IDLE:
			legs.play(ANIM_LEGS_IDLE)
		if torso.animation != shooting_animation:
			if torso.animation != idle_animation:
				torso.play(idle_animation)
	# Crouching swaps the collision shape and lowers the head and torso.
	if Input.is_action_pressed(GameConstants.ACTION_CROUCH) and is_on_floor():
		crouch.disabled = false
		stand.disabled = true
		velocity.x = 0
		velocity.y = 0
		player_head.position.y = HEAD_Y_CROUCHING
		torso.position.y = TORSO_Y_CROUCHING
		legs.play(ANIM_LEGS_CROUCHING)
	else:
		crouch.disabled = true
		stand.disabled = false
		player_head.position.y = HEAD_Y_STANDING
		torso.position.y = TORSO_Y_STANDING
	# Fires when the shoot button is pressed and the cooldown has finished.
	if Input.is_action_just_pressed(GameConstants.ACTION_SHOOT) and can_shoot:
		_shoot()
		torso.play(shooting_animation)
		shoot_animation_timer.start()
	# Faces the direction last moved in.
	if direction != 0:
		facing_direction = signf(direction)
	visuals.scale.x = facing_direction

	move_and_slide()


func take_damage(damage: int) -> void:
	# Ignores invalid damage or damage while already dead or mid-transition.
	if damage <= 0 or is_dead or SceneTransition.is_transitioning:
		return
	# Reduces health or triggers the death scene if it would drop to zero.
	if health > damage:
		health -= damage
		health_ui.value = health
	else:
		is_dead = true
		SceneTransition.change_scene.call_deferred(GameConstants.SCENE_DEATH)


func _shoot() -> void:
	# Spawns a bullet facing the direction the player is facing.
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	bullet.rotation = 0.0 if facing_direction == FACING_RIGHT else PI
	bullet.firing_origin = self
	bullet.damage = current_damage
	bullet.firing_distance = current_firing_distance

	add_sibling(bullet)
	can_shoot = false
	bullet_timer.start()
	# Consumes ammo and resets to the base weapon once a pickup weapon runs out.
	if has_pickup_weapon:
		current_ammo -= 1
		if current_ammo <= 0:
			has_pickup_weapon = false
			current_weapon_id = ""
			current_damage = BASE_DAMAGE
			bullet_timer.wait_time = BASE_FIRE_RATE
			current_firing_distance = BASE_FIRING_DISTANCE
			_update_animation_names()


func pickup_weapon(weapon_id: String, stats: Dictionary) -> void:
	if weapon_id.is_empty():
		return
	# Rejects stats that would break the fire timer or leave no ammo.
	var new_ammo: int = stats.get(GameConstants.WEAPON_AMMO, DEFAULT_PICKUP_AMMO)
	var new_fire_rate: float = stats.get(GameConstants.WEAPON_FIRE_RATE, BASE_FIRE_RATE)
	if new_ammo <= 0 or new_fire_rate <= 0.0:
		return
	# Equips the new weapon.
	has_pickup_weapon = true
	current_weapon_id = weapon_id
	current_ammo = new_ammo
	current_damage = stats.get(GameConstants.WEAPON_DAMAGE, BASE_DAMAGE)
	bullet_timer.wait_time = new_fire_rate
	current_firing_distance = stats.get(GameConstants.WEAPON_FIRE_DISTANCE, BASE_FIRING_DISTANCE)
	_update_animation_names()


func _bullet() -> void:
	can_shoot = true


func _on_shoot_animation_timer_timeout() -> void:
	var direction := Input.get_axis(GameConstants.ACTION_LEFT, GameConstants.ACTION_RIGHT)
	if direction != 0:
		torso.play(walking_animation)
	else:
		torso.play(idle_animation)


func heal(amount: int) -> void:
	if amount <= 0:
		return
	# Stops healing so it can not exceed max health.
	health = min(health + amount, BASE_HEALTH)
	health_ui.value = health
