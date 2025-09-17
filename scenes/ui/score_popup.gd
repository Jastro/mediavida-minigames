extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var difficulty_option: OptionButton = $VBoxContainer/DifficultyContainer/DifficultyOption

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	setup_difficulty_selector()
	update_ui()
	
	GameManager.game_over.connect(_on_game_over)
	# GameManager.play_music("res://audio/music/menu_music.ogg")

func setup_difficulty_selector():
	"""Setup the difficulty selection dropdown"""
	difficulty_option.add_item("Easy")
	difficulty_option.add_item("Normal") 
	difficulty_option.add_item("Hard")
	
	difficulty_option.selected = GameManager.get_difficulty()
	difficulty_option.item_selected.connect(_on_difficulty_changed)

func _on_difficulty_changed(index: int):
	"""Handle difficulty selection change"""
	GameManager.set_difficulty(index as GameManager.Difficulty)
func update_ui():
	"""Update the menu UI with current statistics"""
	high_score_label.text = "High Score: " + str(GameManager.high_score)
	
	var games_played = GameManager.total_games_played
	var games_won = GameManager.games_won
	var win_rate = GameManager.get_win_rate()
	
	if games_played > 0:
		stats_label.text = "Games Played: %d | Won: %d | Win Rate: %.1f%% | Difficulty: %s" % [games_played, games_won, win_rate, GameManager.get_difficulty_name()]
	else:
		stats_label.text = "Ready to play your first game? | Difficulty: %s" % GameManager.get_difficulty_name()
	
	var minigame_count = GameManager.available_minigames.size()
	if minigame_count > 0:
		title_label.text = "Community Minigames\n(%d games available)" % minigame_count
	else:
		title_label.text = "Community Minigames\n(No minigames found!)"
		start_button.disabled = true

func _on_start_pressed():
	"""Start a new game session"""
	GameManager.stop_music()
	GameManager.start_new_game()

func _on_quit_pressed():
	"""Quit the game"""
	get_tree().quit()

func _on_game_over():
	"""Called when returning from a game over"""
	update_ui()
	show_game_over_message()

func show_game_over_message():
	"""Display game over feedback"""
	var popup = AcceptDialog.new()
	add_child(popup)
	
	var final_score = GameManager.current_score
	var message = "Game Over!\n\nFinal Score: %d" % final_score
	
	if final_score == GameManager.high_score:
		message += "\n🎉 NEW HIGH SCORE! 🎉"
	
	popup.dialog_text = message
	popup.title = "Game Over"
	popup.popup_centered()
	
	await get_tree().create_timer(3.0).timeout
	if popup:
		popup.queue_free()

func _input(event):
	if event.is_action_pressed("ui_accept") and start_button.visible:
		_on_start_pressed()
	elif event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()
