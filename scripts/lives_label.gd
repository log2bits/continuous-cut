extends Label

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if is_instance_valid(player):
		text = "Lives: " + str(player.health)
