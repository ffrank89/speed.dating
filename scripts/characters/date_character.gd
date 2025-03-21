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
	print()
	return self.skills.get(skill_name, 0)

func check_item_reaction(item: InventoryItem):
	return "NO REACTIONS"
