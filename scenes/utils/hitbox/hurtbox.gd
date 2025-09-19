extends Area2D

signal hurt(source)

var mask = 0
var timer = Timer.new()

func _ready():
	mask = collision_mask
	area_entered.connect(_on_area_entered)
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_invincibility_timeout)

func set_new_mask(new_mask : int):
	mask = new_mask
	collision_mask = mask

func disable_permanent():
	collision_mask = 0
	timer.stop()

func disable(time):
	collision_mask = 0
	timer.start(time)

func enable():
	collision_mask = mask

func _on_area_entered(source):
	hurt.emit(source)

func _on_invincibility_timeout():
	collision_mask = mask
