extends Control

# References
var character: Character

# Constants for appearance
const BUBBLE_WIDTH = 280
const BUBBLE_MIN_HEIGHT = 80
const BUBBLE_PADDING = 15
const BUBBLE_FONT_SIZE = 16
const BUBBLE_COLOR = Color(1, 1, 1, 0.9)
const TEXT_COLOR = Color(0.1, 0.1, 0.1, 1)
const BUBBLE_CORNER_RADIUS = 12

# Animation parameters
var appear_duration = 0.3
var hover_duration = 2.0
var disappear_duration = 0.3
var is_active = false
var bubble_node: PanelContainer

# Position offsets
var offset_x = 100  # Horizontal offset from character center
var offset_y = -180  # Vertical offset (negative = above)

func _ready():
	# Make sure we're hidden initially
	modulate.a = 0
	visible = false

# Set the character reference
func setup(char: Character):
	character = char

# Show a reaction to an item
func show_reaction(item: InventoryItem):
	# Get the reaction text
	var reaction_text = ""
	if character:
		reaction_text = character.check_item_reaction(item)
	
	if not reaction_text:
		# Default reaction if nothing specific
		reaction_text = "Hmm, interesting..."
	
	# Create or update the bubble
	if bubble_node:
		bubble_node.queue_free()
	
	# Create the speech bubble
	create_speech_bubble(reaction_text)
	
	# Animate the bubble appearing
	animate_bubble_show()

# Create speech bubble with the given text
func create_speech_bubble(text: String):
	# Create the container
	bubble_node = PanelContainer.new()
	add_child(bubble_node)
	
	# Style the bubble
	var style = StyleBoxFlat.new()
	style.bg_color = BUBBLE_COLOR
	style.corner_radius_top_left = BUBBLE_CORNER_RADIUS
	style.corner_radius_top_right = BUBBLE_CORNER_RADIUS
	style.corner_radius_bottom_left = BUBBLE_CORNER_RADIUS
	style.corner_radius_bottom_right = BUBBLE_CORNER_RADIUS
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	bubble_node.add_theme_stylebox_override("panel", style)
	
	# Add margin container for padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", BUBBLE_PADDING)
	margin.add_theme_constant_override("margin_right", BUBBLE_PADDING)
	margin.add_theme_constant_override("margin_top", BUBBLE_PADDING)
	margin.add_theme_constant_override("margin_bottom", BUBBLE_PADDING)
	bubble_node.add_child(margin)
	
	# Add the text label
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", BUBBLE_FONT_SIZE)
	label.add_theme_color_override("font_color", TEXT_COLOR)
	margin.add_child(label)
	
	# Set size constraints
	label.custom_minimum_size.x = BUBBLE_WIDTH - (BUBBLE_PADDING * 2)
	bubble_node.custom_minimum_size.y = BUBBLE_MIN_HEIGHT
	
	# Add a little tail/pointer to the bubble (using a polygon)
	var pointer = Polygon2D.new()
	pointer.color = BUBBLE_COLOR
	pointer.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(-10, -15),
		Vector2(10, -15)
	])
	pointer.position = Vector2(BUBBLE_WIDTH / 2, BUBBLE_MIN_HEIGHT + BUBBLE_PADDING)
	add_child(pointer)
	
	# Position the bubble
	update_position()

# Update the position of the bubble
func update_position():
	if bubble_node:
		var parent_size = get_parent().size
		position = Vector2(
			(parent_size.x / 2) + offset_x,
			(parent_size.y / 2) + offset_y
		)

# Animate the bubble appearing, hovering, and disappearing
func animate_bubble_show():
	visible = true
	is_active = true
	
	var tween = create_tween()
	
	# Appear
	tween.tween_property(self, "modulate:a", 1.0, appear_duration)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), appear_duration)
	
	# Hover
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), hover_duration/2)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), hover_duration/2)
	
	# Disappear
	tween.tween_property(self, "modulate:a", 0.0, disappear_duration)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), disappear_duration)
	
	# Clean up
	tween.tween_callback(func(): 
		is_active = false
		visible = false
	)

# If the parent's size changes, update our position
func _process(delta):
	if is_active and visible:
		update_position()
