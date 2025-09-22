extends Area2D

@export var base_speed := 300.0
var fall_speed := 300.0

var game_scene: Node

func _ready():
	game_scene = get_parent()

	# Escala aleatoria entre 1x y 5x
	var random_scale = randf_range(1, 3)
	scale = Vector2.ONE * random_scale
	
	var difficulty = GameManager.get_difficulty()
	match difficulty:
		GameManager.Difficulty.EASY:
			fall_speed = base_speed * 1.0
		GameManager.Difficulty.NORMAL:
			fall_speed = base_speed * 2.0
		GameManager.Difficulty.HARD:
			fall_speed = base_speed * 3.0

func _process(delta):
	if game_scene and game_scene.is_game_active:
		position.y += fall_speed * delta
	if position.y > 720:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.screen_shake(100.0, 1)

		if game_scene:
			game_scene.end_game(false)
