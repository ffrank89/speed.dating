class_name Inebriated
extends Perk


func _init():
	
	var name = "Inebriated"
	var description = "Success is better. Mistakes are worse."
	var animation = "beer"
	super(name, description, animation)
	
static func create_default() -> Inebriated:
	return Inebriated.new()
