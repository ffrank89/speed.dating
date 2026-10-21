class_name PlayerCharacter
extends RefCounted
## The player: their name and attributes (skills: "Culture", "Intellect", "Seduction",
## "Heart" → 1-9, the scale in data/attribute_rules.tres). Made by the intro (or
## PlayerManager.ensure_player()).

signal stats_changed

var name: String
var skills: Dictionary


func _init(char_name: String) -> void:
	name = char_name
	skills = {
		"Culture": 0,
		"Intellect": 0,
		"Seduction": 0,
		"Heart": 0
	}


func get_skills() -> Dictionary:
	return skills


func get_skill(skill_name: String) -> int:
	return skills.get(skill_name, 0)


# Training raises it (or lowers it), never past the scale's Lowest or Highest.
func increase_skill(skill_name: String, amount: int) -> void:
	skills[skill_name] = Attr.rules().clamp_value(skills.get(skill_name, 0) + amount)
	stats_changed.emit()
