class_name SplitEndsCharacter
extends DateCharacter


func _init():
	super("Split Ends")
	
	# Set profile information
	self.age = 24
	self.bio = "(pretending to be) reading books lol"
	self.icon_path = "res://image_scenes/split_ends_ui/sprite2/split_ends_sprite.tres"
	self.poses = {
		"concerned": "res://assets/green_girl/beauit.png",
		"happy": "res://assets/green_girl/reach.png",
		"normal": "res://assets/green_girl/parker.png",
	}
	# Set interests
	self.interests = [
		"yapping",
		"birds are NOT real!!!",
		"Vintage shopping",
		"fixing up my dads boat ;P"
	]
	self.first_date_path = "res://scenes/Dates/BaseDate/dating_scene.tscn";
	self.first_date_background = "res://assets/bedroom1.png"
	# Set personality traits
	self.personality_traits = {
		"extroverted": 0.7,
		"agreeable": 0.5,
		"neurotic": 0.8,
		"conscientious": 0.3,
		"open": 0.6
	}
	self.compatibility_weights = {
		"Culture": 0.2,
		"Intellect": 0.3,
		"Seduction": 0.3,
		"Heart": 0.2
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
