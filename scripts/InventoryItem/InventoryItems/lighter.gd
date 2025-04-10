class_name Lighter
extends InventoryItem


var PATH = "res://assets/loghter.png";

var ANIMATION_PATH = "";

func _init():
	super("lighter", "adds LIGHT to the room (also makes a small controlled fire)", PATH, ANIMATION_PATH)
	
static func create_default():
	return Lighter.new()
