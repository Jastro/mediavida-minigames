extends Control

@onready var score_label = $ScoreLabel

func setup(points: int, world_pos: Vector2):
	var tween = create_tween()
	# Convertir posición mundial a posición de pantalla
	position = world_pos
	scale = Vector2(0.5,0.5)
	if points > 0:
		score_label.text = "+" + str(points)
		score_label.modulate = Color.GREEN
	else:
		score_label.text = str(points)
		score_label.modulate = Color.RED
	tween.set_parallel(true)
	tween.tween_property(self, "position", world_pos + Vector2.UP*80, 1)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3).set_delay(0.7)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2).set_delay(0.2).set_ease(Tween.EASE_IN)
	tween.play()
	await tween.finished
	queue_free()
