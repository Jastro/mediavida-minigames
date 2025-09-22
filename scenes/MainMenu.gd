extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var difficulty_option = $VBoxContainer/DifficultyContainer/DifficultyOption
@onready var high_score_label = $VBoxContainer/StatsContainer/HighScoreLabel
@onready var win_rate_label = $VBoxContainer/StatsContainer/WinRateLabel
@onready var minigames_button = $VBoxContainer/ButtonsContainer/MinigamesButton
@onready var quit_button = $VBoxContainer/ButtonsContainer/QuitButton

func _ready():
	setup_difficulty_options()
	update_stats_display()

	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.minigame_completed.connect(_on_minigame_completed)

func _on_minigame_completed(_won: bool, _score: int):
	# Actualizar estadísticas cuando termine un minijuego
	update_stats_display()

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		# Actualizar cuando la escena se hace visible
		if high_score_label and win_rate_label:  # Verificar que existan
			update_stats_display()

func setup_difficulty_options():
	difficulty_option.clear()
	difficulty_option.add_item("Fácil")
	difficulty_option.add_item("Normal")
	difficulty_option.add_item("Difícil")
	difficulty_option.selected = GameManager.current_difficulty

func update_stats_display():
	if high_score_label:
		high_score_label.text = "Record: " + str(GameManager.high_score)
	if win_rate_label:
		win_rate_label.text = "Tasa de victoria: %.1f%%" % GameManager.get_win_rate()

func _on_play_button_pressed():
	GameManager.start_new_game()

func _on_difficulty_changed(index: int):
	GameManager.set_difficulty(index as GameManager.Difficulty)

func _on_minigames_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MiniGamesMenu/MinigamesList.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_score_changed(_new_score: int):
	update_stats_display()

func _on_game_over():
	update_stats_display()

func _on_reset_button_pressed():
	GameManager.reset_all_data()
	update_stats_display()
