extends AnimatedSprite2D
signal hovering

# Default and hover speed properties
var default_speed = 1.3
var hover_speed = 3.3
var is_mouse_hovering = false

func _ready():
	# Make sure animation loops
	sprite_frames.set_animation_loop(animation, true)
	
	# Start playing the animation
	play()
	
	# Keep standard process for input handling
	set_process_input(true)
	
	print("!!SMOKEY!! GIF initialized, animation playing")

func _input(event):
	# Handle mouse clicks on the sprite
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		if is_point_inside_sprite(mouse_pos):
			print("Split ends GIF clicked!")
			emit_signal("hovering")
	
	# Check for mouse movement to detect hover
	if event is InputEventMouseMotion:
		var was_hovering = is_mouse_hovering
		is_mouse_hovering = is_point_inside_sprite(get_global_mouse_position())
		
		# Only update speed if hover state changed
		if was_hovering != is_mouse_hovering:
			update_animation_speed()

# Check if a point is inside the sprite (with pixel-perfect detection)
func is_point_inside_sprite(point):
	var texture = sprite_frames.get_frame_texture(animation, 0)
	var size = texture.get_size() * scale
	
	# Create a rectangle representing the sprite's bounds
	var left = global_position.x - size.x/2
	var top = global_position.y - size.y/2
	var sprite_rect = Rect2(left, top, size.x, size.y)
	
	# Check if point is within sprite rectangle first
	if sprite_rect.has_point(point):
		# Additional pixel-perfect check
		var local_point = point - Vector2(left, top)
		var image = texture.get_image()
		var pixel_alpha = image.get_pixel(
			int(local_point.x / scale.x), 
			int(local_point.y / scale.y)
		).a
		
		# Only return true if the pixel is not fully transparent
		return pixel_alpha > 0.1  # Adjust threshold as needed
	
	return false

# Update the animation speed based on hover state
func update_animation_speed():
	if is_mouse_hovering:
		speed_scale = hover_speed
		print("Mouse hovering - GIF playing at 2x speed")
	else:
		speed_scale = default_speed
		print("Mouse not hovering - GIF playing at normal speed")
