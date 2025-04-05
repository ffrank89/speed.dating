extends AnimatedSprite2D

var default_speed = 1

func _ready():
	# Make sure animation loops
	sprite_frames.set_animation_loop(animation, false)
	
	# Start playing the animation
	play("new_animation")

	print("!!Culture!! GIF initialized, animation playing")
