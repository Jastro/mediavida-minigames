extends Sprite2D

func _ready():
	$Hitbox.set_new_layer(Defs.L_ENEMY)
	$Hitbox.enable_permanent()
	AudioManager.play_sound(AudioManager.ESound.TOE_Shoot)
	
	
func kill():
	await get_tree().create_timer(0.2).timeout
	$Hitbox.disable()
	await get_tree().create_timer(3).timeout
	queue_free()
