extends Microgame
## LIGHT IT! Click (or press Space) to flick the lighter. Each flick has a chance to
## catch; when it does, the flame burns for a moment and you win. If time runs out
## first, you lose. Harder difficulty = a lower chance per flick.
##
## The hand is Hand (the flick animation, "flick"); the flame is Hand → Flame ("burn"),
## hidden until it catches. Move or resize them in this scene. Press F6 to try it (Test
## Difficulty). It plays in a date as light_cigarette (data/microgames.tres).
## Guide: docs/guides/making-a-microgame.md

## Chance each flick catches at the easiest difficulty (0) and the hardest (1). 0.3 = 30%.
@export_range(0.0, 1.0, 0.01) var easiest_chance: float = 0.3
@export_range(0.0, 1.0, 0.01) var hardest_chance: float = 0.1
## How long the flame burns before the win counts, in seconds.
@export_range(0.0, 3.0, 0.05) var flame_seconds: float = 0.6

var _chance := 0.0
var _lit := false

@onready var hand: AnimatedSprite2D = $Hand
@onready var flame: AnimatedSprite2D = $Hand/Flame


# Runs once before the banner: work out this round's chance, and reset.
func start(p_difficulty: float, _p_modifiers: Dictionary) -> void:
	_chance = lerpf(easiest_chance, hardest_chance, p_difficulty)
	_lit = false
	flame.visible = false
	hand.frame = 0


# Runs every frame while the timer runs: a click is a flick.
func _process(_delta: float) -> void:
	if _lit:
		return
	if Input.is_action_just_pressed("microgame_press"):
		_flick()


# One flick: the hand animation plays from the start, and it may catch.
func _flick() -> void:
	hand.frame = 0
	hand.play("flick")
	if randf() < _chance:
		_light()


# It caught: show the flame, let it burn, then the win counts.
func _light() -> void:
	_lit = true
	flame.visible = true
	flame.play("burn")
	# The game freezes the moment you win, so the flame burns first. Never wait past
	# the timer, or it would count as running out of time.
	await get_tree().create_timer(minf(flame_seconds, maxf(time_left - 0.1, 0.0))).timeout
	win()
