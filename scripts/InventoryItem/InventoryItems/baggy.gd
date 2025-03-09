class_name Baggy
extends InventoryItem


var PATH = "res://assets/drugs.png";

func _init():
	super("bag", "does this smell like drugs to you?", PATH)
	
static func create_default() -> Baggy:
	return Baggy.new()
