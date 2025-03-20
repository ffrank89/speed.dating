extends Panel

# Reference to the rich text label
var rich_text: RichTextLabel

func _ready():
	# Style the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.25, 0.25, 0.9)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.set_border_width_all(2)
	style.border_color = Color(0.4, 0.4, 0.4)
	add_theme_stylebox_override("panel", style)
	
	# Create or get the RichTextLabel
	if has_node("RichTextLabel"):
		rich_text = $RichTextLabel
	else:
		rich_text = RichTextLabel.new()
		rich_text.name = "RichTextLabel"
		add_child(rich_text)
	
	# Set up the RichTextLabel
	rich_text.bbcode_enabled = true
	rich_text.fit_content = true
	rich_text.size_flags_horizontal = Control.SIZE_FILL
	rich_text.size_flags_vertical = Control.SIZE_FILL
	rich_text.add_theme_font_size_override("normal_font_size", 16)
	rich_text.add_theme_color_override("default_color", Color(0.9, 0.9, 0.9))
	
	# Set the margins
	rich_text.anchor_right = 1.0
	rich_text.anchor_bottom = 1.0
	rich_text.offset_left = 20
	rich_text.offset_top = 20
	rich_text.offset_right = -20
	rich_text.offset_bottom = -20

func update_text(text):
	# Update the displayed text
	if rich_text:
		rich_text.text = text
	else:
		push_error("RichTextLabel not initialized in InfoPanel")
