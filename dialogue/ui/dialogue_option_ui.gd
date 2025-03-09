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
var options_container: VBoxContainer
var last_viewport_size: Vector2

signal option_selected(option: DialogueOption)

func _ready():
	# Create the static dialogue box if it doesn't exist
	if not dialogue_box:
		_create_dialogue_box()
		
	last_viewport_size = get_viewport_rect().size

func _process(delta: float) -> void:
	# Only update position if viewport size has changed
	if get_viewport_rect().size != last_viewport_size:
		_update_position()
		last_viewport_size = get_viewport_rect().size

func _update_position():
	if dialogue_box:
		
		# Dynamically scale dialogue box size based on viewport
		var viewport_size = get_viewport_rect().size
		var scale_factor_x = viewport_size.x / 1920.0  # Assuming 1920 as base width
		var scale_factor_y = viewport_size.y / 1080.0  # Assuming 1080 as base height
		
		# Scale size and position proportionally
		var scaled_width = DIALOGUE_BOX_SIZE.x * scale_factor_x
		var scaled_height = DIALOGUE_BOX_SIZE.y * scale_factor_y
		dialogue_box.custom_minimum_size = Vector2(scaled_width, scaled_height)
		
		# Position the dialogue box at the bottom center of the screen
		var screen_center_x = viewport_size.x / 2
		var screen_bottom = viewport_size.y
		
		dialogue_box.position = Vector2(
			screen_center_x - scaled_width / 2,
			screen_bottom - scaled_height - 40  # 40px from bottom
		)

		# Update button sizes and positions
		var button_index = 0
		for child in dialogue_box.get_children():
			if child is Button:
				var scaled_option_width = OPTION_SIZE.x * scale_factor_x
				var scaled_option_height = OPTION_SIZE.y * scale_factor_y
				
				child.position = Vector2(
					OPTION_MARGIN * scale_factor_x, 
					OPTION_MARGIN * scale_factor_y + button_index * (scaled_option_height + 20)
				)
				child.size = Vector2(scaled_option_width, scaled_option_height)
				button_index += 1
				
func _create_dialogue_box():
	# Create the main dialogue box panel
	dialogue_box = Panel.new()
	dialogue_box.custom_minimum_size = DIALOGUE_BOX_SIZE
	dialogue_box.mouse_filter = Control.MOUSE_FILTER_IGNORE  # CHANGE: Don't block input at all

	# Style the dialogue box
	var box_style = StyleBoxFlat.new()
	box_style.bg_color = BOX_STYLE.bg_color
	box_style.set_border_width_all(BOX_STYLE.border_width)
	box_style.set_corner_radius_all(BOX_STYLE.corner_radius)
	box_style.border_color = Color.WHITE
	dialogue_box.add_theme_stylebox_override("panel", box_style)

	# Don't create VBoxContainer at all, we'll position buttons directly
	add_child(dialogue_box)

	# Set initial position
	_update_position()


func display_options(dialogue_options: Array):
	# Clear previous options
	for child in dialogue_box.get_children():
		if child is Button:
			child.queue_free()
	
	# Create new options and position them directly in the dialogue box
	for i in range(dialogue_options.size()):
		var option = dialogue_options[i]
		var button = create_dialogue_option(option)
		# Connect the button signal directly
		button.pressed.connect(_on_button_pressed.bind(option))
		# Position button manually inside dialogue box
		button.position = Vector2(OPTION_MARGIN, OPTION_MARGIN + i * (OPTION_SIZE.y + 20))
		button.size = OPTION_SIZE
		# Add directly to dialogue box
		dialogue_box.add_child(button)
	# Show the dialogue box
	dialogue_box.visible = true
	

func _on_button_pressed(option: DialogueOption):
	print("dialogue_option_ui.gd: Button pressed for option: ", option.hint_text)
	emit_signal("option_selected", option)

func create_dialogue_option(option: DialogueOption) -> Button:
	var button = Button.new()
	
	button.mouse_filter = Control.MOUSE_FILTER_STOP  # Capture all mouse events
	button.focus_mode = Control.FOCUS_ALL  # Allow keyboard focus
	
		# Monitor mouse events directly
	#button.mouse_entered.connect(func(): print("Mouse entered button: ", option.hint_text))
	#button.mouse_exited.connect(func(): print("Mouse exited button: ", option.hint_text))
	#
	
	# Style the button
	var style = StyleBoxFlat.new()
	style.bg_color = OPTION_STYLE.bg_color
	style.set_border_width_all(OPTION_STYLE.border_width)
	style.set_corner_radius_all(OPTION_STYLE.corner_radius)
	button.add_theme_stylebox_override("normal", style)
	
	button.size_flags_horizontal = Control.SIZE_FILL
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.custom_minimum_size = OPTION_SIZE	
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
