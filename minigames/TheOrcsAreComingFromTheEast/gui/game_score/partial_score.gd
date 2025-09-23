extends HBoxContainer

signal Finished()
var max_val : int	= 0
var tween	: Tween = null

func initialise(attribute_name, attribute_value, new_max_val = 0):
	%PartialScoreLabel.text					= attribute_name
	%PartialScoreLabel.visible_characters	= 0
	%PartialScoreValue.visible				= false
	%PartialScoreValue.text					= "0" + ("" if new_max_val == 0 else "/" + str(new_max_val))
	max_val									= new_max_val
	tween									= create_tween()
	if(tween != null):
		tween.kill()
	tween = create_tween().set_parallel(false).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(%PartialScoreLabel, "visible_ratio", 1.0, 0.5)
	tween.tween_property(%PartialScoreValue, "visible", true, 0.4) # also serves as a delay
	tween.tween_method(animate_value, 0, attribute_value, 0.4)
	tween.play()
	await tween.finished
	Finished.emit()

func animate_value(value):
	if(max_val == 0):
		%PartialScoreValue.text = str(value)
	else:
		%PartialScoreValue.text = str(value) + "/" + str(max_val)
