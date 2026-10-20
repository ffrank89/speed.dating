extends Control
class_name CalendarScene

signal action_selected(action_data)

# UI references
@onready var background = $Background
@onready var calendar_container = $CalendarContainer
@onready var calendar_image = $CalendarContainer/CalendarImage
@onready var grid_container = $GridContainer

# Game state
var current_day = 0
var current_month = 1 # January (1-based, matches PlayerManager)
var month_names = ["January", "February", "March", "April", "May", "June", 
				"July", "August", "September", "October", "November", "December"]

# Action database - will be populated dynamically
var available_actions = {}

func _ready():
	print("Calendar Scene Ready")
	# Set up calendar to fill viewport
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	# Get current day/month from PlayerManager
	var player_manager = get_node_or_null("/root/PlayerManager")
	if player_manager:
		current_day = player_manager.current_day
		current_month = player_manager.current_month
		print("Calendar initialized with day:", current_day)
	
	# Update calendar to reflect current state
	update_calendar()

func generate_available_actions():
	available_actions.clear()
	print("Generate available actions current day", current_day)
	# Generate actions for current day and next 3 days
	for i in range(current_day, current_day + 3):
		if i == current_day:
			available_actions[i] = [{
				"action_name": "stat_increase_culture",
				"scene": "res://scenes/Calendar/calendar.tscn",
				"app": "calendar",
				"icon": "culture"
			}]
		else:
			available_actions[i] = [{
				"action_name": "return_to_start",
				"scene": "res://scenes/Tinder/Screen.tscn",
				"app": "dating_app",
				"icon": "girl"
			}]
			
	for i in range(current_day + 3, 30- current_day + 3):
			available_actions[i] = [{
				"action_name": "",
				"scene": "",
				"icon": "sleepy"
			}]
	
	print("Generated available actions for days", current_day, "to", current_day + 3)

func update_calendar():
	# Update month title
	var calendar_path = "res://assets/" + month_names[current_month-1].to_lower() + ".png"
	if ResourceLoader.exists(calendar_path):
		calendar_image.texture = load(calendar_path)
	
	# Generate available actions for the right days
	generate_available_actions()
	
	for i in range(1, 31):  # 30 days in a month
		var container = grid_container.get_node_or_null("Day_" + str(i))
		if container:
			print("in for loop: update_calendar")
			if i < current_day:
				container.set_past_day(true)
			elif available_actions.has(i):
				container.set_available_action_day(available_actions.get(i))
			

func _on_day_pressed(day_number):
	print("CalendarScene: Day", day_number, "pressed")
	
	# If this day has an action, go directly to that scene
	print("available_actions: ", available_actions)
	if available_actions.has(day_number):
		print("in here")
		var actions = available_actions[day_number]
		var player_manager = get_node_or_null("/root/PlayerManager")
		player_manager.calendar_action(actions)
	else:
		print("No actions available for day ", day_number)
		print("GAME BROKE")

func close():
	queue_free()
