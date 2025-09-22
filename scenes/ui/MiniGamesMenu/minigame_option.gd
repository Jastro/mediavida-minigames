extends MarginContainer

signal Selected(path : String)

var path

func _ready():
	%Button.pressed.connect(_on_pressed)

func set_minigame_path(game_path: String):
	path = game_path
	%Label.text = path.get_file().get_basename()

func _on_pressed():
	Selected.emit(path)
