extends Node

signal item_selected(item)
signal date_selected(date)
signal day_advanced(new_day, new_month)

var player: PlayerCharacter
var selected_date: DateCharacter
var inventory: Array = []
var party: Array = []

var DATE_SELECT = "res://scenes/Tinder/Screen.tscn"
var STATS_SELECT = "res://scenes/Intro/IntroQuestions.tscn"
var CALENDAR = "res://scenes/Calendar/calendar.tscn"


# Calendar state
var current_day: int = 1
var current_month: int = 1
var days_in_month = 30  # Simplified - all months have 30 days
var month_names = ["January", "February", "March", "April", "May", "June", 
"July", "August", "September", "October", "November", "December"]


var available_actions = {}
# Add an item to the inventory
func add_item(item: InventoryItem) -> bool:
	if item:
		inventory.append(item)
		print("Added item to inventory: ", item.name)
		return true
	return false

# Add date to party
func add_date(date: DateCharacter) -> bool:
	if date:
		party.append(date)
		print("Added date to party: ", date.name)
		return true
	return false
	
func set_player(new_player: PlayerCharacter):
	player = new_player
	
func get_player() -> PlayerCharacter:
	return player

# Get the full inventory
func get_inventory() -> Array:
	return inventory
	
func select_item(item: InventoryItem):
	# Emit a global signal
	emit_signal("item_selected", item)
	print("PlayerManager: Item selected: ", item.name)

func select_date(date: DateCharacter):
	# Emit a global signal
	emit_signal("date_selected", date)
	print("PlayerManager: Date selected: ", date.name)
	
func initialize_inventory():
	# Clear any existing items
	inventory.clear()
	
	# Add default items
	var bag = Baggy.create_default()
	var weed = Weed.create_default()
	var cigs = Cigs.create_default()
	var lighter = Lighter.create_default()
	add_item(bag)
	add_item(weed)
	add_item(cigs)
	add_item(lighter)

func get_party() -> Array:
	return party  

func initialize_party():
	#Clear any existing dates
	#party.clear()
	print("PlayerManager: Party initialized with", party.size(), "characters")

func advance_day():
	current_day += 1
	print("current_day: ", current_day)
	# Check if we need to move to the next month
	if current_day > days_in_month:
		current_day = 1
		current_month += 1
		
		# Wrap to January if we go past December
		if current_month > 12:
			current_month = 1
	
	print("Day advanced to", current_day, "of", month_names[current_month - 1])
	emit_signal("day_advanced", current_day, current_month)

# Handle action selected from calendar
func calendar_action(action):
	print("action", action)
	
	# Advance the day for the next time the calendar is opened
	advance_day()
	
	# Change to the action scene
	get_tree().change_scene_to_file(action[0].scene)
