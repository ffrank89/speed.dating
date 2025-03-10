extends Control
class_name DialogueOptionUI

# Dialogue box settings - base size for 1920x1080 resolution
const BASE_DIALOGUE_BOX_SIZE := Vector2(600, 300)
const BASE_OPTION_SIZE := Vector2(550, 50)
const BASE_OPTION_MARGIN := 25
const BASE_OPTION_SPACING := 20

# Styles
const BOX_STYLE := {
	"bg_color": Color(0.1, 0.1, 0.1, 0.4),
	"border_width": 3,
	"corner_radius": 8
}

const OPTION_STYLE := {
	"bg_color": Color(0.2, 0.2, 0.2, 0.6),
	"border_width": 2,
	"corner_radius": 5
}

var dialogue_box: Panel
var last_viewport_size: Vector2

signal option_selected(option: DialogueOption)

func _ready():
	if not dialogue_box:
		_create_dialogue_box()
		
	last_viewport_size = get_viewport_rect().size

func _process(_delta: float) -> void:
	if get_viewport_rect().size != last_viewport_size:
		_update_box_and_buttons()
		last_viewport_size = get_viewport_rect().size

func _update_box_and_buttons():
	if dialogue_box:
		# Get scale factor based on viewport
		var viewport_size = get_viewport_rect().size
		var scale_factor = min(viewport_size.x / 1920.0, viewport_size.y / 1080.0)
		
		# Scale dialogue box
		var scaled_box_size = BASE_DIALOGUE_BOX_SIZE * scale_factor
		dialogue_box.custom_minimum_size = scaled_box_size
		dialogue_box.size = scaled_box_size
		
		# Reposition at bottom center
		dialogue_box.position = Vector2(
			viewport_size.x / 2 - scaled_box_size.x / 2,
			viewport_size.y - scaled_box_size.y - 40 * scale_factor
		)
		
		# Resize buttons
		var option_size = BASE_OPTION_SIZE * scale_factor
		var option_margin = BASE_OPTION_MARGIN * scale_factor
		var option_spacing = BASE_OPTION_SPACING * scale_factor
		
		var button_index = 0
		for child in dialogue_box.get_children():
			if child is Button:
				# Set button size
				child.custom_minimum_size = option_size
				child.size = option_size
				
				# Position button
				child.position = Vector2(
					(scaled_box_size.x - option_size.x) / 2,  # Center horizontally
					option_margin + button_index * (option_size.y + option_spacing)
				)
				child.add_theme_font_size_override("font_size", int(16 * scale_factor))

				# Make sure button doesn't go beyond box
				if child.position.y + option_size.y > scaled_box_size.y - option_margin:
					child.visible = false
				else:
					child.visible = true
					
				button_index += 1

func _create_dialogue_box():
	dialogue_box = Panel.new()
	dialogue_box.custom_minimum_size = BASE_DIALOGUE_BOX_SIZE
	dialogue_box.size = BASE_DIALOGUE_BOX_SIZE
	dialogue_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var box_style = StyleBoxFlat.new()
	box_style.bg_color = BOX_STYLE.bg_color
	box_style.set_border_width_all(BOX_STYLE.border_width)
	box_style.set_corner_radius_all(BOX_STYLE.corner_radius)
	box_style.border_color = Color.WHITE
	dialogue_box.add_theme_stylebox_override("panel", box_style)
	
	add_child(dialogue_box)
	_update_box_and_buttons()

func display_options(dialogue_options: Array):
	# Clear previous options
	for child in dialogue_box.get_children():
		if child is Button:
			child.queue_free()
	
	# Get current scale factor
	var scale_factor = min(get_viewport_rect().size.x / 1920.0, get_viewport_rect().size.y / 1080.0)
	var option_size = BASE_OPTION_SIZE * scale_factor
	var option_margin = BASE_OPTION_MARGIN * scale_factor
	var option_spacing = BASE_OPTION_SPACING * scale_factor
	
	# Create new options
	for i in range(dialogue_options.size()):
		var option = dialogue_options[i]
		var button = create_dialogue_option(option)
		
		# Set size and position
		button.custom_minimum_size = option_size
		button.size = option_size
		button.position = Vector2(
			(dialogue_box.size.x - option_size.x) / 2,
			option_margin + i * (option_size.y + option_spacing)
		)
		
		# Check if button would go beyond box boundary
		if button.position.y + option_size.y > dialogue_box.size.y - option_margin:
			button.visible = false
		
		# Connect signal
		button.pressed.connect(_on_button_pressed.bind(option))
		
		# Add to dialogue box
		dialogue_box.add_child(button)
	
	# Show the dialogue box
	dialogue_box.visible = true

func _on_button_pressed(option: DialogueOption):
	print("Button pressed for option:", option.hint_text)
	emit_signal("option_selected", option)

func create_dialogue_option(option: DialogueOption) -> Button:
	var button = Button.new()
	
	# Configure input handling
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.focus_mode = Control.FOCUS_ALL
	
	# Style the button
	var style = StyleBoxFlat.new()
	style.bg_color = OPTION_STYLE.bg_color
	style.set_border_width_all(OPTION_STYLE.border_width)
	style.set_corner_radius_all(OPTION_STYLE.corner_radius)
	button.add_theme_stylebox_override("normal", style)
	
	# Handle skill check text and coloring
	if option.skill_check:
		var skill = option.skill_check.skill
		var req = option.skill_check.req
		var player_manager = get_node("/root/PlayerManager")
		var player_skill = 0
		if player_manager and player_manager.player:
			player_skill = player_manager.player.get_skill_level(skill)
		
		button.text = "%s [%s %d/%d]" % [
			option.hint_text,
			skill.capitalize(),
			player_skill,
			req
		]
		
		if player_skill >= req:
			style.border_color = Color.GREEN
		else:
			style.border_color = Color.RED
	else:
		button.text = option.hint_text
		style.border_color = Color.WHITE
	
	# Scale font size
	var scale_factor = min(get_viewport_rect().size.x / 1920.0, get_viewport_rect().size.y / 1080.0)
	button.add_theme_font_size_override("font_size", int(16 * scale_factor))
	
	return button

func hide_dialogue_box():
	if dialogue_box:
		dialogue_box.visible = false
