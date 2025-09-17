extends Control

@onready var final_score_label = $VBoxContainer/StatsContainer/FinalScoreLabel
@onready var games_won_label = $VBoxContainer/StatsContainer/GamesWonLabel
@onready var win_rate_label = $VBoxContainer/StatsContainer/WinRateLabel

func _ready():
	update_stats_display()

func update_stats_display():
	final_score_label.text = "Puntuación Final: " + str(GameManager.current_score)
	games_won_label.text = "Minijuegos jugados esta sesión: " + str(GameManager.played_minigames.size())
	win_rate_label.text = "Tasa de victoria global: %.1f%%" % GameManager.get_win_rate()

func _on_play_again_button_pressed():
	# Reiniciar nueva sesión con todos los minijuegos
	GameManager.start_new_game()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")