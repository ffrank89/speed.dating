extends AnimatedSprite2D

signal gif_clicked
var is_playing = true

func _ready():
	# Make sure animation loops
	sprite_frames.set_animation_loop(animation, true)
	play()
	
	# Set up input handling
	set_process_input(true)
	
		# Apply shader
	var shader_material = ShaderMaterial.new()
	var shader = load("res://image_scenes/bunnyGif/bunny_shader.gdshader")
	shader_material.shader = shader
	
	shader_material.shader = shader
	
	# Get the current frame's texture
	var current_texture = sprite_frames.get_frame_texture(animation, 0)
	
	# Set the texture parameter
	shader_material.set_shader_parameter("texture_albedo", current_texture)
	
	# Apply the shader material
	material = shader_material
	
	print("Bunny GIF initialized, awaiting clicks")
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
	if material:
		var current_frame = get_frame()
		var current_texture = sprite_frames.get_frame_texture(animation, current_frame)
		material.set_shader_parameter("texture_albedo", current_texture)
