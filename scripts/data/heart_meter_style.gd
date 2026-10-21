class_name HeartMeterStyle
extends Resource
## How the heart meter looks and sounds: the rings in the top right of a date, one per
## heart. Each ring fills toward her next Affection Threshold (her girl file → Dating);
## when it's full, the grey heart in its middle turns to colour and you get that heart.
## The fill colour is HER dialogue style's Meter Color. One file:
## data/heart_meter_style.tres. Where the meter sits: scenes/Dates/Date/Date.tscn →
## HeartMeter. Full guide: docs/guides/heart-meter.md

@export_group("Rings")
## Size of each ring, in pixels.
@export_range(40, 600) var ring_size: int = 150
## How thick the ring is, in pixels.
@export_range(2, 100) var ring_width: int = 16
## The part of the ring that isn't filled yet.
@export var track_color: Color = Color(1, 1, 1, 0.3)
## A dark line around each ring so it shows up on any background. A = how strong; 0 = none.
@export var ring_outline_color: Color = Color(0, 0, 0, 0.35)
## Space between the rings, in pixels.
@export_range(0, 200) var ring_gap: int = 18
## Seconds a ring takes to fill (or empty) to the new score.
@export_range(0.0, 3.0, 0.05) var fill_seconds: float = 0.6

@export_group("Heart")
## The heart in the middle of each ring.
@export var heart_image: Texture2D
## The heart before its ring is full. Empty = Heart Image in grey.
@export var empty_heart_image: Texture2D
## Size of the heart, in pixels.
@export_range(8, 600) var heart_size: int = 104
## How see-through the grey heart is (1 = solid).
@export_range(0.0, 1.0, 0.05) var empty_heart_alpha: float = 0.85
## How much the heart pops when its ring fills (1 = no pop).
@export_range(1.0, 3.0, 0.05) var heart_pop: float = 1.5

@export_group("Sounds")
## When a ring fills and you get a heart. Now the same sound as getting her number.
@export var heart_sound: AudioStream
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -6.0
