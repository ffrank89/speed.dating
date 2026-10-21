class_name DayBox
extends Control
## One day in the whole month ("See the whole month"): a small square in the player's
## style (data/player_style.tres: its border colour says what the day is: today, coming
## up, the boss, gone, or too far ahead to see) with its weekday on a name tab and what's
## on it.
##
## Its parts are nodes in scenes/Calendar/DayBox.tscn: move, resize or reorder them
## there. To use a different design, make your own scene with this script (and the same
## node names) and put it in the calendar's Month Day Scene slot. Which parts show, sizes
## and words are data/calendar_style.tres (Month, Days, What Shows).

enum Look {
	## Already gone: faded, with what it was spent on.
	PAST,
	## Today: bigger, in Today Color.
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
var _player: PlayerStyle

## The tab and the box. It sits in this plain Control, not straight in the calendar's
## grid, so it can grow (today) without the grid setting it back.
@onready var inner: Control = %Inner
@onready var tab: PanelContainer = %Tab
@onready var weekday_label: Label = %Weekday
@onready var box: PanelContainer = %Box
@onready var number_label: Label = %Number
## The little pictures of what the day offers (a column in DayBox.tscn; a row works too).
@onready var offers: BoxContainer = %Offers
## What the day was spent on (a past day), or the boss.
@onready var picture: TextureRect = %Picture
@onready var boss_label: Label = %BossLabel
## The X on a day too far ahead (Hidden Mark), or the ✕ when there's no picture.
@onready var hidden_mark: TextureRect = %HiddenMark
@onready var hidden_text: Label = %HiddenText


func _ready() -> void:
	inner.minimum_size_changed.connect(_fit_inner)


## Fills the day in. Call it once it's in the scene. `day` = what's on it; `font` = the
## font when the player's style has none (the phone's).
func setup(style: CalendarStyle, player: PlayerStyle, day_number: int, day: RunCalendar.Day,
		day_look: Look, boss_day: bool, font: Font = null) -> void:
	_style = style
	_player = player
	number = day_number
	look = day_look
	var edge := player.day_color(day_look == Look.TODAY, boss_day, day_look == Look.HIDDEN, day_look == Look.PAST)

	# The weekday on a name tab in the day's colour.
	tab.add_theme_stylebox_override("panel", player.make_tab(edge))
	tab.visible = style.show_weekdays
	weekday_label.text = style.weekday(day_number)
	player.style_label(weekday_label, font, style.month_weekday_size)

	box.custom_minimum_size = style.month_day_size
	# Day Image (calendar art), or the player's card in the day's colour.
	var panel := style.make_day_box()
	if not panel:
		panel = player.make_card(edge, style.day_padding)
		(panel as StyleBoxFlat).set_border_width_all(maxi(player.border_width / 2, 2))
		(panel as StyleBoxFlat).shadow_size = 0
	box.add_theme_stylebox_override("panel", panel)
	var ink := style.day_text_color if style.day_image else player.text_color

	number_label.text = str(day_number)
	number_label.visible = style.show_day_numbers
	player.style_label(number_label, font, style.day_number_size, ink)
	player.style_label(boss_label, font, style.month_weekday_size, ink)
	boss_label.text = style.boss_text
	player.style_label(hidden_text, font, style.month_spent_icon_size, Color(ink, 0.6))
	for part: Control in [picture, hidden_mark]:
		part.custom_minimum_size = Vector2.ONE * style.month_spent_icon_size

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
			modulate.a = player.past_alpha
		_:
			if boss_day and not day.options.is_empty():
				picture.texture = day.options[0].icon
				picture.visible = day.options[0].icon != null
				boss_label.visible = style.show_boss_text
			else:
				offers.visible = style.show_offers
				for action in day.options:
					if action.icon:
						offers.add_child(_icon(action.icon, style.month_offer_icon_size))
	tooltip_text = ""
	if style.show_tooltips and day_look != Look.HIDDEN:
		tooltip_text = ", ".join(day.options.map(func(action: DayAction) -> String: return action.title))

	inner.scale = grown_scale()
	z_index = 1 if day_look == Look.TODAY else 0
	_fit_inner()


## Today's size: its normal size times Month Today Scale (1 for other days).
func grown_scale() -> Vector2:
	return Vector2.ONE * (_style.month_today_scale if look == Look.TODAY else 1.0)


func _fit_inner() -> void:
	var needed := inner.get_combined_minimum_size()
	inner.size = needed
	inner.pivot_offset = needed / 2.0
	custom_minimum_size = needed


func _icon(texture: Texture2D, side: int) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = Vector2(side, side)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon
