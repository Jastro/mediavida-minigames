extends Node

# Signals
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal game_over
signal minigame_completed(won: bool, score: int)
signal difficulty_changed(new_difficulty: Difficulty)

# Difficulty System
enum Difficulty {
	EASY	= 0,
	NORMAL	= 1,
	HARD	= 2
}

# Game State Variables
var current_score		: int = 0
var lives				: int = 3
var high_score			: int = 0
var total_games_played	: int = 0
var games_won			: int = 0



var current_difficulty: Difficulty = Difficulty.NORMAL

# Minigame Management
var available_minigames: Array[String] = []
var played_minigames: Array[String] = []
var current_minigame_scene: Node = null

func _ready():
	randomize()
	load_game_data()
	scan_minigames()

# === CORE GAME FUNCTIONS ===
func start_new_game():
	"""Start a new game session"""
	current_score = 0
	lives = 3
	played_minigames.clear()  # Resetear lista de minijuegos jugados
	# NO resetear total_games_played y games_won aquí, esas son estadísticas persistentes

	score_changed.emit(current_score)
	lives_changed.emit(lives)

	start_random_minigame()

func add_score(points: int):
	"""Add points to current score"""
	current_score += points
	if current_score > high_score:
		high_score = current_score
		save_game_data()
	
	score_changed.emit(current_score)

func lose_life():
	"""Remove one life and check for game over"""
	lives -= 1
	lives_changed.emit(lives)
	
	if lives <= 0:
		trigger_game_over()
	else:
		# Continue to next minigame
		start_random_minigame()

func trigger_game_over():
	"""End the current game session"""
	save_game_data()
	game_over.emit()
	
	# Return to main menu after a delay
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# === MINIGAME MANAGEMENT ===
func scan_minigames():
	"""Automatically scan for available minigames in the minigames folder"""
	available_minigames.clear()
	const base_dir_path = "res://minigames/"
	var base_dir = DirAccess.open(base_dir_path)
	
	if base_dir:
		base_dir.list_dir_begin()
		var game_dir_name = base_dir.get_next()
		
		while game_dir_name != "":
			var game_dir = DirAccess.open(base_dir_path + game_dir_name)
			if(game_dir):
				game_dir.list_dir_begin()
				var game_file_name = game_dir.get_next()
				while(game_file_name):
					var game_file_name_no_ext = game_file_name.substr(0, game_file_name.find("."))
					if game_file_name.ends_with(".tscn") and game_file_name_no_ext.to_lower() == game_dir_name.to_lower():
						available_minigames.append(base_dir_path + game_dir_name + "/" + game_file_name)
					game_file_name = game_dir.get_next()
			game_dir_name = base_dir.get_next()

func start_random_minigame():
	"""Start a random minigame from available ones with current difficulty"""
	if available_minigames.is_empty():
		printerr("No minigames found!")
		return

	# Filtrar minijuegos no jugados
	var unplayed_minigames = []
	for game in available_minigames:
		if not played_minigames.has(game):
			unplayed_minigames.append(game)

	# Si no quedan minijuegos por jugar, mostrar pantalla de completado
	if unplayed_minigames.is_empty():
		show_game_complete_screen()
		return

	var random_game = unplayed_minigames[randi() % unplayed_minigames.size()]
	played_minigames.append(random_game)  # Marcar como jugado

	# Store current difficulty for the minigame to access
	get_tree().change_scene_to_file(random_game)

func complete_minigame(won: bool, score_earned: int = 0):
	"""Call this when a minigame finishes"""
	AudioManager.stop_music()
	total_games_played += 1

	if won:
		games_won += 1
		AudioManager.play_success()
	else:
		AudioManager.play_fail()

	# Actualizar high score si es mayor
	if score_earned > high_score:
		high_score = score_earned

	# Siempre volver al menú principal después de un minijuego individual
	save_game_data()
	minigame_completed.emit(won, score_earned)

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# === DIFFICULTY SYSTEM ===
func set_difficulty(difficulty: Difficulty):
	"""Change the current difficulty level"""
	current_difficulty = difficulty
	difficulty_changed.emit(current_difficulty)
	save_game_data()

func get_difficulty() -> Difficulty:
	"""Get the current difficulty level"""
	return current_difficulty

func get_difficulty_name() -> String:
	"""Get the current difficulty as a string"""
	match current_difficulty:
		Difficulty.EASY:
			return "Easy"
		Difficulty.NORMAL:
			return "Normal"
		Difficulty.HARD:
			return "Hard"
		_:
			return "Normal"

func create_minigame_timer(duration: float = 30.0) -> Timer:
	"""Create a standard minigame timer"""
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	return timer

func start_countdown_timer(duration: float, callback: Callable) -> Timer:
	"""Start a countdown timer with callback"""
	var timer = create_minigame_timer(duration)
	get_tree().current_scene.add_child(timer)
	timer.timeout.connect(callback)
	timer.start()
	return timer

# === VISUAL EFFECTS ===

func screen_shake(intensity: float = 10.0, duration: float = 0.5):
	"""Create screen shake effect"""
	var camera = get_viewport().get_camera_2d()
	if camera:
		var original_pos = camera.global_position
		var tween = create_tween()
		
		for i in range(int(duration * 60)): # 60 FPS
			var shake_offset = Vector2(
				randf_range(-intensity, intensity),
				randf_range(-intensity, intensity)
			)
			tween.tween_method(
				func(pos): camera.global_position = pos,
				camera.global_position,
				original_pos + shake_offset,
				0.016 # One frame
			)
		
		tween.tween_callback(func(): camera.global_position = original_pos)

func show_score_popup(points: int, world_position: Vector2):
	"""Show animated score popup"""
	var popup = preload("res://scenes/ui/ScorePopup.tscn").instantiate()
	get_tree().current_scene.add_child(popup)
	popup.setup(points, world_position)

# === DATA PERSISTENCE ===
func save_game_data():
	"""Save game statistics"""
	var save_data = {
		"high_score": high_score,
		"total_games_played": total_games_played,
		"games_won": games_won,
		"difficulty": current_difficulty
	}
	
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_game_data():
	"""Load saved game statistics"""
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var save_data = json.data
			high_score = save_data.get("high_score", 0)
			total_games_played = save_data.get("total_games_played", 0)
			games_won = save_data.get("games_won", 0)
			current_difficulty = save_data.get("difficulty", Difficulty.NORMAL)

# === UTILITY FUNCTIONS ===

func get_win_rate() -> float:
	"""Calculate win rate percentage"""
	if total_games_played == 0:
		return 0.0
	return float(games_won) / float(total_games_played) * 100.0

func show_game_complete_screen():
	"""Show congratulations screen when all minigames are completed"""
	save_game_data()
	get_tree().change_scene_to_file("res://scenes/GameComplete.tscn")

func reset_all_data():
	"""Reset all game data (for debugging)"""
	current_score = 0
	lives = 3
	high_score = 0
	total_games_played = 0
	games_won = 0
	current_difficulty = Difficulty.NORMAL
	save_game_data()
