class_name CalendarScene
extends Control
## The run's calendar: an app on your phone, laid out like Balatro's blinds.
##
## Three day cards, stacked: today's at the top with its 2-3 choices side by side, then
## the next two days, dimmed and "Upcoming", showing what they'll offer. Each card's
## border and tab are coloured by what the day is (today, coming up, the boss, too far
## ahead to see). Click a choice's Pick (or press 1-3) and it does what its action file
## says (data/day_actions/): changes attributes, plays a line from
## dialogue/calendar.dialogue in a box on the phone, uses up its days (or ends the
## chapter), and opens a screen (a date opens the dating app on the phone; a real-life
## screen, like a boss fight, puts the phone down).
## "Month" swaps the cards for the whole month, small; days past this chapter show an X
## (data/calendar_rules.tres → Foresight Days lets you see further).
## C and P switch to your other apps, Contacts and Profile (a debug note says so).
##
## Every part is swappable: the layout is this scene (PhoneScreen → Phone → Body →
## Screen), a day is Card Scene (DayCard.tscn), a choice is Choice Scene
## (DayChoice.tscn), a day in the month is Month Day Scene (DayBox.tscn). Words, sizes,
## what shows and sounds are Style; the colours, font and buttons are Player Style;
## what's offered is Rules; the phone and your room behind it are data/phone_style.tres.
## Full guide: docs/guides/the-calendar.md

## Words, sizes, which parts show, calendar art and sounds (data/calendar_style.tres).
@export var style: CalendarStyle
## The player's look: the cards' colours, font, borders and buttons (data/player_style.tres).
@export var player_style: PlayerStyle
## How the calendar runs and what it offers (data/calendar_rules.tres). Used when the run
## starts; after that the run keeps its calendar (PlayerManager.get_calendar()).
@export var rules: CalendarRules
## The lines actions can play (dialogue/calendar.dialogue).
@export var messages: DialogueResource
## One day's card. Make your own design from DayCard.tscn and drop it here.
@export var card_scene: PackedScene = preload("res://scenes/Calendar/DayCard.tscn")
## One of today's choices. Make your own design from DayChoice.tscn and drop it here.
@export var choice_scene: PackedScene = preload("res://scenes/Calendar/DayChoice.tscn")
## One day in the whole month. Make your own design from DayBox.tscn and drop it here.
@export var month_day_scene: PackedScene = preload("res://scenes/Calendar/DayBox.tscn")

var _calendar: RunCalendar
var _expanded := false
var _busy := false
var _choices: Array[DayChoice] = []

## The phone the calendar is on (its look and your room: data/phone_style.tres).
@onready var phone_screen: PhoneScreen = %PhoneScreen
@onready var title: Label = %Title
@onready var chapter_label: Label = %ChapterLabel
@onready var days_left: Label = %DaysLeft
@onready var expand_button: Button = %ExpandButton
## Today's card and the days coming up.
@onready var cards: VBoxContainer = %Cards
## The whole month, when it's open.
@onready var month_box: PanelContainer = %MonthBox
@onready var days_grid: GridContainer = %Days
@onready var dialogue_box: DialogueBox = %DialogueBox
@onready var contacts: ContactsApp = %ContactsApp
@onready var profile: ProfileApp = %ProfileApp
@onready var sound: AudioStreamPlayer = %Sound


func _ready() -> void:
	if not style:
		style = CalendarStyle.new()
	if not style.box_style:
		style.box_style = DialogueBoxStyle.new()
	if not player_style:
		player_style = PlayerStyle.new()
	_calendar = PlayerManager.get_calendar(rules)
	dialogue_box.default_style = style.box_style
	expand_button.pressed.connect(_toggle_expanded)
	_apply_style()
	_refresh()


## Re-reads the styles and rebuilds everything (e.g. after changing a style while playing).
func refresh_look() -> void:
	_apply_style()
	_refresh()


