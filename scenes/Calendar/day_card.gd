class_name DayCard
extends PanelContainer
## One day on the calendar's main view, like a blind in Balatro: a card in the player's
## style whose border and name tab are coloured by what the day is (today, coming up,
## the boss, too far ahead to see).
##   Today: its choices side by side (the calendar puts a DayChoice for each into Choices).
##   Coming up: dimmed, "Upcoming", with little pictures of what it'll offer.
##   The boss: its picture, BOSS and what it does.
##   Too far ahead: the X.
##
## Its parts are nodes in scenes/Calendar/DayCard.tscn: move, resize or reorder them
## there. To use a different design, make your own scene with this script (and the same
## node names) and put it in the calendar's Card Scene slot. Words, sizes and what shows
## are data/calendar_style.tres; colours, font and borders are data/player_style.tres.

## The day's calendar-day number (1 = the run's first day).
var number := 0
var is_today := false

@onready var tab: PanelContainer = %Tab
@onready var tab_label: Label = %TabLabel
## "Upcoming", or "Can't see that far ahead".
@onready var status: Label = %Status
## Today's choices go here.
@onready var choices: HBoxContainer = %Choices
## What a day coming up offers.
@onready var offers: HBoxContainer = %Offers
@onready var boss: Control = %Boss
@onready var boss_icon: TextureRect = %BossIcon
@onready var boss_title: Label = %BossTitle
@onready var boss_detail: Label = %BossDetail
@onready var hidden_part: Control = %Hidden
@onready var hidden_mark: TextureRect = %HiddenMark
@onready var hidden_words: Label = %HiddenWords


## Fills the card in. `day` = what's on it; `today` = today's card (the calendar adds
## its choices); `seen` = false for a day too far ahead to see; `font` = the font when
## the player's style has none (the phone's).
func setup(style: CalendarStyle, player: PlayerStyle, day_number: int, day: RunCalendar.Day,
		today: bool, boss_day: bool, seen: bool, font: Font = null) -> void:
	number = day_number
	is_today = today
	var edge := player.day_color(today, boss_day, not seen)

	# Calendar art (Day Image), or the player's card with a border in the day's colour.
	var panel := style.make_day_box()
	if panel:
		panel.set_content_margin_all(style.card_padding)
	else:
		panel = player.make_card(edge, style.card_padding)
	add_theme_stylebox_override("panel", panel)
	# On calendar art, its Day Text Color; on the player's card, the faint colour.
	var ink := style.day_text_color if style.day_image else player.faint_text_color

	var blanks := {"weekday": style.weekday(day_number), "day": day_number}
	tab.add_theme_stylebox_override("panel", player.make_tab(edge))
	tab_label.text = style.words(style.today_text if today else style.day_text, blanks)
	player.style_label(tab_label, font, style.tab_size)
	tab.visible = style.show_weekdays or today

	status.text = "" if today else (style.upcoming_text if seen else style.hidden_text)
	status.visible = not status.text.is_empty()
	player.style_label(status, font, style.upcoming_title_size, ink)

	for child in offers.get_children():
		child.queue_free()
	choices.visible = today
	offers.visible = false
	boss.visible = false
	hidden_part.visible = false
	if not seen:
		hidden_part.visible = true
		hidden_mark.texture = style.hidden_mark
		hidden_mark.visible = style.hidden_mark != null
		hidden_mark.custom_minimum_size = Vector2.ONE * style.boss_icon_size
		hidden_words.text = "" if style.hidden_mark else "✕"
		player.style_label(hidden_words, font, style.boss_icon_size if not style.hidden_mark else style.upcoming_title_size, ink)
		status.visible = true
	elif boss_day and not today and not day.options.is_empty():
		var boss_action: DayAction = day.options[0]
		boss.visible = true
		boss_icon.texture = boss_action.icon
		boss_icon.visible = boss_action.icon != null
		boss_icon.custom_minimum_size = Vector2.ONE * style.boss_icon_size
		boss_title.text = style.boss_text
		player.style_label(boss_title, font, style.choice_title_size + 8, player.boss_color)
		boss_detail.text = boss_action.description
		boss_detail.visible = not boss_action.description.is_empty()
		player.style_label(boss_detail, font, style.choice_detail_size, ink)
	elif not today:
		offers.visible = style.show_offers
		for action in day.options:
			offers.add_child(_offer(action, style, player, font, ink))

	modulate.a = 1.0 if today else player.upcoming_alpha
	tooltip_text = ""
	if style.show_tooltips and seen and not today:
		tooltip_text = ", ".join(day.options.map(func(action: DayAction) -> String: return action.title))


# A day coming up: an offer's little picture with its title underneath.
func _offer(action: DayAction, style: CalendarStyle, player: PlayerStyle, font: Font, ink: Color) -> Control:
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 4)
	if action.icon:
		var picture := TextureRect.new()
		picture.texture = action.icon
		picture.custom_minimum_size = Vector2.ONE * style.upcoming_icon_size
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(picture)
	var words := Label.new()
	words.text = action.title
	words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player.style_label(words, font, style.upcoming_title_size, ink)
	column.add_child(words)
	return column
