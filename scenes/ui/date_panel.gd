extends Panel

func _ready():
	custom_minimum_size = Vector2(200, 400)
	position = Vector2(800, 20)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#ffffff88")
	add_theme_stylebox_override("panel", style)
