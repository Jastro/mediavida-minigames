extends Control

@onready var minigames_list = $VBoxContainer/ScrollContainer/MinigamesList

func _ready():
	load_minigames()

func load_minigames():
	for child in minigames_list.get_children():
		child.queue_free()

	for minigame_path in GameManager.available_minigames:
		var item = create_minigame_item(minigame_path)
		minigames_list.add_child(item)

func create_minigame_item(path: String) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 80)

	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 20)
	panel.add_child(hbox)

	var name_label = Label.new()
	name_label.text = path.get_file().get_basename()
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(name_label)

	var play_button = Button.new()
	play_button.text = "Jugar"
	play_button.custom_minimum_size = Vector2(100, 40)
	play_button.pressed.connect(_on_play_minigame.bind(path))
	hbox.add_child(play_button)

	return panel

func _on_play_minigame(path: String):
	get_tree().change_scene_to_file(path)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
