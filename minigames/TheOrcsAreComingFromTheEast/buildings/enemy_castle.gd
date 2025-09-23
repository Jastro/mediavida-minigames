extends Node2D

signal Destroyed()

var max_hp = {
	GameManager.Difficulty.EASY		: 8,
	GameManager.Difficulty.NORMAL	: 12,
	GameManager.Difficulty.HARD		: 18,
}

var current_hp

func _ready():
	current_hp = max_hp[GameManager.get_difficulty()]
	$Hurtbox.hurt.connect(_on_hurt)
	$Hurtbox.set_new_mask(Defs.L_PLAYER)

func _on_hurt(_source):
	AudioManager.play_sound(AudioManager.ESound.TOE_Hurt)
	$AnimationPlayer.play("Hurt")
	current_hp = clamp(current_hp-1, 0, max_hp[GameManager.get_difficulty()])
	if(current_hp == 0):
		%Hurtbox.disable_permanent()
		AudioManager.stop_music(true, 1)
		# TODO: FIRE ANIMATION
		# TODO: Show score
		Destroyed.emit()
