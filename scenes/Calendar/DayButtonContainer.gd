extends Control

# Forward the button pressed signal
signal day_pressed(day_number)

# References to child nodes
@onready var day_button = $Day_Button
@onready var x_sprite = $XSprite
@onready var question_sprite = $QSprite
@onready var culture_sprite = $CultureSprite
@onready var sleepy_sprite = $SleepySprite

# Day number (extracted from node name)
var day_number = 0

# Position and size parameters
var grid_position = Vector2.ZERO  # Position within the calendar grid
var cell_size = Vector2(50, 50)  # Default size of each calendar cell

# Day status
var is_past_day = false
var is_available_action_day = false

# Debug mode
var debug_mode = false

var sprites = []
var sprite_map = {}
func _ready():
	print("Day Button ", name, "_ready")
	sprite_map = {	
	"x": x_sprite,
	"question": question_sprite,
	"culture": culture_sprite,
	"sleep": sleepy_sprite
	}
	sprites = [x_sprite, question_sprite, culture_sprite, sleepy_sprite]
	# Make this container completely transparent
	self.modulate.a = 0
	
	# Extract day number from the name (e.g., Day_12 → 12)
	var name_parts = name.split("_")
	if name_parts.size() > 1 and name_parts[1].is_valid_int():
		day_number = int(name_parts[1])
		
	# Set up button interaction
	if day_button:
		# Make button fully transparent but keep text visible
		day_button.flat = true
		
		# Create and apply a transparent style
		var empty_style = StyleBoxEmpty.new()
		day_button.add_theme_stylebox_override("normal", empty_style)
		day_button.add_theme_stylebox_override("hover", empty_style)
		day_button.add_theme_stylebox_override("pressed", empty_style)
		day_button.add_theme_stylebox_override("focus", empty_style)
		
		# Still need the text to be visible
		day_button.text = str(day_number)
		day_button.self_modulate = Color(1, 1, 1, 1)
		
		# Set up button properties
		day_button.mouse_filter = Control.MOUSE_FILTER_STOP
		day_button.focus_mode = Control.FOCUS_NONE
		day_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		# Connect the signal
		if day_button.is_connected("pressed", _on_button_pressed):
			print("Button already connected for Day_", day_number)
		else:
			day_button.pressed.connect(_on_button_pressed)
			print("Connected button signal for Day_", day_number)
	
	# Connect directly to CalendarScene
	var calendar_scene = get_parent().get_parent()
	if calendar_scene and calendar_scene.has_method("_on_day_pressed"):
		if is_connected("day_pressed", calendar_scene._on_day_pressed):
			print("Already connected to CalendarScene")
		else:
			day_pressed.connect(calendar_scene._on_day_pressed)
			print("Connected day_pressed directly to CalendarScene")
	
	
	for sprite in sprites:
		print("print sprite: ", sprite)
		setup_sprite(sprite)
		sprite.visible = false
	# Enable input handling
	set_process_input(true)

func setup_sprite(sprite):
	if sprite:
		# Make sprite visible despite container being transparent
		sprite.self_modulate = Color(1, 1, 1, 1)
		
		# Start animation if it has frames
		if sprite.sprite_frames:
			sprite.play()
		
		sprite.centered = true

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var rect = Rect2(global_position, size)
		
		if rect.has_point(mouse_pos):
			print("Day_", day_number, " area clicked at ", mouse_pos)
			
			# Check if button should have detected this
			var button_rect = Rect2(day_button.global_position, day_button.size)
			
			# Only handle clicks for non-past days
			if !is_past_day and button_rect.has_point(mouse_pos):
				print("Manually handling button click for Day_", day_number)
				_on_button_pressed()

func get_day_number():
	return day_number

func set_grid_position(x, y, size):
	grid_position = Vector2(x, y)
	cell_size = size
	update_position()

func update_position():
	# Set container size to match cell size
	custom_minimum_size = cell_size
	size = cell_size
	
	# Position the container based on grid position
	position = grid_position
	
	# Set button size to match container
	if day_button:
		day_button.custom_minimum_size = cell_size
		day_button.size = cell_size
	
	# Position and scale sprites
	for sprite in sprites:
		position_sprite(sprite)

func position_sprite(sprite):
	if sprite:
		# Center sprite in container
		sprite.position = cell_size / 2
		
		# Scale sprite to fit container
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(sprite.animation):
			var frame_texture = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
			if frame_texture:
				var texture_size = frame_texture.get_size()
				if texture_size.x > 0 and texture_size.y > 0:
					var scale_x = cell_size.x / texture_size.x
					var scale_y = cell_size.y / texture_size.y
					var scale_factor = min(scale_x, scale_y) * 0.8  # 80% of cell size for margin
					sprite.scale = Vector2(scale_factor, scale_factor)

func set_past_day(is_past):
	is_past_day = is_past
	
	# Show X mark for past days
	if x_sprite:
		x_sprite.visible = is_past
	
	# Disable interaction for past days by setting button appearance
	if day_button:
		if is_past:
			day_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
		else:
			day_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	

func set_available_action_day(available_action):
	is_available_action_day = true
	update_sprites(available_action)

func update_sprites(available_action):
	# Logic to determine which sprite to show:
	# - If it's a past day, show X
	# - If it's an available action day, show Q
	# - Otherwise, show neither
	
	if is_past_day:
		x_sprite.visible
		return
	
	print("\nsprite_map: ", sprite_map)
	print("\n available_action: ", available_action)
	var cur_sprite = sprite_map.get(available_action[0].get("icon"))
	cur_sprite.visible = true
	

	#elif sprite_map[available_action[0]["icon"]]:
		#print
	#if question_sprite:
		#question_sprite.visible = !is_past_day && is_available_action_day
	
func set_debug_mode(enabled):
	debug_mode = enabled
	if debug_mode:
		# Need to make container visible for debug drawing
		self.modulate.a = 1
	else:
		# Make container invisible for normal operation
		self.modulate.a = 0

func _on_button_pressed():
	# Only emit signal if this is not a past day
	if !is_past_day:
		print("Day", day_number, "button pressed - about to emit day_pressed signal")
		emit_signal("day_pressed", day_number)
		print("Day", day_number, "day_pressed signal emitted")
	else:
		print("Day", day_number, "is a past day - ignoring click")
