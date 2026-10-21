class_name Annoyance
extends Resource
## How she reacts when something annoys her on a date. The date stops for a moment (her
## dialogue and the option bubbles freeze, and her dialogue box grays out), she turns
## around, reacts, says her line in a bubble by her head (the date's Bark), and the date
## loses points. Then she turns back and the date carries on.
##
## One file each in data/annoyances/ (ew.tres: the fly sitting on her). A stage hazard
## points at one (its top node → Annoying Her → Annoyance), so several hazards can share
## the same reaction, and changing the file changes it for all of them.
## Full guide: docs/guides/stage-hazards.md

## What she says, in a little bubble by her head (the date's Bark), in her own box style
## and voice. Empty = nothing.
@export var line: String = ".....ew"
## Her reaction: a name in data/reactions.tres (anger, question...). Empty = none.
@export var reaction: String = "anger"
## Optional: a pose she switches to (a pose name from her girl file, e.g. backshot:
## turned away). A girl without that pose stays as she is. Empty = no change.
@export var pose: String = ""
## On = she goes back to the pose she had when the date carries on. Off = she stays in
## Pose until a line changes it.
@export var pose_back: bool = true
## Points taken off the date score (the heart meter drains).
@export_range(0.0, 10.0, 0.5) var points: float = 1.0
## How long the date stops, in seconds (at least as long as her line takes to type).
@export_range(0.0, 10.0, 0.1) var pause_seconds: float = 1.0
## Her dialogue box at the bottom grays out to this colour while the date is stopped.
## White = no change.
@export var box_color: Color = Color(0.55, 0.55, 0.55, 1.0)
## How long the box takes to gray out and come back, in seconds.
@export_range(0.0, 1.0, 0.05) var box_fade_seconds: float = 0.15
