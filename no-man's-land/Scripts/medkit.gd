extends Area2D

const HEAL_AMOUNT: int = 5
var player_nearby: bool = false
var player_ref = null
var active: bool = true

func _process(_delta: float) -> void:
	if player_nearby and active and Input.is_action_just_pressed("ui_interact"):
		_grant_health()
		

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("heal"):
		player_nearby = true
		player_ref = body


func _on_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_nearby = false
		player_ref = null
	
	
func _grant_health() -> void:
	if not player_ref:
		return
	if player_ref.health >= player_ref.base_health:
		return
		
	player_ref.heal(HEAL_AMOUNT)
	active = false
	queue_free()

		
	
