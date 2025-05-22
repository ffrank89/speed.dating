class_name ScoreCalculator
extends Node

# Constants for score values
const SCORE_GREAT = 40
const SCORE_GOOD = 20
const SCORE_MEH = 1
const SCORE_BAD = -10

# Calculate the score for a dialogue option
func calculate_score(option: DialogueOption, player: PlayerCharacter, active_perks: Array) -> int:
	print("calculate_score: active_perks: ", active_perks)
	# Get the base score from the option
	var base_score = option.score_value
	
	# Apply perk modifiers
	var modified_score = apply_perk_modifiers(base_score, active_perks)
	
	
	## Apply stat multipliers if we have a dialogue type
	if option.skill_check["skill"] != "":
		print("option.skill_check", option.skill_check["skill"])
		modified_score = apply_stat_multipliers(modified_score, option.skill_check["skill"], player)
	
	return modified_score

# Apply modifiers from active perks
func apply_perk_modifiers(score: int, active_perks: Array) -> int:
	var modified_score = score
	
	for perk in active_perks:
		print("perk: ", perk.name)
		# Example: Inebriated perk
		if perk is Inebriated:
			if score > 0:
				modified_score *= 2  # Positive scores multiplied by 2
			elif score == SCORE_MEH:
				modified_score = -1  # Meh scores become -1
			elif score < 0:
				modified_score *= 2  # Negative scores multiplied by 2
		if perk is Sleepy:
			# Implement Sleepy perk effects
			# For example: "Forgiveness UP" might mean negative scores are less severe
			if score < 0:
				modified_score = score / 2  # Reduce negative impact
	
	return modified_score

# Apply stat multipliers based on dialogue type
func apply_stat_multipliers(score: int, dialogue_type: String, player: PlayerCharacter) -> int:
	var stat_value = player.get_skill(dialogue_type)
	
	# Calculate multiplier: 1.0 + (stat_value / 100)
	# Example: stat of 50 gives 1.5x multiplier
	var multiplier = 1.0 + (float(stat_value) / 100.0)
	
	print("apply_stat_multipliers, multiplier, ", multiplier)
	# Apply the multiplier
	return int(score * multiplier) 
	
	
func print_shit():
	print("SHIt")
