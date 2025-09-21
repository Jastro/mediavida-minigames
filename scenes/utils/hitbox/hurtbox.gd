extends Area2D

signal hurt(source)

var mask = 0
var timer = Timer.new()

func _ready():
	mask = collision_mask
	monitoring = true
	area_entered.connect(_on_area_entered)
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_invincibility_timeout)

func set_new_mask(new_mask : int):
	mask = new_mask
	collision_mask = mask

func disable_permanent():
	set_deferred("monitoring", false)
	timer.stop()

func disable(time):
	set_deferred("monitoring", false)
	timer.start(time)

func enable():
	set_deferred("monitoring", true)

func _on_area_entered(source):
	hurt.emit(source)

func _on_invincibility_timeout():
	set_deferred("monitoring", true)
