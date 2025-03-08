# dating_scene.gd
extends Control

var player: Character
var current_date: Character
var dialogue_manager: DialogueManager

# References to UI elements
@onready var player_panel = $PlayerPanel
@onready var date_panel = $DatePanel
@onready var dialogue_panel = $DialoguePanel
@onready var compatibility_meter = $CompatibilityMeter
@onready var dialogue_ui = $DialogueDataUI
@onready var option_ui = $DialogueOptionUI
@onready var bonus_label = $CompatibilityMeter/BonusLabel

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

func setup_player() -> void:
	# Create player character
	player = Character.new("Me!")
	
	# Set up player in the global manager
	var player_manager = get_node_or_null("/root/PlayerManager")
	if player_manager:
		player_manager.set_player(player)
	else:
		# Create manager if not available as autoload
		player_manager = load("res://scripts/manager/player_manager.gd").new()
		player_manager.name = "PlayerManager"
		player_manager.player = player
		get_tree().root.add_child(player_manager)
	
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
	current_date = Character.new("Date")
	var partner_position = $BackgroundCircle
	
	# Animate partner entry
	var tween = create_tween()
	partner_position.position = Vector2(1200, partner_position.position.y)
	tween.tween_property(partner_position, "position", 
		Vector2(700, partner_position.position.y), 1.0)
	
	# Start both compatibility and dialogue
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
	
	# Update compatibility based on dialogue choice
	if option.success_effect.has("compatibility"):
		compatibility_score += option.success_effect.compatibility * 100
		var tween = create_tween()
		tween.tween_property(compatibility_meter, "value", compatibility_score, 0.3)

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
	var bonuses = Calculations.character_outfit_bonus(current_date)
	bonus_label.update_bonuses(bonuses)
	
	var total_bonus = 0
	for bonus in bonuses:
		total_bonus += bonuses[bonus] * 33
		
	tween.tween_property(compatibility_meter, "value", compatibility_score, 0.3)
	if total_bonus > 0:
		tween.tween_interval(0.2)
		tween.tween_property(compatibility_meter, "value", 
			compatibility_score + total_bonus, 0.5)
