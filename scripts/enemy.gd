extends CharacterBody2D

@export var player: CharacterBody2D
@export var speed: float = 80.0

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	velocity = global_position.direction_to(player.global_position) * speed
	move_and_slide()
