class_name GirlVoice
extends Resource
## How a girl sounds while her lines type out (Animalese-style).
## Every girl shares the same letter sounds; these settings make each voice distinct.

## 1.0 is the recorded pitch. Higher sounds younger and brighter.
@export_range(0.5, 2.5, 0.01) var pitch: float = 1.0
## Random pitch wobble per letter, so she doesn't sound like a robot.
@export_range(0.0, 0.5, 0.01) var pitch_variance: float = 0.1
## Typing speed. Lower is faster.
@export_range(0.01, 0.15, 0.005) var seconds_per_letter: float = 0.04
@export_range(-24.0, 6.0, 0.5) var volume_db: float = -6.0
