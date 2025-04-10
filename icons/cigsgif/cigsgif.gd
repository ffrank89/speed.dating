extends AnimatedSprite2D

var default_speed = .2

func _ready():
	sprite_frames.set_animation_loop(animation, false)
	
	# Start playing the animation
	play("new_animation")

	print("!!CIGS!! GIF initialized, animation playing")