## Rebuilds the cards (or the month) and today's choices from the run's calendar.
func _refresh() -> void:
	var today_number := _calendar.calendar_today()
	var blanks := {
		"chapter": _calendar.chapter,
		"days": _calendar.days_until_boss(),
		"weekday": style.weekday(today_number),
		"day": today_number,
	}
	title.text = style.title_text
	chapter_label.text = style.words(style.chapter_text, blanks)
	chapter_label.visible = style.show_chapter
	days_left.text = style.words(style.one_day_left_text if _calendar.days_until_boss() == 1 else style.days_left_text, blanks)
	if _calendar.is_boss_day():
		days_left.text = style.boss_today_text
	days_left.visible = style.show_days_left
	expand_button.text = style.collapse_text if _expanded else style.expand_text
	expand_button.visible = style.show_expand_button
	cards.visible = not _expanded
	month_box.visible = _expanded
	if _expanded:
		_build_month()
	else:
		_build_cards()


# Today's card with its choices, then the days coming up.
func _build_cards() -> void:
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
	_choices.clear()
	cards.add_theme_constant_override("separation", style.card_gap)
	var font := phone_screen.style.ui_font
	var today_number := _calendar.calendar_today()
	for offset in range(style.upcoming_days + 1):
		var number := today_number + offset
		if number > _calendar.calendar_length():
			break
		var card := card_scene.instantiate() as DayCard
		cards.add_child(card)
		card.setup(style, player_style, number, _calendar.day_at(number), offset == 0,
			_calendar.is_boss(number), _calendar.is_revealed(number), font)
		if offset == 0:
			_build_choices(card)


func _build_choices(card: DayCard) -> void:
	card.choices.add_theme_constant_override("separation", style.choice_gap)
	var options := _calendar.today_day().options
	for i in options.size():
		var choice := choice_scene.instantiate() as DayChoice
		card.choices.add_child(choice)
		choice.setup(style, player_style, options[i], _calendar.fits(options[i]), phone_screen.style.ui_font)
		choice.picked.connect(_on_picked)
		choice.blocked.connect(func(_choice: DayChoice) -> void: _play(style.blocked_sound))
		_choices.append(choice)


# The whole month, small: every day, X'd out past what you can see.
func _build_month() -> void:
	for child in days_grid.get_children():
		days_grid.remove_child(child)
		child.queue_free()
	_choices.clear()
	days_grid.columns = maxi(style.weekdays.size(), 1)
	days_grid.add_theme_constant_override("h_separation", style.month_gap)
	days_grid.add_theme_constant_override("v_separation", style.month_gap)
	var today_number := _calendar.calendar_today()
	for number in range(1, _calendar.calendar_length() + 1):
		var look := DayBox.Look.AHEAD
		if number < today_number:
			look = DayBox.Look.PAST
		elif number == today_number:
			look = DayBox.Look.TODAY
		elif not _calendar.is_revealed(number):
			look = DayBox.Look.HIDDEN
		var day_box := month_day_scene.instantiate() as DayBox
		days_grid.add_child(day_box)
		day_box.setup(style, player_style, number, _calendar.day_at(number), look,
			_calendar.is_boss(number), phone_screen.style.ui_font)


func _on_picked(choice: DayChoice) -> void:
	if _busy or AppLauncher.is_busy():
		return
	_busy = true
	_play(style.pick_sound)
	var action := choice.action
	# The action's parts, in order (each one only if the action has it).
	var changes := action.attribute_changes()
	if not changes.is_empty():
		var player := PlayerManager.ensure_player()
		for attr in changes:
			player.increase_skill(Attr.display_name(attr), changes[attr])
	await _say(action)
	if action.ends_chapter:
		_calendar.next_chapter()
	else:
		_calendar.spend(action)
	if not action.scene.is_empty():
		# Its days are already used up; the screen it opens comes back to the calendar.
		if action.real_life:
			AppLauncher.phone_down(action.scene)
		else:
			AppLauncher.open_scene(action.app_name if not action.app_name.is_empty() else "calendar", action.scene, choice.get_global_rect())
		return
	_play(style.day_done_sound)
	_refresh()
	await _slide_in_cards()
	_busy = false


