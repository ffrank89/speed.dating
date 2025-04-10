class_name InventoryItem
extends Resource

@export var name: String = ""
@export var description: String = ""
@export var icon: String = ""  
@export var animation: String = ""

func _init(p_name="", p_description="", p_icon="", p_animation=""):
	name = p_name
	description = p_description
	icon = p_icon
	animation = p_animation

func use():
	# Override in subclasses
	pass
