extends AnimatedSprite2D

func _ready():
	play("dash")
	animation_finished.connect(queue_free)
