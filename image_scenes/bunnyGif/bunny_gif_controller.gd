
# BunnyGifContainer.gd
extends Control

# Forward the clicked signal from the gif
signal gif_clicked

# Reference to the actual gif sprite
@onready var bunny_gif = $BunnyGif

# Size and position constants - adjust these as needed
const DEFAULT_SIZE := Vector2(350, 350)
const TARGET_POSITION := Vector2(0.75, 0.75)  # Normalized position (0-1) where we want the bunny (0.9, 0.1 = near top-right)
const PADDING := 20  # Minimum padding from screen edges

func _ready():
	# Set up anchors - we'll use full screen anchors for better boundary control
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Make sure we capture the child's signal
	bunny_gif.gif_clicked.connect(_on_gif_clicked)
	
	# Initial update of positioning
	update_position()

# Forward the clicked signal
func _on_gif_clicked():
	gif_clicked.emit()

func update_position():
	var viewport_size = get_viewport_rect().size
	
	# Calculate a proportional size based on viewport
	var size_factor = min(viewport_size.x, viewport_size.y) / 1080.0
	var scaled_size = DEFAULT_SIZE * size_factor
	
	# Update container size
	custom_minimum_size = scaled_size
	size = scaled_size
	
	# Calculate target position based on viewport size
	var target_x = viewport_size.x * TARGET_POSITION.x
	var target_y = viewport_size.y * TARGET_POSITION.y
	
	# Apply constraints to keep fully on screen
	var min_x = PADDING
	var max_x = viewport_size.x - scaled_size.x - PADDING
	var min_y = PADDING
	var max_y = viewport_size.y - scaled_size.y - PADDING
	
	# Clamp the position within safe boundaries
	var safe_x = clamp(target_x - scaled_size.x/2, min_x, max_x)
	var safe_y = clamp(target_y - scaled_size.y/2, min_y, max_y)
	
	# Set position directly (in global coordinates)
	global_position = Vector2(safe_x, safe_y)
	
	# Ensure the gif itself is centered in the container
	if bunny_gif:
		# Center the sprite in the container
		bunny_gif.position = scaled_size / 2
		#resize gif to be in center of container
		if bunny_gif.sprite_frames and bunny_gif.sprite_frames.has_animation(bunny_gif.animation):
			var frame_texture = bunny_gif.sprite_frames.get_frame_texture(bunny_gif.animation, 0)
			if frame_texture:
				var texture_size = frame_texture.get_size()
				if texture_size.x > 0 and texture_size.y > 0:
					var scale_x = scaled_size.x / texture_size.x
					var scale_y = scaled_size.y / texture_size.y
					var scale_factor = min(scale_x, scale_y) * 0.9  # 90% of container for margin
					bunny_gif.scale = Vector2(scale_factor, scale_factor)

func _process(delta):
	# Update on each frame to handle viewport changes
	update_position()
