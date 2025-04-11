class_name DateCharacter
extends Node


signal stats_changed
signal outfit_changed

var personality_traits: Dictionary = {}
var interests: Array = []
var charm: float = .1

var age: int = 0
var bio: String = ""
var icon_path: String = ""
var first_date_path: String = ""
var reaction: String
var skill_scores: Dictionary = {}
var compatibility_weights: Dictionary = {}
var relationship_requirements: Dictionary = {}

var success_threshold: float = 70
var is_in_party: bool = false

func _init(char_name: String):
	self.name = char_name
	self.reaction = "Neutral"
	self.skill_scores = {
		"Culture": 0,
		"Intellect": 0,
		"Seduction": 0,
		"Heart": 0
	}
	self.compatibility_weights = {
		"Culture": 1,
		"Intellect": 1,
		"Seduction": 1,
		"Heart": 1
	}
	self.relationship_requirements = {
		"max_party_size": 6
	}	
	

func calculate_option_score(option, player: PlayerCharacter) -> float:
	var skill_type = option.skill_type  # "Culture", "Intellect", etc.
	var req = option.req  # Required value to select the option
	
	# Get this character's preference weight for this skill
	var preference_weight = compatibility_weights.get(skill_type, 1.0)
	
	# Calculate the score based on weight × threshold
	var score = preference_weight * req
	
	# bonus points for skills far above threshold
	var player_skill = player.get_skill(skill_type)
	if player_skill > req * 1.5:
		score *= 1.2  # 20% bonus for greatly exceeding threshold
	
	return score

func check_item_reaction(item: InventoryItem):
	return "NO REACTIONS"
