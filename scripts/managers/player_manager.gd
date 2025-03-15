extends Node

signal item_selected(item)


var player: Character
# Store inventory items
var inventory: Array = []

# Add an item to the inventory
func add_item(item: InventoryItem) -> bool:
	if item:
		inventory.append(item)
		print("Added item to inventory: ", item.name)
		return true
	return false
	
func set_player(new_player: Character):
	player = new_player
	
func get_player() -> Character:
	return player

# Get the full inventory
func get_inventory() -> Array:
	return inventory
	
# New method to handle item selection
func select_item(item: InventoryItem):
	# Emit a global signal that any character can listen for
	emit_signal("item_selected", item)
	print("PlayerManager: Item selected: ", item.name)


# Initialize with default items
func initialize_inventory():
	# Clear any existing items
	inventory.clear()
	
	# Add default items
	var bag = Baggy.create_default()
	var weed = Weed.create_default()
	add_item(bag)
	add_item(weed)

	
