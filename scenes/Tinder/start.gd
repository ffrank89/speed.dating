extends Button

func _ready():
	text = "Start Dating!"
	custom_minimum_size = Vector2(180, 70)
	
	# Style the button
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.6, 0.3)  # Green
	normal_style.set_corner_radius_all(15)
	normal_style.set_border_width_all(2)
	normal_style.border_color = Color(0.3, 0.7, 0.4)
	add_theme_stylebox_override("normal", normal_style)
	
	# Hover style
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.7, 0.4)  # Lighter green
	hover_style.set_corner_radius_all(15)
	hover_style.set_border_width_all(2)
	hover_style.border_color = Color(0.4, 0.8, 0.5)
	add_theme_stylebox_override("hover", hover_style)
	
	# Pressed style
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.15, 0.5, 0.25)  # Darker green
	pressed_style.set_corner_radius_all(15)
	pressed_style.set_border_width_all(2)
	pressed_style.border_color = Color(0.3, 0.7, 0.4)
	add_theme_stylebox_override("pressed", pressed_style)
	
	# Text styling
	add_theme_font_size_override("font_size", 20)
	add_theme_color_override("font_color", Color(1, 1, 1))
	add_theme_color_override("font_hover_color", Color(1, 1, 1))
	add_theme_color_override("font_pressed_color", Color(0.9, 0.9, 0.9))
