extends Node2D

@export var spawn_interval: float = 0.2
@export var rotation_speed: float = 1.0
@export var random_jitter: float = 5.0
@export var switch_direction_chance: float = 0.7
@export var skip_chance: float = 0.3

var screen_height = 648 / 2.0 / 2.0
var screen_width = 1152 / 2.0 / 2.0
var current_time = 0.0
var direction: float = 1.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
func _process(delta: float) -> void:
	current_time += delta
	if randf() < switch_direction_chance * delta:
		direction *= -1.0
	if randf() < skip_chance * delta:
		current_time += PI / 2.0 / rotation_speed

func _on_timer_timeout() -> void:
	var spawn_distance = sqrt((screen_height + 16) ** 2 + (screen_width + 16) ** 2)
	var jitter = Vector2(randf_range(-random_jitter, random_jitter), randf_range(-random_jitter, random_jitter))
	var spawn_pos = Vector2.from_angle(current_time * rotation_speed * direction) * spawn_distance + jitter
	spawn_mob(spawn_pos)

func spawn_mob(pos: Vector2) -> void:
	var new_mob = preload("res://Scenes/enemy.tscn").instantiate()
	new_mob.global_position = pos
	new_mob.player = get_parent().get_node("Player")
	add_child(new_mob)
