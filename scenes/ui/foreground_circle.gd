extends Sprite2D

func _ready():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.5)
	style.corner_radius_top_left = 50
	style.corner_radius_top_right = 50
	style.corner_radius_bottom_left = 50
	style.corner_radius_bottom_right = 50
	
	$ColorRect.add_theme_stylebox_override("panel", style)
	$ColorRect.custom_minimum_size = Vector2(100, 100)
