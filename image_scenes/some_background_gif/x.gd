extends AnimatedSprite2D

var default_speed = 1

func _ready():
	# Make sure animation loops
	sprite_frames.set_animation_loop(animation, true)
	
	# Start playing the animation
	play()
	
	# Keep standard process for input handling
	set_process_input(true)
	
	print("!!Background!! GIF initialized, animation playing")
