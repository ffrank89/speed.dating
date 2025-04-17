extends Control
class_name DatePresenter

@onready var character_name_label = $CharacterNameLabel
@onready var character_image = $CharacterImage
@onready var stats_display = $CharacterStatsDisplay
@onready var reaction_display = $InventoryReaction
@onready var background = $BackgroundImage
const DEFAULT_SIZE := Vector2(600, 800)
const TARGET_POSITION := Vector2(0.5, 0.5)
const PADDING := 30

signal entry_completed

var date_character: DateCharacter

func _ready():
	# Initial setup
	update_position()

	# Connect to window resize signal to update when needed
	get_viewport().connect("size_changed", Callable(self, "update_position"))

func initialize(character: DateCharacter) -> void:
	self.date_character = character
	
	setup_background()
	# Setup UI elements
	setup_character_ui()
	setup_stats()
	setup_reaction_display()
	connect_inventory_signals()

	# Initial position update
	update_position()

func setup_character_ui():
	if character_name_label:
		character_name_label.text = date_character.name
	
	var cur_image = date_character.poses.normal
	
	# Load and set character image
	if character_image and cur_image:
		var texture = load(cur_image)
		if texture:
			character_image.texture = texture
			print("Texture loaded successfully with size: ", texture.get_size())
			
			character_image.expand = true
			character_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		else:
			print("Failed to load character texture from path: ", cur_image)
	else:
		print("Character image node not found or no valid pose path!")

func setup_stats():
	stats_display.setup(date_character)
	stats_display.start_orbiting()

func setup_reaction_display():
	reaction_display.setup(date_character)


func connect_inventory_signals():
	add_to_group("characters")  # Add this character to a group for easier finding
	PlayerManager.item_selected.connect(_on_inventory_item_selected)

func _on_inventory_item_selected(item):
	print("Character reacting to item: ", item.name)
	if reaction_display:
		reaction_display.show_reaction(item)

func update_position():
	var viewport_size = get_viewport_rect().size
	
	# Set background size first, before any position changes
	if background:
		# Make background ignore position changes by setting it back to fill viewport
		background.anchor_right = 1.0
		background.anchor_bottom = 1.0
		background.offset_left = 0
		background.offset_top = 0
		background.offset_right = 0
		background.offset_bottom = 0
		background.size = viewport_size
		print("viewport_size", viewport_size)
	
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
	
	# After position change, reset background to fill screen
	if background:
		background.global_position = Vector2.ZERO
	
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
		
func change_pose(pose_key: String) -> bool:
	if date_character.poses.has(pose_key):
		var pose_path = date_character.poses[pose_key]
		var texture = load(pose_path)
		if texture and character_image:
			character_image.texture = texture
			return true
	return false

func setup_background():
	if background and date_character.first_date_background:
		# Load the background texture
		var background_texture = load(date_character.first_date_background)
		if background_texture:
			# Create a shader material to display the texture
			var shader_material = ShaderMaterial.new()
			shader_material.shader = load("res://image_scenes/background_image/background_shader.gdshader")
			shader_material.set_shader_parameter("texture_albedo", background_texture)

			# Apply the material
			background.material = shader_material
		else:
			print("Failed to load background texture from path: ", date_character.first_date_background)
