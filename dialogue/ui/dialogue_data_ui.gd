extends Control
class_name DialogueDataUI

# Partner's response text settings
const RESPONSE_SIZE := Vector2(800, 100)
const RESPONSE_FONT_SIZE := 32
const RESPONSE_ANIMATION_TIME := 1.5

func _process(delta):
	# Update positions of all child elements
	for child in get_children():
		if child is Panel or child is RichTextLabel:
			_update_element_position(child)

func _update_element_position(element):
	# Center in the top portion of the screen
	var screen_center_x = get_viewport_rect().size.x / 2
	element.position = Vector2(screen_center_x - RESPONSE_SIZE.x / 2, 50)
	
func create_dates_response(data: DialogueData):
	var label = RichTextLabel.new()
	
	label.custom_minimum_size = RESPONSE_SIZE
	# Enable BBCode but keep it simple
	label.bbcode_enabled = true
	
	var formatted_text = "[center][color=#FF2996]♥ %s ♥[/color][/center]" % data.text
	label.text = formatted_text
	
	# Enhanced styling
	label.add_theme_font_size_override("normal_font_size", RESPONSE_FONT_SIZE)
	label.add_theme_color_override("default_color", Color("#FF2996"))  # Brighter pink
	
	# Add a semi-transparent background panel for the text
	var bg = Panel.new()
	bg.custom_minimum_size = RESPONSE_SIZE
	bg.size = RESPONSE_SIZE
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6)  # Semi-transparent black
	style.set_corner_radius_all(15)
	style.set_border_width_all(3)
	style.border_color = Color("#FF2996")  # Match the text color
	bg.add_theme_stylebox_override("panel", style)
	
	# Set initial positions (will be updated in _process)
	_update_element_position(bg)
	_update_element_position(label)
	
	# Add the background first, then the text on top
	add_child(bg)
	add_child(label)
	
	# Animate both the background and text
	bg.modulate.a = 0
	label.modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(bg, "modulate:a", 1.0, RESPONSE_ANIMATION_TIME * 0.8)
	tween.tween_property(label, "modulate:a", 1.0, RESPONSE_ANIMATION_TIME)
	tween.tween_property(label, "visible_characters", formatted_text.length(), RESPONSE_ANIMATION_TIME)
	
	return label

func create_player_response(option: DialogueOption):
	pass
