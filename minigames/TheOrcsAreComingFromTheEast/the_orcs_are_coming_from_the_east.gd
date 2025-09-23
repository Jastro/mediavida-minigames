extends Node2D

func _ready():
	%Player.Hurt.connect(_on_hurt)
	%HeartsContainer.initialise(%Player.get_max_hp())
	$%Player.Cooldown.connect(_on_cooldown_spell)
	AudioManager.play_music(AudioManager.EMusic.Ambient)

func _on_hurt(new_hp):
	%HeartsContainer.update_hp(new_hp)

func _on_cooldown_spell(time, spell):
	match spell:
		0:
			%Slash.set_reuse(time)
		1:
			%DarkSpell.set_reuse(time)
		2:
			%Dash.set_reuse(time)
