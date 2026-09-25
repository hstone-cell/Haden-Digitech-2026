extends Area2D

const ANIM_FLAG: String = "end-flag"

@export var flag: AnimatedSprite2D
@export var player: CharacterBody2D

# Plays the flag's idle animation and connects the body-entered signal.
func _ready() -> void:
	flag.play(ANIM_FLAG)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body != player:
		return
	# Stop detecting further collisions and start the transition.
	set_deferred("monitoring", false)
	SceneTransition.fade_change_scene(GameConstants.SCENE_LEVEL_COMPLETE)
