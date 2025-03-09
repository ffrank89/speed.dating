class_name SplitEndsCharacter
extends Character


func _init():
	super("split ends")
	
static func create_default() -> SplitEndsCharacter:
	return SplitEndsCharacter.new()
