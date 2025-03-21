class_name Weed
extends InventoryItem


var PATH = "res://assets/weed.png";

func _init():
	super("weed", "it comes from the earth", PATH)
	
static func create_default() -> Weed:
	return Weed.new()
