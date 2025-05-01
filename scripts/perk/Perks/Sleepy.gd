class_name Sleepy
extends Perk


func _init():
	
	var name = "Sleepy"
	var description = "Awww you're fine ... (Forgiveness UP)"
	var animation = "sleepy"
	super(name, description, "sleepy")

static func create_default() -> Sleepy:
	return Sleepy.new()
