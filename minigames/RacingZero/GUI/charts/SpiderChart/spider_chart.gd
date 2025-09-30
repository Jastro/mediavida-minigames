extends Control

signal Finished()

@export_category("Chart")
@export var margin			: Vector2 = Vector2(100,100)
@export var chart_offset	: Vector2 = Vector2.ZERO
@export_category("Grid")
@export					var grid_enable		: bool	= true
@export_range(2, 10, 1)	var grid_step		: int	= 5
@export_category("Leyend")
@export	var leyend_enable 	: bool	= true
@export	var leyend_distance	: float	= 50
@export var leyend_width	: float	= 200
@export var font			: Font
@export var font_size		: int = 20

var categories		: Array[String]	= []
var target_points	: Array[float]	= []
var origin_points	: Array[float]	= []
var current_points	: Array[float]	= []
var max_values		: Array[float]	= []
var colors			: Array[Color]	= []

var tween : Tween = null

func _ready():
	set_categories(["Acceleration", "Max Speed", "Maneuverability", "Break"], [7.0,7.0,7.0,7.0], [Color(0.8,0.2,0.2,0.8), Color(0.2,0.8,0.2,0.8), Color(0.2,0.2,0.8,0.8), Color(0.8,0.8,0.2,0.8)])
	set_chart([5.0,7.0,3.0,4.0], 1)
	await Finished
	await get_tree().create_timer(0.7).timeout
	set_chart([7.0,1.0,0.4,2.0], 1)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func set_categories(new_categories : Array[String], new_max_values : Array[float], new_colors : Array[Color] = []):
	categories = new_categories
	max_values = new_max_values
	for point in range(0, new_categories.size()):
		if(point < new_colors.size()):
			colors.append(new_colors[point])
		else:
			colors.append(Color.WHITE)
	
func set_chart(new_points : Array[float], time : float = 0.5):
	
	if(current_points.size() == 0):
		target_points	= new_points
		for point in range(0, new_points.size()):
			origin_points.append(0)
			current_points.append(0)
	else:
		origin_points.clear()
		for point in range(0, new_points.size()):
			origin_points.append(target_points[point])
			target_points[point]	= new_points[point]
		
	if(tween != null):
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_method(update_point, 0.0, 1.0, time)
	tween.play()
	await tween.finished
	Finished.emit()
	
func _draw():
	var dist = min(size.x - margin.x, size.y - margin.y)/2
	var grid_offset = 1.0*dist / grid_step
	
	var center : Vector2 = size/2 + chart_offset
	var num_points : int = target_points.size()
	var offset = (2*PI)/num_points
	
	for point_idx in range(0, num_points):
		var next_point_idx = (point_idx + 1) % num_points
		var curr_offset = point_idx*offset - PI/2 # Adjust from starting on the right to starting on the top
		var next_offset = curr_offset + offset
		var dir		 = Vector2(cos(curr_offset), sin(curr_offset))
		var dir_next = Vector2(cos(next_offset), sin(next_offset))
		var curr_point = center + dir*dist * (current_points[point_idx] / max_values[point_idx])
		var next_point = center + dir_next*dist * (current_points[next_point_idx] / max_values[next_point_idx])
		draw_polygon([center, curr_point, next_point], [colors[point_idx]])
		
		# Print grid
		if(grid_enable):
			for grid_idx in range(1, grid_step+1):
				var transparency
				if grid_idx < grid_step:
					transparency = 0.7
				else:
					transparency = 1
				draw_line(center + dir * (grid_idx * grid_offset), center + dir_next * (grid_idx * grid_offset), Color(1,1,1, transparency))
		
		if(leyend_enable):
			var string_size = font.get_string_size(categories[point_idx])
			var leyend_string_offset = string_size * dir + Vector2.DOWN *  string_size.y/4
			draw_string(font, center + dir * dist + leyend_string_offset + Vector2.LEFT*leyend_width/2, categories[point_idx], HORIZONTAL_ALIGNMENT_CENTER, leyend_width, font_size)
func update_point(percent):
	for point in range(0, target_points.size()):
		current_points[point] = origin_points[point] * (1-percent) + target_points[point] * percent
	queue_redraw()
