extends Control
class_name PerkBorder

var player_manager: PlayerManager
@onready var right_container = $RightContainer

# Arrays to store slot references
var top_slots = []
var left_slots = []
var right_slots = []
var bottom_slots = []
var all_slots = []

# All containers in an array for easy access
var containers = []

# Perk icon scene to instance
var perk_icon_scene = preload("res://icon_scenes/perk_icon/PerkIcon.tscn")

# Configuration
var icon_size = Vector2(64, 64)
var slots_per_container = 7

# Active perks
var active_perks = []
var occupied_slots = []

func _ready():
	
	player_manager = get_node_or_null("/root/PlayerManager")
	player_manager.connect("perk_added", Callable(self, "_on_perk_added"))
	
	# Initialize our containers array
	containers = [right_container]

	
	# Initialize slot arrays
	initialize_slot_arrays()
	

func initialize_slot_arrays():
	
	# Get references to slots from the editor
	for i in range(slots_per_container):
		var slot_name = "Slot" + str(i)

		# Right container slots
		if right_container.has_node(slot_name):
			right_slots.append(right_container.get_node(slot_name))

	# Combine all slots into one array for easy access
	all_slots = top_slots + right_slots + bottom_slots + left_slots
	
	print("Initialized ", all_slots.size(), " slots")

func add_perk(perk_data: Perk):

	# Find an available slot
	var target_slot = choose_random_available_slot()
	
	if target_slot:
		# Create the icon
		var icon = perk_icon_scene.instantiate()
		icon.setup(perk_data)
		
		# Add to the selected slot
		target_slot.add_child(icon)
		
		# Mark slot as occupied
		occupied_slots.append(target_slot)
		
		# Add to active perks
		active_perks.append(perk_data)
		
		# Add pop-in animation
		icon.scale = Vector2(0.1, 0.1)  # Start small
		var tween = create_tween()
		tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		
		print("Added perk to slot", target_slot.name)
		return true
	else:
		print("ERROR: No available slots for new perk")
		return false

func choose_random_available_slot():
	# Collect slots that aren't occupied
	var available_slots = []
	
	for slot in all_slots:
		if not slot in occupied_slots:
			available_slots.append(slot)
	
	if available_slots.size() > 0:
		# Choose a random slot from the available ones
		return available_slots[randi() % available_slots.size()]
	
	return null
	
func _on_perk_added(perk_data: Perk):
	print("_on_perk_added: ", perk_data.animation)
	add_perk(perk_data)

# Helper function to add a perk to a specific slot
func add_perk_to_slot(perk_data, slot):
	# Create the icon
	var icon = perk_icon_scene.instantiate()
	icon.setup(perk_data)
	
	# Add to the specified slot
	slot.add_child(icon)
	
		
	# Mark slot as occupied
	occupied_slots.append(slot)
	active_perks.append(perk_data)
	
	## Add pop-in animation
	icon.scale = Vector2(0.1, 0.1)  # Start small
	var tween = create_tween()
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
