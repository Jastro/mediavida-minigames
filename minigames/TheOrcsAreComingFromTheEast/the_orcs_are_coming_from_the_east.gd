extends Node2D

var TIME = {
	GameManager.Difficulty.EASY		: 120,
	GameManager.Difficulty.NORMAL	: 60,
	GameManager.Difficulty.HARD		: 40,
}

var orcs_defeated		: int	= 0
var castle_destroyed	: bool	= false

func _ready():
	$Timer.wait_time = TIME[GameManager.get_difficulty()]
	$Timer.timeout.connect(_on_loss)
	$Timer.start()
	%TimeLeft.text = "Time Left: " + str(int(ceil(TIME[GameManager.get_difficulty()])))
	$TimeUpdate.timeout.connect(_on_time_update)
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
	castle_destroyed = true
	show_score()

func _on_loss():
	show_score()
	
func show_score():
	#var tween = create_tween()
	#tween.tween_property(Engine, "time_scale", 0, 0.2)
	for enemy in get_tree().get_nodes_in_group("freezable"):
		enemy.freeze()
	%Player.disable_hurtbox()
	$Timer.paused = true
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
	]
	if(castle_destroyed):
		score.append({
			"attribute"		: "Time left",
			"value"			: $Timer.time_left,
			"total"			: 0,
			"multiplier"	: 0.2,
		})
	%GameScore.visible = true
	%GameScore.setup(score, castle_destroyed)
func _on_time_update():
	%TimeLeft.text = "Time Left: " + str(int(ceil($Timer.time_left)))
