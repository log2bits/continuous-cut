extends CharacterBody2D

@export var speed: float = 32.0
var player: CharacterBody2D

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	velocity = global_position.direction_to(player.global_position) * speed
	rotation = global_position.angle_to_point(player.global_position) + PI / 2.0
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == player:
			queue_free()
			
func _ready() -> void:
	add_to_group("enemies")
