# character.gd
extends Node

class_name Character

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
		"Style": 15
	}
	#self.accessory.color.color = ColorType.Colors.BLACK
