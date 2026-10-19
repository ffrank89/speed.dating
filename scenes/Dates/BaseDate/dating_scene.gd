extends Control

var player: PlayerCharacter
var current_date: DateCharacter
var dialogue_manager: LegacyDialogueManager
var player_manager: PlayerManager
var date_presenter: DatePresenter
var score_calculator: ScoreCalculator

# References to UI elements
@onready var player_panel = $PlayerPanel
@onready var compatibility_meter = $CompatibilityMeter
@onready var dialogue_ui = $DialogueDataUI
@onready var option_ui = $DialogueOptionUI
@onready var inventory_ui = $InventoryUI
@onready var party_ui = $PartyUI
@onready var bunny_gif_container = $BunnyGif
@onready var date_presenter_container = $DatePresenterContainer
@onready var perk_border = $PerkBorder
@onready var dialogue_history = $DialogueHistory

var compatibility_score: float = 0.0

var date_score: float = 0.0

# Set once end_date() runs so late clicks during the fade can't end the date again
var date_over: bool = false

func _ready() -> void:
	player_manager = get_node_or_null("/root/PlayerManager")
	
	# Ensure this control fills the viewport
	anchors_preset = Control.PRESET_FULL_RECT
	# Print debug information
	print("Window size at startup: ", DisplayServer.window_get_size())
	print("Viewport size: ", get_viewport_rect().size)

	# Initialize player character
	setup_player()
	
	# Setup dialogue system
	setup_dialogue()
	
	#setup score calculator
	setup_score_calculator()
	# Spawn initial partner
	spawn_new_partner()
	
	# Connect signals
	option_ui.option_selected.connect(_on_option_selected)
	move_child(perk_border, get_child_count() - 1)  # Move to end (top of draw stack)
	move_child(party_ui, get_child_count() - 1)  # Move to end (top of draw stack)
	move_child(inventory_ui, get_child_count() - 1)
	move_child(option_ui, get_child_count() - 1)  # Move to end (top of draw stack)

func _on_bunny_gif_clicked():
	print("Bunny GIF was clicked in dating scene at: ", get_global_mouse_position())

func setup_player() -> void:
	# Set up player in the global manager
	if player_manager:
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

func setup_score_calculator() -> void:
	score_calculator = ScoreCalculator.new()
	
func setup_dialogue() -> void:
	dialogue_manager = LegacyDialogueManager.new()
	add_child(dialogue_manager)
	
	# Connect dialogue signals
	dialogue_manager.dialogue_started.connect(_on_dialogue_started)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	dialogue_manager.compatibility_changed.connect(_on_compatibility_changed)
	dialogue_manager.turn_used.connect(_on_turn_used)

	dialogue_manager.load_dialogue()

func spawn_new_partner() -> void:
	
	if player_manager:
		current_date = player_manager.current_date
		
		if current_date:
			var date_presenter_scene = load("res://scenes/DatePresenter/DatePresenter.tscn")
			date_presenter = date_presenter_scene.instantiate()
			date_presenter_container.add_child(date_presenter)
			
			date_presenter.initialize(current_date)
			
			calculate_compatibility()
			dialogue_manager.start_date_dialogue(current_date, player)
		else:
			print("ERROR NO CURRENT DATE IN PLAYER MANAGER")
	else:
		print("ERROR NO PLAYER MANAGER")

func _on_dialogue_started(dialogue: DialogueData) -> void:
	# Clear previous dialogue options
	for child in dialogue_ui.get_children():
		child.queue_free()
		
	# Create new dialogue elements
	dialogue_ui.create_dates_response(dialogue)
	
	# Add the dialogue text to the history
	dialogue_history.add_message(dialogue.text, current_date.name)
	
	# Create options in the static dialogue box
	option_ui.display_options(dialogue.options)

func _on_option_selected(option: DialogueOption) -> void:
	if date_over:
		return
	# Add the player's choice to the dialogue history
	dialogue_history.add_message(option.hint_text, player.name)
	
	# Process the option selection
	dialogue_manager.select_option(option)
	
	pose_changer(option, date_presenter.cur_pose)
	reaction_shower(option, date_presenter.cur_reaction)
	
	score_keeper(option)

func _on_compatibility_changed(value: float, increase: float) -> void:
	compatibility_score = value
	
	# Animate the meter
	var tween = create_tween()
	tween.tween_property(compatibility_meter, "value", compatibility_score, 0.3)
	
	# Show a floating indicator for the increase
	if increase > 0:
		show_compatibility_increase(increase)
	

func _on_turn_used(turns: int) -> void:
	print("_on_turn_used")
	print("Date Scene turn_used: ", turns)
	if turns >= player_manager.current_date.max_turns:
		print("Turns > player_manager.current_date.max_turns: ", turns, "::", player_manager.current_date.max_turns)
		end_date()

	
func pose_changer(option, cur_pose):

		
	var x = current_date.poses.size()

	var rand_index = randi_range(0, x-1)
	date_presenter.change_pose(current_date.poses.keys()[rand_index])


func reaction_shower(option, cur_reaction):
	# Generate a random emphasis level between 1 and 3
	var emphasis = randi_range(1, 3)
	
	if cur_reaction == "none":
		date_presenter.show_reaction("exclamation", emphasis)
	elif cur_reaction == "exclamation":
		date_presenter.show_reaction("question", emphasis)
	elif cur_reaction == "question":
		date_presenter.show_reaction("exclamation", emphasis)


func score_keeper(option):

	date_score += score_calculator.calculate_score(option, player_manager.player, player_manager.perks)
	print("SCORE: ", date_score)

	date_presenter.update_scores_sequence(option.score_value, 30, date_score)
	
	
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


func check_success(player_score: float, success_threshold: float):
	print("check_success player_score: ", player_score)
	print("check_success success_threshold: ", success_threshold)

	if player_score >= success_threshold:
		print("check_success DATE SUCCESS")
		print("Adding ", current_date, " to party! ")
		if player_manager:
			print("current_date", current_date)
			player_manager.add_date(current_date)
			party_ui.update_party(player_manager.get_party())
		else:
			print("ERROR player_manager DOES NOT EXIST!!!! IN _on_dialogue_ended success!!!")
	else:
		print("check_success DATE FAILED")


func end_date() -> void:
	if date_over:
		return
	date_over = true

	check_success(date_score, current_date.success_threshold)
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
			get_tree().change_scene_to_file(player_manager.CALENDAR)
		else:
			print("ERROR: No player_manager found!")
			
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
				# Add this line to match what you do with inventory:
				party_ui.set_process_input(party_ui.is_visible())
			else:
				print("Party UI not available")
		print("2 Mouse at: ", get_global_mouse_position())
