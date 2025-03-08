extends Control
class_name DialogueDataUI

# Partner's response text settings
const RESPONSE_SIZE := Vector2(800, 100)
const RESPONSE_POSITION := Vector2(200, 50)  # Centered in upper middle
const RESPONSE_FONT_SIZE := 32
const RESPONSE_ANIMATION_TIME := 1.5


func create_dates_response(data: DialogueData):
	var label = RichTextLabel.new()
	
	label.custom_minimum_size = RESPONSE_SIZE
	label.position = RESPONSE_POSITION
	# Enable BBCode but keep it simple
	label.bbcode_enabled = true
	var formatted_text = "[center]♥ %s ♥[/center]" % data.text
	label.text = formatted_text

	# Basic styling
	label.add_theme_font_size_override("normal_font_size", RESPONSE_FONT_SIZE)
	label.add_theme_color_override("default_color", Color("#FF69B4"))  # Pink

	# Simple fade in
	label.modulate.a = 0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "modulate:a", 1.0, RESPONSE_ANIMATION_TIME)
	tween.tween_property(label, "visible_characters", formatted_text.length(), RESPONSE_ANIMATION_TIME)

	return label
