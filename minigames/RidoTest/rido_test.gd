extends Node2D

func _ready():
	var popup = preload("res://scenes/ui/ScorePopup.tscn").instantiate()
	add_child(popup)
	popup.setup(100, Vector2(400,400))
