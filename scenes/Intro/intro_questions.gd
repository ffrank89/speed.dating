extends Control

# Path to your main scene
const MAIN_SCENE_PATH = "res://scenes/ui/dating_scene.tscn"
const DATING_SITE_PATH = "res://scenes/Tinder/Screen.tscn"
# Track player stats
var player_stats = {
	"Culture": 0,
	"Intellect": 0,
	"Seduction": 0,
	"Heart": 0
}

# UI References
@onready var title_label = $TitleLabel
@onready var stats_container = $StatsInputContainer
@onready var start_button = $FinalScreen/StartDatingButton
@onready var split_ends_sprite_container = $SplitEndsSprite2

# Sliders for each stat
var stat_sliders = {}

func _ready():
	# Wait for the scene to be fully loaded
	await get_tree().process_frame
	
	# Setup full screen anchors
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Get viewport size for positioning
	var viewport_size = get_viewport_rect().size
	
	# Position title at the top
	title_label.anchor_right = 1.0
	title_label.custom_minimum_size.y = 60
	title_label.position.y = 50
	
	# Create debug label
	var debug_label = Label.new()
	debug_label.text = "Debug Mode: Directly set character stats"
	debug_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	debug_label.add_theme_font_size_override("font_size", 16)
	debug_label.anchor_right = 1.0
	debug_label.position.y = 120
	add_child(debug_label)
	
	# Position stats container in the middle
	stats_container.custom_minimum_size = Vector2(600, 400)
	stats_container.position = Vector2(
		viewport_size.x / 2 - 300,  # Center horizontally
		viewport_size.y / 2 - 200   # Center vertically
	)
	
	# Position start button at the bottom
	start_button.custom_minimum_size = Vector2(200, 60)
	start_button.position = Vector2(
		viewport_size.x / 2 - 100,  # Center horizontally
		viewport_size.y - 100       # Bottom with margin
	)
	
	# Rest of your setup
	style_ui_elements()
	setup_stats_interface()
	start_button.pressed.connect(_on_start_dating_pressed)
func style_ui_elements():
	# Style title label
	if title_label:
		title_label.text = "Set Character Stats (Debug Mode)"
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.add_theme_font_size_override("font_size", 32)
		title_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.6))
		
		# Set proper anchors for title
		title_label.anchor_right = 1.0
		title_label.custom_minimum_size.y = 60
	
	# Style start button
	if start_button:
		start_button.text = "Start Dating!"
		start_button.add_theme_font_size_override("font_size", 24)
		start_button.custom_minimum_size = Vector2(200, 60)
	
	# Add a debug note
	var debug_label = Label.new()
	debug_label.text = "Debug Mode: Directly set character stats"
	debug_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	debug_label.add_theme_font_size_override("font_size", 16)
	debug_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	# Properly position the debug label
	debug_label.anchor_right = 1.0
	debug_label.custom_minimum_size.y = 30
	
	# Add with proper positioning
	add_child(debug_label)
	debug_label.position.y = title_label.position.y + title_label.size.y + 10

func setup_stats_interface():
	# Check if container exists
	if not stats_container:
		print("ERROR: Stats container not found!")
		return
	
	# Clear any existing children
	for child in stats_container.get_children():
		child.queue_free()
	
	# Add a slider for each stat
	var index = 0
	for stat in player_stats.keys():
		var stat_row = HBoxContainer.new()
		stat_row.size_flags_horizontal = Control.SIZE_FILL
		
		# Create label
		var label = Label.new()
		label.text = stat
		label.custom_minimum_size.x = 100
		label.add_theme_font_size_override("font_size", 20)
		
		# Create slider
		var slider = HSlider.new()
		slider.min_value = 0
		slider.max_value = 100
		slider.value = player_stats[stat]
		slider.step = 1
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size.y = 40
		
		# Create value label
		var value_label = Label.new()
		value_label.text = str(int(slider.value))
		value_label.custom_minimum_size.x = 50
		value_label.add_theme_font_size_override("font_size", 20)
		
		# Connect slider value change
		slider.value_changed.connect(func(val): 
			player_stats[stat] = val
			value_label.text = str(int(val))
		)
		
		# Store the slider for later reference
		stat_sliders[stat] = slider
		
		# Add elements to the row
		stat_row.add_child(label)
		stat_row.add_child(slider)
		stat_row.add_child(value_label)
		
		# Add row to the container
		stats_container.add_child(stat_row)
		
		# Add spacer between rows
		if index < player_stats.size() - 1:
			var spacer = Control.new()
			spacer.custom_minimum_size.y = 20
			stats_container.add_child(spacer)
		
		index += 1
	
	# Add random button
	var random_button = Button.new()
	random_button.text = "Randomize Stats"
	random_button.custom_minimum_size = Vector2(200, 50)
	random_button.add_theme_font_size_override("font_size", 18)
	random_button.pressed.connect(_on_randomize_pressed)
	
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_child(random_button)
	
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 30
	stats_container.add_child(spacer)
	stats_container.add_child(button_container)

func _on_randomize_pressed():
	# Generate random stats
	for stat in player_stats.keys():
		var random_value = randi_range(10, 90)
		player_stats[stat] = random_value
		stat_sliders[stat].value = random_value

func _on_start_dating_pressed():
	# Get the PlayerManager singleton
	var player_manager = get_node("/root/PlayerManager")
	
	# Create a new player with custom stats
	var new_player = PlayerCharacter.new("Me!")
	
	# Set the stats based on slider values
	for stat in player_stats:
		new_player.skills[stat] = player_stats[stat]
	
	print("Debug mode - Player stats set to:", player_stats)
	
	# Replace the player in PlayerManager
	player_manager.player = new_player
	
	# Initialize inventory
	player_manager.initialize_inventory()
	#change to main scene
	var tween = create_tween()
	tween.tween_callback(func(): get_tree().change_scene_to_file(DATING_SITE_PATH))
	
