extends Node2D

@export var spawn_point: Marker2D
@export var enemy_scene: PackedScene


	
func _spawn_enemy() -> void:	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_point.global_position
	add_child(enemy)
	
