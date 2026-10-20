class_name DayBox
extends Control
## One day on the calendar: a box in the calendar's dialogue-box style with its weekday
## on a name tab, its number, and what's on it. The calendar builds these (calendar.gd);
## their look is data/calendar_style.tres.

enum Look {
	## Already gone: faded, with what it was spent on.
	PAST,
	## Today: bigger, with a highlight.
	TODAY,
	## Later this chapter (or seen with foresight): what it offers.
	AHEAD,
	## Too far ahead to see: an X.
	HIDDEN,
}

## The day's calendar-day number (1 = the run's first day).
var number := 0
var look := Look.AHEAD
## The day's box, under its tab.
var box: PanelContainer
## The tab and the box. It sits in this plain Control, not straight in the calendar's
## grid, so it can grow (today) without the grid setting it back.
var inner: VBoxContainer

var _style: CalendarStyle
var _box_style: DialogueBoxStyle


## Builds the day. `day` = what's on it (RunCalendar.Day).
func setup(style: CalendarStyle, day_number: int, day: RunCalendar.Day, day_look: Look, boss_day: bool) -> void:
	_style = style
	_box_style = style.box_style if style.box_style else DialogueBoxStyle.new()
	number = day_number
	look = day_look
	mouse_filter = Control.MOUSE_FILTER_PASS
	for child in get_children():
		child.queue_free()
	inner = VBoxContainer.new()
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_theme_constant_override("separation", -4)
	add_child(inner)
	# This day takes up as much room in the grid as its tab and box need.
	inner.minimum_size_changed.connect(_fit_inner)

	# The weekday on a name tab, like the speaker's name over a dialogue box.
	var tab_row := CenterContainer.new()
	tab_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(tab_row)
	var tab := PanelContainer.new()
	tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab.add_theme_stylebox_override("panel", _box_style.make_name_plate())
	tab.visible = _box_style.show_name_plate
	tab_row.add_child(tab)
	var weekday := _label(_weekday(), _box_style.name_font if _box_style.name_font else _font(), style.weekday_size, _box_style.name_color)
	tab.add_child(weekday)

	box = PanelContainer.new()
	box.custom_minimum_size = style.day_size
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := _box_style.make_box()
	panel.set_content_margin_all(style.day_padding)
	box.add_theme_stylebox_override("panel", panel)
	box.draw.connect(_draw_box_extras)
	inner.add_child(box)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 6)
	box.add_child(column)
	var day_label := _label(str(day_number), _font(), style.day_number_size, _box_style.text_color)
	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(day_label)

	match day_look:
		Look.HIDDEN:
			column.add_child(_hidden_mark())
		Look.PAST:
			if day.spent_on and day.spent_on.icon:
				column.add_child(_icon(day.spent_on.icon, style.spent_icon_size))
			modulate.a = style.past_alpha
		_:
			if boss_day and not day.options.is_empty():
				column.add_child(_icon(day.options[0].icon, style.spent_icon_size))
				var boss := _label(style.boss_text, _font(), style.weekday_size, _box_style.text_color)
				boss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				column.add_child(boss)
			else:
				var row := HBoxContainer.new()
				row.mouse_filter = Control.MOUSE_FILTER_IGNORE
				row.alignment = BoxContainer.ALIGNMENT_CENTER
				row.add_theme_constant_override("separation", 6)
				column.add_child(row)
				for action in day.options:
					if action.icon:
						row.add_child(_icon(action.icon, style.offer_icon_size))
	if day_look != Look.HIDDEN:
		tooltip_text = ", ".join(day.options.map(func(action: DayAction) -> String: return action.title))

	if day_look == Look.TODAY:
		# Grow from the middle, so today stands out without pushing its neighbours.
		inner.scale = Vector2.ONE * style.today_scale
		z_index = 1
	_fit_inner()


## Today's size: its normal size times Today Scale (1 for other days).
func grown_scale() -> Vector2:
	return Vector2.ONE * (_style.today_scale if look == Look.TODAY else 1.0)


func _fit_inner() -> void:
	var needed := inner.get_combined_minimum_size()
	inner.size = needed
	inner.pivot_offset = needed / 2.0
	custom_minimum_size = needed


# The outline over a picture box (like her dialogue box), and today's highlight.
func _draw_box_extras() -> void:
	var outline := _box_style.make_outline()
	if outline:
		box.draw_style_box(outline, Rect2(Vector2.ZERO, box.size))
	if look == Look.TODAY and _style.today_outline_width > 0:
		var highlight := StyleBoxFlat.new()
		highlight.draw_center = false
		highlight.border_color = _style.today_outline_color
		highlight.set_border_width_all(_style.today_outline_width)
		highlight.set_corner_radius_all(_box_style.corner_radius)
		highlight.anti_aliasing = true
		box.draw_style_box(highlight, Rect2(Vector2.ZERO, box.size).grow(_style.today_outline_width * 0.5))


func _weekday() -> String:
	if _style.weekdays.is_empty():
		return ""
	return _style.weekdays[(number - 1) % _style.weekdays.size()]


func _hidden_mark() -> Control:
	if _style.hidden_mark:
		return _icon(_style.hidden_mark, _style.spent_icon_size)
	var mark := _label("✕", _font(), _style.spent_icon_size, Color(_box_style.text_color, 0.6))
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return mark


func _icon(texture: Texture2D, side: int) -> TextureRect:
	var picture := TextureRect.new()
	picture.texture = texture
	picture.custom_minimum_size = Vector2(side, side)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return picture


func _label(words: String, font: Font, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", _box_style.text_outline_width)
	label.add_theme_color_override("font_outline_color", _box_style.text_outline_color)
	return label


func _font() -> Font:
	return _box_style.text_font()
