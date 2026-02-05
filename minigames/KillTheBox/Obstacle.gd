extends StaticBody2D
class_name KTB_Obstacle

@export var size_px: Vector2 = Vector2(90.0, 30.0)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	pass
	#var rect: Rect2 = Rect2(-size_px * 0.5, size_px)
	#draw_rect(rect, Color(0.15, 0.15, 0.15, 1.0), true)
	#draw_rect(rect, Color(0.9, 0.9, 0.9, 1.0), false, 2.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()
