extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -250.0
var facing_direction = 1 
var health: int = 10
var can_shoot = true
var current_ammo: int = 0
var current_damage: int = 1
var has_pickup_weapon: bool = false
const base_damage: int = 1
const base_fire_rate: float = 0.2
@export var health_ui: ProgressBar
@export var bullet_scene: PackedScene
@export var bullet_spawn: Marker2D
@export var bullet_timer: Timer
@export var Visuals: Node2D
@export var legs: AnimatedSprite2D
@export var torso: AnimatedSprite2D
@export var stand: CollisionShape2D
@export var crouch: CollisionShape2D
@export var stand_visuals: ColorRect
@export var crouch_visuals: ColorRect




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
		if torso.animation != "torso-walking":
			torso.play("torso-walking")
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if legs.animation != "legs-idle":
			legs.play("legs-idle")
		if torso.animation != "torso-idle":
			torso.play("torso-idle")
	
	if Input.is_action_pressed("ui_crouch") and is_on_floor():
		crouch.disabled = false
		stand.disabled = true
		velocity.x = direction * SPEED/2
		velocity.y = JUMP_VELOCITY * 0
		stand_visuals.color = 0
		crouch_visuals.color = 100
	else:
		crouch.disabled = true
		stand.disabled = false
		stand_visuals.color = 100
		crouch_visuals.color = 0
	
	if Input.is_action_pressed("ui_shoot") and can_shoot:
		_shoot()
		
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
	add_sibling(bullet)
	can_shoot = false
	bullet_timer.start()
	
	if has_pickup_weapon:
		current_ammo -= 1
		if current_ammo == 0:
			has_pickup_weapon = false
			current_damage = base_damage
			bullet_timer.wait_time = base_fire_rate
	
func pickup_weapon(_id: String, stats: Dictionary) -> void:
	has_pickup_weapon = true
	current_damage = stats.get("damage", base_damage)
	current_ammo = stats.get("ammo", 10)
	bullet_timer.wait_time = stats.get("fire_rate", base_fire_rate)
	
	
func _bullet() -> void:
	can_shoot = true
	
