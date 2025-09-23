extends Node

enum ESound {
	Success,
	Fail,
	### THE ORCS ARE COMING FROM THE WEST
	TOE_Dark_Spell,
	TOE_Explosion,
	TOE_Hurt,
	TOE_Shoot,
	TOE_Sword_Slash,
	TOE_Dash,
	TOE_Death,
	### END
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
	ESound.Success	: "res://assets/audio/maygenko.itch.iobasic-rpg-sfx-by-maygenko/success.ogg",
	ESound.Fail		: "res://assets/audio/maygenko.itch.iobasic-rpg-sfx-by-maygenko/fail.ogg",
	### THE ORCS ARE COMING FROM THE WEST
	ESound.TOE_Dark_Spell	: "res://minigames/TheOrcsAreComingFromTheEast/assets/audio/rido/dark_spell.wav",
	ESound.TOE_Explosion	: "res://minigames/TheOrcsAreComingFromTheEast/assets/audio/rido/explosion.wav",
	ESound.TOE_Hurt			: "res://minigames/TheOrcsAreComingFromTheEast/assets/audio/rido/hurt.wav",
	ESound.TOE_Shoot		: "res://minigames/TheOrcsAreComingFromTheEast/assets/audio/rido/shoot.wav",
	ESound.TOE_Sword_Slash	: "res://minigames/TheOrcsAreComingFromTheEast/assets/audio/rido/sword_slash.wav",
	ESound.TOE_Dash			: "res://minigames/TheOrcsAreComingFromTheEast/assets/audio/rido/dash.wav",
	ESound.TOE_Death		: "res://minigames/TheOrcsAreComingFromTheEast/assets/audio/rido/death.wav",
	### END
}
var MUSIC_PATH = {
	EMusic.Ambient	: "res://minigames/TheOrcsAreComingFromTheEast/assets/audio/leohpaz.itch.iominifantasy-dungeon-sfx-pack/Goblins_Dance_(Battle).wav"
}

var tween : Tween = null
# Audio players
var music_player: AudioStreamPlayer

func _ready():
	music_player				= AudioStreamPlayer.new()
	music_player.process_mode	= Node.PROCESS_MODE_ALWAYS # Plays even when paused
	music_player.bus			= EBus.keys()[EBus.Music]
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

func play_music(music_type: EMusic, loop: bool = true):
	"""Play background music"""
	var music = load(MUSIC_PATH[music_type]) as AudioStream
	
	if music:
		music_player.stream = music
		if music is AudioStreamOggVorbis:
			music.loop = loop
		music_player.play()

func play_success():
	play_sound(ESound.Success)
func play_fail():
	play_sound(ESound.Fail)

func stop_music(fade_out : bool = false, time : float = 1.0):
	"""Stop background music"""
	if(fade_out):
		if(tween != null):
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_OUT)
		tween.tween_property(music_player, "volume_linear", 0.0, time)
		tween.play()
		await tween.finished
	music_player.stop()

func _on_sound_finished():
	queue_free()

func get_bus(bus : EBus):
	return BusToString[bus]
