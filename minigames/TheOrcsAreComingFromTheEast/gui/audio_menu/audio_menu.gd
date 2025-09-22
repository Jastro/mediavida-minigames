extends ColorRect

var show_pos	: Vector2
var hidden_pos	: Vector2
var tween		: Tween

var active = false

func _ready():
	show_pos		= Vector2.ZERO
	hidden_pos		= Vector2.UP * get_viewport().get_visible_rect().size.y
	global_position = hidden_pos

func _input(event):
	if(event.is_action_pressed("pause")):
		if(active):
			hide_custom()
		else:
			show_custom()

func show_custom():
	active = true
	get_tree().paused = true
	if(tween != null):
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", show_pos, 1)
	tween.play()

func hide_custom():
	active = false
	if(tween != null):
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", hidden_pos, 1)
	tween.play()
	await tween.finished
	get_tree().paused = false
