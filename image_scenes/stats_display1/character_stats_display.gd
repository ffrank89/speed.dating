# CharacterStatsDisplay.gd
extends Control

# References
var character: DateCharacter
@onready var stats_container = $StatsContainer

# Constants for appearance
const STAT_FONT_SIZE = 16
const STAT_LABEL_COLOR = Color(1, 1, 1, 1)  # White
const STAT_VALUE_COLOR = Color(1, 0.8, 0.2, 1)  # Gold
const STAT_PADDING = 5
const STAT_MARGIN = 10

# Stats to display (can be customized)
var stats_to_display = ["Culture", "Intellect", "Seduction", "Heart"]

# Variables for orbital animation
var orbit_center = Vector2.ZERO
var orbit_radius = 150
var orbit_speed = 0.3
var stat_nodes = []
var animation_time = 0.0
var is_orbiting = false

# Variables for pulsing effect
var pulse_min_scale = 0.8  # Minimum scale factor (80% of original size)
var pulse_max_scale = 1.2  # Maximum scale factor (120% of original size)
var pulse_speed = 1.5      # Speed of pulsing animation

func _ready():
	# Create the stats container if it doesn't exist
	if not stats_container:
		stats_container = Control.new()
		stats_container.name = "StatsContainer"
		add_child(stats_container)
	
	# Set up process for animation
	set_process(true)

# Set the character reference and create the stat displays
func setup(char: DateCharacter):
	character = char
	refresh_stats()

# Create or refresh the stat displays
func refresh_stats():
	# Clear existing stats
	for child in stats_container.get_children():
		child.queue_free()
	
	stat_nodes.clear()
	
	# Create new stat displays
	if character:
		var index = 0
		for stat_name in stats_to_display:
			if character.compatibility_weights.has(stat_name):
				var stat_value = character.compatibility_weights[stat_name]
				var stat_node = create_stat_node(stat_name, stat_value, index)
				stats_container.add_child(stat_node)
				stat_nodes.append(stat_node)
				index += 1

# Create a single stat display node
func create_stat_node(stat_name: String, stat_value: int, index: int) -> Control:
	var stat_container = Panel.new()
	stat_container.name = "Stat_" + stat_name
	
	# Create a stylish background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	style.set_border_width_all(1)
	style.border_color = Color(0.8, 0.8, 0.8, 0.5)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	stat_container.add_theme_stylebox_override("panel", style)
	
	# Create a VBoxContainer for the content
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_FILL
	vbox.size_flags_vertical = Control.SIZE_FILL
	vbox.add_theme_constant_override("separation", STAT_PADDING)
	stat_container.add_child(vbox)
	
	# Add padding to the container
	vbox.position = Vector2(STAT_PADDING, STAT_PADDING)
	
	# Create the stat name label
	var name_label = Label.new()
	name_label.text = stat_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", STAT_LABEL_COLOR)
	name_label.add_theme_font_size_override("font_size", STAT_FONT_SIZE)
	vbox.add_child(name_label)
	
	# Create the stat value label
	var value_label = Label.new()
	value_label.text = str(stat_value)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_color_override("font_color", STAT_VALUE_COLOR)
	value_label.add_theme_font_size_override("font_size", STAT_FONT_SIZE + 2)
	vbox.add_child(value_label)
	
	# Set size and position
	stat_container.custom_minimum_size = Vector2(80, 60)
	stat_container.position = Vector2(index * (80 + STAT_MARGIN), 0)
	
	return stat_container

# Start the orbital animation
func start_orbiting():
	is_orbiting = true
	# Initial positions (evenly distributed around a circle)
	for i in range(stat_nodes.size()):
		var angle = (2 * PI / stat_nodes.size()) * i
		position_stat_at_angle(stat_nodes[i], angle)

# Stop the orbital animation
func stop_orbiting():
	is_orbiting = false
	for i in range(stat_nodes.size()):
		var stat_node = stat_nodes[i]
		# Return to linear layout and reset scale
		var tween = create_tween()
		tween.parallel().tween_property(stat_node, "position", Vector2(i * (80 + STAT_MARGIN), 0), 0.5)
		tween.parallel().tween_property(stat_node, "scale", Vector2(1, 1), 0.5)

# Position a stat node at a specific angle around the orbit
func position_stat_at_angle(stat_node: Control, angle: float):
	var pos_x = orbit_center.x + cos(angle) * orbit_radius
	var pos_y = orbit_center.y + sin(angle) * orbit_radius
	stat_node.position = Vector2(pos_x, pos_y)

func _process(delta):
	if is_orbiting and stat_nodes:
		animation_time += delta * orbit_speed
		
		# Update each stat node position and scale
		for i in range(stat_nodes.size()):
			var angle = animation_time + (2 * PI / stat_nodes.size()) * i
			position_stat_at_angle(stat_nodes[i], angle)
			
			# Apply pulsing effect with phase offset for each stat
			# This creates a wave-like effect as they orbit
			var pulse_phase = animation_time * pulse_speed + (PI / stat_nodes.size()) * i
			var pulse_factor = lerp(pulse_min_scale, pulse_max_scale, 
				(sin(pulse_phase) + 1) / 2)  # Convert sin wave to 0-1 range
			
			# Apply the scaling
			stat_nodes[i].scale = Vector2(pulse_factor, pulse_factor)

# Update the position of the stats display
func update_position(new_orbit_center: Vector2):
	orbit_center = new_orbit_center
	
	# Update container position
	stats_container.position = Vector2(
		-orbit_radius,  # Center the container around the orbit center
		-orbit_radius
	)
	
	# If orbiting, update the positions
	if is_orbiting:
		for i in range(stat_nodes.size()):
			var angle = animation_time + (2 * PI / stat_nodes.size()) * i
			position_stat_at_angle(stat_nodes[i], angle)
