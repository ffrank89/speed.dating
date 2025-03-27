extends Node

signal item_selected(item)
signal date_selected(date)

var player: PlayerCharacter
var selected_date: DateCharacter
var inventory: Array = []
var party: Array = []
var SCENE = "res://scenes/Tinder/Screen.tscn"

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
	add_item(bag)
	add_item(weed)

func get_party() -> Array:
	return party  

func initialize_party():
	#Clear any existing dates
	#party.clear()
	print("PlayerManager: Party initialized with", party.size(), "characters")
