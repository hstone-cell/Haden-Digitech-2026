extends MenuBase

# Starts the level.
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(GameConstants.SCENE_LEVEL)

# Opens the help screen.
func _on_help_button_pressed() -> void:
	get_tree().change_scene_to_file(GameConstants.SCENE_HELP)
