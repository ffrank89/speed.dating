class_name PlayerCharacter
extends RefCounted
## The player: their name and attributes (skills: "Culture", "Intellect", "Seduction",
## "Heart" → 0-100). Made by the intro (or PlayerManager.ensure_player()).

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


func increase_skill(skill_name: String, amount: int) -> void:
	skills[skill_name] = skills.get(skill_name, 0) + amount
	stats_changed.emit()
