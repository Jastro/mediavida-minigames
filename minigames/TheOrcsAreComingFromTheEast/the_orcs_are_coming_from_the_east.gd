extends Node2D

var orcs_defeated		: int	= 0
var castle_destroyed	: bool	= false

func _ready():
	%Player.Hurt.connect(_on_hurt)
	%HeartsContainer.initialise(%Player.get_max_hp())
	$%Player.Cooldown.connect(_on_cooldown_spell)
	AudioManager.play_music(AudioManager.EMusic.Ambient)
	for enemy in %Enemies.get_children():
		enemy.Dead.connect(_on_enemy_defeated)
	%Player.Dead.connect(_on_loss)
	%EnemyCastle.Destroyed.connect(_on_win)

func _on_hurt(new_hp):
	%HeartsContainer.update_hp(new_hp)
	
func _on_enemy_defeated():
	orcs_defeated += 1
	
func _on_cooldown_spell(time, spell):
	match spell:
		0:
			%Slash.set_reuse(time)
		1:
			%DarkSpell.set_reuse(time)
		2:
			%Dash.set_reuse(time)
func _on_win():
	%Player.disable_hurtbox()
	castle_destroyed = true
	show_score()

func _on_loss():
	show_score()
	
func show_score():
	var score = [
		{
			"attribute" 	: "Orcs defeated",
			"value"			: orcs_defeated,
			"total"			: 0,
			"multiplier"	: 4,
		},
		{
			"attribute" 	: "hp",
			"value"			: %Player.current_hp,
			"total"			: %Player.max_hp[GameManager.get_difficulty()],
			"multiplier"	: 10,
		},
		{
			"attribute"		: "Castle defeated",
			"value"			: 1 if castle_destroyed else 0,
			"total"			: 1,
			"multiplier"	: 40,
		},
		{
			"attribute"		: "Time left",
			"value"			: 126,
			"total"			: 0,
			"multiplier"	: 0.2,
		}
	]
	%GameScore.visible = true
	%GameScore.setup(score, castle_destroyed)
