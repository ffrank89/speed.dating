extends Control
class_name DialogueOptionUI

@onready var player_panel = $PlayerPanel

# Player's dialogue options settings
const OPTION_SIZE := Vector2(300, 50)
const OPTION_START_POSITION := Vector2(400, 500)  # Bottom middle
const OPTION_SPACING := Vector2(0, 60)  # Vertical spacing between options
const OPTION_STYLE := {
	"bg_color": Color(0.2, 0.2, 0.2, 0.8),
	"border_width": 2,
	"corner_radius": 5
}

func create_dialogue_option(option: DialogueOption):
	var button = Button.new()
	
	# Style the button
	var style = StyleBoxFlat.new()
	style.bg_color = OPTION_STYLE.bg_color
	style.set_border_width_all(OPTION_STYLE.border_width)
	style.set_corner_radius_all(OPTION_STYLE.corner_radius)
	button.add_theme_stylebox_override("normal", style)
	
	button.custom_minimum_size = OPTION_SIZE
	
	var option_count = get_child_count()
	
	button.position = OPTION_START_POSITION + (OPTION_SPACING * option_count)
	
	if option.skill_check:
		var skill = option.skill_check.skill
		var req = option.skill_check.req
		var player_skill = player_panel.get_skill(skill)
		
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
			button.disabled = true
	else:
		button.text = option.hint_text
		style.border_color = Color.WHITE
		button.disabled = false
		
	return button
