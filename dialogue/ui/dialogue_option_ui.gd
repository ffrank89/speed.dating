extends Control
class_name DialogueOptionUI

# Dialogue box settings
const DIALOGUE_BOX_SIZE := Vector2(600, 300)
const DIALOGUE_BOX_POSITION := Vector2(920, 900)  # Position from the top-left corner

# Option settings
const OPTION_SIZE := Vector2(550, 50)
const OPTION_SPACING := 60  # Vertical spacing between options
const OPTION_MARGIN := 25   # Margin from the dialogue box edges

# Styles
const BOX_STYLE := {
	"bg_color": Color(0.1, 0.1, 0.1, 0.9),
	"border_width": 3,
	"corner_radius": 8
}

const OPTION_STYLE := {
	"bg_color": Color(0.2, 0.2, 0.2, 0.8),
	"border_width": 2,
	"corner_radius": 5
}

var dialogue_box: Panel
var options_container: VBoxContainer
signal option_selected(option: DialogueOption)

func _ready():
	# Create the static dialogue box if it doesn't exist
	if not dialogue_box:
		_create_dialogue_box()

func _create_dialogue_box():
	# Create the main dialogue box panel
	dialogue_box = Panel.new()
	dialogue_box.custom_minimum_size = DIALOGUE_BOX_SIZE
	dialogue_box.position = DIALOGUE_BOX_POSITION - DIALOGUE_BOX_SIZE / 2  # Center the box
	
	# Style the dialogue box
	var box_style = StyleBoxFlat.new()
	box_style.bg_color = BOX_STYLE.bg_color
	box_style.set_border_width_all(BOX_STYLE.border_width)
	box_style.set_corner_radius_all(BOX_STYLE.corner_radius)
	box_style.border_color = Color.WHITE
	dialogue_box.add_theme_stylebox_override("panel", box_style)
	
	# Create a container for the options
	options_container = VBoxContainer.new()
	options_container.custom_minimum_size = Vector2(OPTION_SIZE.x, DIALOGUE_BOX_SIZE.y - OPTION_MARGIN * 2)
	options_container.position = Vector2(OPTION_MARGIN, OPTION_MARGIN)
	options_container.add_theme_constant_override("separation", 10)  # Space between buttons
	
	dialogue_box.add_child(options_container)
	add_child(dialogue_box)
	
	# Initially hide the dialogue box
	dialogue_box.visible = false

func display_options(dialogue_options: Array):
	# Clear previous options
	for child in options_container.get_children():
		child.queue_free()
	
	# Create new options
	for option in dialogue_options:
		var button = create_dialogue_option(option)
		button.pressed.connect(func():
			emit_signal("option_selected", option)
		)
		options_container.add_child(button)
	
	# Show the dialogue box
	dialogue_box.visible = true

func create_dialogue_option(option: DialogueOption) -> Button:
	var button = Button.new()
	
	# Style the button
	var style = StyleBoxFlat.new()
	style.bg_color = OPTION_STYLE.bg_color
	style.set_border_width_all(OPTION_STYLE.border_width)
	style.set_corner_radius_all(OPTION_STYLE.corner_radius)
	button.add_theme_stylebox_override("normal", style)
	
	button.custom_minimum_size = OPTION_SIZE
	button.size_flags_horizontal = Control.SIZE_FILL
	
	if option.skill_check:
		var skill = option.skill_check.skill
		var req = option.skill_check.req
		var player_manager = get_node("/root/PlayerManager")
		var player_skill = 0
		if player_manager and player_manager.player:
			print("Successfully got player from root")
			player_skill = player_manager.player.get_skill_level(skill)
		
		button.text = "%s [%s %d/%d]" % [
			option.hint_text,
			skill.capitalize(),
			player_skill,
			req
		]
		
		if player_skill >= req:
			style.border_color = Color.GREEN
			button.disabled = false
		else:
			style.border_color = Color.RED
			button.disabled = false  # Still allow clicking, like in Fallout
	else:
		button.text = option.hint_text
		style.border_color = Color.WHITE
		button.disabled = false
	
	return button

func hide_dialogue_box():
	if dialogue_box:
		dialogue_box.visible = false
