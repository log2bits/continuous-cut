extends Control

@onready var audio = $AudioStreamPlayer2D

func _on_start_button_pressed() -> void:
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	get_tree().quit()
	pass # Replace with function body.
