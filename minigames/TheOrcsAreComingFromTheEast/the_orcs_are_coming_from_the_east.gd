extends Node2D

func _ready():
	%Player.Hurt.connect(_on_hurt)
	%HeartsContainer.initialise(%Player.get_max_hp())
	$%Player.Cooldown.connect(_on_cooldown_spell)

func _on_hurt(new_hp):
	%HeartsContainer.update_hp(new_hp)

func _on_cooldown_spell(time, spell):
	if(spell == 0):
		%Slash.set_reuse(time)
	else:
		%DarkSpell.set_reuse(time)
