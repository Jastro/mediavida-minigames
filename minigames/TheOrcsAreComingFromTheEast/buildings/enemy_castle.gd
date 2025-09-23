extends Node2D

func _ready():
	$Hurtbox.hurt.connect(_on_hurt)
	$Hurtbox.set_new_mask(Defs.L_PLAYER)

func _on_hurt(_source):
	AudioManager.play_sound(AudioManager.ESound.TOE_Hurt)
	$AnimationPlayer.play("Hurt")
