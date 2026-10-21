class_name StatBars
extends VBoxContainer
## A list of the player's stats, each with its picture, name, number (1-9) and a bar.
## It shows every stat that's on (data/stats.tres), in that file's order, or just the ones
## in Only These. It's a scene of its own (scenes/Stats/StatBars.tscn), so it can go on
## any screen: drag it in and it fills itself in. Profile is one. refresh() shows the
## stats as they are now (Profile calls it each time it opens).
## Full guide: docs/guides/stats.md

## A heading above the list (e.g. "Stats"). Empty = none.
@export var heading_text: String = ""
## Only these stats (drag stat files from data/stats/ here), in this order. Empty = every
## stat that's on. Stats that are off are left out either way.
@export var only_these: Array[PlayerStat] = []
## The phone's look: its font, text colour and Accent Color (the numbers and bars).
@export var phone_style: PhoneStyle

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


## Lists the stats as they are now. Hides itself when there's nothing to list (every stat
## it would show is off).
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
	var all := StatList.get_default()
	for stat in only_these if not only_these.is_empty() else all.stats:
		if all.is_active(stat):
			list.append({"name": stat.display_name, "value": player.get_stat(stat),
				"icon": stat.icon, "description": stat.description})
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
		# A full bar is the highest a stat goes (data/stats.tres).
		row.add_child(_bar(float(stat.value) / maxf(StatList.get_default().highest, 1.0), ui.accent_color))
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
