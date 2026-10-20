extends Control

# Character classes to load profiles from
var character_classes = [
	SplitEndsCharacter,
	SmokeyCharacter
]
var characters = []  # Will store loaded instances of character classes
var current_profile_index = 0

# References to UI elements
@onready var icon_panel = $IconPanel
@onready var info_panel = $InfoPanel
@onready var start_button = $Start
@onready var next_button = $NextIcon

func _ready():
	# Set up the UI layout
	setup_layout()
	
	load_characters()
	update_display()
	
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	next_button.pressed.connect(_on_next_pressed)

func setup_layout():
	# Make sure the root control fills the viewport
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Position and size the icon panel (profile picture)
	icon_panel.anchor_left = 0.1
	icon_panel.anchor_top = 0.1
	icon_panel.anchor_right = 0.45
	icon_panel.anchor_bottom = 0.7
	icon_panel.offset_left = 0
	icon_panel.offset_top = 0
	icon_panel.offset_right = 0
	icon_panel.offset_bottom = 0
	
	# Position and size the info panel (character info)
	info_panel.anchor_left = 0.5
	info_panel.anchor_top = 0.1
	info_panel.anchor_right = 0.9
	info_panel.anchor_bottom = 0.7
	info_panel.offset_left = 0
	info_panel.offset_top = 0
	info_panel.offset_right = 0
	info_panel.offset_bottom = 0
	
	# Position the Start button
	start_button.anchor_left = 0.3
	start_button.anchor_top = 0.8
	start_button.anchor_right = 0.5
	start_button.anchor_bottom = 0.9
	start_button.offset_left = 0
	start_button.offset_top = 0
	start_button.offset_right = 0
	start_button.offset_bottom = 0
	
	# Position the Next button
	next_button.anchor_left = 0.6
	next_button.anchor_top = 0.8
	next_button.anchor_right = 0.8
	next_button.anchor_bottom = 0.9
	next_button.offset_left = 0
	next_button.offset_top = 0
	next_button.offset_right = 0
	next_button.offset_bottom = 0
	
	# Setup button text and styles
	if start_button is Button:
		start_button.text = "Start Dating!"
		var start_style = StyleBoxFlat.new()
		start_style.bg_color = Color(0.2, 0.6, 0.3)  # Green
		start_style.set_corner_radius_all(15)
		start_style.set_border_width_all(2)
		start_style.border_color = Color(0.3, 0.7, 0.4)
		start_button.add_theme_stylebox_override("normal", start_style)
		start_button.add_theme_font_size_override("font_size", 20)
	
	if next_button is Button:
		next_button.text = "Next Profile"
		var next_style = StyleBoxFlat.new()
		next_style.bg_color = Color(0.4, 0.4, 0.6)  # Blue-ish
		next_style.set_corner_radius_all(15)
		next_style.set_border_width_all(2)
		next_style.border_color = Color(0.5, 0.5, 0.7)
		next_button.add_theme_stylebox_override("normal", next_style)
		next_button.add_theme_font_size_override("font_size", 20)
	
func load_characters():
	# Create instances of each character class
	for char_class in character_classes:
		print("load_characters char_class", char_class)
		var character = char_class.create_default()
		# A girl whose first date failed is gone for the run; one in your contacts is taken.
		var player_manager = get_node("/root/PlayerManager")
		if player_manager.is_gone(character.name) or player_manager.is_in_party(character.name):
			continue
		# Add default interests and other fields if they're not set
		if character.interests.is_empty():
			set_default_character_data(character)
			  
		characters.append(character)
		
func set_default_character_data(character):
	print("NO CHARACTER DATA")
	
func update_display():
	if characters.is_empty():
		# Everyone's taken or gone: Start goes back to the calendar instead.
		info_panel.update_text("[center]No one left to swipe on.[/center]")
		start_button.text = "Back to the calendar"
		next_button.disabled = true
		return
	var character = self.characters[current_profile_index]
	
	# Update the icon
	var texture_path = get_character_icon(character)
	icon_panel.update_display(texture_path)
	
	# Update info panel text
	var info_text = "[center][b]%s, %d[/b][/center]\n\n%s\n\n[b]Interests:[/b]\n" % [
		character.name.capitalize(), 
		character.age if "age" in character else 10000,
		character.bio if "bio" in character else "No bio available."
	]
	
	# Add interests
	for interest in character.interests:
		info_text += "• " + interest + "\n"
	
	info_panel.update_text(info_text)

func get_character_icon(character):
	if character.icon_path:
		return character.icon_path
		
	print("NO ICON IN CHARACTER")
	# Fallback to default
	return ""

func _on_next_pressed():
	# Animate transition to next profile
	var tween = create_tween()
	tween.tween_property(icon_panel, "modulate", Color(1,1,1,0), 0.3)
	tween.parallel().tween_property(info_panel, "modulate", Color(1,1,1,0), 0.3)
	tween.tween_callback(func():
		# Go to next profile
		self.current_profile_index = (self.current_profile_index + 1) % characters.size()
		update_display()
	)
	
	tween.tween_property(icon_panel, "modulate", Color(1,1,1,1), 0.3)
	tween.parallel().tween_property(info_panel, "modulate", Color(1,1,1,1), 0.3)

func _on_start_pressed():
	var player_manager = get_node("/root/PlayerManager")
	if characters.is_empty():
		AppLauncher.open_scene("calendar", player_manager.CALENDAR, start_button.get_global_rect())
		return
	# Store selected character in PlayerManager
	player_manager.select_date(characters[self.current_profile_index])
	
	# Open the date like an app, growing from the Start button (data/apps/date.tres)
	AppLauncher.open_scene("date", player_manager.current_date.first_date_path, start_button.get_global_rect())
