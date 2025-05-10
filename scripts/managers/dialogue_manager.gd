class_name DialogueManager
extends Node

signal dialogue_started(dialogue: DialogueData)
signal dialogue_ended(success: bool)
signal compatibility_changed(value, increase)
signal turn_used(turns: int)

var current_dialogue: DialogueData
var dialogue_tree: Dictionary
var active_partner: DateCharacter
var player: PlayerCharacter

# Date scoring
var date_score: float = 0.0

var click_sound: AudioStreamPlayer

var turns_used: int = 0

# Load dialogue from JSON
func load_dialogue():
	var json = JSON.new()
	var file = FileAccess.open("res://dialogue/data/cursor_json.json", FileAccess.READ)
	var json_text = file.get_as_text()
	dialogue_tree = json.parse_string(json_text)
	
func start_date_dialogue(partner: DateCharacter, player_char: PlayerCharacter):
	active_partner = partner
	player = player_char
	
	# Reset scoring for new date
	date_score = 0.0

	if not click_sound:
		click_sound = AudioStreamPlayer.new()
		add_child(click_sound)
		var sound = load("res://assets/audio/clicks/clickApr42025.ogg")
		print("Before SOUND")

		if sound:
			print("SOUND")
			click_sound.stream = sound
	
	load_dialogue()
	current_dialogue = get_starting_dialogue()
	emit_signal("dialogue_started", current_dialogue)

func get_dialogue(dialogue_id: String) -> DialogueData:
	if not dialogue_tree.has(dialogue_id):
		return null
		
	var data = dialogue_tree[dialogue_id]
	var dialogue = DialogueData.new()
	dialogue.id = data.id
	dialogue.text = data.text
	
	# Convert each option in the JSON to DialogueOption objects
	var options: Array[DialogueOption] = []
	for option_data in data.options:
		var option = DialogueOption.new()
		option.hint_text = option_data.hint_text
		option.next_dialogue_id = option_data.next_dialogue_id
		option.score_value = option_data.score_value
		# Handle skill checking - keep your original structure
		if option_data.has("skill_check"):
			option.skill_check = option_data.skill_check
		
		# Handle effects - keep your original structure
		if option_data.has("success_effect"):
			option.success_effect = option_data.success_effect
		if option_data.has("failure_effect"):
			option.failure_effect = option_data.failure_effect
		
		options.append(option)
	
	dialogue.options = options
	return dialogue
	
func get_starting_dialogue() -> DialogueData:
	return get_dialogue(dialogue_tree["START_ID"].id)

func select_option(option: DialogueOption):
	# Check if option passes skill check

	if click_sound and click_sound.stream:
		print("Yes Click sound select_option")
		click_sound.play()

	var success = true
	var skill_type = ""
	var req = 0
	
	if option.skill_check:
		skill_type = option.skill_check.skill
		req = option.skill_check.req
		success = check_skill(option.skill_check)
		print("SKILL CHECK: ", skill_type, req, success)
	
	print("Option: ", option.hint_text, "Score: ", option.score_value)
	
	# Calculate compatibility impact
	if success and skill_type != "":
		var compatibility_impact = calculate_compatibility_impact(skill_type, req)
		date_score += compatibility_impact
		
		# Calculate percentage for UI
		var compatibility_percentage = 0.0
		compatibility_percentage = (date_score) * 100
		
		emit_signal("compatibility_changed", compatibility_percentage, compatibility_impact)
	
	#Increment turns used
	turns_used += 1
	print("\n turns_used: ", turns_used)
	emit_signal("turn_used", turns_used)

	# Get next dialogue
	current_dialogue = get_dialogue(option.next_dialogue_id)
	if current_dialogue:
		emit_signal("dialogue_started", current_dialogue)
	else:
		end_dialogue()

func check_skill(skill_check: Dictionary) -> bool:
	if player and "skill" in skill_check and "req" in skill_check:
		var player_skill = player.get_skill(skill_check.skill)
		return player_skill >= skill_check.req
	return true  # Default to success if no valid skill check

func calculate_compatibility_impact(skill_type: String, req: int) -> float:
	print("\n\nIN calculate_compatibility_impact\n\n")
	if not active_partner or skill_type.is_empty() or req <= 0:
		return 0.0
	
	# Get character's compatibility weight for this skill
	var weight = active_partner.compatibility_weights.get(skill_type, 1.0)
	
	# Calculate score based on weight × requirement
	var impact = weight * req / 10.0  # Normalize to a 0-10 scale
	
	# Bonus for greatly exceeding requirement
	var player_skill = player.get_skill(skill_type)
	if player_skill >= req * 1.5:
		impact *= 1.2  # 20% bonus
	print("\nEND calculate_compatibility_impact. Impact: ", impact)
	return impact

func apply_effects(effects: Dictionary):
	## Apply compatibility (kept for backward compatibility)
	#if effects.has("compatibility"):
		#active_partner.modify_compatibility(effects.compatibility)
	#
	## Apply skill effects if specified
	#if effects.has("Skill") and effects.has("Effect") and player:
		#var skill = effects["Skill"]
		#var boost = effects["Effect"]
		#if boost > 0:
			#player.increase_skill(skill, boost)
			
	pass

func end_dialogue():
	# Check if date was successful
	var success = false
	var success_percentage = (date_score) * 100
	success = success_percentage >= active_partner.success_threshold
	
	# Store the result 
	if active_partner.skill_scores.has("total_score"):
		active_partner.skill_scores["total_score"] = date_score
	
	# Print result for debugging
	if success:
		print("Date successful! Score: ",
			" (", (date_score ) * 100, "%)")
	else:
		print("Date unsuccessful. Score: ", 
			" (", (date_score) * 100, "%)")
	
	# Emit signal to notify that dialogue has ended
	emit_signal("dialogue_ended", success)
