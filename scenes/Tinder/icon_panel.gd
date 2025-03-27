# sprite_icon_panel.gd
extends Panel

# Reference to the animated sprite
var animated_sprite: AnimatedSprite2D

func _ready():
	# Style the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.set_border_width_all(2)
	style.border_color = Color(0.4, 0.4, 0.4)
	add_theme_stylebox_override("panel", style)
	
	# Create the animated sprite if it doesn't exist
	if has_node("AnimatedSprite2D"):
		animated_sprite = $AnimatedSprite2D
	else:
		animated_sprite = AnimatedSprite2D.new()
		animated_sprite.name = "AnimatedSprite2D"
		add_child(animated_sprite)
	
	# Center the sprite in the panel
	animated_sprite.position = size / 2

func update_display(frames_path):
		
	if ResourceLoader.exists(frames_path):		
		var sprite_frames = load(frames_path)
		print(sprite_frames)
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.play()
	else:
		push_error("Sprite frames not found: " + frames_path + " for character ")

func _process(delta):
	# Keep sprite centered as panel resizes
	if animated_sprite and is_instance_valid(animated_sprite):
		animated_sprite.position = size / 2
		
		# Adjust scale to fit panel
		if animated_sprite.sprite_frames:
			var texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, 0)
			if texture:
				var texture_size = texture.get_size()
				var scale_factor = min(
					(size.x * 0.9) / texture_size.x,
					(size.y * 0.9) / texture_size.y
				)
				animated_sprite.scale = Vector2(scale_factor, scale_factor)
