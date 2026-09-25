extends Area2D

const MAX_LIFETIME: float = 4.0

var speed = 1000.0
var firing_origin: CharacterBody2D
var lifetime: float = 0.0
var damage: int = 1
var firing_distance: int = Player.BASE_FIRING_DISTANCE


func _process(delta: float) -> void:
	# Removes the bullet once it has lived for too long.
	lifetime += delta
	if lifetime >= MAX_LIFETIME:
		queue_free()
		return
	# Removes the bullet once it is too far from the player.
	if (
			is_instance_valid(firing_origin)
			and firing_origin is Player
			and global_position.distance_to(firing_origin.global_position) > firing_distance
	):
		queue_free()
	# Moves the bullet forward.
	position += transform.x * speed * delta


func _on_body_collision(body: Node2D) -> void:
	# Damages the body if it is a valid target other than the shooter.
	if body != firing_origin:
		if (
				body.is_in_group(GameConstants.GROUP_PLAYER)
				or body.is_in_group(GameConstants.GROUP_ENEMY)
		):
			body.take_damage(damage)
	# Removes the bullet on any collision.
	queue_free()
