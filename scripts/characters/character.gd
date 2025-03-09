# character.gd
class_name Character
extends Node


signal stats_changed
signal outfit_changed

var personality_traits: Dictionary = {}
var interests: Array = []
var charm: float = .1

var pant: Pant
var shirt: Shirt
var accessory: Accessory
var skills: Dictionary

func _init(char_name: String):
	self.name = char_name
	self.pant = Pant.create_random() as Pant
	self.shirt = Shirt.create_random() as Shirt
	self.accessory = Accessory.create_random() as Accessory
	skills = {
		"Speech": 25,
		"Flirt": 30,
		"Insight": 20,
		"Style": 15,
		"Size": 100,
		"Wit": 20
	}
	#self.accessory.color.color = ColorType.Colors.BLACK
	
	

func change_outfit_piece(piece_type: String, new_piece):
	match piece_type.to_lower():
		"pant", "pants":
			pant = new_piece
		"shirt":
			shirt = new_piece
		"accessory", "accessories":
			accessory = new_piece
	
	emit_signal("outfit_changed")
	
func get_skill_level(skill: String):
	return self.skills[skill]
	
func increase_skill(skill_name: String, amount: int):
	if skills.has(skill_name):
		skills[skill_name] += amount
	else:
		skills[skill_name] = amount
	
	emit_signal("stats_changed")

func get_skill(skill_name: String) -> int:
	return skills.get(skill_name, 0)
