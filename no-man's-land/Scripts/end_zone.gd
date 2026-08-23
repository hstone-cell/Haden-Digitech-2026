extends Area2D

@export var flag: AnimatedSprite2D
@export var player: CharacterBody2D

func _ready() -> void:
	flag.play("end-flag")
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	if body != player:
		return
	set_deferred("monitoring", false)
	SceneTransition.fade_change_scene("res://Scenes/level_complete.tscn")
	

	

	
