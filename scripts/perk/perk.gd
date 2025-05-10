class_name Perk
extends Resource

@export var name: String = ""
@export var description: String = ""
@export var animation: String = ""
#TODO
#ADD EFFECTS FIELDS OR AN EFFECTS DICTIONARY
func _init(p_name="", p_description="", p_animation=""):
	name = p_name
	description = p_description
	animation = p_animation

func use():
	# Override in subclasses
	pass
