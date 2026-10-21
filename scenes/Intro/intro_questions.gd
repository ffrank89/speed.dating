extends Control
## The intro, on your phone: "Your Profile". For now it's a debug screen: set your four
## attributes with the sliders (or Randomize), then Start Dating! opens the calendar on
## the phone, and the run begins. The sliders go from the attributes' Lowest to Highest
## (1-9, data/attribute_rules.tres) and start at Highest.
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
## Size of each attribute's name and number.
@export_range(8, 200) var stat_font_size: int = 44

# Track player stats, by name. They start at the highest (data/attribute_rules.tres).
var player_stats = {}
# Sliders for each stat
var stat_sliders = {}

@onready var phone_screen: PhoneScreen = %PhoneScreen
@onready var title_label: Label = %TitleLabel
@onready var hint: Label = %Hint
@onready var stats_container: VBoxContainer = %StatsInputContainer
@onready var randomize_button: Button = %RandomizeButton
@onready var start_button: Button = %StartDatingButton


func _ready():
	for attr in Attr.NAMES:
		player_stats[Attr.display_name(attr)] = Attr.rules().highest
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
	var ui := phone_screen.style
	# Clear any existing children
	for child in stats_container.get_children():
		child.queue_free()

	# Add a slider for each stat
	for stat in player_stats.keys():
		var stat_row = HBoxContainer.new()
		stat_row.add_theme_constant_override("separation", 24)

		# Create label
		var label = Label.new()
		label.text = stat
		label.custom_minimum_size.x = 250
		ui.style_label(label, ui.ui_text_color, stat_font_size)

		# Create slider
		var slider = HSlider.new()
		slider.min_value = Attr.rules().lowest
		slider.max_value = Attr.rules().highest
		slider.value = player_stats[stat]
		slider.step = 1
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.custom_minimum_size.y = 50

		# Create value label
		var value_label = Label.new()
		value_label.text = str(int(slider.value))
		value_label.custom_minimum_size.x = 90
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		ui.style_label(value_label, ui.accent_color, stat_font_size)

		# Connect slider value change
		slider.value_changed.connect(func(val):
			player_stats[stat] = val
			value_label.text = str(int(val))
		)

		# Store the slider for later reference
		stat_sliders[stat] = slider

		stat_row.add_child(label)
		stat_row.add_child(slider)
		stat_row.add_child(value_label)
		stats_container.add_child(stat_row)


func _on_randomize_pressed():
	# Generate random stats
	for stat in player_stats.keys():
		var random_value = randi_range(Attr.rules().lowest, Attr.rules().highest)
		player_stats[stat] = random_value
		stat_sliders[stat].value = random_value


func _on_start_dating_pressed():
	# A new player with the stats from the sliders.
	var new_player = PlayerCharacter.new("Me!")
	for stat in player_stats:
		new_player.skills[stat] = player_stats[stat]
	PlayerManager.player = new_player

	# The run starts on the calendar, opening on the phone (a date day opens the dating
	# app from there).
	AppLauncher.open_scene("calendar", PlayerManager.CALENDAR, start_button.get_global_rect())
