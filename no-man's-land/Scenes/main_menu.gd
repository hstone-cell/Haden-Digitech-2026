extends Control


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_options_button_pressed() -> void:
	print("Options button pressed")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
