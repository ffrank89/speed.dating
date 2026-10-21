class_name MusicTrack
extends Resource
## One piece of music: the sound file, how loud it is, and how it loops. Tracks live in
## data/music.tres → Tracks, each under a name; a scene's Music Cue picks one by name.
## Full guide: docs/guides/music.md

## The sound file (.ogg, .mp3 or .wav).
@export var stream: AudioStream
## Louder or quieter than the other tracks, in dB. 0 = as loud as the music's Volume.
@export_range(-30.0, 12.0, 0.5) var volume_db: float = 0.0
## On = it starts again when it ends.
@export var loop: bool = true
## Starts again this many seconds before the end, for files with silence at the end.
## 0 = at the very end.
@export_range(0.0, 10.0, 0.05) var loop_early_seconds: float = 0.0
## Where it starts (and loops back to), in seconds.
@export_range(0.0, 600.0, 0.1) var start_at: float = 0.0
