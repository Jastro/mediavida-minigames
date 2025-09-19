extends AnimatedSprite2D

const PLAYER_MASK : int = 2

func _ready():
	$Hurtbox.set_new_mask(PLAYER_MASK)
	$Hurtbox.hurt.connect(_on_hurt)
	animation_finished.connect(_on_animation_finished)
func _on_hurt(_source):
	play("Hurt")
	$Hurtbox.disable_permanent()
func _on_animation_finished():
	$Hurtbox.enable()
