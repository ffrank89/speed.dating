extends Control
## The intro, on your phone: "Your Profile". For now it's a debug screen: set your stats
## with the sliders (or Randomize), then Start Dating! opens the calendar on the phone,
## and the run begins. There's a slider for every stat that's on (data/stats.tres), from
## Lowest to Highest (1-9), starting at the stat's Starting Value. The list scrolls when
## it's taller than the phone.
##
## The words are the settings below. The phone, its font, colours and your room behind
## it are data/phone_style.tres. Move the parts in this scene (PhoneScreen → Phone →
## Body → Screen → Margin).

## The app's big title.
@export var title_text: String = "Your Profile"
## Under the title.
@export var hint_text: String = "Debug: set your stats"
@export var randomize_text: String = "Randomize Stats"
@export var start_text: String = "Start Dating!"
## Size of each stat's name and number.
@export_range(8, 200) var stat_font_size: int = 40

# The stats that are on (PlayerStat → value), from their Starting Value.
var player_stats = {}
# Sliders for each stat (PlayerStat → HSlider)
var stat_sliders = {}

@onready var phone_screen: PhoneScreen = %PhoneScreen
@onready var title_label: Label = %TitleLabel
@onready var hint: Label = %Hint
@onready var stats_container: VBoxContainer = %StatsInputContainer
@onready var randomize_button: Button = %RandomizeButton
@onready var start_button: Button = %StartDatingButton


func _ready():
	for stat in StatList.get_default().active():
		player_stats[stat] = StatList.get_default().starting_value_of(stat)
	style_ui_elements()
	setup_stats_interface()
	randomize_button.pressed.connect(_on_randomize_pressed)
	start_button.pressed.connect(_on_start_dating_pressed)


# The phone's font and colours for the words; the buttons in the phone's accent colour.
func style_ui_elements():
	var ui := phone_screen.style
	ui.style_label(title_label, ui.ui_text_color, ui.title_font_size)
	title_label.text = title_text
	ui.style_label(hint, Color(ui.ui_text_color, 0.5))
	hint.text = hint_text
	randomize_button.text = randomize_text
	start_button.text = start_text
	_style_button(randomize_button, Color(ui.accent_color, 0.15), ui.accent_color)
	_style_button(start_button, ui.accent_color, Color.WHITE)


func _style_button(button: Button, fill: Color, ink: Color) -> void:
	var ui := phone_screen.style
	for state in ["normal", "hover", "pressed"]:
		var box := StyleBoxFlat.new()
		box.bg_color = fill.lightened(0.1) if state == "hover" else (fill.darkened(0.1) if state == "pressed" else fill)
		box.set_corner_radius_all(30)
		box.anti_aliasing = true
		button.add_theme_stylebox_override(state, box)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	if ui.ui_font:
		button.add_theme_font_override("font", ui.ui_font)
	button.add_theme_font_size_override("font_size", ui.ui_font_size)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(color_name, ink)


func setup_stats_interface():
	# Clear any existing children
	for child in stats_container.get_children():
		child.queue_free()

	# A slider for each stat that's on.
	for stat: PlayerStat in player_stats:
		_add_slider(stat, stat.display_name, player_stats, stat_font_size)


# One row: the stat's name, its slider and its number. `values[key]` follows the slider.
func _add_slider(key, label_text: String, values: Dictionary, font_size: int) -> void:
	var ui := phone_screen.style
	var stat_row = HBoxContainer.new()
	stat_row.add_theme_constant_override("separation", 24)

	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 250
	ui.style_label(label, ui.ui_text_color, font_size)

	var slider = HSlider.new()
	slider.min_value = StatList.get_default().lowest
	slider.max_value = StatList.get_default().highest
	slider.value = values[key]
	slider.step = 1
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.custom_minimum_size.y = 50
	# The mouse wheel scrolls the list instead of moving the slider under it.
	slider.scrollable = false

	var value_label = Label.new()
	value_label.text = str(int(slider.value))
	value_label.custom_minimum_size.x = 90
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ui.style_label(value_label, ui.accent_color, font_size)

	slider.value_changed.connect(func(val):
		values[key] = int(val)
		value_label.text = str(int(val))
	)
	stat_sliders[key] = slider

	stat_row.add_child(label)
	stat_row.add_child(slider)
	stat_row.add_child(value_label)
	stats_container.add_child(stat_row)


func _on_randomize_pressed():
	# Generate random stats (the sliders update the values).
	for key in stat_sliders:
		stat_sliders[key].value = randi_range(StatList.get_default().lowest, StatList.get_default().highest)


func _on_start_dating_pressed():
	# A new player with the stats from the sliders.
	var new_player = PlayerCharacter.new("Me!")
	for stat: PlayerStat in player_stats:
		new_player.stats[stat.id] = player_stats[stat]
	PlayerManager.player = new_player

	# The run starts on the calendar, opening on the phone (a date day opens the dating
	# app from there).
	AppLauncher.open_scene("calendar", PlayerManager.CALENDAR, start_button.get_global_rect())
