class_name Microgame
extends Control
## The base every microgame extends. A microgame is a short test (5 seconds by default)
## played on the phone over the date when the player picks an option tagged
## [#microgame=name]. Passing counts as a hit, failing as a miss.
## It fills the phone's screen (about 964 × 1414 pixels with the phone in
## data/phone_style.tres), so build it tall, not wide.
##
## The shared frame (dim, banner, timer bar, NICE/OOPS stamp) is drawn for you by
## MicrogameHost. A microgame only has to:
##   - set itself up for `difficulty` in start()        (0 = easiest, 1 = hardest)
##   - play in _process() / _input()                     (only runs while the timer runs)
##   - call win() or lose()                              (or let the timer run out)
##
## Mouse and keyboard: use the "microgame_press" action (Space, Enter or left click)
## and `pointer` (follows the mouse; arrow keys / WASD steer it too), and both work.
##
## Press F6 on a microgame's scene to play it on its own, over and over.
## Start a new one by copying scenes/Microgames/_template/.
## Full guide: docs/guides/making-a-microgame.md

## Sent once, when the microgame is won or lost.
signal finished(passed: bool)

const HOST_SCENE := "res://scenes/Microgames/MicrogameHost.tscn"

@export_group("Frame")
## The instruction shown big at the start, e.g. "LIGHT IT!". Keep it to 1–3 words.
@export var banner_text: String = "GO!"
## How long the player has, in seconds.
@export_range(1.0, 20.0, 0.5) var seconds: float = 5.0
## What running out of time means. Off = it's a fail (do something in time).
## On = it's a pass (survive / keep it up until time runs out).
@export var pass_when_time_runs_out: bool = false
## The app this microgame opens as: its icon and launch screen (a file from data/apps/).
## Empty = data/apps/microgame.tres.
@export var app: AppInfo

@export_group("Testing (F6)")
## The difficulty used when you play this scene on its own with F6. 0 = easiest, 1 = hardest.
@export_range(0.0, 1.0, 0.05) var test_difficulty: float = 0.5
## Start again automatically after each try when playing on its own.
@export var replay_after_test: bool = true

## 0 = easiest, 1 = hardest. Comes from the player's stat against the option's
## requirement (tune it in data/date_rules.tres → Microgames). Set before start().
var difficulty: float = 0.5
## Extras from perks, e.g. {"extra_time": 1.5}. Usually empty.
var modifiers: Dictionary = {}
## Where the player is aiming, in this microgame's own space. Follows the mouse;
## the arrow keys / WASD move it too. Updated every frame by the host.
var pointer: Vector2 = Vector2.ZERO
## True from the end of the banner until win(), lose() or time running out.
var is_playing: bool = false
## Seconds left on the timer.
var time_left: float = 0.0


## Override this: set the microgame up for `p_difficulty` (0 = easiest, 1 = hardest).
## Called once, before the banner shows. `difficulty` and `modifiers` are already set.
func start(_p_difficulty: float, _p_modifiers: Dictionary) -> void:
	pass


## Call when the player has succeeded. Only the first win() or lose() counts.
func win() -> void:
	_finish(true)


## Call when the player has failed. Only the first win() or lose() counts.
func lose() -> void:
	_finish(false)


## Called by the host when the timer reaches zero.
func time_up() -> void:
	_finish(pass_when_time_runs_out)


## True if the player is aiming at `node` (mouse over it, or the keyboard pointer on it).
func is_pointing_at(node: Control) -> bool:
	return node.get_global_rect().has_point(get_global_transform() * pointer)


## Where the player is aiming, in screen space.
func pointer_on_screen() -> Vector2:
	return get_global_transform() * pointer


func _finish(passed: bool) -> void:
	if not is_playing:
		return
	is_playing = false
	finished.emit(passed)


# _notification runs for every script in the chain, so this works even when a
# microgame has its own _ready(). Played on its own (F6), it hosts itself.
func _notification(what: int) -> void:
	if what == NOTIFICATION_READY and get_parent() == get_tree().root:
		_play_alone.call_deferred()


func _play_alone() -> void:
	var host: MicrogameHost = load(HOST_SCENE).instantiate()
	get_tree().root.add_child(host)
	# On the host's phone, as in the game.
	host.hold(self)
	var passed: bool = await host.run(self, test_difficulty)
	print("%s: %s at difficulty %.2f" % [name, "PASSED" if passed else "FAILED", test_difficulty])
	if replay_after_test:
		host.queue_free()
		get_tree().reload_current_scene()
