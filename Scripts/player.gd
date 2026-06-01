class_name Player
extends CharacterBody2D

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	rotation += PI / 2.0
