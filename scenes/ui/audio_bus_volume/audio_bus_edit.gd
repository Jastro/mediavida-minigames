extends HBoxContainer

@export var bus : AudioManager.EBus

var bus_idx

var volume

func _ready():
	$Left.pressed.connect(_on_left)
	$Right.pressed.connect(_on_right)
	bus_idx		= AudioServer.get_bus_index(AudioManager.get_bus(bus))
	volume		= AudioServer.get_bus_volume_linear(bus_idx)
	$ProgressBar.value = volume
func _on_left():
	volume = clamp(volume-0.1, 0.0, 1.0)
	AudioServer.set_bus_volume_linear(bus_idx, volume)
	$ProgressBar.value = volume
func _on_right():
	volume = clamp(volume+0.1, 0.0, 1.0)
	AudioServer.set_bus_volume_linear(bus_idx, volume)
	$ProgressBar.value = volume
	
