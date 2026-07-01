extends Area2D

var speed = 1000.0
var direction
var firing_origin: CharacterBody2D
var damage: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x * speed * delta
	global_transform.basis_xform(Vector2.RIGHT)
	
func _damage_player(body: Node2D) -> void:
	if body.is_in_group("player") and not body == firing_origin:
		body.take_damage(damage)
		queue_free()




func _damage_enemy(body: Node2D) -> void:
	if body.is_in_group("enemy") and not body == firing_origin:
		body.take_damage(damage)
		queue_free()
