extends Control
class_name PartyUI

signal date_selected(date)

# Party panel settings
const PARTY_SIZE := Vector2(500, 600)
const CHARACTER_SLOT_SIZE := Vector2(480, 100)
const SLOT_MARGIN := 10
const MAX_PARTY_MEMBERS := 6

# Styling
const PANEL_STYLE := {
	"bg_color": Color(0.1, 0.1, 0.1, 0.7),
	"border_width": 2,
	"corner_radius": 8
}

const SLOT_STYLE := {
	"bg_color": Color(0.2, 0.2, 0.2, 0.8),
	"border_width": 1,
	"corner_radius": 5
}

const STAT_BAR_COLORS := {
	"Culture": Color(0.0, 0.7, 0.0),    # Green
	"Intellect": Color(0.0, 0.0, 0.8),  # Blue
	"Seduction": Color( 0.8, 0.0, 0.0),  # Red
	"Heart": Color(0.8, 0.0, 0.8)       # Purple
}

var party_panel: Panel
var vbox_container: VBoxContainer
var party_members = []
var selected_character: DateCharacter = null

func _ready():
	anchor_right = 1.0
	anchor_bottom = 1.0
	_create_party_panel()
	
	# Connect to player manager global for updates
	var player_manager = get_node_or_null("/root/PlayerManager")
	if player_manager:
		pass
		# Add signals for party changes

func _update_position():
	if party_panel:
		var viewport_size = get_viewport_rect().size
		var scale_factor_x = viewport_size.x / 1920.0
		var scale_factor_y = viewport_size.y / 1080.0
		
		# Reduce overall size - 70% of the scaled size
		var size_reduction_factor = 0.7
		
		# Scale party size
		var scaled_width = PARTY_SIZE.x * scale_factor_x * size_reduction_factor
		var scaled_height = PARTY_SIZE.y * scale_factor_y * size_reduction_factor
		
		# Scale character slot size
		var scaled_slot_width = CHARACTER_SLOT_SIZE.x * scale_factor_x * size_reduction_factor
		var scaled_slot_height = CHARACTER_SLOT_SIZE.y * scale_factor_y * size_reduction_factor
		
		# Fixed right margin in pixels (right-aligned like Pokémon party screen)
		var right_margin = 20
		
		# Calculate position to maintain right alignment
		var x_position = viewport_size.x - scaled_width - right_margin
		var y_position = 100  # Fixed top position
		
		# Set custom minimum size and position
		party_panel.custom_minimum_size = Vector2(scaled_width, scaled_height)
		party_panel.size = Vector2(scaled_width, scaled_height)
		party_panel.position = Vector2(x_position, y_position)
		
		# Update vbox container
		vbox_container.position = Vector2(SLOT_MARGIN, 35)
		vbox_container.custom_minimum_size = Vector2(
			scaled_width - SLOT_MARGIN * 2,
			scaled_height - 45
		)
		
		# Update existing character slots
		for child in vbox_container.get_children():
			child.custom_minimum_size = Vector2(scaled_slot_width, scaled_slot_height)

func _process(_delta):
	# Check for viewport size changes and update position
	if party_panel:
		_update_position()

func _create_party_panel():
	party_panel = Panel.new()
	
	# Position in the upper right corner
	party_panel.position = Vector2(get_viewport_rect().size.x - PARTY_SIZE.x - 20, 100)
	party_panel.custom_minimum_size = PARTY_SIZE

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = PANEL_STYLE.bg_color
	panel_style.set_border_width_all(PANEL_STYLE.border_width)
	panel_style.set_corner_radius_all(PANEL_STYLE.corner_radius)
	panel_style.border_color = Color.WHITE
	party_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Add a title
	var title_label = Label.new()
	title_label.text = "Party"
	title_label.position = Vector2(10, 5)
	title_label.add_theme_font_size_override("font_size", 18)
	party_panel.add_child(title_label)
	
	# Create a vertical box container for character slots
	vbox_container = VBoxContainer.new()
	vbox_container.position = Vector2(SLOT_MARGIN, 35)  # Below the title
	vbox_container.custom_minimum_size = Vector2(
		PARTY_SIZE.x - SLOT_MARGIN * 2,
		PARTY_SIZE.y - 45
	)
	vbox_container.add_theme_constant_override("separation", SLOT_MARGIN)
	
	party_panel.add_child(vbox_container)
	add_child(party_panel)
	
	# Initially hide the party panel
	party_panel.visible = false
	
func update_party(characters):
	print("Update party")
	for child in vbox_container.get_children():
		child.queue_free()
		
	print(characters)
	# Add each character to the vertical box
	for character in characters:
		print("character", character)
		var character_slot = _create_character_slot(character)
		vbox_container.add_child(character_slot)
	
	# Add empty slots if needed
	var empty_slots = MAX_PARTY_MEMBERS - characters.size()
	for i in range(empty_slots):
		var empty_slot = _create_empty_slot()
		vbox_container.add_child(empty_slot)

