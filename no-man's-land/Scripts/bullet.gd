extends Area2D

var speed = 1000.0
var direction
var firing_origin: CharacterBody2D
var damage: int = 1
var firing_distance: int = 550


func _ready():
	pass

func _process(delta: float) -> void:
	if firing_origin is Player:
		if global_position.distance_to(firing_origin.global_position) > firing_distance:
			queue_free()
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
