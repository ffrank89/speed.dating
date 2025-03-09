extends Node

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
	
