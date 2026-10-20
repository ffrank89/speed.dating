class_name StageHazard
extends Control
## The base for stage hazards: things that turn up during a date and get in the way
## (a fly buzzing around her...). Dealing with one earns a bonus: she reacts and the
## date score goes up. If it goes away on its own, nothing happens.
##
## Each hazard is its own scene extending this. It covers the whole screen (3000 × 1700),
## so anything placed or drawn in it is in screen pixels. A child named DrawingGuide
## (e.g. a picture of the date) is shown only when you play the scene on its own.
##
## A date lists its hazards on its StageHazards node. Press F6 on a hazard's scene to
## try it on its own, over and over. Full guide: docs/guides/stage-hazards.md
##
## Making a new one: extend StageHazard, start it up in begin(), and call clear() when
## the player deals with it (or leave() when it goes away by itself).

## Sent when the player deals with it (e.g. shoos the fly off screen).
signal cleared(hazard: StageHazard)
## Sent when it goes away on its own (no reward).
signal left(hazard: StageHazard)

@export_group("When")
## It turns up after the player has answered this many questions on a date.
@export_range(0, 50) var appears_after_answers: int = 1
## Then it turns up again every this many answers. 0 = only once per date.
@export_range(0, 50) var again_every_answers: int = 0
## Seconds between that answer and it turning up.
@export_range(0.0, 30.0, 0.1) var delay_seconds: float = 1.0
## Chance it turns up when it's due: 1 = always, 0.5 = half the time.
@export_range(0.0, 1.0, 0.05) var chance: float = 1.0
## It goes away on its own after this many seconds (no reward). 0 = it stays until dealt with.
@export_range(0.0, 120.0, 0.5) var leaves_after_seconds: float = 0.0

@export_group("Reward")
## Points added to the date score when the player deals with it.
@export_range(-10.0, 10.0, 0.5) var points: float = 1.0
## Her reaction when the player deals with it: a name in data/reactions.tres (exclamation,
## question, anger, heart). Empty = none.
@export var reaction: String = "heart"
## Optional: a pose she switches to (a pose name from her girl file). Empty = no change.
@export var pose: String = ""
## Played when the player deals with it.
@export var cleared_sound: AudioStream

@export_group("Testing (F6)")
## When playing this scene on its own, bring it back after it's dealt with or leaves.
@export var replay_after_test: bool = true

## True while it's on screen.
var is_active := false
var _appearance := 0


## Override: set it up and start it. Called each time it turns up.
func begin() -> void:
	pass


## Override (optional): called when Leaves After Seconds runs out. Default: leave() at once.
func time_to_go() -> void:
	leave()


## Call when the player has dealt with it: she reacts and the date earns Points.
func clear() -> void:
	if is_active:
		_finish()
		cleared.emit(self)


## Call when it goes away on its own: no reward.
func leave() -> void:
	if is_active:
		_finish()
		left.emit(self)


## Makes it turn up now. StageHazards calls this when it's due.
func appear() -> void:
	if is_active:
		return
	is_active = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	_appearance += 1
	begin()
	if leaves_after_seconds > 0.0 and is_active:
		var this_time := _appearance
		get_tree().create_timer(leaves_after_seconds, false).timeout.connect(func() -> void:
			if is_active and _appearance == this_time:
				time_to_go()
		)


## True if it should turn up now that the player has given `answers` answers.
func is_due(answers: int) -> bool:
	if is_active:
		return false
	var due := answers == appears_after_answers
	if again_every_answers > 0 and answers > appears_after_answers:
		due = (answers - appears_after_answers) % again_every_answers == 0
	return due and randf() <= chance


func _finish() -> void:
	is_active = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED


# _notification runs for every script in the chain, so this works even when a hazard
# has its own _ready(). Played on its own (F6), it shows its DrawingGuide and loops.
func _notification(what: int) -> void:
	if what != NOTIFICATION_READY:
		return
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if get_parent() == get_tree().root:
		_play_alone.call_deferred()
	else:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED


func _play_alone() -> void:
	var guide := get_node_or_null("DrawingGuide") as CanvasItem
	if guide:
		guide.visible = true
	cleared.connect(func(_h: StageHazard) -> void: _test_result("CLEARED (+%s points, reaction: %s)" % [points, reaction]))
	left.connect(func(_h: StageHazard) -> void: _test_result("LEFT on its own"))
	appear()


func _test_result(what: String) -> void:
	print("%s: %s" % [name, what])
	if replay_after_test:
		await get_tree().create_timer(1.0).timeout
		appear()
