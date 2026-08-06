extends Area2D

var speed = 1000.0
var direction
var firing_origin: CharacterBody2D
var damage: int = 1
var firing_distance: int = 550


func _ready():
	pass


func _process(delta: float) -> void:
	if is_instance_valid(firing_origin):
		if firing_origin is Player:
			if global_position.distance_to(firing_origin.global_position) > firing_distance:
				queue_free()
	position += transform.x * speed * delta
	global_transform.basis_xform(Vector2.RIGHT)


func _on_body_collision(body: Node2D) -> void:
	if not body == firing_origin:
		if body.is_in_group("player") or body.is_in_group("enemy"):
			body.take_damage(damage)
	queue_free()
