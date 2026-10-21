class_name StatBars
extends VBoxContainer
## A list of the player's stats, each with its picture, name, number (1-9) and a bar:
## the four attributes, or the skills that are on (data/skills.tres). Profile shows one of
## each. It's a scene of its own (scenes/Stats/StatBars.tscn), so it can go on any
## screen: drag it in, pick what it Shows, and it fills itself in. refresh() shows the
## stats as they are now (Profile calls it each time it opens).
## Full guide: docs/guides/skills.md

enum Shows {
	## Culture, Intellect, Seduction, Heart.
	ATTRIBUTES,
	## The skills that are on (data/skills.tres), in that file's order.
	SKILLS,
}

## Which stats it lists.
@export var shows: Shows = Shows.ATTRIBUTES
## A heading above the list (e.g. "Skills"). Empty = none.
@export var heading_text: String = ""
## The phone's look: its font, text colour and Accent Color (the numbers and bars).
@export var phone_style: PhoneStyle
## Where the attribute pictures come from (an option style's Attribute Icons). Skills
## use their own Icon.
@export var icons_from: OptionListStyle

@export_group("Sizes")
## Size of the heading.
@export_range(8, 200) var heading_size: int = 44
## Size of each stat's name and number.
@export_range(8, 200) var font_size: int = 50
## Size of each stat's picture, in pixels. 0 = no pictures.
@export_range(0, 300) var icon_size: int = 90
## Height of each bar, in pixels. 0 = no bars.
@export_range(0, 100) var bar_height: int = 26
## Space between the stats, in pixels.
@export_range(0, 200) var row_gap: int = 50
## The empty part of each bar.
@export var bar_back_color: Color = Color(0, 0, 0, 0.08)


func _ready() -> void:
	refresh()


## Lists the stats as they are now. Hides itself when there's nothing to list (e.g. no
## skills are on).
func refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var ui := phone_style if phone_style else PhoneStyle.new()
	add_theme_constant_override("separation", row_gap)
	var rows := _stats()
	visible = not rows.is_empty()
	if rows.is_empty():
		return
	if not heading_text.is_empty():
		var heading := Label.new()
		heading.text = heading_text
		ui.style_label(heading, ui.ui_text_color, heading_size)
		add_child(heading)
	for stat in rows:
		add_child(_make_row(stat, ui))


# Each stat to list: {"name", "value", "icon", "description"}.
func _stats() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var player := PlayerManager.ensure_player()
	if shows == Shows.ATTRIBUTES:
		for attr in Attr.NAMES:
			var attr_name := Attr.display_name(attr)
			list.append({"name": attr_name, "value": player.get_attribute(attr_name),
				"icon": icons_from.icon_for(attr) if icons_from else null, "description": ""})
	else:
		for skill in SkillList.get_default().active():
			list.append({"name": skill.display_name, "value": player.get_skill(skill),
				"icon": skill.icon, "description": skill.description})
	return list


func _make_row(stat: Dictionary, ui: PhoneStyle) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	# The mouse resting on it shows its description; scrolling still reaches the list.
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.tooltip_text = stat.description
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 24)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(line)
	var picture: Texture2D = stat.icon
	if picture and icon_size > 0:
		var icon := TextureRect.new()
		icon.texture = picture
		icon.custom_minimum_size = Vector2.ONE * icon_size
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(icon)
	var name_label := Label.new()
	name_label.text = stat.name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui.style_label(name_label, ui.ui_text_color, font_size)
	line.add_child(name_label)
	var number := Label.new()
	number.text = str(stat.value)
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui.style_label(number, ui.accent_color, font_size)
	line.add_child(number)
	if bar_height > 0:
		# A full bar is the highest a stat goes (data/attribute_rules.tres).
		row.add_child(_bar(float(stat.value) / maxf(Attr.rules().highest, 1.0), ui.accent_color))
	return row


# A rounded bar, filled to `amount` (0-1).
func _bar(amount: float, fill: Color) -> Control:
	var back := Panel.new()
	back.custom_minimum_size.y = bar_height
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.add_theme_stylebox_override("panel", _round(bar_back_color))
	var front := Panel.new()
	front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	front.add_theme_stylebox_override("panel", _round(fill))
	front.anchor_bottom = 1.0
	front.anchor_right = clampf(amount, 0.0, 1.0)
	back.add_child(front)
	return back


func _round(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(100)
	box.anti_aliasing = true
	return box
