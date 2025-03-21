# dating_scene.gd
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
@onready var bonus_label = $CompatibilityMeter/BonusLabel
@onready var inventory_ui = $InventoryUI
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
	
	option_ui.option_selected.connect(_on_option_selected)
	move_child(option_ui, get_child_count() - 1)  # Move to end (top of draw stack)
	option_ui.set_process_input(true)
	inventory_ui.set_process_input(false)  # Only process input when visible


func _on_bunny_gif_clicked():
	print("Bunny GIF was clicked in dating scene at: ", get_global_mouse_position())
	
func _on_sprite_hover():
	print("Sprite hovered at: ", get_global_mouse_position())
	
func setup_player() -> void:
	
	# Set up player in the global manager
	var player_manager = get_node_or_null("/root/PlayerManager")
	if player_manager:
		player_manager.initialize_inventory()
		inventory_ui.update_inventory(player_manager.get_inventory())
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
	dialogue_manager.dialogue_started.connect(_on_dialogue_started)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
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
	player_manager = get_node_or_null("/root/PlayerManager")
	
	dialogue_manager.select_option(option)
	
	# Update compatibility based on dialogue choice
	if option.success_effect.has("compatibility"):
		compatibility_score += option.success_effect.compatibility * 100
		var tween = create_tween()
		tween.tween_property(compatibility_meter, "value", compatibility_score, 0.3)

	var skill = option.success_effect["Skill"]
	var boost = option.success_effect["Effect"]
	player_manager.player.increase_skill(skill, boost)
	
func _on_dialogue_ended() -> void:
	end_date()

func end_date() -> void:
	var tween = create_tween()
	bonus_label.clear_bonuses()
	tween.tween_interval(0.2)
	tween.tween_property($BackgroundCircle, "position",
		Vector2(-200, $BackgroundCircle.position.y), 1.0)
	tween.tween_interval(0.5)
	tween.tween_callback(spawn_new_partner)

func calculate_compatibility() -> void:
	compatibility_score = randi_range(18, 46) 
	var tween = create_tween()
	var bonuses = Calculations.date_outfit_bonus(current_date)
	bonus_label.update_bonuses(bonuses)
	
	var total_bonus = 0
	for bonus in bonuses:
		total_bonus += bonuses[bonus] * 33
		
	tween.tween_property(compatibility_meter, "value", compatibility_score, 0.3)
	if total_bonus > 0:
		tween.tween_interval(0.2)
		tween.tween_property(compatibility_meter, "value", 
			compatibility_score + total_bonus, 0.5)
			
			
			
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I:  # 'I' key toggles inventory
			if inventory_ui:
				inventory_ui.toggle_visibility()
				# Toggle input processing so it only processes input when visible
				inventory_ui.set_process_input(inventory_ui.is_visible())
			print("Mouse at: ", get_global_mouse_position())
		else:
			print("Inventory UI not available")
