extends Control

@onready var score_label = $ScoreLabel
@onready var animation_player = $AnimationPlayer

func setup(points: int, world_pos: Vector2):
	# Convertir posición mundial a posición de pantalla
	position = world_pos

	if points > 0:
		score_label.text = "+" + str(points)
		score_label.modulate = Color.GREEN
	else:
		score_label.text = str(points)
		score_label.modulate = Color.RED

	animation_player.play("popup")
	await animation_player.animation_finished
	queue_free()