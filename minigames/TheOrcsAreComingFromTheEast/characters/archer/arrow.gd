extends Sprite2D

func kill():
	await get_tree().create_timer(1).timeout
	queue_free()
