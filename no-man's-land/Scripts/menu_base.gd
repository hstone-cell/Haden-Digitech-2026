class_name MenuBase
extends Control

# Shows the mouse cursor so menu buttons can be clicked.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Returns to the main menu.
func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(GameConstants.SCENE_MAIN_MENU)

# Closes the game.
func _on_quit_pressed() -> void:
	get_tree().quit()
