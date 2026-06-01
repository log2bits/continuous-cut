extends Node2D

var slashing: bool = false
var points: Array[Vector2] = []
var current_dist: float = 0.0
var guide_radius: float = 10.0;
@export var dist_smoothing: float = 8.0
@export var max_width: float = 8.0
@export var min_width: float = 1.0
@onready var line: Line2D = $Line2D
@onready var guide_line: Line2D = $GuideLine2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		slashing = event.pressed
		if slashing:
			current_dist = get_global_mouse_position().length()
		if not slashing:
			points.clear()
			line.points = []
			queue_redraw()

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var mouse_screen = get_viewport().get_mouse_position()
	var vp_size = get_viewport().get_visible_rect().size
	
	if slashing:
		current_dist = lerp(current_dist, mouse_pos.length(), dist_smoothing * delta)
	else:
		current_dist = mouse_pos.length()
	
	_update_guide(current_dist)
	guide_line.visible = not slashing
	
	(guide_line.material as ShaderMaterial).set_shader_parameter("mouse_screen_pos", mouse_screen)
	(guide_line.material as ShaderMaterial).set_shader_parameter("viewport_size", vp_size)
	
	if not slashing:
		return
	var new_pos = mouse_pos.normalized() * current_dist
	points.append(new_pos)
	if points.size() > 50:
		points.pop_front()
	line.points = points
	_check_cuts()
	queue_redraw()

func _check_cuts() -> void:
	if points.size() < 2:
		return
	var a = points[-2]
	var b = points[-1]
	var t = float(points.size()) / 50.0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if _line_intersects_circle(a, b, enemy.global_position, 32):
			enemy.queue_free()

func _line_intersects_circle(a: Vector2, b: Vector2, center: Vector2, radius: float) -> bool:
	var closest = Geometry2D.get_closest_point_to_segment(center, a, b)
	return closest.distance_to(center) <= radius

func _update_guide(radius: float) -> void:
	var pts: Array[Vector2] = []
	var steps = 128
	for i in range(steps + 1):
		var angle = (float(i) / float(steps)) * TAU
		pts.append(Vector2.from_angle(angle) * radius)
	guide_line.points = pts
