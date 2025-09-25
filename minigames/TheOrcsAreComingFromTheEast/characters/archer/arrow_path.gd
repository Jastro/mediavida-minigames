extends Path2D

signal finished

var current_arrow	: Sprite2D = null
var arrow_stopped	: bool = false
var arrow_scn		: PackedScene
var tween			: Tween = null
var ARROW_SPEED = {
	GameManager.Difficulty.EASY		: 900,
	GameManager.Difficulty.NORMAL	: 1000,
	GameManager.Difficulty.HARD		: 1150,
}

func _ready():
	add_to_group("freezable")
	arrow_scn = preload("res://minigames/TheOrcsAreComingFromTheEast/characters/archer/arrow.tscn")
	
func shoot_arrow(origin : Vector2, target : Vector2):
	var curve_ref = (curve as Curve2D)
	current_arrow = arrow_scn.instantiate()
	current_arrow.tree_collision.connect(stop_arrow)
	
	origin = origin - global_position
	target = target - global_position
	
	var cancel_curve = (origin.y - target.y > 20) || (abs(origin.x-target.x) < 150)
	var time = origin.distance_to(target) / ARROW_SPEED[GameManager.get_difficulty()]
	var middle_point 	: Vector2
	var point_in_out	: Vector2 = Vector2.ZERO
	
	if(cancel_curve || origin.distance_to(target) < 50):
		# Direct flight
		middle_point = (target + origin)/2
	else:
		# Angle
		middle_point = Vector2((target.x+origin.x)/2, origin.y + Vector2.UP.y * 100)
		point_in_out	= Vector2(middle_point.x-origin.x, 0)
	
	curve_ref.clear_points()
	curve_ref.add_point(origin)
	curve_ref.add_point(middle_point, -point_in_out, point_in_out)
	curve_ref.add_point(target)
	
	%PathFollow2D.add_child(current_arrow)
	if(tween != null):
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(%PathFollow2D, "progress_ratio", 1, time)
	await tween.finished
	if(arrow_stopped == false):
		var current_arrow_pos = current_arrow.global_position
		var current_arrow_rot = current_arrow.global_rotation
		%PathFollow2D.remove_child(current_arrow)
		get_parent().add_child(current_arrow)
		current_arrow.global_position = current_arrow_pos
		current_arrow.global_rotation = current_arrow_rot
		current_arrow.kill()
	current_arrow = null
	arrow_stopped = false
	%PathFollow2D.progress_ratio = 0
	finished.emit()

func stop_arrow():
	arrow_stopped = true
	var current_arrow_pos = current_arrow.global_position
	var current_arrow_rot = current_arrow.global_rotation
	%PathFollow2D.call_deferred("remove_child", current_arrow)
	get_parent().call_deferred("add_child", current_arrow)
	current_arrow.set_deferred("global_position", current_arrow_pos)
	current_arrow.set_deferred("global_rotation", current_arrow_rot)
	current_arrow.call_deferred("kill")

func freeze():
	if(tween != null):
		tween.pause()
