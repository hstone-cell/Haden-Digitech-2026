extends MenuBase

# Exit button on the help screen returns to the main menu.
func _on_exit_button_pressed() -> void:
	_on_main_menu_pressed()
