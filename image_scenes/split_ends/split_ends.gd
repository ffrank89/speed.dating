# SplitEnds.gd
extends Control

var character: SplitEndsCharacter
@onready var character_name_label = $CharacterNameLabel
@onready var character_image = $CharacterImage
@onready var stats_display = $CharacterStatsDisplay
# Size and position constants
const DEFAULT_SIZE := Vector2(600, 800)  # Adjust based on your character image
const TARGET_POSITION := Vector2(0.5, 0.5)  # Position at center of screen
const PADDING := 30  # Minimum padding from screen edges
# Shader parameters
const STATIC_AMOUNT := 0.50
const SCAN_LINE_INTENSITY := 0.1

signal entry_completed

func _ready() -> void:
	# Set up full screen anchors for boundary control
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Create the character instance
	character = SplitEndsCharacter.create_default()
	
	# Setup UI elements
	setup_character_ui()
	apply_filter()
	setup_stats()
	
	# Initial position update
	update_position()
	
	# Set up process to handle window resizing
	set_process(true)
	
	# Debug print to verify proper initialization
	print("SplitEnds initialized with size: ", size)

func _process(delta):
	# Update position on each frame to handle viewport changes
	update_position()

func setup_character_ui():
	# Set the character name
	if character_name_label:
		character_name_label.text = character.name
	
	# Load and set character image
	if character_image:
		var texture = load("res://assets/splitends.png")
		if texture:
			character_image.texture = texture
			print("Texture loaded successfully with size: ", texture.get_size())
			
			# Configure the TextureRect for proper display
			character_image.expand = true
			character_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		else:
			print("Failed to load character texture")
	else:
		print("Character image node not found!")

func setup_stats():
	stats_display.setup(character)
	stats_display.start_orbiting()	

func apply_filter():
	# Create shader material
	var shader_material = ShaderMaterial.new()
	
	# Load shader
	var shader = load("res://image_scenes/split_ends/static_filter.gdshader")
	if shader:
		shader_material.shader = shader
		
		# Set shader parameters
		shader_material.set_shader_parameter("static_amount", STATIC_AMOUNT)
		shader_material.set_shader_parameter("scan_line_intensity", SCAN_LINE_INTENSITY)
		
		# Apply material to the character image
		character_image.material = shader_material
		print("Shader applied to character image")
	else:
		print("Failed to load static filter shader")

func update_position():
	var viewport_size = get_viewport_rect().size
	
	# Calculate a proportional size based on viewport
	var size_factor = min(viewport_size.x / 1920.0, viewport_size.y / 1080.0)
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
	
	# Special handling for extremely small viewports
	if max_x < min_x:
		# Screen too narrow - center horizontally
		min_x = viewport_size.x / 2 - scaled_size.x / 2
		max_x = min_x
	
	if max_y < min_y:
		# Screen too short - center vertically
		min_y = viewport_size.y / 2 - scaled_size.y / 2
		max_y = min_y
	
	# Clamp the position within safe boundaries
	var safe_x = clamp(target_x - scaled_size.x/2, min_x, max_x)
	var safe_y = clamp(target_y - scaled_size.y/2, min_y, max_y)
	
	# Set position directly (in global coordinates)
	global_position = Vector2(safe_x, safe_y)
	
	# CRITICAL: Configure the character image to properly fill the container
	if character_image:
		# Set the character image to fill the container
		character_image.custom_minimum_size = scaled_size
		character_image.size = scaled_size
		character_image.position = Vector2.ZERO
		
		# Set layout properties to ensure it stays contained
		character_image.anchor_right = 1.0
		character_image.anchor_bottom = 1.0
		character_image.size_flags_horizontal = Control.SIZE_FILL
		character_image.size_flags_vertical = Control.SIZE_FILL

	if stats_display:
		# Position the orbit center near the character's head
		var orbit_center = Vector2(
			scaled_size.x / 2,  # Centered horizontally
			scaled_size.y * 0.2  # Near the top (adjust as needed)
		)
		stats_display.update_position(orbit_center)

func _on_stats_changed():
	print("Character stats updated")

func _on_outfit_changed():
	print("Character outfit changed")
