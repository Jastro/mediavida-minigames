extends AnimatedSprite2D

const PLAYER_MASK	: int = 2
const EXTENDED_RANGE: int = 25

var player : CharacterBody2D = null
var timer
var arrow_path : Path2D

var RANGE = {
	GameManager.Difficulty.EASY		: 400,
	GameManager.Difficulty.NORMAL	: 450,
	GameManager.Difficulty.HARD		: 500,
}
var FREQ = {
	GameManager.Difficulty.EASY		: 1.5,
	GameManager.Difficulty.NORMAL	: 1.2,
	GameManager.Difficulty.HARD		: 0.8,
}

func _ready():
	var arrow_path_scn = preload("res://minigames/TheOrcsAreComingFromTheEast/characters/archer/arrow_path.tscn") as PackedScene
	play("Idle")
	arrow_path = arrow_path_scn.instantiate()
	get_parent().call_deferred("add_child", arrow_path) # potentially we want archers to be able to move without moving all the arrows with them
	(%CollisionShape2D.shape as CircleShape2D).radius = RANGE[GameManager.get_difficulty()]
	$Area2D.body_entered.connect(_on_player_detected)
	$Area2D.collision_mask	= PLAYER_MASK
	$Area2D.collision_layer = 0
	timer			=  Timer.new()
	timer.wait_time = FREQ[GameManager.get_difficulty()]
	timer.one_shot	= false
	timer.autostart = false
	timer.timeout.connect(_on_shoot)
	add_child(timer)
	
func _on_player_detected(player_scene):
	player = player_scene
	timer.start()
	$Area2D.collision_mask = 0

func _on_shoot():
	if(player != null and player.global_position.distance_to(global_position) > (RANGE[GameManager.get_difficulty()] + EXTENDED_RANGE)):
		player = null
	
	if(player == null):
		$Area2D.collision_mask = PLAYER_MASK
		timer.stop()
		return
	flip_h = player.global_position.x < global_position.x
	$Pivot.scale.x = -1 if flip_h else 1
	shoot()
	
func shoot():
	if(animation == "Idle" || !is_playing()):
		play("Shoot")
		timer.stop()
		await get_tree().create_timer(0.6).timeout
		arrow_path.shoot_arrow(%ArrowPosition.global_position, player.global_position)
		await arrow_path.finished
		timer.start()
