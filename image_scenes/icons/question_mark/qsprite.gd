extends AnimatedSprite2D

var default_speed = 1

func _ready():
	# Make sure animation loops
	sprite_frames.set_animation_loop(animation, true)
	
	# Start playing the animation
	play("new_animation")

	print("!!Q!! GIF initialized, animation playing")
