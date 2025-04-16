# SplitEndsContainer.gd
extends Control

# Character reference - same as in your original script
var character: DateCharacter

# Reference to the actual sprite
@onready var sprite = $SplitEndsSprite

# Forward the hovering signal from the sprite
signal hovering

# Size and position constants - adjust these as needed
const DEFAULT_SIZE := Vector2(180, 250)  # Adjust to match your sprite size
const TARGET_POSITION := Vector2(0.25, 0.5)  # Normalized position (0-1) where we want the sprite
const PADDING := 20  # Minimum padding from screen edges

func _ready():
	# Set up anchors - we'll use full screen anchors for better boundary control
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Connect to the sprite's hovering signal
	sprite.hovering.connect(_on_sprite_hovering)
	
	# Initial update of positioning
	update_position()

# Forward the hovering signal
func _on_sprite_hovering():
	hovering.emit()

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
	
	# Ensure the sprite itself is centered in the container
	if sprite:
		# Center the sprite in the container
		sprite.position = scaled_size / 2
		
		# For AnimatedSprite2D in Godot 4.3
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(sprite.animation):
			var frame_texture = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
			if frame_texture:
				var texture_size = frame_texture.get_size()
				if texture_size.x > 0 and texture_size.y > 0:
					var scale_x = scaled_size.x / texture_size.x
					var scale_y = scaled_size.y / texture_size.y
					var scale_factor = min(scale_x, scale_y) * 0.9  # 90% of container for margin
					sprite.scale = Vector2(scale_factor, scale_factor)

func _process(_delta):
	# Update on each frame to handle viewport changes
	update_position()
