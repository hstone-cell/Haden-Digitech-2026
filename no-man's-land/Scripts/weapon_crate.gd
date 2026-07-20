extends Area2D

const weapons: Dictionary = {
	"shotgun": {
		"ammo": 16,
		"damage": 3,
		"fire_rate": 1.5,
		"fire_distance": 450,
	},
	"rifle": {
		"ammo": 32,
		"damage": 1.5,
		"fire_rate": 0.7,
		"fire_distance": 500,
	},
	"sniper": {
		"ammo": 3,
		"damage": 10,
		"fire_rate": 2.5,
		"fire_distance": 600,
	},	
}

@export var weapon_id: String = "shotgun"

var _player_nearby: bool = false
var _player_ref = null 
var _active: bool = true

func _ready() -> void:
	weapon_id = weapons.keys()[randi() % weapons.size()]




func _process(_delta: float) -> void:
	if _player_nearby and _active and Input.is_action_just_pressed("ui_interact"):
		_grant_weapon()


func _on_body_entered(body: Node) -> void:
	if body.has_method("pickup_weapon"):
		_player_nearby = true
		_player_ref = body


func _on_body_exited(body: Node) -> void:
	if body == _player_ref:
		_player_nearby = false
		_player_ref = null



func _grant_weapon() -> void:
	if not _player_ref or not weapons.has(weapon_id):
		return

	_player_ref.pickup_weapon(weapon_id, weapons[weapon_id].duplicate())

	_active = false
	queue_free()
