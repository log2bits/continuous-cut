extends Node2D

const POPUP_FONT = preload("res://assets/Fonts/dogicapixel.ttf")

var slashing: bool = false
var points: Array[Vector2] = []
var current_dist: float = 0.0
@export var dist_smoothing: float = 8.0
@export var swipe_timeout: float = 0.25
var combo: int = 0
var time_since_cut: float = 0.0
@onready var line: Line2D = $Line2D
@onready var guide_line: Line2D = $GuideLine2D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		slashing = event.pressed
		if slashing:
			current_dist = get_global_mouse_position().length()
			combo = 0
			time_since_cut = 0.0
		if not slashing:
			_end_swipe()

func _end_swipe() -> void:
	slashing = false
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
	time_since_cut += delta
	if time_since_cut >= swipe_timeout:
		_end_swipe()
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
		if _line_intersects_circle(a, b, enemy.global_position, 16):
			combo += 1
			var amount = combo * 100
			Score.total += amount
			time_since_cut = 0.0
			_spawn_score_popup(enemy.global_position, amount)
			enemy.queue_free()

func _spawn_score_popup(pos: Vector2, amount: int) -> void:
	var label = Label.new()
	label.add_theme_font_override("font", POPUP_FONT)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", colors.PRIMARY)
	label.text = "+" + str(amount)
	label.z_index = 100
	get_parent().add_child(label)
	label.global_position = pos
	var tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", pos + Vector2(0, -20), 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(label.queue_free)

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

func _ready() -> void:
	Score.reset()
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(0.5, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	line.width_curve = curve
