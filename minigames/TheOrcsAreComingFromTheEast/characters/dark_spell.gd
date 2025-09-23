extends AnimatedSprite2D

const speed : float = 350.0

var lifetime = {
	GameManager.Difficulty.EASY		: 3,
	GameManager.Difficulty.NORMAL	: 1.5,
	GameManager.Difficulty.HARD		: 1,
}

var direction = Vector2.RIGHT
var timer

func _ready():
	$Hitbox.set_new_layer(Defs.L_PLAYER)
	$Hitbox.enable_permanent()
	play("default")
	animation_finished.connect(_on_animation_finished)
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = lifetime[GameManager.get_difficulty()]
	timer.timeout.connect(_on_death)
	add_child(timer)
	timer.start()
	AudioManager.play_sound(AudioManager.ESound.TOE_Dark_Spell)
	
func _physics_process(delta):
	global_position += direction * speed * delta

func _on_death():
	timer.stop()
	AudioManager.play_sound(AudioManager.ESound.TOE_Explosion)
	play("destroy")

func _on_animation_finished():
	if(animation == "destroy"):
		queue_free()
