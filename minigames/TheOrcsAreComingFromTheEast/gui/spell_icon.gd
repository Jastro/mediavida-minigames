extends TextureProgressBar

var tween : Tween

func _ready():
	value = 1

func set_reuse(time):
	if(tween != null):
		tween.kill()
	tween = create_tween()
	value = 0
	tween.tween_property(self, "value", 1.0, time)
	tween.play()
