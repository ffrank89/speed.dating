extends Button

var heart_points = [
	Vector2(50, 20),  # Top middle
	Vector2(20, 0),   # Left top
	Vector2(0, 25),   # Left point
	Vector2(50, 80),  # Bottom point
	Vector2(100, 25), # Right point
	Vector2(80, 0),   # Right top
]

func _ready():
	text = "PASS"
	custom_minimum_size = Vector2(100, 100)

	# Center the button's position
	var viewport_size = get_viewport_rect().size
	position = viewport_size / 2 - custom_minimum_size / 2

	# Set the pivot point to the center of the button
	# This is crucial for in-place rotation
	pivot_offset = custom_minimum_size / 2

	pressed.connect(_on_pressed)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 0, 0, 1)
	style.set_corner_radius_all(0)
	add_theme_stylebox_override("normal", style)

	animate_idle()
	animate_color()
	animate_text()


func _on_pressed():
	get_parent().end_date()

func animate_idle():
	# Create a single tween for rotation
	var rotate_tween = create_tween()
	# Important: Make it persistent to prevent cleanup
	rotate_tween.set_loops()
	# Use a full 360 rotation with a longer duration
	rotate_tween.tween_property(self, "rotation_degrees", 360, 3.0).from(0).set_trans(Tween.TRANS_LINEAR)
	# When this completes, reset to 0 instantly
	rotate_tween.chain().tween_property(self, "rotation_degrees", 0, 0)

func animate_color():
	var color_tween = create_tween()
	color_tween.set_loops()
	color_tween.tween_property(self, "modulate", Color.RED, 2.0)
	color_tween.tween_property(self, "modulate", Color.BLUE, 2.0)
	color_tween.tween_property(self, "modulate", Color.GREEN, 2.0)

func animate_text():
	var text_tween = create_tween()
	text_tween.set_loops()
	text_tween.tween_callback(func(): add_theme_color_override("font_color", Color.BLACK))
	text_tween.tween_interval(0.5)
	text_tween.tween_callback(func(): add_theme_color_override("font_color", Color.WHITE))
	text_tween.tween_interval(0.5)
