class_name DialogueManager
extends Node

signal dialogue_started(dialogue: DialogueData)
signal dialogue_ended
signal compatibility_changed(value, increase)
signal relationship_hint_given(hint)

var current_dialogue: DialogueData
var dialogue_tree: Dictionary
var active_partner: DateCharacter
var player: PlayerCharacter

# Date scoring
var date_score: float = 0.0
var max_possible_score: float = 0.0

# Load dialogue from JSON
func load_dialogue():
	var json = JSON.new()
	var file = FileAccess.open("res://dialogue/data/test_dialogue_tree.json", FileAccess.READ)
	var json_text = file.get_as_text()
	dialogue_tree = json.parse_string(json_text)
	#print(dialogue_tree)

func start_date_dialogue(partner: DateCharacter, player_char: PlayerCharacter):
	active_partner = partner
	player = player_char
	
	# Reset scoring for new date
	date_score = 0.0
	max_possible_score = 0.0
	
	load_dialogue()
	current_dialogue = get_starting_dialogue()
	emit_signal("dialogue_started", current_dialogue)
	
	# Occasionally provide a relationship hint
	if randf() < 0.3:  # 30% chance at the start
		var hint = active_partner.get_relationship_hint()
		emit_signal("relationship_hint_given", hint)

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
		
		# Handle skill checking
		if option_data.has("skill_check") and not option_data.skill_check.is_empty():
			option.skill_check = option_data.skill_check
			option.skill_type = option_data.skill_check.get("skill", "")
			option.req = option_data.skill_check.get("req", 0)
		elif option_data.has("skill_type") and option_data.has("req"):
			option.skill_type = option_data.skill_type
			option.req = option_data.req
			option.skill_check = {"skill": option_data.skill_type, "req": option_data.req}
		
		# Handle responses
		if option_data.has("responses"):
			option.responses = option_data.responses
		
		# Handle effects
		if option_data.has("success_effect"):
			option.success_effect = option_data.success_effect
		if option_data.has("failure_effect"):
			option.failure_effect = option_data.failure_effect
		
		# Check availability based on player skills
		option.is_available = check_option_availability(option)
		if not option.is_available:
			option.locked_reason = "Requires " + option.skill_type + " " + str(option.req)
		else:
			# Set response based on skill level
			var response_key = "good"
			if player.get_skill(option.skill_type) >= option.req * 1.5:
				response_key = "great"
			option.selected_response = option.responses.get(response_key, "")
		
		options.append(option)
	
	dialogue.options = options
	return dialogue
	
func get_starting_dialogue() -> DialogueData:
	return get_dialogue(dialogue_tree["START_ID"].id)

func select_option(option: DialogueOption):
	if not option.is_available:
		return
	
	# Calculate score impact for this option
	var compatibility_impact = calculate_option_score(option)
	date_score += compatibility_impact
	max_possible_score += 10  # Using 10 as standard max per option
	
	# Calculate percentage for UI
	var compatibility_percentage = 0.0
	if max_possible_score > 0:
		compatibility_percentage = (date_score / max_possible_score) * 100
	
	emit_signal("compatibility_changed", compatibility_percentage, compatibility_impact)
	
	# Apply skill effects if specified
	if option.success_effect.has("Skill") and option.success_effect.has("Effect"):
		var skill = option.success_effect["Skill"]
		var boost = option.success_effect["Effect"]
		if player and boost > 0:
			player.increase_skill(skill, boost)
	
	# Move to next dialogue
	var next_id = option.next_dialogue_id
	if next_id and next_id != "":
		current_dialogue = get_dialogue(next_id)
		if current_dialogue:
			emit_signal("dialogue_started", current_dialogue)
		else:
			end_dialogue()
	else:
		end_dialogue()

func calculate_option_score(option: DialogueOption) -> float:
	if not active_partner or not option.skill_type or option.skill_type.is_empty():
		return 0.0
	
	# Get character's compatibility weight for this skill
	var weight = active_partner.compatibility_weights.get(option.skill_type, 1.0)
	
	# Calculate score based on weight × requirement
	var score = weight * option.req / 10.0  # Normalize to a 0-10 scale
	print("CALCULATE_OPTION_SCORE: weight", weight)
	print("CALCULATE_OPTION_SCORE: score", score)

	# Bonus for greatly exceeding requirement
	var player_skill = player.get_skill(option.skill_type)
	if player_skill >= option.req * 1.5:
		score *= 1.2  # 20% bonus
	
	return score

func check_option_availability(option: DialogueOption) -> bool:
	if option.skill_type.is_empty() or option.req <= 0:
		return true
		
	var player_skill = player.get_skill(option.skill_type)
	return player_skill >= option.req

func end_dialogue():
	# Check if date was successful
	var success = false
	if max_possible_score > 0:
		var success_percentage = (date_score / max_possible_score) * 100
		success = success_percentage >= active_partner.success_threshold
	
	# Store the result 
	if active_partner and active_partner.skill_scores.has("total_score"):
		active_partner.skill_scores["total_score"] = date_score
	
	# Print result for debugging
	if success:
		print("Date successful! Score: ", date_score, "/", max_possible_score, 
			" (", (date_score / max_possible_score) * 100, "%)")
	else:
		print("Date unsuccessful. Score: ", date_score, "/", max_possible_score,
			" (", (date_score / max_possible_score) * 100, "%)")
	
	# Emit signal to notify that dialogue has ended
	emit_signal("dialogue_ended")
