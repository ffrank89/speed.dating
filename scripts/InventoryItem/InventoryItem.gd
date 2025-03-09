class_name InventoryItem
extends Resource

@export var name: String = ""
@export var description: String = ""
@export var icon: String = ""  

func _init(p_name="", p_description="", p_icon=""):
	name = p_name
	description = p_description
	icon = p_icon

func use():
	# Override in subclasses
	pass
