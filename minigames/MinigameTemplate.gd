extends Node2D

signal minigame_finished(won: bool, score: int)

var score: int = 0
var is_game_active: bool = false
var time_left: float = 30.0

func _ready():
	setup_minigame()
	await get_tree().create_timer(2.0).timeout
	start_minigame()

func setup_minigame():
	pass

func start_minigame():
	is_game_active = true
	score = 0
	time_left = 30.0

	var timer = GameManager.start_countdown_timer(30.0, end_minigame)

func _process(delta):
	if is_game_active:
		time_left -= delta
		update_game_logic(delta)

func update_game_logic(_delta):
	pass

func add_points(points: int):
	if not is_game_active:
		return

	var difficulty_bonus = GameManager.get_difficulty_multiplier()
	var final_points = int(points * difficulty_bonus)
	score += final_points

	GameManager.add_score(final_points)

func end_minigame():
	is_game_active = false

	var won = check_win_condition()

	await get_tree().create_timer(2.0).timeout

	GameManager.complete_minigame(won, score)

func check_win_condition() -> bool:
	return score >= 1000
