#player_panel.gd
extends Panel

@onready var money_label = $MoneyLabel
@onready var stats_panel = $StatsPanel

var player: PlayerCharacter

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

	stats_panel.position = Vector2(10, 260)
	stats_panel.size = Vector2(350, 300)
	stats_panel.bbcode_enabled = true

func setup(player_character: PlayerCharacter):
	player = player_character
	update_display()
	
func update_display():
	if not player:
		return

	# Update money display
	money_label.text = "Money: $100"

	# Skills section - eventually these would come from player
	var skill_text = "[b]SKILLS:[/b]\n"
	var skills = player.skills
	for skill_name in skills:
		skill_text += "%s: %d\n" % [skill_name, skills[skill_name]]

	# Update the stats panel text
	stats_panel.text = skill_text

func update_skills():
	update_display()
