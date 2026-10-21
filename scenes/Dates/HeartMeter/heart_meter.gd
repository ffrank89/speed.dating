class_name HeartMeter
extends HBoxContainer
## The heart meter in the top right of a date: one ring per heart she can give (her
## Affection Thresholds, girl file → Dating). Each ring fills as the date score climbs
## toward its threshold; when it's full, its grey heart turns to colour and the heart
## sound plays. Dropping back below a threshold greys that heart again (hearts are
## counted at the end of the date).
##
## The fill colour is her dialogue style's Meter Color; everything else is Style
## (data/heart_meter_style.tres). One ring's design is Ring Scene (HeartRing.tscn).
## Where the meter sits: move this node in the date scene. A column instead of a row:
## turn on Vertical in the Inspector. Full guide: docs/guides/heart-meter.md

## Sent when a ring fills and she gives a heart. `hearts` = how many now.
signal heart_won(hearts: int)

## The meter's look and sound (data/heart_meter_style.tres).
@export var style: HeartMeterStyle
## One ring. Make your own design from HeartRing.tscn and drop it here.
@export var ring_scene: PackedScene = preload("res://scenes/Dates/HeartMeter/HeartRing.tscn")

@export_group("Testing (F6)")
## Played on its own, the meter uses her thresholds and colour, and fills up step by step.
@export var test_girl: GirlData
## Points added each step when played on its own.
@export_range(0.5, 5.0, 0.5) var test_step: float = 1.5

var _thresholds: Array[int] = []
var _rings: Array[HeartRing] = []

@onready var sound: AudioStreamPlayer = %Sound
## The filling ticks get their own player, so they don't cut off the heart sound.
@onready var fill_player: AudioStreamPlayer = %FillSound


func _ready() -> void:
	if not style:
		style = HeartMeterStyle.new()
	if get_parent() == get_tree().root:
		_play_alone.call_deferred()


## Builds one ring per heart `girl` can give, filled with her Meter Color, and empties them.
func setup(girl: GirlData) -> void:
	for ring in _rings:
		ring.queue_free()
	_rings.clear()
	_thresholds.assign(girl.affection_thresholds)
	_thresholds.sort()
	add_theme_constant_override("separation", style.ring_gap)
	var box_style := ContactCard.box_style_of(girl)
	for i in _thresholds.size():
		var ring := ring_scene.instantiate() as HeartRing
		add_child(ring)
		ring.setup(style, box_style.meter_color)
		ring.heart_won.connect(_on_heart_won)
		ring.ticked.connect(_on_ticked)
		_rings.append(ring)
	show_score(0.0, false)


## Fills the rings for this date score. `animate` = slide there (and play the sound for
## a new heart); off = jump there quietly.
func show_score(score: float, animate := true) -> void:
	var floor_score := 0.0
	for i in _rings.size():
		var top := float(_thresholds[i])
		var span := maxf(top - floor_score, 0.001)
		_rings[i].fill_to((score - floor_score) / span, animate)
		floor_score = top


## How many hearts the rings show now.
func hearts() -> int:
	return _rings.filter(func(ring: HeartRing) -> bool: return ring.won).size()


# A filling (or draining) tick, higher the fuller the ring.
func _on_ticked(amount: float, filling: bool) -> void:
	var stream := style.fill_sound if filling else style.drain_sound
	if not stream:
		return
	fill_player.stream = stream
	fill_player.volume_db = style.fill_volume_db
	fill_player.pitch_scale = lerpf(style.fill_pitch_start, style.fill_pitch_end, clampf(amount, 0.0, 1.0))
	fill_player.play()


func _on_heart_won() -> void:
	if style.heart_sound:
		sound.stream = style.heart_sound
		sound.volume_db = style.volume_db
		sound.play()
	heart_won.emit(hearts())


# F6: fills up a step at a time to past her last heart, then starts over.
func _play_alone() -> void:
	if not test_girl:
		push_warning("HeartMeter: set Testing → Test Girl to play it on its own.")
		return
	position = Vector2(get_viewport_rect().size.x - size.x - 80.0, 80.0)
	while true:
		setup(test_girl)
		var score := 0.0
		while score < float(_thresholds.back()) + test_step:
			await get_tree().create_timer(1.0).timeout
			score += test_step
			show_score(score)
			print("HeartMeter: score %.1f, %d hearts" % [score, hearts()])
		await get_tree().create_timer(2.0).timeout
