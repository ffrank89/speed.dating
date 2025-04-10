class_name Cigs
extends InventoryItem


var PATH = "res://assets/cig_gif/cig1.png";

var ANIMATION_PATH = "res://icons/cigsgif/cigsgif.tscn"

func _init():
	super("cigs", "this gives people cancer which is a disease that people die from painfully but people still smoke them because it feels good and is fun to do socially", PATH, ANIMATION_PATH)
	
static func create_default() -> Cigs:
	return Cigs.new()
