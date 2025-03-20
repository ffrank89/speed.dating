# character.gd
class_name Character
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
var pant: Pant
var shirt: Shirt
var accessory: Accessory
var skills: Dictionary
var reaction: String

func _init(char_name: String):
	self.name = char_name
	self.pant = Pant.create_random() as Pant
	self.shirt = Shirt.create_random() as Shirt
	self.accessory = Accessory.create_random() as Accessory
	self.skills = {
		"Speech": 0,
		"Flirt": 0,
		"Insight": 0,
		"Style": 0,
		"Size": 0,
		"Wit": 0
	}
	self.reaction = "Neutral"
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
	
func increase_skill(skill_name: String, amount):
	if amount is int:
		_increase_skill_add(skill_name, amount)
	elif amount is float:
		_increase_skill_mult(skill_name, amount)

func _increase_skill_add(skill_name: String, amount: int):
	if skills.has(skill_name):
		skills[skill_name] += amount
	else:
		skills[skill_name] = amount
	
	emit_signal("stats_changed")

func _increase_skill_mult(skill_name: String, amount: float):
	if skills.has(skill_name):
		var h = skills[skill_name]
		skills[skill_name] = int(h*(amount))
	else:
		print("TODO logic for when new skill introduced as mult")
		#TODO logic for when new skill introduced as mult
		skills[skill_name] = amount
	
	emit_signal("stats_changed")

func get_skill(skill_name: String) -> int:
	return skills.get(skill_name, 0)

func check_item_reaction(item: InventoryItem):
	if item is Baggy:
		if self.skills["Wit"] < 10:
			return "Like sooo down"
		else:
			return "Aren't you like thirty...?"
	elif item is Weed:
		if self.skills["Insight"] < 100:
			return "OMg can we watch youtube too"
		else:
			return "That gets me in my head these days"
