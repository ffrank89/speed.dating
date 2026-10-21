class_name PlayerCharacter
extends RefCounted
## The player: their name, their four attributes ("Culture", "Intellect", "Seduction",
## "Heart") and their skills (data/skills.tres: "speech", "barter"...), all on the 1-9
## scale in data/attribute_rules.tres. Made by the intro (or
## PlayerManager.ensure_player()).

signal stats_changed

var name: String
## Attribute name ("Culture") → 1-9.
var attributes: Dictionary
## Skill id (&"speech") → 1-9. Every skill in data/skills.tres, on or off, so turning one
## on mid-run just works.
var skills: Dictionary


func _init(char_name: String) -> void:
	name = char_name
	attributes = {
		"Culture": 0,
		"Intellect": 0,
		"Seduction": 0,
		"Heart": 0
	}
	skills = {}
	for skill in SkillList.get_default().skills:
		if skill:
			skills[skill.id] = skill.starting_value


func get_attribute(attribute_name: String) -> int:
	return attributes.get(attribute_name, 0)


# Training raises it (or lowers it), never past the scale's Lowest or Highest.
func raise_attribute(attribute_name: String, amount: int) -> void:
	attributes[attribute_name] = Attr.rules().clamp_value(attributes.get(attribute_name, 0) + amount)
	stats_changed.emit()


## The skill's value. A skill the player hasn't got yet starts at its Starting Value.
func get_skill(skill: PlayerSkill) -> int:
	return skills.get(skill.id, skill.starting_value)


# Raises (or lowers) a skill, never past the scale's Lowest or Highest.
func raise_skill(skill: PlayerSkill, amount: int) -> void:
	skills[skill.id] = Attr.rules().clamp_value(get_skill(skill) + amount)
	stats_changed.emit()
