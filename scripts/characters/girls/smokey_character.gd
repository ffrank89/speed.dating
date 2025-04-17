class_name SmokeyCharacter
extends DateCharacter


func _init():
	super("Smokey")
	
	self.age = 24
	self.bio = "friends made me get on here but im indaa not opposed rn!"
	self.icon_path = "res://image_scenes/smokey/smokey_sprite/smokey_sprite.tres"
	self.poses = {
		"normal": "res://assets/green_girl/beauit.png",
		"happy": "res://assets/green_girl/reach.png",
		"concerned": "res://assets/green_girl/parker.png",
	}
	# Set interests
	self.interests = [
		"weed",
		"and",
		"smoken it ",
		"frogs in the park"
	]
	self.first_date_path = "res://scenes/Dates/BaseDate/dating_scene.tscn";
	self.first_date_background = "res://assets/background 2.png"

	# Set personality traits
	self.personality_traits = {
		"extroverted": 0.0,
		"agreeable": 0.0,
		"neurotic": 0.0,
		"conscientious": 0.0,
		"open": 0.0
	}
		
static func create_default() -> SmokeyCharacter:
	return SmokeyCharacter.new()


# SplitEnds-specific reactions to items
func check_item_reaction(item: InventoryItem):
	# First check parent class for common reactions
	var base_reaction = super.check_item_reaction(item)
	if base_reaction:
		return base_reaction
		
	# SplitEnds-specific reactions
	if item is Baggy:
		return "Yeah I really just dont like that stuff"
	elif item is Weed:
		return "I KNEW i smelled that haahaha  "
	# Default response if no specific reaction
	return "Oh, cool I guess..."
