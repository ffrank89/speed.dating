class_name VoicePlayer
extends Node
## Plays a girl's Animal Crossing-style voice: one short sound per typed letter.
## Connect a DialogueLabel's `spoke` signal to speak(). Set the voice with set_voice().
## Spaces, numbers and punctuation are silent.

## How many sounds can overlap. Fast talkers need a few so sounds don't cut each other off.
const CHANNELS := 4
const EXTENSIONS := ["wav", "ogg", "mp3"]

var _voice: GirlVoice
var _sounds: Dictionary = {}  # "a" -> AudioStream
var _players: Array[AudioStreamPlayer] = []
var _next_player := 0
var _letters_since_sound := 0


func _ready() -> void:
	for i in CHANNELS:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)


## Switch to a girl's voice. Pass null for a silent speaker.
func set_voice(voice: GirlVoice) -> void:
	_voice = voice
	_sounds = _load_letters(voice.letter_sounds_folder) if voice else {}


## Call at the start of each line so "every Nth letter" starts counting fresh.
func reset() -> void:
	_letters_since_sound = 0


## Matches DialogueLabel.spoke(letter, letter_index, speed).
func speak(letter: String, _letter_index: int = 0, _speed: float = 1.0) -> void:
	var key := letter.to_lower()
	if not _voice or not _sounds.has(key):
		return
	_letters_since_sound += 1
	if (_letters_since_sound - 1) % _voice.letters_per_sound != 0:
		return
	var player := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = _sounds[key]
	player.pitch_scale = maxf(0.05, _voice.pitch + randf_range(-_voice.pitch_variance, _voice.pitch_variance))
	player.volume_db = _voice.volume_db
	player.play()


# Loads a.wav … z.wav from the folder; letters with no file are silent.
static func _load_letters(folder: String) -> Dictionary:
	var sounds := {}
	for code in range("a".unicode_at(0), "z".unicode_at(0) + 1):
		var letter := String.chr(code)
		for ext in EXTENSIONS:
			var path := "%s/%s.%s" % [folder.trim_suffix("/"), letter, ext]
			if ResourceLoader.exists(path):
				sounds[letter] = load(path)
				break
	if sounds.is_empty():
		push_warning("VoicePlayer: no letter sounds found in %s" % folder)
	return sounds
