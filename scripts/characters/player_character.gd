class_name PlayerCharacter
extends Node


signal stats_changed
signal outfit_changed

var personality_traits: Dictionary = {}
var charm: float = .1

var age: int = 0
var bio: String = ""
var icon_path: String = ""
var skills: Dictionary
var reaction: String


func _init(char_name: String):
	self.name = char_name
	self.skills = {
		"Culture": 0,
		"Intellect": 0,
		"Seduction": 0,
		"Heart": 0
	}
	self.reaction = "Neutral"
	

func get_skill_level(skill: String):
	print("get_skill_level: ", self.skills)
	return self.skills[skill]
	
func get_skills():
	return self.skills
	
func increase_skill(skill_name: String, amount):
	_increase_skill_add(skill_name, amount)

func _increase_skill_add(skill_name: String, amount: int):
	if self.skills.has(skill_name):
		print("Increase skill add, ADDING")
		self.skills[skill_name] += amount
	else:
		print("Increase skill add, EQIAL")

		self.skills[skill_name] = amount
	
	emit_signal("stats_changed")

func get_skill(skill_name: String) -> int:
	return self.skills.get(skill_name, 0)

func check_item_reaction(item: InventoryItem):
	return "NO REACTIONS"
