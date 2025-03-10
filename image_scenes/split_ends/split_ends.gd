extends Control

var character: SplitEndsCharacter
@onready var character_name_label = $CharacterNameLabel
@onready var character_image = $CharacterImage
var last_viewport_size: Vector2
var is_entering = false
var entry_duration = 2.0

signal entry_completed

const BASE_POSITION := Vector2(1200, 540)  # Right side of screen at mid-height
const BASE_SCALE := Vector2(1.0, 1.0)

const REFERENCE_RESOLUTION := Vector2(1920, 1080)
const CHARACTER_WIDTH_PERCENT := 0.3  # Character takes up 30% of viewport width
const CHARACTER_RIGHT_MARGIN := 0.05  # 5% margin from right edge
const CHARACTER_VERTICAL_CENTER := 0.55  # Positioned 55% down from the top

const GIRL_SIZE := Vector2(600, 300)
const GIRL_POSITION := Vector2(-150, -400)  # Position from the top-left corner


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	custom_minimum_size = GIRL_SIZE
	position = GIRL_POSITION
	# Create the character instance
	character = SplitEndsCharacter.create_default()
	
	# Setup UI elements
	setup_character_ui()
	apply_filter()
	
	# Store initial viewport size
	last_viewport_size = get_viewport_rect().size
	
	# Set up process to check for window size changes
	set_process(true)

func _process(_delta):
	# Check if viewport size changed
	if get_viewport_rect().size != last_viewport_size:
		update_position()
		last_viewport_size = get_viewport_rect().size

func setup_character_ui():
	# Set the character name
	if character_name_label:
		character_name_label.text = character.name
	
	# Load and set character image
	if character_image:
		var texture = load("res://assets/splitends.png")
		character_image.texture = texture
		var image_size = texture.get_size() 
		var rect_size = character_image.size 
	
		
			# Position relative to anchors with margin (20px from left, 20px from bottom)
		#character_image.position = Vector2(20, get_viewport_rect().size.y - INVENTORY_SIZE.y - 20)

		
func apply_filter():
	# Create shader material
	var shader_material = ShaderMaterial.new()
	
	# Load shader
	var shader = load("res://image_scenes/split_ends/static_filter.gdshader")
	if shader:
		shader_material.shader = shader
		
		# Set shader parameters
		shader_material.set_shader_parameter("static_amount", 0.28)
		shader_material.set_shader_parameter("scan_line_intensity", 0.03)
		
		# Apply material to the character image
		character_image.material = shader_material
	else:
		print("Failed to load static filter shader")

func _on_stats_changed():
	print("Character stats updated")

func _on_outfit_changed():
	print("Character outfit changed")
	
func update_position():
	if is_entering:
		# Don't update position during entry animation
		return
		
	# Dynamically scale dialogue box size based on viewport
	var viewport_size = get_viewport_rect().size
	var scale_factor_x = viewport_size.x / 1920.0  # Assuming 1920 as base width
	var scale_factor_y = viewport_size.y / 1080.0  # Assuming 1080 as base height

	# Scale size and position proportionally
	var scaled_width = GIRL_SIZE.x * scale_factor_x
	var scaled_height = GIRL_SIZE.y * scale_factor_y
	character_image.custom_minimum_size = Vector2(scaled_width, scaled_height)

	# Position the dialogue box at the bottom center of the screen
	var screen_center_x = viewport_size.x / 2
	var screen_bottom = viewport_size.y

	character_image.position = Vector2(
		screen_center_x - scaled_width / 2,
		screen_bottom - scaled_height - 40  # 40px from bottom
	)
	
#func start_entry_animation():
	## Set initial position off-screen to the right
	#var viewport_size = get_viewport_rect().size
	#var scale_factor_x = viewport_size.x / 1920.0
	#var scale_factor_y = viewport_size.y / 1080.0
	#
	#position = Vector2(viewport_size.x + 200, BASE_POSITION.y * scale_factor_y)
	#
	## Calculate target position
	#var target_x = BASE_POSITION.x * scale_factor_x
	#var target_y = BASE_POSITION.y * scale_factor_y
	#
	## Start animation
	#is_entering = true
	#var tween = create_tween()
	#tween.tween_property(self, "position", Vector2(target_x, target_y), entry_duration)
	#tween.tween_callback(func(): 
		#is_entering = false
		#emit_signal("entry_completed")
	#)
