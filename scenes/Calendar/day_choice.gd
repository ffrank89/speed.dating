class_name DayChoice
extends PanelContainer
## One of today's choices on the calendar: a box in the calendar's dialogue-box style
## with the action's picture, title, and how many days it takes. Click it, or press its
## number key. The calendar builds these (calendar.gd); their look is
## data/calendar_style.tres.

## Clicked (or its key pressed) and it fits.
signal picked(choice: DayChoice)
## Clicked but it doesn't fit before the boss.
signal blocked(choice: DayChoice)

var action: DayAction
## False when it doesn't fit before the boss day.
var fits := true

var _style: CalendarStyle
var _box_style: DialogueBoxStyle


func setup(style: CalendarStyle, day_action: DayAction, key_number: int, does_fit: bool) -> void:
	_style = style
	_box_style = style.box_style if style.box_style else DialogueBoxStyle.new()
	action = day_action
	fits = does_fit
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_stylebox_override("panel", _box_style.make_box())
	draw.connect(func() -> void:
		var outline := _box_style.make_outline()
		if outline:
			draw_style_box(outline, Rect2(Vector2.ZERO, size)))
	resized.connect(func() -> void: pivot_offset = size / 2.0)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 28)
	add_child(row)

	if style.show_keys:
		# The key on a little name tab.
		var key := PanelContainer.new()
		key.mouse_filter = Control.MOUSE_FILTER_IGNORE
		key.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		key.add_theme_stylebox_override("panel", _box_style.make_name_plate())
		key.add_child(_label(str(key_number), _box_style.name_font if _box_style.name_font else _font(), style.choice_detail_size, _box_style.name_color))
		row.add_child(key)

	if action.icon:
		var picture := TextureRect.new()
		picture.texture = action.icon
		picture.custom_minimum_size = Vector2.ONE * style.choice_icon_size
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(picture)

	var words := VBoxContainer.new()
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(words)
	words.add_child(_label(action.title, _font(), style.choice_title_size, _box_style.text_color))
	var detail := _days_text()
	if not fits:
		detail = style.not_enough_days_text
	elif not action.description.is_empty():
		detail = "%s · %s" % [detail, action.description]
	var detail_label := _label(detail, _font(), style.choice_detail_size, Color(_box_style.text_color, 0.7))
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.add_child(detail_label)

	if not fits:
		modulate.a = 0.45
		mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))


## Picks it, as if clicked.
func press() -> void:
	if fits:
		picked.emit(self)
	else:
		blocked.emit(self)
		var shake := create_tween()
		for offset in [14.0, -14.0, 8.0, 0.0]:
			shake.tween_property(self, "position:x", position.x + offset, 0.04)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		accept_event()
		press()


func _on_hover(on: bool) -> void:
	if not fits:
		return
	create_tween().tween_property(self, "scale", Vector2.ONE * (1.04 if on else 1.0), 0.1)
	if on and _style.hover_sound:
		var player := AudioStreamPlayer.new()
		player.stream = _style.hover_sound
		player.volume_db = _style.volume_db
		add_child(player)
		player.finished.connect(player.queue_free)
		player.play()


func _days_text() -> String:
	return _style.one_day_text if action.days == 1 else _style.many_days_text % action.days


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
