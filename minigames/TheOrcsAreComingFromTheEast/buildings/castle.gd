extends Sprite2D
enum ESkin {
	Blue,
	Yellow,
	Red,
	Black,
}
var skins = {
	ESkin.Blue		: "res://minigames/TheOrcsAreComingFromTheEast/assets/TinySwords/Buildings/Blue Buildings/Castle.png",
	ESkin.Yellow	: "res://minigames/TheOrcsAreComingFromTheEast/assets/TinySwords/Buildings/Yellow Buildings/Castle.png",
	ESkin.Red		: "res://minigames/TheOrcsAreComingFromTheEast/assets/TinySwords/Buildings/Red Buildings/Castle.png",
	ESkin.Black	: "res://minigames/TheOrcsAreComingFromTheEast/assets/TinySwords/Buildings/Black Buildings/Castle.png",
}
@export var skin : ESkin

func set_skin(new_skin : ESkin):
	skin = new_skin
	var new_texture : CompressedTexture2D = load(skins[skin])
	texture = new_texture

func _ready():
	var new_texture : CompressedTexture2D = load(skins[skin])
	texture = new_texture
