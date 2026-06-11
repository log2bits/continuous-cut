class_name Player
extends CharacterBody2D

@export var health: int = 3

func _ready() -> void:
	add_to_group("player")

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	rotation += PI / 2.0

func _physics_process(delta: float) -> void:
	pass;

func take_damage(amount: int) -> void:
	health -= amount
	print("Player took damage! Health remaining: ", health)
	
	if health <= 0:
		die()

func die() -> void:
	print("Player has died!")
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/death_screen.tscn")
