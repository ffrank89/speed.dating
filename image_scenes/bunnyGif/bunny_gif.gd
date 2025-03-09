extends AnimatedSprite2D

signal gif_clicked
var is_playing = true

func _ready():
	# Make sure animation loops
	sprite_frames.set_animation_loop(animation, true)
	play()
	
	# Position in lower right corner
	position_in_corner()
	
	# Set up input handling
	set_process_input(true)
	print("Bunny GIF initialized, awaiting clicks")

# Position the bunny in the lower-right corner with some margin
func position_in_corner():
	var viewport_size = get_viewport_rect().size
	var margin = 50  # Distance from the edges
	var texture = sprite_frames.get_frame_texture(animation, 0)
	var sprite_size = texture.get_size() * scale
	
	## Adjust scale if bunny is too large
	if sprite_size.x > viewport_size.x / 4 or sprite_size.y > viewport_size.y / 4:
		var scale_factor = min(viewport_size.x / 1 / texture.get_width(), viewport_size.y / 1 / texture.get_height())
		#0.06352941176471
		scale = Vector2(scale_factor, scale_factor)
		sprite_size = texture.get_size() * scale
	position = Vector2(
		viewport_size.x - (sprite_size.x/2) - margin,
		viewport_size.y - (sprite_size.y/2) - margin + 199
	)
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var texture = sprite_frames.get_frame_texture(animation, 0)
		var size = texture.get_size() * scale
		
		# Create a rectangle representing the sprite's bounds
		var left = global_position.x - size.x/2
		var top = global_position.y - size.y/2
		var sprite_rect = Rect2(left, top, size.x, size.y)
		
		# Check if click is within sprite rectangle first
		if sprite_rect.has_point(mouse_pos):
			# Additional pixel-perfect check
			var local_mouse_pos = mouse_pos - Vector2(left, top)
			var image = texture.get_image()
			var pixel_alpha = image.get_pixel(
				int(local_mouse_pos.x / scale.x), 
				int(local_mouse_pos.y / scale.y)
			).a
			
			# Only trigger if the pixel is not fully transparent
			if pixel_alpha > 0.1:  # Adjust threshold as needed
				print("Bunny GIF clicked!")
				toggle_animation()
				emit_signal("gif_clicked")

func toggle_animation():
	is_playing = !is_playing
	if is_playing:
		play()
		print("Bunny GIF playing")
	else:
		stop()
		print("Bunny GIF stopped")

# Ensure the bunny stays in the corner if viewport is resized
func _process(_delta):
	if get_viewport_rect().size != Vector2.ZERO:
		position_in_corner()
