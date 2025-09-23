extends Node2D

@onready var player = $Player
@onready var score_label: Label = $UI/UIRoot/ScorePanel/ScoreLabel
@onready var start_panel: Control = $UI/UIRoot/StartPanel
@onready var result_panel: Control = $UI/UIRoot/ResultPanel
@onready var result_label: Label = $UI/UIRoot/ResultPanel/ResultLabel
@export var obstacle_scene: PackedScene
var is_game_active := false
var time_left := 10.0
var score := 0.0
var obstacle_timer: Timer

func _ready():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_show_start_message()
		await get_tree().create_timer(2.0).timeout
		
		GameManager.start_countdown_timer(time_left, _on_minigame_timeout)
		is_game_active = true
		# print("Dificultad: %d" % GameManager.get_difficulty())
		spawn_obstacles()

func spawn_obstacles():
	obstacle_timer = Timer.new()
	# Ajustamos el tiempo entre rocas según la dificultad
	match GameManager.get_difficulty():
		GameManager.Difficulty.EASY:
			obstacle_timer.wait_time = 0.25
		GameManager.Difficulty.NORMAL:
			obstacle_timer.wait_time = 0.10
		GameManager.Difficulty.HARD:
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
				score_label.text = "Puntuación: " + str(round(score))

func end_game(won: bool):
		is_game_active = false
		var final_score = round(score)
		# Mostrar cartel centrado
		var headline = "¡Ups! ¡Te alcanzó un patinete!"
		if won:
			headline = "¡Superaste la espera!"
		result_label.text = "%s\nPuntuación final: %d" % [headline, final_score]
		result_panel.visible = true
		start_panel.visible = false
		GameManager.complete_minigame(won, final_score)

func _show_start_message():
		start_panel.visible = true
		var timer := get_tree().create_timer(2.0)
		timer.timeout.connect(func():
				start_panel.visible = false
		)
