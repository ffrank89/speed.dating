class_name DayChoice
extends PanelContainer
## One of today's choices on the calendar: a box in the calendar's dialogue-box style
## with the action's picture, title, and a line about it (what it does, how many days).
## Click it, or press its number key.
##
## Its parts are nodes in scenes/Calendar/DayChoice.tscn: move, resize or reorder them
## there. To use a different design, make your own choice scene with this script (and
## the same node names) and put it in the calendar's Choice Scene slot. Which parts show,
## sizes and words are data/calendar_style.tres; colours and font are the calendar's
## dialogue-box style.

## Clicked (or its key pressed) and it fits.
signal picked(choice: DayChoice)
## Clicked but it doesn't fit before the boss.
signal blocked(choice: DayChoice)

var action: DayAction
## False when it doesn't fit before the boss day.
var fits := true

var _style: CalendarStyle
var _box_style: DialogueBoxStyle

## The number key that picks it, on a little name tab.
@onready var key: PanelContainer = %Key
@onready var key_label: Label = %KeyLabel
@onready var icon: TextureRect = %Icon
@onready var title: Label = %Title
## Its description (or what it changes) and how many days it takes.
@onready var detail: Label = %Detail


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	draw.connect(_draw_outline)
	resized.connect(func() -> void: pivot_offset = size / 2.0)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))


## Fills the choice in. Call it once it's in the scene.
func setup(style: CalendarStyle, day_action: DayAction, key_number: int, does_fit: bool) -> void:
	_style = style
	_box_style = style.box_style if style.box_style else DialogueBoxStyle.new()
	action = day_action
	fits = does_fit
	var box := _box_style.make_box()
	box.set_content_margin_all(style.choice_padding)
	add_theme_stylebox_override("panel", box)

	key.visible = style.show_keys
	key.add_theme_stylebox_override("panel", _box_style.make_name_plate())
	key_label.text = str(key_number)
	_font(key_label, _box_style.name_font if _box_style.name_font else _box_style.text_font(), style.choice_detail_size, _box_style.name_color)

	icon.texture = action.icon
	icon.visible = action.icon != null
	icon.custom_minimum_size = Vector2.ONE * style.choice_icon_size

	title.text = action.title
	_font(title, _box_style.text_font(), style.choice_title_size, _box_style.text_color)

	var about := action.description if not action.description.is_empty() else action.changes_text()
	var line := style.one_day_text if action.days == 1 else style.words(style.many_days_text, {"days": action.days})
	if not fits:
		line = style.not_enough_days_text
	elif not about.is_empty():
		line = "%s · %s" % [line, about]
	detail.text = line
	detail.visible = style.show_details
	_font(detail, _box_style.text_font(), style.choice_detail_size, Color(_box_style.text_color, 0.7))

	modulate.a = 1.0 if fits else 0.45
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if fits else Control.CURSOR_FORBIDDEN
	queue_redraw()


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
	if not fits or not _style:
		return
	create_tween().tween_property(self, "scale", Vector2.ONE * (1.04 if on else 1.0), 0.1)
	if on and _style.hover_sound:
		var player := AudioStreamPlayer.new()
		player.stream = _style.hover_sound
		player.volume_db = _style.volume_db
		add_child(player)
		player.finished.connect(player.queue_free)
		player.play()


# The outline over a picture box, like her dialogue box.
func _draw_outline() -> void:
	var outline := _box_style.make_outline() if _box_style else null
	if outline:
		draw_style_box(outline, Rect2(Vector2.ZERO, size))


func _font(label: Label, font: Font, font_size: int, color: Color) -> void:
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", _box_style.text_outline_width)
	label.add_theme_color_override("font_outline_color", _box_style.text_outline_color)
