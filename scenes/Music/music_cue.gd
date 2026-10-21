class_name MusicCue
extends Node
## Says what music plays in a scene: drop MusicCue.tscn into the scene and type the name
## of a track from data/music.tres → Tracks. When the scene starts, the music fades to it.
## A scene without a Music Cue keeps whatever is playing. Full guide: docs/guides/music.md

## The track to play (a name in data/music.tres → Tracks). Empty = the music stops.
@export var track: String = ""
## Seconds to fade to it. -1 = data/music.tres → Fade Seconds.
@export_range(-1.0, 10.0, 0.1) var fade_seconds: float = -1.0
## Off = it waits for play() from code instead of playing when the scene starts.
@export var play_on_start: bool = true


func _ready() -> void:
	if play_on_start:
		play()


## Fades the music to Track (or stops it when Track is empty).
func play() -> void:
	Music.play(track, fade_seconds)
