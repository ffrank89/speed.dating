class_name LoopSound
extends Resource
## A sound that loops while something's on screen (the fly's buzz), with its own pitch,
## wobble and loudness, the way a girl's voice has hers. One file each in data/sounds/
## (fly_buzz.tres). A hazard points at one, e.g. the fly's Sounds → Buzz.

## The recording. Make it loop: click the file in FileSystem → Import tab → Loop Mode
## Forward (.wav) or Loop on (.ogg / .mp3) → Reimport.
@export var stream: AudioStream
## 1.0 plays it as recorded. Higher = higher and faster, lower = deeper and slower.
@export_range(0.25, 4.0, 0.01) var pitch: float = 1.0
## How much the pitch drifts up and down while it plays, so it doesn't sound like a
## machine. 0 = steady, 0.1 = up to 10% either way.
@export_range(0.0, 0.5, 0.01) var pitch_wobble: float = 0.08
## How fast the pitch drifts, in wobbles per second.
@export_range(0.0, 20.0, 0.1) var wobble_speed: float = 3.0
## Loudness. 0 = as recorded, negative = quieter.
@export_range(-40.0, 12.0, 0.5) var volume_db: float = -6.0


## The pitch `time` seconds after it started: Pitch, drifting by up to Pitch Wobble.
func pitch_at(time: float) -> float:
	var t := time * wobble_speed * TAU
	# Two waves at odd speeds, so the drift doesn't sound regular.
	var drift := (sin(t) + 0.5 * sin(t * 2.3 + 1.7)) / 1.5
	return maxf(0.05, pitch * (1.0 + pitch_wobble * drift))
