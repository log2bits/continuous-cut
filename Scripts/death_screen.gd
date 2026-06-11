extends Control

@onready var audio = $click_player

func _ready() -> void:
	$ScoreLabel.text = "Score: " + str(Score.total)

func _on_quit_button_pressed() -> void:
	$click_player.play()
	await $click_player.finished
	get_tree().quit()
	pass # Replace with function body.


func _on_restart_button_pressed() -> void:
	$click_player.play()
	await $click_player.finished
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	pass # Replace with function body.
