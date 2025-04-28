extends Control
class_name PerkBorder

# References to containers for each edge
@onready var top_container = $TopContainer
@onready var left_container = $LeftContainer
@onready var right_container = $RightContainer
@onready var bottom_container = $BottomContainer

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
	# Initialize our containers array
	containers = [top_container, right_container, bottom_container, left_container]

	
	# Initialize slot arrays
	initialize_slot_arrays()
	
	# Set up default perks
	setup_default_perks()

func initialize_slot_arrays():
	
	# Get references to slots from the editor
	for i in range(slots_per_container):
		var slot_name = "Slot" + str(i)
		
		## Top container slots
		#if top_container.has_node(slot_name):
			#top_slots.append(top_container.get_node(slot_name))
		#
		## Left container slots
		#if left_container.has_node(slot_name):
			#left_slots.append(left_container.get_node(slot_name))
		#
		# Right container slots
		if right_container.has_node(slot_name):
			right_slots.append(right_container.get_node(slot_name))
		
		## Bottom container slots
		#if bottom_container.has_node(slot_name):
			#bottom_slots.append(bottom_container.get_node(slot_name))
	
	

	# Combine all slots into one array for easy access
	all_slots = top_slots + right_slots + bottom_slots + left_slots
	
	print("Initialized ", all_slots.size(), " slots")

func add_perk(perk_data):
	# Make a copy of the perk data to avoid reference issues
	var perk_copy = perk_data.duplicate()
	
	# Find an available slot
	var target_slot = choose_random_available_slot()
	
	if target_slot:
		# Create the icon
		var icon = perk_icon_scene.instantiate()
		icon.setup(perk_copy)
		
		# Add to the selected slot
		target_slot.add_child(icon)
		
		# Mark slot as occupied
		occupied_slots.append(target_slot)
		
		# Add to active perks
		active_perks.append(perk_copy)
		
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

func remove_perk(perk_id):
	# Find the perk by ID
	var index_to_remove = -1
	for i in range(active_perks.size()):
		if active_perks[i].id == perk_id:
			index_to_remove = i
			break
	
	if index_to_remove >= 0:
		# Remove the perk from our array
		active_perks.remove_at(index_to_remove)
		
		# Find the visual representation to remove
		for slot in occupied_slots:
			# Skip corner slots (which have Panel children, not PerkIcon)
			if slot.get_child_count() == 0 or not slot.get_child(0) is Control or "perk_data" not in slot.get_child(0):
				continue
				
			var icon = slot.get_child(0)
			if icon.perk_data.id == perk_id:
				# Add a fade-out animation
				var tween = create_tween()
				tween.tween_property(icon, "modulate", Color(1, 1, 1, 0), 0.3)
				tween.tween_callback(func(): 
					icon.queue_free()
					# Mark slot as available again
					occupied_slots.erase(slot)
				)
				return true
	
	return false

func update_perk(perk_id, new_data):
	# Find the perk by ID
	for i in range(active_perks.size()):
		if active_perks[i].id == perk_id:
			# Update our data
			active_perks[i] = new_data.duplicate()
			
			# Find and update the visual representation
			for slot in occupied_slots:
				# Skip corner slots
				if slot.get_child_count() == 0 or not slot.get_child(0) is Control or "perk_data" not in slot.get_child(0):
					continue
					
				var icon = slot.get_child(0)
				if icon.perk_data.id == perk_id:
					icon.setup(new_data)
					icon.pulse()  # Add visual feedback
					return true
	
	return false

func get_perk(perk_id):
	# Find the perk by ID
	for perk in active_perks:
		if perk.id == perk_id:
			return perk
			
	return null

func clear_perks():
	# Clear all perks but leave default perks
	var perks_to_remove = []
	
	for perk in active_perks:
		if not perk.has("is_default") or not perk.is_default:
			perks_to_remove.append(perk.id)
	
	for perk_id in perks_to_remove:
		remove_perk(perk_id)

func setup_default_perks():
	## Create default perks for the corners
	
	var beer = create_default_perk("beer", "beer", "Inebriated stat.", "beer")
	var culture = create_default_perk("culture", "culture", "culture stat.", "culture")
	var generosity = create_default_perk("generosity", "generosity", "generosity stat.", "generosity")
	var high = create_default_perk("high", "high", "high stat.", "high")
	var love = create_default_perk("love", "love", "love stat.", "love")
	var radiation = create_default_perk("radiation", "radiation", "radiation stat.", "radiation")
	var sleepy = create_default_perk("sleepy", "sleepy", "sleepy stat.", "sleepy")

		

	add_perk_to_slot(beer, right_slots[0])
	add_perk_to_slot(culture, right_slots[1])
	add_perk_to_slot(generosity, right_slots[2])
	add_perk_to_slot(high, right_slots[3])
	add_perk_to_slot(love, right_slots[4])
	add_perk_to_slot(radiation, right_slots[5])
	add_perk_to_slot(sleepy, right_slots[6])



# Helper function to create a default perk
func create_default_perk(id, name, description, type):
	return {
		"id": id,
		"name": name,
		"description": description,
		"type": type,
		"duration": -1,  # Permanent
		"is_default": true  # Flag to identify default perks
	}

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
