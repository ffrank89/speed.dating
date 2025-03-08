extends Panel

@onready var money_label = $MoneyLabel
@onready var outfit_panel = $OutfitPanel
@onready var stats_panel = $StatsPanel

var player: Character

func _ready():
	custom_minimum_size = Vector2(200, 600)
	position = Vector2(20, 20)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	add_theme_stylebox_override("panel", style)

	# Configure child nodes
	money_label.text = "Money: $100"
	money_label.position = Vector2(10, 10)
	money_label.size = Vector2(180, 30)

	outfit_panel.position = Vector2(10, 50)
	outfit_panel.custom_minimum_size = Vector2(180, 200)

	stats_panel.position = Vector2(10, 260)
	stats_panel.size = Vector2(350, 300)
	stats_panel.bbcode_enabled = true

func setup(player_character: Character):
	player = player_character
	update_display()

func get_skill(skill: String):
	if not player:
		return 0
	return player.skills[skill]
	
func update_display():
	if not player:
		return

	# Update money display
	money_label.text = "Money: $100"

	# Skills section - eventually these would come from player
	var skill_text = "[b]SKILLS:[/b]\n"
	var skills = {
	"Wit": 25,
	"Sex": 30,
	"Cool": 20,
	"Style": 15,
	"Size": 100,
	}
	for skill_name in skills:
		skill_text += "%s: %d\n" % [skill_name, skills[skill_name]]

	# Outfit section
	var outfit_text = "\n[b]CURRENT OUTFIT:[/b]\n"

	# Get color names as readable strings
	var pant_color = ColorType.Colors.keys()[player.pant.color.color]
	var shirt_color = ColorType.Colors.keys()[player.shirt.color.color]
	var accessory_color = ColorType.Colors.keys()[player.accessory.color.color]

	outfit_text += "Pants: %s\n" % pant_color
	outfit_text += "Shirt: %s\n" % shirt_color
	outfit_text += "Accessory: %s\n" % accessory_color

	# Update the stats panel text
	stats_panel.text = skill_text + outfit_text
func update_outfit():
	update_display()

func update_skills():
	update_display()
