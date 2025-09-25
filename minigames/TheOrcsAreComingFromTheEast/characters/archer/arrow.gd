extends Sprite2D

signal tree_collision()

func _ready():
	$Hitbox.set_new_layer(Defs.L_ENEMY)
	$Hitbox.enable_permanent()
	AudioManager.play_sound(AudioManager.ESound.TOE_Shoot)
	$Area2D.body_entered.connect(_on_tree_collision)
	
func kill():
	await get_tree().create_timer(0.2).timeout
	$Hitbox.disable()
	await get_tree().create_timer(3).timeout
	queue_free()

func _on_tree_collision(_source):
	$Area2D.set_deferred("monitoring", false)
	tree_collision.emit()
	
