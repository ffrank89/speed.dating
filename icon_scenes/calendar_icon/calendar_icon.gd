extends AnimatedSprite2D
class_name CalendarIcon

# Default size for all icons in pixels
var target_size = Vector2(1000, 1000)

func _ready():
	# Connect to animation signals
	animation_finished.connect(_on_animation_finished)
	animation_changed.connect(_on_animation_changed)
	
	# Initialize with proper scaling
	update_scale()

# Update scale when animation changes
func _on_animation_changed():
	update_scale()

# Handle animation loops or sequences if needed
func _on_animation_finished():
	# You can add logic here if you want to chain animations
	pass

# Play a specific animation
func play_icon(icon_type: String):
	if sprite_frames.has_animation(icon_type):
		play(icon_type)
	else:
		print("Error: CalendarIcon missing animation: ", icon_type)
		# Fall back to a default animation if available
		if sprite_frames.has_animation("question"):
			play("question")

# Update scale based on current animation frame
func update_scale():
	if !sprite_frames or !sprite_frames.has_animation(animation):
		return
		
	var frame_texture = sprite_frames.get_frame_texture(animation, 0)
	if frame_texture:
		# Get the size of the current texture
		var texture_size = frame_texture.get_size()
		
		# Calculate scale to reach target size
		if texture_size.x > 0 and texture_size.y > 0:
			var scale_factor_x = target_size.x / texture_size.x
			var scale_factor_y = target_size.y / texture_size.y
			
			# Use the smaller scale to maintain aspect ratio
			var uniform_scale = min(scale_factor_x, scale_factor_y)
			scale = Vector2(uniform_scale, uniform_scale)
