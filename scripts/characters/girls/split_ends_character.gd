class_name SplitEndsCharacter
extends DateCharacter


func _init():
	super("Split Ends")
	
	# Set profile information
	self.age = 24
	self.bio = "(pretending to be) reading books lol"
	self.icon_path = "res://image_scenes/split_ends/sprite2/split_ends_sprite.tres"
	# Set interests
	self.interests = [
		"yapping",
		"birds are NOT real!!!",
		"Vintage shopping",
		"fixing up my dads boat ;P"
	]
	self.first_date_path = "res://scenes/ui/dating_scene.tscn";
	# Set personality traits
	self.personality_traits = {
		"extroverted": 0.7,
		"agreeable": 0.5,
		"neurotic": 0.8,
		"conscientious": 0.3,
		"open": 0.6
	}
	
	# Set skills
	self.skills = {
		"Speech": 40,
		"Flirt": 65,
		"Insight": 25,
		"Style": 70,
		"Wit": 35,
		"Size": 100
	}
		
static func create_default() -> SplitEndsCharacter:
	return SplitEndsCharacter.new()


# SplitEnds-specific reactions to items
func check_item_reaction(item: InventoryItem):
	# SplitEnds-specific reactions
	if item is Baggy:
		return "Love bag"
	elif item is Weed:
		return "Hate weed"
	# Default response if no specific reaction
	return "Oh, cool I guess..."
