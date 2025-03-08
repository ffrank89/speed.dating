# test_ui.gd
extends Control

var player: Character
var current_date: Character

# References to UI elements
@onready var player_outfit_panel = $PlayerPanel/OutfitPanel
@onready var player_stats = $PlayerPanel/StatsPanel
@onready var date_panel = $DatePanel
@onready var dialogue_panel = $DialoguePanel
@onready var money_label = $PlayerPanel/MoneyLabel

var player_money: int = 100

# Outfit options for testing
var available_outfits = {
	"pants": [
		{"name": "Casual Jeans", "bonus": 0.1, "cost": 20},
		{"name": "Formal Slacks", "bonus": 0.2, "cost": 40},
		{"name": "Trendy Shorts", "bonus": 0.15, "cost": 30}
	],
	"shirt": [
		{"name": "T-Shirt", "bonus": 0.1, "cost": 15},
		{"name": "Dress Shirt", "bonus": 0.2, "cost": 35},
		{"name": "Designer Top", "bonus": 0.25, "cost": 50}
	],
	"accessories": [
		{"name": "Watch", "bonus": 0.1, "cost": 25},
		{"name": "Necklace", "bonus": 0.15, "cost": 30},
		{"name": "Glasses", "bonus": 0.05, "cost": 15}
	]
}

func _ready():
	setup_player()
	setup_outfit_selection()
	update_money_display()

func setup_player():
	player = Character.new("Me")
	
	update_player_stats()

func setup_outfit_selection():
	# Create outfit selection buttons
	for category in available_outfits:
		var category_container = VBoxContainer.new()
		var label = Label.new()
		label.text = category.capitalize()
		category_container.add_child(label)
		
		for item in available_outfits[category]:
			var button = Button.new()
			button.text = "%s ($%d)" % [item["name"], item["cost"]]
			button.custom_minimum_size = Vector2(150, 30)
			
			# Connect button press to outfit change
			button.pressed.connect(
				func(): try_purchase_outfit(category, item)
			)
			
			category_container.add_child(button)
		
		player_outfit_panel.add_child(category_container)

func try_purchase_outfit(category: String, item: Dictionary):
	if player_money >= item["cost"]:
		player_money -= item["cost"]
		player.change_outfit_piece(category, item["name"], item["bonus"])
		update_player_stats()
		update_money_display()

func update_player_stats():
	var stats_text = ""
	stats_text += "Current Outfit:\n"
	for category in player.outfit:
		var item = player.outfit[category]["item"]
		stats_text += "%s: %s\n" % [category, "None" if item == "" else item]
	
	stats_text += "\nTotal Bonus: %.1f%%" % (player.get_total_outfit_bonus() * 100)
	player_stats.text = stats_text

func update_money_display():
	money_label.text = "Money: $%d" % player_money
