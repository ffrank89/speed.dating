class_name GirlVoice
extends Resource
## How a girl sounds while her lines type out (Animal Crossing-style).
## Every letter plays a short sound; these settings make each girl's voice distinct.
## Full guide: docs/guides/dialogue-box.md

## Folder holding the letter sounds: a.wav, b.wav … z.wav (.ogg and .mp3 work too).
## Every girl can share one folder; pitch below makes them sound different.
@export_dir var letter_sounds_folder: String = "res://assets/audio/voice/default"
## 1.0 plays the sounds as recorded. Higher sounds younger and brighter, lower sounds deeper.
@export_range(0.5, 2.5, 0.01) var pitch: float = 1.0
## Random pitch wobble on each sound, so she doesn't sound like a robot. 0 = none.
@export_range(0.0, 0.5, 0.01) var pitch_variance: float = 0.1
## How long each letter takes to appear, in seconds. Lower = she talks faster.
@export_range(0.01, 0.15, 0.005) var seconds_per_letter: float = 0.04
## Play a sound every Nth letter. 1 = every letter (busy), 2 = every other letter (calmer).
@export_range(1, 4) var letters_per_sound: int = 1
## Loudness. 0 = as recorded, negative = quieter.
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -6.0
