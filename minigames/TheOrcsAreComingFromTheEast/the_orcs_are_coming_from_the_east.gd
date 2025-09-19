extends Node2D

func _ready():
	%Player.Hurt.connect(_on_hurt)
	%HeartsContainer.initialise(%Player.max_hp)

func _on_hurt(new_hp):
	%HeartsContainer.update_hp(new_hp)
