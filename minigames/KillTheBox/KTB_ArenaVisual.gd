extends Node2D
class_name KTB_ArenaVisual

var _arena_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

func set_arena_rect(rect: Rect2) -> void:
	_arena_rect = rect
	queue_redraw()

func _draw() -> void:
	# Fondo negro
	draw_rect(_arena_rect, Color(0.0, 0.0, 0.0, 1.0), true)

	# Borde blanco
	draw_rect(_arena_rect, Color(1.0, 1.0, 1.0, 1.0), false, 2.0)
