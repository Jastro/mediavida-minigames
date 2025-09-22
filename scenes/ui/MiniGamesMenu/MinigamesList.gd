extends Control

var minigame_option_scn : PackedScene

func _ready():
	minigame_option_scn = preload("res://scenes/ui/MiniGamesMenu/minigame_option.tscn")
	load_minigames()

func load_minigames():
	for child in %MinigamesList.get_children():
		child.queue_free()

	for minigame_path in GameManager.available_minigames:
		var item = create_minigame_item(minigame_path)
		%MinigamesList.add_child(item)

func create_minigame_item(path: String) -> MarginContainer:
	var minigame_option = minigame_option_scn.instantiate() as MarginContainer
	minigame_option.set_minigame_path(path)
	minigame_option.Selected.connect(_on_play_minigame)
	return minigame_option
	

func _on_play_minigame(path: String):
	get_tree().change_scene_to_file(path)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
