extends Area2D

const HEAL_AMOUNT: int = 5
const METHOD_HEAL: String = "heal"

var player_nearby: bool = false
var player_ref = null
var active: bool = true

# Grants health when the player is nearby, active and presses interact.
func _process(_delta: float) -> void:
	if (
			player_nearby
			and active
			and Input.is_action_just_pressed(GameConstants.ACTION_INTERACT)
	):
		_grant_health()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method(METHOD_HEAL):
		player_nearby = true
		player_ref = body


func _on_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_nearby = false
		player_ref = null


func _grant_health() -> void:
	# Skips if the player reference is gone.
	if not is_instance_valid(player_ref):
		return
	# Skips if the player is already at full health.
	if player_ref.health >= player_ref.BASE_HEALTH:
		return
	# Heals the player and remove this medkit.
	player_ref.heal(HEAL_AMOUNT)
	active = false
	queue_free()
