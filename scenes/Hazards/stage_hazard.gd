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
## A stat can slow it down (Slow Motion): e.g. the fly moves in slow motion when the
## player's Perception is above 5. It can annoy her (Annoying Her): e.g. the fly sitting
## on her for a second makes the date stop while she says ".....ew" and loses points.
##
## Making a new one: extend StageHazard, start it up in begin(), and call clear() when
## the player deals with it (or leave() when it goes away by itself). If it Needs Action
## Cursor, check can_act() before letting the player deal with it. For Slow Motion,
## multiply its own timing by time_scale (and its sounds' pitch). For Annoying Her, call
## track_annoying() each frame with where it is.

## Sent when the player deals with it (e.g. shoos the fly off screen).
signal cleared(hazard: StageHazard)
## Sent when it goes away on its own (no reward).
signal left(hazard: StageHazard)
## Sent when it has been over her for Annoy Seconds: the date stops for a moment, she
## reacts and the date loses Annoy Points.
signal annoyed(hazard: StageHazard)

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

@export_group("Dealing With It")
## The player has to switch to the action cursor (S) before they can deal with it.
## Off = the normal cursor works too.
@export var needs_action_cursor: bool = true

@export_group("Slow Motion")
## A stat that slows it down (drag one from data/stats/, e.g. perception.tres). When the
## player's stat is above Slow Above, it moves, animates and sounds in slow motion, and
## stays that much longer. Empty = never.
@export var slow_stat: PlayerStat
## It's slowed when the stat is above this: 5 = at 6 or more.
@export_range(0, 100) var slow_above: int = 5
## How fast it goes in slow motion: 0.5 = half speed, and its sounds half speed and an
## octave lower. 1 = no change.
@export_range(0.05, 1.0, 0.05) var slow_speed: float = 0.5

@export_group("Annoying Her")
## Seconds it has to stay over her (her drawn pixels, not the space around her) before
## it annoys her: the date stops for a moment (her dialogue and the options freeze), she
## reacts, says Annoy Line, and the date loses Annoy Points. 0 = it never annoys her.
@export_range(0.0, 30.0, 0.1) var annoy_seconds: float = 0.0
## How many times it can annoy her each time it turns up.
@export_range(1, 20) var annoy_limit: int = 1
## Points taken off the date score when it annoys her.
@export_range(0.0, 10.0, 0.5) var annoy_points: float = 1.0
## Her reaction: a name in data/reactions.tres (anger, question...). Empty = none.
@export var annoy_reaction: String = "anger"
## What she says, in a little bubble by her head (the date's Bark). Empty = nothing.
@export var annoy_line: String = ".....ew"
## Optional: a pose she switches to (a pose name from her girl file). Empty = no change.
@export var annoy_pose: String = ""
## How long the date stops, in seconds (at least as long as her line takes).
@export_range(0.0, 10.0, 0.1) var annoy_pause_seconds: float = 1.0

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
## The player's stats on this date (stat id → value), handed over by the date (the test
## bench's sliders included). Empty = the player's own.
var stats: Dictionary = {}
## How fast it runs this time it's on screen: 1 = normal, Slow Speed in slow motion.
## Worked out each time it turns up.
var time_scale := 1.0
## Her portrait on the date (set by StageHazards), to tell when it's over her. Null = it
## can't annoy her (e.g. played on its own).
var her: GirlPortrait
# Annoying Her: seconds it's been over her without a break, and how often it has annoyed
# her this time.
var _over_her := 0.0
var _annoyances := 0
var _appearance := 0


## Override: set it up and start it. Called each time it turns up.
func begin() -> void:
	pass


## Whether the player can deal with it right now: always, or with Needs Action Cursor
## only while the action cursor is on (S).
func can_act() -> bool:
	return not needs_action_cursor or PlayerCursor.action_mode


## True if it's in slow motion this time (Slow Motion).
func is_slowed() -> bool:
	return time_scale < 1.0


## Annoying Her: call each frame with where it is (in screen pixels) and the real seconds
## passed. Once it's been over her (her drawn pixels) for Annoy Seconds without a break,
## it annoys her: annoyed is sent. Moving off her starts the count again.
func track_annoying(point: Vector2, real_delta: float) -> void:
	if annoy_seconds <= 0.0 or not her or not is_active or _annoyances >= annoy_limit:
		return
	if not her.is_point_on_her(point):
		_over_her = 0.0
		return
	_over_her += real_delta
	if _over_her >= annoy_seconds:
		_over_her = 0.0
		_annoyances += 1
		annoyed.emit(self)


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
	_over_her = 0.0
	_annoyances = 0
	time_scale = slow_speed if _slowed_by_stat() else 1.0
	begin()
	if leaves_after_seconds > 0.0 and is_active:
		var this_time := _appearance
		# In slow motion it stays longer too.
		get_tree().create_timer(leaves_after_seconds / time_scale, false).timeout.connect(func() -> void:
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


# Slow Motion: the player's Slow Stat (on this date) is above Slow Above, and the stat is
# on (data/stats/).
func _slowed_by_stat() -> bool:
	if not slow_stat or not StatList.get_default().is_active(slow_stat):
		return false
	var value: int = stats.get(slow_stat.id, PlayerManager.ensure_player().get_stat(slow_stat))
	return value > slow_above


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
	# Played alone, S switches to the action cursor here too.
	PlayerCursor.action_allowed = true
	cleared.connect(func(_h: StageHazard) -> void: _test_result("CLEARED (+%s points, reaction: %s)" % [points, reaction]))
	left.connect(func(_h: StageHazard) -> void: _test_result("LEFT on its own"))
	appear()


func _test_result(what: String) -> void:
	print("%s: %s" % [name, what])
	if replay_after_test:
		await get_tree().create_timer(1.0).timeout
		appear()
