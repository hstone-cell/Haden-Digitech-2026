extends CanvasLayer

@onready var fade: ColorRect = $fade

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	fade.modulate.a = 0.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func fade_change_scene(path: String, duration: float = 1.5) -> void:
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween_out := create_tween()
	tween_out.tween_property(fade, "modulate:a", 1.0, duration)
	await tween_out.finished
	
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	
	var tween_in := create_tween()
	tween_in.tween_property(fade, "modulate:a", 0.0, duration)
	await tween_in.finished
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
