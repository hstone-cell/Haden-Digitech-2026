extends CanvasLayer

const FADE_LAYER: int = 100
const DEFAULT_FADE_DURATION: float = 1.5
const ALPHA_HIDDEN: float = 0.0
const ALPHA_VISIBLE: float = 1.0
const ALPHA_PROPERTY: String = "modulate:a"
const ERROR_SCENE_NOT_FOUND: String = "Scene not found: "

@onready var fade: ColorRect = $fade

var is_transitioning: bool = false


func _ready() -> void:
	# Keeps the overlay active even while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = FADE_LAYER
	# Starts fully transparent and lets inputs pass through.
	fade.modulate.a = ALPHA_HIDDEN
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Switches scenes instantly, with no fade.
func change_scene(path: String) -> void:
	# Validates the path before using it.
	if not _scene_exists(path):
		return

	get_tree().change_scene_to_file(path)

# Fades out, switches scenes, then fades back in for level completion.
func fade_change_scene(path: String, duration: float = DEFAULT_FADE_DURATION) -> void:
	# Skips if already transitioning, the duration is invalid, or the path is missing.
	if is_transitioning or duration < 0.0 or not _scene_exists(path):
		return

	is_transitioning = true
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	# Fades to black.
	var tween_out := create_tween()
	tween_out.tween_property(fade, ALPHA_PROPERTY, ALPHA_VISIBLE, duration)
	await tween_out.finished
	# Swaps the scene while the screen is fully black.
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	# Fades back in.
	var tween_in := create_tween()
	tween_in.tween_property(fade, ALPHA_PROPERTY, ALPHA_HIDDEN, duration)
	await tween_in.finished
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false

# Checks a scene path resolves to a real file before it's used.
func _scene_exists(path: String) -> bool:
	if ResourceLoader.exists(path):
		return true
	# Logs an error and reports failure if the path doesn't resolve.
	push_error(ERROR_SCENE_NOT_FOUND + path)
	return false
