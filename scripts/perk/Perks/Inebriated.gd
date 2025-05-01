class_name Inebriated
extends Perk


func _init():
	
	var name = "Inebriated"
	var description = "Success is better. Mistakes are worse. "
	super("bag", "does this smell like drugs to you?", "beer")
	
static func create_default() -> Inebriated:
	return Inebriated.new()
