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
	collision_layer = 0

func enable(time):
	collision_layer = layer
	timer.start(time)
