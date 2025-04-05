extends Control

var player: PlayerCharacter
var current_date: DateCharacter
var dialogue_manager: DialogueManager
var player_manager: PlayerManager

# References to UI elements
@onready var player_panel = $PlayerPanel
@onready var date_panel = $DatePanel
@onready var dialogue_panel = $DialoguePanel
@onready var compatibility_meter = $CompatibilityMeter
@onready var dialogue_ui = $DialogueDataUI
@onready var option_ui = $DialogueOptionUI
@onready var inventory_ui = $InventoryUI
@onready var party_ui = $PartyUI
@onready var split_ends = $SplitEnds
@onready var split_ends_sprite_container = $SplitEndsSprite
@onready var bunny_gif_container = $BunnyGif

var compatibility_score: float = 0.0

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	# Ensure this control fills the viewport
	anchors_preset = Control.PRESET_FULL_RECT
	
	# Print debug information
	print("Window size at startup: ", DisplayServer.window_get_size())
	print("Viewport size: ", get_viewport_rect().size)

	# Initialize player character
	setup_player()
	
	# Setup dialogue system
	setup_dialogue()
	
	# Spawn initial partner
	spawn_new_partner()
	
	# Connect signals
	option_ui.option_selected.connect(_on_option_selected)
	
	move_child(option_ui, get_child_count() - 1)  # Move to end (top of draw stack)
	option_ui.set_process_input(true)
	inventory_ui.set_process_input(false)  # Only process input when visible
	party_ui.set_process_input(false)  # Only process input when visible

func _on_bunny_gif_clicked():
	print("Bunny GIF was clicked in dating scene at: ", get_global_mouse_position())
	
func _on_sprite_hover():
	print("Sprite hovered at: ", get_global_mouse_position())
	
func setup_player() -> void:
	# Set up player in the global manager
	player_manager = get_node_or_null("/root/PlayerManager")
	if player_manager:
		player_manager.initialize_inventory()
		player_manager.initialize_party()
		inventory_ui.update_inventory(player_manager.get_inventory())
		party_ui.update_party(player_manager.get_party())
		player = player_manager.player
	else:
		print("No PLAYER MANAGER ready")

	# Update player panel
	player_panel.setup(player)
	
	# Initialize compatibility meter
	compatibility_meter.min_value = 0
	compatibility_meter.max_value = 100
	compatibility_meter.value = 0

func setup_dialogue() -> void:
	dialogue_manager = DialogueManager.new()
	add_child(dialogue_manager)
	
	# Connect dialogue signals
	dialogue_manager.dialogue_started.connect(_on_dialogue_started)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	dialogue_manager.compatibility_changed.connect(_on_compatibility_changed)
		
	dialogue_manager.load_dialogue()

func spawn_new_partner() -> void:
	# Get the Character instance from the scene
	current_date = split_ends.character
	
	# Reset the character if previously added
	if split_ends.get_parent():
		print("Partner already spawned!")
		split_ends.get_parent().remove_child(split_ends)
	
	# Add the character to the scene
	add_child(split_ends)
	
	# Make sure character is set up for correct positioning
	split_ends.update_position()
	
	# Start the date-specific content
	calculate_compatibility()
	dialogue_manager.start_date_dialogue(current_date, player)

func _on_dialogue_started(dialogue: DialogueData) -> void:
	# Clear previous dialogue
	for child in dialogue_ui.get_children():
		child.queue_free()
		
	# Create new dialogue elements
	var response = dialogue_ui.create_dates_response(dialogue)
	dialogue_ui.add_child(response)
	
	# Create options in the static dialogue box
	option_ui.display_options(dialogue.options)

func _on_option_selected(option: DialogueOption) -> void:
	dialogue_manager.select_option(option)

func _on_compatibility_changed(value: float, increase: float) -> void:
	compatibility_score = value
	
	# Animate the meter
	var tween = create_tween()
	tween.tween_property(compatibility_meter, "value", compatibility_score, 0.3)
	
	# Show a floating indicator for the increase
	if increase > 0:
		show_compatibility_increase(increase)

func show_compatibility_increase(amount: float) -> void:
	# Create a floating label to show the increase
	var label = Label.new()
	label.text = "+ " + str(int(amount))
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.2))
	label.position = Vector2(compatibility_meter.position.x + 100, compatibility_meter.position.y - 30)
	add_child(label)
	
	# Animate it floating up and fading out
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 50, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_callback(label.queue_free)
	
func _on_dialogue_ended(success: bool) -> void:
	if success:
		print("DATE SUCCESS")
		print("Adding ", current_date, " to party! ")
		if player_manager:
			print("current_date", current_date)
			player_manager.add_date(current_date)
			party_ui.update_party(player_manager.get_party())
		else:
			print("ERROR player_manager DOES NOT EXIST!!!! IN _on_dialogue_ended success!!!")
	end_date()

func end_date() -> void:
	# Animate transition to calendar scene
	var fade_panel = ColorRect.new()
	fade_panel.color = Color(0, 0, 0, 0)
	fade_panel.anchors_preset = Control.PRESET_FULL_RECT
	add_child(fade_panel)
	
	var tween = create_tween()
	tween.tween_property(fade_panel, "color", Color(0, 0, 0, 1), 1.0)
	print("In end_date - transitioning to calendar")
	
	# After the fade completes, open the calendar
	tween.tween_callback(func(): 
		if player_manager:			
			# Change scene to calendar
			get_tree().change_scene_to_file(player_manager.CALENDAR)
		else:
			print("ERROR: No player_manager found!")
			# Fallback to a default scene
			get_tree().change_scene_to_file(player_manager.STATS_SELECT)
	)

func calculate_compatibility() -> void:
	compatibility_score = randi_range(18, 46) 
	var tween = create_tween()
	
		
	tween.tween_property(compatibility_meter, "value", compatibility_score, 0.3)
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I:
			if inventory_ui:
				inventory_ui.toggle_visibility()
				# Toggle input processing so it only processes input when visible
				inventory_ui.set_process_input(inventory_ui.is_visible())
			else:
				print("Inventory UI not available")
		elif event.keycode == KEY_P:
			if party_ui:
				party_ui.toggle_visibility()
				# Toggle input processing so it only processes input when visible
				party_ui.set_process_input(party_ui.is_visible())
			else:
				print("Party UI not available")
		print("2 Mouse at: ", get_global_mouse_position())
