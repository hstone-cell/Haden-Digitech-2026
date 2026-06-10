extends CharacterBody2D

var speed: float = 150
var JUMP_VELOCITY: = -500
var gravity: float = 900

var player: CharacterBody2D



@export var pivot: Node2D

var direction

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		player = node


func _physics_process(delta: float) -> void:
	
	
		
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_on_floor():
		if direction:
			velocity.x = direction * speed
			if direction != pivot.scale.x:
				pivot.scale.x = direction
				
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		var relative_position = player.global_position - global_position
		if relative_position.x < 0:
			direction = -1
		else:
			direction = 1
		
	move_and_slide()


	
