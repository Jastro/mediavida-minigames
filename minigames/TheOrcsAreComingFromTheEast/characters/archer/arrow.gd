extends Sprite2D

func _ready():
	$Hitbox.set_new_layer(Defs.L_ENEMY)
	$Hitbox.enable_permanent()
	
func kill():
	$Hitbox.disable()
	await get_tree().create_timer(3).timeout
	queue_free()
