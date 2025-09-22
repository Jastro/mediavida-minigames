extends AnimatedSprite2D

@export var time_up = 1
@export var time_down = 1

var up = false
var timer

func _ready():
	$Hitbox.set_new_layer(Defs.L_ENEMY)
	timer			= Timer.new()
	timer.one_shot	= true
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	timer.start(time_down)

func _on_timeout():
	if(up):
		play_backwards("default")
		timer.start(time_down)
	else:
		play("default")
		await get_tree().create_timer(0.4).timeout
		$Hitbox.enable(time_up)
		timer.start(time_up)
	up = !up
