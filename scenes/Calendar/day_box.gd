class_name DayBox
extends Control
## One day on the calendar: a box in the calendar's dialogue-box style with its weekday
## on a name tab and what's on it.
##
## Its parts are nodes in scenes/Calendar/DayBox.tscn: move, resize or reorder them
## there. To use a different design, make your own day scene with this script (and the
## same node names) and put it in the calendar's Day Scene slot. The calendar fills the
## parts in; which ones show, their sizes and the words are data/calendar_style.tres;
## the box, font and tab colours are the calendar's dialogue-box style.

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

var _style: CalendarStyle
var _box_style: DialogueBoxStyle

## The tab and the box. It sits in this plain Control, not straight in the calendar's
## grid, so it can grow (today) without the grid setting it back.
@onready var inner: Control = %Inner
@onready var tab: PanelContainer = %Tab
@onready var weekday_label: Label = %Weekday
@onready var box: PanelContainer = %Box
@onready var number_label: Label = %Number
## The little pictures of what the day offers.
@onready var offers: HBoxContainer = %Offers
## What the day was spent on (a past day), or the boss.
@onready var picture: TextureRect = %Picture
@onready var boss_label: Label = %BossLabel
## The X on a day too far ahead (Hidden Mark), or the ✕ when there's no picture.
@onready var hidden_mark: TextureRect = %HiddenMark
@onready var hidden_text: Label = %HiddenText


func _ready() -> void:
	inner.minimum_size_changed.connect(_fit_inner)
	box.draw.connect(_draw_box_extras)


## Fills the day in. Call it once it's in the scene. `day` = what's on it; `box_size` =
## the box's size (Day Size, or Month Day Size when the whole month is open).
func setup(style: CalendarStyle, day_number: int, day: RunCalendar.Day, day_look: Look, boss_day: bool, box_size: Vector2) -> void:
	_style = style
	_box_style = style.box_style if style.box_style else DialogueBoxStyle.new()
	number = day_number
	look = day_look

	# The weekday on a name tab, like the speaker's name over a dialogue box.
	tab.add_theme_stylebox_override("panel", _box_style.make_name_plate())
	tab.visible = style.show_weekdays and _box_style.show_name_plate
	weekday_label.text = style.weekday(day_number)
	_font(weekday_label, _box_style.name_font if _box_style.name_font else _box_style.text_font(), style.weekday_size, _box_style.name_color)

	box.custom_minimum_size = box_size
	# Day Image (calendar art) or the box style.
	var panel := style.make_day_box()
	if not panel:
		panel = _box_style.make_box()
		panel.set_content_margin_all(style.day_padding)
	box.add_theme_stylebox_override("panel", panel)
	var ink := style.day_text_color if style.day_image else _box_style.text_color

	number_label.text = str(day_number)
	number_label.visible = style.show_day_numbers
	_font(number_label, _box_style.text_font(), style.day_number_size, ink)
	_font(boss_label, _box_style.text_font(), style.weekday_size, ink)
	boss_label.text = style.boss_text
	_font(hidden_text, _box_style.text_font(), style.spent_icon_size, Color(ink, 0.6))
	for part: Control in [picture, hidden_mark]:
		part.custom_minimum_size = Vector2.ONE * style.spent_icon_size

	for child in offers.get_children():
		child.queue_free()
	offers.visible = false
	picture.visible = false
	boss_label.visible = false
	hidden_mark.visible = false
	hidden_text.visible = false
	modulate.a = 1.0
	match day_look:
		Look.HIDDEN:
			hidden_mark.texture = style.hidden_mark
			hidden_mark.visible = style.hidden_mark != null
			hidden_text.visible = style.hidden_mark == null
		Look.PAST:
			if day.spent_on and day.spent_on.icon:
				picture.texture = day.spent_on.icon
				picture.visible = true
			modulate.a = style.past_alpha
		_:
			if boss_day and not day.options.is_empty():
				picture.texture = day.options[0].icon
				picture.visible = day.options[0].icon != null
				boss_label.visible = style.show_boss_text
			else:
				offers.visible = style.show_offers
				for action in day.options:
					if action.icon:
						offers.add_child(_icon(action.icon, style.offer_icon_size))
	tooltip_text = ""
	if style.show_tooltips and day_look != Look.HIDDEN:
		tooltip_text = ", ".join(day.options.map(func(action: DayAction) -> String: return action.title))

	inner.scale = grown_scale()
	z_index = 1 if day_look == Look.TODAY else 0
	_fit_inner()
	box.queue_redraw()


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
	if not _box_style:
		return
	var outline := _box_style.make_outline() if not _style.day_image else null
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


func _icon(texture: Texture2D, side: int) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = Vector2(side, side)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _font(label: Label, font: Font, font_size: int, color: Color) -> void:
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", _box_style.text_outline_width)
	label.add_theme_color_override("font_outline_color", _box_style.text_outline_color)
