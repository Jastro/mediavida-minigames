extends Node

enum ESound {
	Success,
	Fail,
}

enum EMusic {
	Ambient,
}

enum EBus {
	Master, SFX, Music
}
var BusToString = {
	EBus.Master : "Master",
	EBus.SFX	: "SFX",
	EBus.Music	: "Music",
}
var SOUND_PATH = {
	ESound.Success	: "res://assets/audio/maygenko.itch.iobasic-rpg-sfx-by-maygenko/small victory slide up.ogg",
	ESound.Fail		: "res://assets/audio/maygenko.itch.iobasic-rpg-sfx-by-maygenko/falling notes - trouble.ogg",
}
var MUSIC_PATH = {
	EMusic.Ambient	: "res://assets/audio/leohpaz.itch.iominifantasy-dungeon-sfx-pack/Goblins_Dance_(Battle).wav",
}

# Audio players
var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = EBus.keys()[EBus.Music]
	add_child(music_player)
	
func play_sound(soundType: ESound):
	"""Play a sound effect"""
	var sound = load(SOUND_PATH[soundType]) as AudioStream
	if sound:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = EBus.keys()[EBus.SFX]
		sfx_player.stream = sound
		add_child(sfx_player)
		sfx_player.finished.connect(func():
			sfx_player.queue_free()
		)
		sfx_player.play()

func play_music(music_path: String, loop: bool = true):
	"""Play background music"""
	var music = load(music_path) as AudioStream
	if music:
		music_player.stream = music
		if music is AudioStreamOggVorbis:
			music.loop = loop
		music_player.play()

func play_success():
	play_sound(ESound.Success)
func play_fail():
	play_sound(ESound.Fail)

func stop_music():
	"""Stop background music"""
	music_player.stop()

func _on_sound_finished():
	queue_free()

func get_bus(bus : EBus):
	return BusToString[bus]
