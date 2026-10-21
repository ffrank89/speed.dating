class_name MusicLibrary
extends Resource
## The game's music: every track by name, how one track turns into the next, and how loud
## the music is. A scene says which track plays there with a Music Cue
## (scenes/Music/MusicCue.tscn); a scene without one keeps whatever is playing.
## One file: data/music.tres. Full guide: docs/guides/music.md

@export_group("Tracks")
## Every track by name. Add one with Add Key/Value Pair: type its name, then make a new
## MusicTrack and drag the sound file onto its Stream. Two names can share a file: going
## from one to the other doesn't restart it.
@export var tracks: Dictionary[String, MusicTrack] = {}

@export_group("Changing Tracks")
## Seconds one track takes to fade into the next (and to fade out when the music stops).
@export_range(0.0, 10.0, 0.1) var fade_seconds: float = 1.5
## Off = the new track fades in while the old one fades out. On = the old one fades out
## first, then the new one fades in.
@export var fade_out_first: bool = false

@export_group("Volume")
## How loud all the music is, in dB. 0 = as recorded.
@export_range(-40.0, 6.0, 0.5) var volume_db: float = -8.0
## The audio bus the music plays on (the Audio panel at the bottom of Godot). Its effects
## and volume apply to all the music.
@export var bus: StringName = &"Music"
## While a microgame plays, the music gets this much quieter, in dB. 0 = no change.
@export_range(-40.0, 0.0, 0.5) var microgame_quieter_db: float = -12.0
## Seconds it takes to get quieter, and loud again.
@export_range(0.0, 3.0, 0.05) var quieter_seconds: float = 0.3


## The track with this name, or null (with a warning) if there isn't one.
func track(track_name: String) -> MusicTrack:
	var found: MusicTrack = tracks.get(track_name)
	if not found:
		push_warning("Music: no track named \"%s\" in data/music.tres." % track_name)
	elif not found.stream:
		push_warning("Music: the track \"%s\" has no Stream." % track_name)
		return null
	return found
