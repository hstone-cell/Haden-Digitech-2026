extends Area2D

const METHOD_PICKUP_WEAPON: String = "pickup_weapon"

const WEAPONS: Dictionary = {
	"shotgun": {
		GameConstants.WEAPON_AMMO: 16,
		GameConstants.WEAPON_DAMAGE: 5,
		GameConstants.WEAPON_FIRE_RATE: 1.5,
		GameConstants.WEAPON_FIRE_DISTANCE: 400,
	},
	"rifle": {
		GameConstants.WEAPON_AMMO: 32,
		GameConstants.WEAPON_DAMAGE: 3,
		GameConstants.WEAPON_FIRE_RATE: 0.7,
		GameConstants.WEAPON_FIRE_DISTANCE: 550,
	},
	"sniper": {
		GameConstants.WEAPON_AMMO: 3,
		GameConstants.WEAPON_DAMAGE: 5,
		GameConstants.WEAPON_FIRE_RATE: 2.5,
		GameConstants.WEAPON_FIRE_DISTANCE: 700,
	},
}

var weapon_id: String = ""
var _player_nearby: bool = false
var _player_ref = null
var _active: bool = true

# Picks a random weapon for the weapon crate to grant.
func _ready() -> void:
	weapon_id = WEAPONS.keys()[randi() % WEAPONS.size()]

# Grants the weapon when the player is nearby, active, and presses interact.
func _process(_delta: float) -> void:
	if (
			_player_nearby
			and _active
			and Input.is_action_just_pressed(GameConstants.ACTION_INTERACT)
	):
		_grant_weapon()


func _on_body_entered(body: Node) -> void:
	if body.has_method(METHOD_PICKUP_WEAPON):
		_player_nearby = true
		_player_ref = body


func _on_body_exited(body: Node) -> void:
	if body == _player_ref:
		_player_nearby = false
		_player_ref = null


func _grant_weapon() -> void:
	# Skips if the player reference is gone or the weapon id is not valid.
	if not is_instance_valid(_player_ref) or not WEAPONS.has(weapon_id):
		return
	# Gives the player a copy of this weapon's stats.
	_player_ref.pickup_weapon(weapon_id, WEAPONS[weapon_id].duplicate())
	# Removes this weapon crate now that it's been used.
	_active = false
	queue_free()
