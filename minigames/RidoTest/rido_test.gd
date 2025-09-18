extends Node2D

var test = 0
var num = 0
func _ready():
	var popup = preload("res://scenes/ui/ScorePopup.tscn").instantiate()
	add_child(popup)
	popup.setup(100, Vector2(400,400))

func _physics_process(delta):
	if(test > 0.2):
		AudioManager.play_sound(AudioManager.ESound.Success)
		num += 1
		test = 0
		if(num == 10):
			set_physics_process(false)
		return
	test += delta
