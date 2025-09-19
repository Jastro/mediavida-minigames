extends HBoxContainer

var target_hp	: float	= 0
var current_hp	: float	= 0
var max_hp		: float	= 0

var timer = Timer.new()
var heart_scene : PackedScene
var hearts = []

func _ready():
	timer.one_shot = false
	timer.wait_time = 0.1 # steps
	add_child(timer)
	timer.timeout.connect(_on_heart_step)
	heart_scene = preload("res://minigames/TheOrcsAreComingFromTheEast/gui/heart.tscn")

func initialise(new_max_hp):
	max_hp = new_max_hp
	target_hp = new_max_hp
	for heart in hearts:
		heart.queue_free()
	for heard_idx in range(max_hp):
		var heart = heart_scene.instantiate() as TextureProgressBar
		heart.value = 0
		hearts.push_back(heart)
		add_child(heart)
	update_hp(max_hp)
func update_hp(new_hp):
	target_hp = new_hp
	timer.start()
func _on_heart_step():
	if(current_hp < target_hp):
		var next_hp = current_hp + 0.25
		var frac	= next_hp - floor(next_hp)
		if(frac == 0):
			hearts[floor(current_hp)].value = 1
		else:
			hearts[floor(current_hp)].value = frac
		current_hp = next_hp
	elif(current_hp > target_hp):
		var next_hp		= current_hp - 0.25
		var frac		= next_hp - floor(next_hp)
		var heart_idx	= floor(current_hp)-1 if frac == 0.75 else floor(current_hp)
		
		hearts[heart_idx].value = frac
		current_hp = next_hp
	else:
		timer.stop()
