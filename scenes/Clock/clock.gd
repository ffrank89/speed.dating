@tool
class_name ClockTimer
extends Control
## An analog clock you can use as a timer. Set Minutes and Seconds, and the hands show
## that much time. Press F6 to watch it run. In the editor the hands show the time you
## set, so you can see where they'll end up.
##
## The big hand goes round once every Seconds Per Big Turn (60: a second hand). The
## little hand goes round once every Seconds Per Little Turn (3600: a minute hand, so
## each number is 5 minutes). Change those to make them other hands.

## Sent when the time has run out.
signal finished

## How long the timer runs: minutes...
@export_range(0, 59) var minutes: int = 1:
	set(value):
		minutes = value
		_show(_total())
## ...and seconds.
@export_range(0, 59) var seconds: int = 30:
	set(value):
		seconds = value
		_show(_total())
## Off = the hands start at 12 and move round as time passes.
## On = they start at the time you set and move back to 12.
@export var count_down: bool = false
## Start running as soon as the scene opens.
@export var autostart: bool = true
## How fast it runs: 1 = real time, 10 = ten times as fast (for testing).
@export_range(0.1, 100.0, 0.1) var speed: float = 1.0

@export_group("Hands")
## Seconds for the big hand to go all the way round once.
@export var seconds_per_big_turn: float = 60.0
## Seconds for the little hand to go all the way round once.
@export var seconds_per_little_turn: float = 3600.0

## Seconds passed since start().
var elapsed := 0.0
## True while it's running.
var running := false

@onready var big_hand: TextureRect = $BigHand
@onready var little_hand: TextureRect = $LittleHand


func _ready() -> void:
	# In the editor: show the time you set. In the game: show where it starts.
	_show(_total() if Engine.is_editor_hint() else _reading())
	if Engine.is_editor_hint():
		return
	if get_parent() == get_tree().root:
		finished.connect(func() -> void: print("%s: time's up" % name))
	if autostart:
		start()


## Starts the timer from the beginning.
func start() -> void:
	elapsed = 0.0
	running = true
	_show(_reading())


## Stops the timer where it is.
func stop() -> void:
	running = false


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not running:
		return
	elapsed = minf(elapsed + delta * speed, _total())
	_show(_reading())
	if elapsed >= _total():
		running = false
		finished.emit()


# The time the hands show now: the time passed, or (counting down) the time left.
func _reading() -> float:
	return _total() - elapsed if count_down else elapsed


# The whole time, in seconds.
func _total() -> float:
	return minutes * 60.0 + seconds


# Turns both hands to show `time` seconds, around the clock's middle.
func _show(time: float) -> void:
	if not is_node_ready():
		return
	for hand: TextureRect in [big_hand, little_hand]:
		hand.pivot_offset = hand.size / 2.0
	big_hand.rotation = fposmod(TAU * time / seconds_per_big_turn, TAU)
	little_hand.rotation = fposmod(TAU * time / seconds_per_little_turn, TAU)
