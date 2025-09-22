extends Area2D

var layer = 0
var timer = Timer.new()

func _ready():
	layer = collision_layer
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(disable)

func set_new_layer(new_mask : int):
	layer = new_mask
	collision_layer = layer

func disable():
	set_deferred("monitorable", false)

func enable(time):
	set_deferred("monitorable", true)
	timer.start(time)

func enable_permanent():
	set_deferred("monitorable", true)
	collision_layer = layer
