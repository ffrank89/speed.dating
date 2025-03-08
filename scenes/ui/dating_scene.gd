extends Control

@onready var player_position = $ForegroundCircle
@onready var partner_position = $BackgroundCircle
@onready var compatibility_meter = $CompatibilityMeter
@onready var dialogue_box = $DialoguePanel
@onready var bonus_label = $CompatibilityMeter/BonusLabel
@onready var dialogue_ui = $DialogueDataUI
@onready var option_ui = $DialogueOptionUI
@onready var player_panel = $PlayerPanel

var dialogue_manager: DialogueManager
var current_partner: Character
var compatibility_score: float = 0.0
var player: Character
var partner: Character

func _ready():
	setup_scene()
	setup_dialogue()
	spawn_new_partner()
	player = Character.new("Me!")
	
	# Create manager with direct reference
	var player_manager = load("res://scripts/manager/player_manager.gd").new()
	player_manager.name = "PlayerManager"
	player_manager.player = player  # Set directly as a property
	
	# Add to tree
	get_tree().root.add_child(player_manager)
	

func setup_scene():
	compatibility_meter.min_value = 0
	compatibility_meter.max_value = 100
	compatibility_meter.value = 0
	
	player = Character.new("Me!")
	get_node("/root/PlayerManager").set_player(player)
	$PlayerPanel.setup(player)
	
func setup_dialogue():
	dialogue_manager = DialogueManager.new()
	add_child(dialogue_manager)
	dialogue_manager.dialogue_started.connect(_on_dialogue_started)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	dialogue_manager.load_dialogue()

func spawn_new_partner():
	partner = Character.new("lady!")
	var tween = create_tween()
	partner_position.position = Vector2(1200, partner_position.position.y)
	tween.tween_property(partner_position, "position", 
		Vector2(700, partner_position.position.y), 1.0)
	
	# Start both compatibility and dialogue
	calculate_compatibility()
	dialogue_manager.start_date_dialogue(partner, player)

func _on_dialogue_started(dialogue: DialogueData):
	# Clear previous dialogue
	for child in dialogue_ui.get_children():
		child.queue_free()
	for child in option_ui.get_children():
		child.queue_free()
		
	# Create new dialogue elements
	var response = dialogue_ui.create_dates_response(dialogue)
	dialogue_ui.add_child(response)
	
	# Create options
	for option in dialogue.options:
		var button = option_ui.create_dialogue_option(option)
		button.pressed.connect(func(): _on_option_selected(option))
		option_ui.add_child(button)

func _on_option_selected(option: DialogueOption):
	dialogue_manager.select_option(option)
	# Update compatibility based on dialogue choice
	if option.success_effect.has("compatibility"):
		compatibility_score += option.success_effect.compatibility * 100
		var tween = create_tween()
		tween.tween_property(compatibility_meter, "value", compatibility_score, 0.3)

func _on_dialogue_ended():
	end_date()

func end_date():
	var tween = create_tween()
	bonus_label.clear_bonuses()
	tween.tween_interval(0.2)
	tween.tween_property(partner_position, "position",
		Vector2(-200, partner_position.position.y), 1.0)
	tween.tween_interval(0.5)
	tween.tween_callback(spawn_new_partner)

func calculate_compatibility():
	compatibility_score = randi_range(18, 46) 
	var tween = create_tween()
	var bonuses = Calculations.character_outfit_bonus(partner)
	bonus_label.update_bonuses(bonuses)
	
	var total_bonus = 0
	for bonus in bonuses:
		total_bonus += bonuses[bonus] * 33
		
	tween.tween_property(compatibility_meter, "value", compatibility_score, 0.3)
	if total_bonus > 0:
		tween.tween_interval(0.2)
		tween.tween_property(compatibility_meter, "value", 
			compatibility_score + total_bonus, 0.5)
