
extends Control

@onready var background_sprite = $BackgroundSprite

func _ready():
	# Make sure this control fills the entire viewport
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Start the animation
	if background_sprite:
		background_sprite.play()
	
	# Position immediately and also connect to viewport size changes
	_resize_background()
	get_tree().root.size_changed.connect(_resize_background)

func _resize_background():
	# Make sure we have a sprite to work with
	if not background_sprite or not is_instance_valid(background_sprite):
		print("ERROR: No valid background sprite found")
		return
		
	# Get the viewport size
	var viewport_size = get_viewport_rect().size
	print("Viewport size updated: ", viewport_size)
	
	# Update the control to fill the viewport
	size = viewport_size
	
	# Position the sprite at the center of the screen
	background_sprite.position = viewport_size / 2
	
	# Force stretch to fill entire screen regardless of aspect ratio
	if background_sprite.sprite_frames and background_sprite.sprite_frames.has_animation(background_sprite.animation):
		var frame_texture = background_sprite.sprite_frames.get_frame_texture(background_sprite.animation, 0)
		if frame_texture:
			var texture_size = frame_texture.get_size()
			
			# Calculate scale to fill screen entirely
			var scale_x = viewport_size.x / texture_size.x
			var scale_y = viewport_size.y / texture_size.y
			
			# Always scale to fully cover the screen in both dimensions
			background_sprite.scale = Vector2(scale_x, scale_y)
			print("Background sprite stretched to fill screen: ", background_sprite.scale)
