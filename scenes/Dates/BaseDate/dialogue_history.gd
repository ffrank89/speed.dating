# scrolling_dialogue_history.gd
extends Control

# Configuration
var max_messages = 7  # Maximum number of messages to display
var message_height = 120  # Height of each message box
var spacing = 0 # Spacing between messages
var fade_duration = 0.3  # Time to fade in/out messages
var slide_duration = 0.4  # Time to slide messages down

# Internal variables
var message_containers = []
var target_positions = []
var message_labels = []

func _ready():
	# Set up the initial positions for message containers
	for i in range(max_messages):
		var container = create_message_container()
		container.modulate.a = 0  # Start invisible
		container.position.y = i * (message_height + spacing)
		target_positions.append(container.position.y)
		message_containers.append(container)
		add_child(container)
	for i in range(message_containers.size()):
		print("Container ", i, " position: ", message_containers[i].position)
		print("Container ", i, " size: ", message_containers[i].size)

	custom_minimum_size = Vector2(500, max_messages * (message_height + spacing))

func create_message_container():
	var container = PanelContainer.new()
	
	# Style the container
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	container.add_theme_stylebox_override("panel", style)
	
	# Set size
	container.custom_minimum_size = Vector2(400, message_height)
	
	# Use RichTextLabel instead of Label for rich text support
	var label = RichTextLabel.new()
	label.name = "MessageLabel"
	label.bbcode_enabled = true  # Enable rich text
	label.fit_content = true
	label.scroll_active = false
	label.add_theme_color_override("default_color", Color(1, 1, 1, 1))  # White text
	
	# Add margins
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_bottom", 5)
	
	margin.add_child(label)
	container.add_child(margin)
	message_labels.append(label)  # Store reference to the label

	return container

func add_message(text, character_name = ""):
	
	
	print("add_message: Text: ", text)
	print("add_message: character_name: ", character_name)

	print("add_message: message_containers: ", message_containers)
	
	print("add_message: message_containers[0]: ", message_containers[0])

	# Create the full message text
	var full_text = text
	if character_name != "":
		full_text = "[b]" + character_name + ":[/b] " + text
	print("Full text to display: ", full_text)

	## Shift all existing messages down
	for i in range(message_containers.size() - 1, 0, -1):
		var current_label = message_labels[i]
		var previous_label = message_labels[i-1]
		
		# Copy text from previous to current
		current_label.text = previous_label.text

		# If the previous had text, make sure this one is visible
		if previous_label.text != "":
			message_containers[i].modulate.a = message_containers[i-1].modulate.a
		
	# Set the new message at the top
	# Set the new message at the top
	var top_label = message_labels[0]
	top_label.text = full_text
	print("Top label text after setting: ", top_label.text)
	
	# Make sure the top container is explicitly visible
	message_containers[0].modulate.a = 1.0
	
	# Animate all messages
	animate_messages()
	
func animate_messages():
	# Create a tween for animations
	var tween = create_tween()
	
	# Fade in the top message if it has text
	if message_labels[0].text != "":
		message_containers[0].modulate.a = 0
		tween.parallel().tween_property(message_containers[0], "modulate:a", 1.0, fade_duration)
	
	# Slide all messages to their target positions
	for i in range(message_containers.size()):
		var container = message_containers[i]
		tween.parallel().tween_property(container, "position:y", target_positions[i], slide_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Fade out the bottom message if it's going to be replaced next time
	if message_labels[-1].text != "":
		tween.parallel().tween_property(message_containers[-1], "modulate:a", 0.3, fade_duration * 2)