func _create_character_slot(character: DateCharacter):
	var slot = Panel.new()
	slot.custom_minimum_size = CHARACTER_SLOT_SIZE
	
	# Create slot background style
	var slot_style = StyleBoxFlat.new()
	slot_style.bg_color = SLOT_STYLE.bg_color
	slot_style.set_border_width_all(SLOT_STYLE.border_width)
	slot_style.set_corner_radius_all(SLOT_STYLE.corner_radius)
	slot_style.border_color = Color.WHITE
	slot.add_theme_stylebox_override("panel", slot_style)
	
	# Create a horizontal container for layout
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_FILL
	hbox.size_flags_vertical = Control.SIZE_FILL
	hbox.custom_minimum_size = CHARACTER_SLOT_SIZE
	
	# Character portrait/icon
	var portrait_container = Control.new()
	portrait_container.custom_minimum_size = Vector2(80, 80)

	# Create animated sprite for the character's icon
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.centered = true

	# Set sprite frames and play animation
	if character.icon_path and character.icon_path != "":
		if ResourceLoader.exists(character.icon_path):
			var sprite_frames = load(character.icon_path)
			animated_sprite.sprite_frames = sprite_frames
			animated_sprite.play()
			
			# Center the sprite in the container
			animated_sprite.position = Vector2(40, 40)  # Half of 80x80
			
			# Scale the sprite to fit the container
			if animated_sprite.sprite_frames:
				var texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, 0)
				if texture:
					var texture_size = texture.get_size()
					var scale_factor = min(
						(80.0 * 0.9) / texture_size.x,
						(80.0 * 0.9) / texture_size.y
					)
					animated_sprite.scale = Vector2(scale_factor, scale_factor)

	portrait_container.add_child(animated_sprite)
	
	# Character info container
	var info_container = VBoxContainer.new()
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Character name
	var name_label = Label.new()
	name_label.text = character.name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	info_container.add_child(name_label)
	
	# Skill bars container
	var skills_container = GridContainer.new()
	skills_container.columns = 2
	skills_container.add_theme_constant_override("h_separation", 10)
	skills_container.add_theme_constant_override("v_separation", 5)
	skills_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Add skill bars
	for skill_name in character.skill_scores.keys():
		var skill_hbox = HBoxContainer.new()
		
		var skill_label = Label.new()
		skill_label.text = skill_name + ":"
		skill_label.custom_minimum_size = Vector2(70, 0)
		skill_hbox.add_child(skill_label)
		
		var progress_bar = ProgressBar.new()
		progress_bar.min_value = 0
		progress_bar.max_value = 100
		progress_bar.value = character.skill_scores[skill_name]
		progress_bar.custom_minimum_size = Vector2(100, 10)
		progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Style the progress bar
		var bar_style = StyleBoxFlat.new()
		bar_style.bg_color = STAT_BAR_COLORS[skill_name]
		bar_style.set_corner_radius_all(2)
		progress_bar.add_theme_stylebox_override("fill", bar_style)
		
		skill_hbox.add_child(progress_bar)
		skills_container.add_child(skill_hbox)
	
	info_container.add_child(skills_container)
	
	# Make the entire slot clickable
	var button = Button.new()
	button.flat = true
	button.position = Vector2.ZERO
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Connect button press
	button.pressed.connect(func():
		selected_character = character
		emit_signal("date_selected", character)
		_highlight_selected_slot(slot)
	)
	
	# Add elements to the layout
	hbox.add_child(portrait_container)
	hbox.add_child(info_container)
	
	slot.add_child(hbox)
	slot.add_child(button)
	
	return slot

func _create_empty_slot():
	var slot = Panel.new()
	slot.custom_minimum_size = CHARACTER_SLOT_SIZE
	
	# Create slot background style (darker/dimmed for empty slots)
	var slot_style = StyleBoxFlat.new()
	slot_style.bg_color = Color(0.15, 0.15, 0.15, 0.6)  # Darker than filled slots
	slot_style.set_border_width_all(SLOT_STYLE.border_width)
	slot_style.set_corner_radius_all(SLOT_STYLE.corner_radius)
	slot_style.border_color = Color(0.3, 0.3, 0.3)  # Dimmed border
	slot.add_theme_stylebox_override("panel", slot_style)
	
	# Empty slot label
	var empty_label = Label.new()
	empty_label.text = "Empty"
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_label.add_theme_font_size_override("font_size", 16)
	empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))  # Gray text
	
	slot.add_child(empty_label)
	return slot

func _highlight_selected_slot(selected_slot):
	# Reset all slot styles
	for i in range(vbox_container.get_child_count()):
		var slot = vbox_container.get_child(i)
		if slot == selected_slot:
			# Highlight the selected slot
			var highlighted_style = StyleBoxFlat.new()
			highlighted_style.bg_color = Color(0.3, 0.3, 0.4, 0.9)  # Highlighted background
			highlighted_style.set_border_width_all(2)
			highlighted_style.set_corner_radius_all(SLOT_STYLE.corner_radius)
			highlighted_style.border_color = Color(1.0, 0.8, 0.0)  # Golden border
			slot.add_theme_stylebox_override("panel", highlighted_style)
		else:
			# Reset other slots to default style
			var default_style = StyleBoxFlat.new()
			default_style.bg_color = SLOT_STYLE.bg_color
			default_style.set_border_width_all(SLOT_STYLE.border_width)
			default_style.set_corner_radius_all(SLOT_STYLE.corner_radius)
			default_style.border_color = Color.WHITE
			slot.add_theme_stylebox_override("panel", default_style)

func toggle_visibility():
	party_panel.visible = !party_panel.visible
	
	# When panel is not visible, make sure it doesn't block mouse events
	if !party_panel.visible:
		party_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		party_panel.mouse_filter = Control.MOUSE_FILTER_STOP
func get_selected_character():
	return selected_character
