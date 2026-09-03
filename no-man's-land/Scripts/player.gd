class_name Player
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -350.0
var facing_direction = 1 
const base_health: int = 10
var health: int = base_health
var can_shoot = true
var current_ammo: int = 0
var current_damage: int = 1
var has_pickup_weapon: bool = false
const base_damage: int = 1
const base_fire_rate: float = 0.2
var current_firing_distance: int = 550
const base_firing_distance: int = 550
var current_weapon_id: String = ""
var idle_animation: String = "torso-idle"
var walking_animation: String = "torso-walking"
var shooting_animation: String = "torso-shooting"
@export var health_ui: ProgressBar
@export var bullet_scene: PackedScene
@export var bullet_spawn: Marker2D
@export var bullet_timer: Timer
@export var Visuals: Node2D
@export var legs: AnimatedSprite2D
@export var torso: AnimatedSprite2D
@export var stand: CollisionShape2D
@export var crouch: CollisionShape2D
@export var player_head: Marker2D
@export var shoot_animation_timer: Timer


func _ready() -> void:
	_update_animation_names()
	torso.play(idle_animation)
	legs.play("legs-idle")
	
func _update_animation_names() -> void:
	if current_weapon_id == "":
		idle_animation = "torso-idle"
		walking_animation = "torso-walking"
		shooting_animation = "torso-shooting"
	else:
		idle_animation = "torso-" + current_weapon_id + "-idle"
		walking_animation = "torso-" + current_weapon_id + "-walking"
		shooting_animation = "torso-" + current_weapon_id + "-shooting"


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if legs.animation != "legs-walking":
			legs.play("legs-walking")
		if torso.animation != shooting_animation:
			if Input.is_action_pressed("ui_crouch"):
				if torso.animation != (idle_animation):
					torso.play(idle_animation)
			elif torso.animation != walking_animation:
				torso.play(walking_animation)
				
					
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if legs.animation != "legs-idle":
			legs.play("legs-idle")
		if torso.animation != shooting_animation:
			if torso.animation != idle_animation:
				torso.play(idle_animation)
	
	if Input.is_action_pressed("ui_crouch") and is_on_floor():
		crouch.disabled = false
		stand.disabled = true
		velocity.x = 0
		velocity.y = 0
		player_head.position.y = -14
		torso.position.y = -7.5
		legs.play("legs-crouching")
	else:
		crouch.disabled = true
		stand.disabled = false
		player_head.position.y = -32
		torso.position.y = -20.5
	
	if Input.is_action_just_pressed("ui_shoot") and can_shoot:
		_shoot()
		torso.play(shooting_animation)
		shoot_animation_timer.start()

		
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir != 0:
		facing_direction = input_dir
	
	Visuals.scale.x = facing_direction
	if direction != 0:
		facing_direction = direction
	if direction != Visuals.scale.x and direction != 0:
		Visuals.scale.x = direction
		

	move_and_slide()

func take_damage(damage: int) -> void:
	if health > damage:
		health -= damage
		health_ui.value = health
	else:
		get_tree().call_deferred("reload_current_scene")
		
			
func _shoot() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	bullet.direction = facing_direction
	bullet.rotation = 0.0 if facing_direction == 1 else PI
	bullet.firing_origin = self
	bullet.damage = current_damage
	bullet.firing_distance = current_firing_distance
	add_sibling(bullet)
	can_shoot = false
	bullet_timer.start()
	
	if has_pickup_weapon:
		current_ammo -= 1
		if current_ammo == 0:
			has_pickup_weapon = false
			current_weapon_id = ""
			current_damage = base_damage
			bullet_timer.wait_time = base_fire_rate
			current_firing_distance = base_firing_distance
			_update_animation_names()
	
func pickup_weapon(_id: String, stats: Dictionary) -> void:
	has_pickup_weapon = true
	current_weapon_id = _id
	current_damage = stats.get("damage", base_damage)
	current_ammo = stats.get("ammo", 10)
	bullet_timer.wait_time = stats.get("fire_rate", base_fire_rate)
	current_firing_distance = stats.get("fire_distance", base_firing_distance)
	_update_animation_names()
	
	
func _bullet() -> void:
	can_shoot = true
	


func _on_shoot_animation_timer_timeout() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		torso.play(walking_animation)
	else: 
		torso.play(idle_animation)
		
func heal(amount: int) -> void:
	health = min(health + amount, base_health)
	health_ui.value = health
		
