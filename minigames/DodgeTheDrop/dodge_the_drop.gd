extends Node2D

@onready var player = $Player
@onready var score_label: Label = $ScoreLabel
@onready var result_label: Label = $ResultLabel
@export var obstacle_scene: PackedScene
var is_game_active := false
var time_left := 10.0
var score := 0.0
var obstacle_timer: Timer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.start_countdown_timer(time_left, _on_minigame_timeout)
	is_game_active = true
	print("Dificultad: %d" % GameManager.get_difficulty())
	spawn_obstacles()

func spawn_obstacles():
	obstacle_timer = Timer.new()
	# Ajustamos el tiempo entre rocas según la dificultad
	match GameManager.get_difficulty():
		0:
			obstacle_timer.wait_time = 0.25
		1:
			obstacle_timer.wait_time = 0.10
		2:
			obstacle_timer.wait_time = 0.05

	obstacle_timer.autostart = true

	obstacle_timer.timeout.connect(func ():
		if not is_game_active:
			return
		var obs = obstacle_scene.instantiate()
		obs.game_scene = self
		obs.position = Vector2(randi_range(20, 1152), -40)
		add_child(obs)
	)
	add_child(obstacle_timer)

func _on_minigame_timeout():
	is_game_active = false
	# 100 puntos si no colisionó
	end_game(true)
	
func _process(delta):
	if is_game_active:
		score += 100.0 / time_left * delta
		score = clamp(score, 0.0, 100.0)
		score_label.text = "Puntos: " + str(round(score))
	
func end_game(won: bool):
	is_game_active = false
	var final_score = round(score)
	# Mostrar cartel centrado
	result_label.text = "¡Has ganado %d puntos!" % final_score
	result_label.visible = true
	GameManager.complete_minigame(won, final_score)
