extends Microgame
## TEMPLATE AND EXAMPLE: "CATCH IT!" A logo bounces around; click it, or steer with the
## arrow keys / WASD and press Space. Copy this whole folder to start a new microgame.
## Guide: docs/guides/making-a-microgame.md
##
## Everything a microgame needs is used here:
##   start()               set up for the difficulty (0 = easiest, 1 = hardest)
##   _process()            the game itself; it only runs while the timer is running
##   win() / lose()        end it (or let the timer run out: see Pass When Time Runs Out)
##   is_pointing_at(node)  is the player aiming at it? (mouse, or arrow keys / WASD)
##   "microgame_press"     Space, Enter or left click

## How fast the logo moves at the easiest and hardest difficulty, in pixels per second.
@export var easiest_speed: float = 450.0
@export var hardest_speed: float = 1500.0
## How big the logo is at the easiest and hardest difficulty, in pixels.
@export var easiest_size: float = 320.0
@export var hardest_size: float = 160.0

var _velocity := Vector2.ZERO

@onready var area: Control = $PlayArea
@onready var target: TextureRect = $PlayArea/Target


# Set up for the difficulty. Runs once, before the banner shows.
func start(p_difficulty: float, _p_modifiers: Dictionary) -> void:
	var side := lerpf(easiest_size, hardest_size, p_difficulty)
	target.size = Vector2(side, side)
	target.position = (area.size - target.size) / 2.0
	var speed := lerpf(easiest_speed, hardest_speed, p_difficulty)
	_velocity = Vector2.from_angle(randf_range(0.0, TAU)) * speed


# The game. Only runs while the timer is running (not during the banner or stamp).
func _process(delta: float) -> void:
	_bounce(delta)
	if Input.is_action_just_pressed("microgame_press") and is_pointing_at(target):
		win()


# Moves the logo and bounces it off the edges of the play area.
func _bounce(delta: float) -> void:
	target.position += _velocity * delta
	var far_corner := area.size - target.size
	if target.position.x < 0.0 or target.position.x > far_corner.x:
		_velocity.x = -_velocity.x
	if target.position.y < 0.0 or target.position.y > far_corner.y:
		_velocity.y = -_velocity.y
	target.position = target.position.clamp(Vector2.ZERO, far_corner)
