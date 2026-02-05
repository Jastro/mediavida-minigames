extends Area2D
class_name KTB_Powerup

signal collected

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _draw() -> void:
	# Estrella simple (polígono dibujado)
	var pts: PackedVector2Array = PackedVector2Array()
	pts.append(Vector2(0.0, -18.0))
	pts.append(Vector2(5.0, -6.0))
	pts.append(Vector2(18.0, -6.0))
	pts.append(Vector2(8.0, 2.0))
	pts.append(Vector2(12.0, 16.0))
	pts.append(Vector2(0.0, 8.0))
	pts.append(Vector2(-12.0, 16.0))
	pts.append(Vector2(-8.0, 2.0))
	pts.append(Vector2(-18.0, -6.0))
	pts.append(Vector2(-5.0, -6.0))

	draw_colored_polygon(pts, Color(1.0, 0.9, 0.2, 1.0))

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body is KTB_Player:
		collected.emit()
		queue_free()
