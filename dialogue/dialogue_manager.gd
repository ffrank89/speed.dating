# dialogue_manager.gd
class_name DialogueManager
extends Node

signal dialogue_started(dialogue: DialogueData)
signal dialogue_ended
signal option_selected(option: DialogueOption)

var current_dialogue: DialogueData
var dialogue_tree: Dictionary
var active_partner: Character
var player: Character

# Load dialogue from JSON
func load_dialogue():
	var json = JSON.new()
	var file = FileAccess.open("res://dialogue/data/test_dialogue_tree.json", FileAccess.READ)
	var json_text = file.get_as_text()
	dialogue_tree = json.parse_string(json_text)
	#print(dialogue_tree)

func start_date_dialogue(partner: Character, player_char: Character):
	active_partner = partner
	player = player_char
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
		option.skill_check = option_data.skill_check if option_data.has("skill_check") else {}
		option.success_effect = option_data.success_effect if option_data.has("success_effect") else {}
		option.failure_effect = option_data.failure_effect if option_data.has("failure_effect") else {}
		options.append(option)
	
	dialogue.options = options
	return dialogue
	
func get_starting_dialogue() -> DialogueData:
	return get_dialogue(dialogue_tree["START_ID"].id)

func create_option(hint: String, next_id: String, skill_check: Dictionary = {}) -> DialogueOption:
	var option = DialogueOption.new()
	option.hint_text = hint
	option.next_dialogue_id = next_id
	option.skill_check = skill_check
	if skill_check:
		option.success_effect = {"compatibility": 0.2}
		option.failure_effect = {"compatibility": -0.1}
	else:
		option.success_effect = {"compatibility": 0.05}
	return option

func select_option(option: DialogueOption):
	# Check if option passes skill check
	var success = true
	if option.skill_check:
		success = check_skill(option.skill_check)

	# Apply effects
	if success:
		apply_effects(option.success_effect)
	else:
		apply_effects(option.failure_effect)

	# Get next dialogue
	current_dialogue = get_dialogue(option.next_dialogue_id)
	if current_dialogue:
		emit_signal("dialogue_started", current_dialogue)
	else:
		emit_signal("dialogue_ended")

func check_skill(skill_check: Dictionary) -> bool:
	print("Skill check", skill_check)
	return player.skills[skill_check.skill] >= skill_check.req

func apply_effects(effects: Dictionary):
	if effects.has("compatibility"):
		active_partner.modify_compatibility(effects.compatibility)