# A line from dialogue/calendar.dialogue in the calendar's box, at the bottom of the
# phone over the days coming up. The lines can use {{action}}, {{changes}},
# {{attribute}} and {{amount}}.
func _say(action: DayAction) -> void:
	if not messages or action.dialogue_title.is_empty() or not messages.get_titles().has(action.dialogue_title):
		return
	var changes := action.attribute_changes()
	var first: int = changes.keys()[0] if not changes.is_empty() else -1
	var details := {
		"action": action.title,
		"changes": action.changes_text(),
		"attribute": Attr.display_name(first) if first >= 0 else "",
		"amount": changes[first] if first >= 0 else 0,
	}
	# The days coming up make way (keeping their room, so today's card doesn't move).
	for card: DayCard in cards.get_children():
		if not card.is_today:
			card.modulate.a = 0.0
	dialogue_box.start(messages, action.dialogue_title, [], [details])
	await dialogue_box.finished


# A day has passed: the cards fade in and settle, one after another. (They only change
# how they're drawn, never where they sit: the column keeps them in place.)
func _slide_in_cards() -> void:
	var appear: Tween = null
	var list := cards.get_children()
	for i in list.size():
		var card: DayCard = list[i]
		var target := card.modulate.a
		card.modulate.a = 0.0
		card.scale = Vector2.ONE * 0.94
		card.resized.connect(func() -> void: card.pivot_offset = card.size / 2.0)
		card.pivot_offset = card.size / 2.0
		appear = create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		appear.tween_property(card, "scale", Vector2.ONE, style.slide_seconds).set_delay(i * 0.07)
		appear.tween_property(card, "modulate:a", target, style.slide_seconds * 0.6).set_delay(i * 0.07)
	if appear:
		await appear.finished


func _toggle_expanded() -> void:
	if _busy:
		return
	_expanded = not _expanded
	_play(style.expand_sound)
	_refresh()
	if not _expanded:
		await _slide_in_cards()
		return
	# The weeks pop in one after another.
	var columns := days_grid.columns
	var boxes := days_grid.get_children()
	for i in boxes.size():
		var day_box: Control = boxes[i]
		var target := day_box.modulate.a
		day_box.modulate.a = 0.0
		var pop := create_tween()
		pop.tween_interval(style.row_pop_seconds * (i / columns))
		pop.tween_property(day_box, "modulate:a", target, 0.15)


func _unhandled_input(event: InputEvent) -> void:
	if _busy or contacts.visible or profile.visible or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key: int = event.keycode if event.keycode != KEY_NONE else event.physical_keycode
	var index := key - KEY_1
	if index >= 0 and index < _choices.size() and not _expanded:
		get_viewport().set_input_as_handled()
		_choices[index].press()
	elif key == KEY_ESCAPE and _expanded:
		get_viewport().set_input_as_handled()
		_toggle_expanded()


func _apply_style() -> void:
	var ui := phone_screen.style
	var player := player_style
	# The app's title and how long to the boss are the phone's words; the Month button is
	# the player's.
	ui.style_label(title, ui.ui_text_color, ui.title_font_size)
	ui.style_label(chapter_label, Color(ui.ui_text_color, 0.5), style.choice_detail_size + 6)
	ui.style_label(days_left, Color(ui.ui_text_color, 0.6), style.choice_detail_size + 8)
	_style_button(expand_button, player.month_button_color)
	# The page the whole month sits on: Page Image (calendar art) or a player's card.
	var page := style.make_page_box()
	if not page:
		page = player.make_card(player.upcoming_color, style.page_box_padding)
	month_box.add_theme_stylebox_override("panel", page)
	month_box.queue_redraw()


# A chunky button in the player's style.
func _style_button(button: Button, color: Color) -> void:
	var player := player_style
	for state in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, player.make_button(color, state))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var font := player.font_or(phone_screen.style.ui_font)
	if font:
		button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", style.button_size)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(color_name, player.button_text_color)
	button.add_theme_constant_override("outline_size", player.text_outline_width)
	button.add_theme_color_override("font_outline_color", player.text_outline_color)


func _play(stream: AudioStream) -> void:
	if stream:
		sound.stream = stream
		sound.volume_db = style.volume_db
		sound.play()
