extends Node

signal item_selected(item)
signal date_selected(date)
signal day_advanced(new_day, new_month)
signal perk_added(perk)
## A girl joined your party (her contact was saved), or her hearts changed.
signal party_changed

var player: PlayerCharacter
var current_date: DateCharacter

var inventory: Array = []
## Your party: the girls who gave you their number, saved as contacts in your phone
## (the Contacts app, scenes/Phone/Contacts/). One PartyMember each.
var party: Array[PartyMember] = []
## Girls whose first date failed: they're gone for the rest of the run.
var gone_for_run: Array = []

var perks: Array = []

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
var perk_viewport


func _ready() -> void:
	#TODO , do this somewhere else lol.
	self.initialize_inventory()
	self.initialize_party()
	self.initialize_perks()
# Add an item to the inventory
func add_item(item: InventoryItem) -> bool:
	if item:
		inventory.append(item)
		print("Added item to inventory: ", item.name)
		return true
	return false

# She gave you her number: she's saved in your contacts with the hearts she gave you.
# Already there = her hearts go up if this date went better.
func add_party_member(girl: GirlData, affection: int, profile: DateCharacter = null) -> PartyMember:
	for member in party:
		if member.girl == girl:
			member.affection = maxi(member.affection, affection)
			party_changed.emit()
			return member
	var member := PartyMember.new(girl, affection, profile)
	party.append(member)
	print("Added to party (saved in contacts): ", member.display_name())
	party_changed.emit()
	return member


# True if the girl with this dating-app name is in your party.
func is_in_party(date_name: String) -> bool:
	return party.any(func(member: PartyMember) -> bool: return member.profile and member.profile.name == date_name)


# A failed first date: she's gone for the rest of the run (the dating app skips her).
func mark_gone(date: DateCharacter) -> void:
	if date and not date in gone_for_run:
		gone_for_run.append(date)
		print("Gone for the run: ", date.name)


func is_gone(date_name: String) -> bool:
	return gone_for_run.any(func(date: DateCharacter) -> bool: return date.name == date_name)


func add_perk(perk):
	if perk:
		perks.append(perk)
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
	current_date = date
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

func get_party() -> Array[PartyMember]:
	return party

func initialize_party():
	#TODO this is a beta system -Clear any existing dates
	party.clear()
	print("PlayerManager: Party initialized with", party.size(), "characters")



func initialize_perks():
	var beer = Inebriated.create_default()
	var sleepy = Sleepy.create_default()
	add_player_perk(beer)
	add_player_perk(sleepy)


func add_player_perk(perk_data: Perk):
	perks.append(perk_data)
	emit_signal("perk_added", perk_data)
	
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
	
	# Open the action's scene like a phone app (rest days have no scene, so reopen the
	# calendar). The app is its file name in data/apps/.
	var scene_path = action[0].scene if action[0].scene != "" else CALENDAR
	var app_name = action[0].get("app", "calendar") if action[0].scene != "" else "calendar"
	AppLauncher.open_scene(app_name, scene_path)
