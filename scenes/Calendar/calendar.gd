class_name CalendarScene
extends Control
## The run's calendar: an app on your phone, its boxes in the calendar's own dialogue-box
## style (data/dialogue_styles/calendar.tres).
##
## At the top: this chapter's days, a row each (the weekday on a name tab, what's on
## the day). Today is highlighted, days gone are faded, and the boss sits on the last
## day. "See the whole month" swaps the week for the whole month, small; days past this
## chapter show an X (data/calendar_rules.tres → Foresight Days lets you see further).
## At the bottom: today's 2-3 choices. Click one (or press 1-3) and it does what its
## action file says (data/day_actions/): changes attributes, plays a line from
## dialogue/calendar.dialogue in a box on the phone, uses up its days (or ends the
## chapter), and opens a screen (a date opens the dating app on the phone; a real-life
## screen, like a boss fight, puts the phone down).
## Press C for your Contacts.
##
## Every part is swappable: the layout is this scene (PhoneScreen → Phone → Body →
## Screen), a day in the week is Week Day Scene (DayRow.tscn), a day in the month is
## Month Day Scene (DayBox.tscn), a choice is Choice Scene (DayChoice.tscn); words,
## sizes, which parts show and sounds are Style; what's offered is Rules; the phone and
## your room behind it are data/phone_style.tres. Full guide: docs/guides/the-calendar.md

## The look, words, which parts show, and sounds (data/calendar_style.tres).
@export var style: CalendarStyle
## How the calendar runs and what it offers (data/calendar_rules.tres). Used when the run
## starts; after that the run keeps its calendar (PlayerManager.get_calendar()).
@export var rules: CalendarRules
## The lines actions can play (dialogue/calendar.dialogue).
@export var messages: DialogueResource
## One day in the week list. Make your own design from DayRow.tscn and drop it here.
@export var week_day_scene: PackedScene = preload("res://scenes/Calendar/DayRow.tscn")
## One day in the whole month. Make your own design from DayBox.tscn and drop it here.
@export var month_day_scene: PackedScene = preload("res://scenes/Calendar/DayBox.tscn")
## One of today's choices. Make your own design from DayChoice.tscn and drop it here.
@export var choice_scene: PackedScene = preload("res://scenes/Calendar/DayChoice.tscn")

var _calendar: RunCalendar
var _expanded := false
var _busy := false
var _choices: Array[DayChoice] = []

## The phone the calendar is on (its look and your room: data/phone_style.tres).
@onready var phone_screen: PhoneScreen = %PhoneScreen
@onready var title: Label = %Title
@onready var month_box: PanelContainer = %MonthBox
@onready var chapter_plate: PanelContainer = %ChapterPlate
@onready var chapter_label: Label = %ChapterLabel
@onready var days_left: Label = %DaysLeft
@onready var expand_button: Label = %ExpandButton
## This chapter's days, a row each.
@onready var week_scroll: ScrollContainer = %WeekScroll
@onready var week: VBoxContainer = %Week
## The whole month, when it's open.
@onready var days_grid: GridContainer = %Days
@onready var today_panel: Control = %TodayPanel
@onready var today_label: Label = %TodayLabel
@onready var choices_list: VBoxContainer = %Choices
@onready var dialogue_box: DialogueBox = %DialogueBox
@onready var contacts: ContactsApp = %ContactsApp
@onready var sound: AudioStreamPlayer = %Sound


func _ready() -> void:
	if not style:
		style = CalendarStyle.new()
	if not style.box_style:
		style.box_style = DialogueBoxStyle.new()
	_calendar = PlayerManager.get_calendar(rules)
	dialogue_box.default_style = style.box_style
	expand_button.gui_input.connect(_on_expand_input)
	month_box.draw.connect(_draw_outline)
	_apply_style()
	_refresh()


## Re-reads Style and rebuilds everything (e.g. after changing the style while playing).
func refresh_look() -> void:
	_apply_style()
	_refresh()


## Rebuilds the days and today's choices from the run's calendar.
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
	days_left.text = style.boss_today_text if _calendar.is_boss_day() else style.words(style.days_left_text, blanks)
	days_left.visible = style.show_days_left
	expand_button.text = style.collapse_text if _expanded else style.expand_text
	expand_button.visible = style.show_expand_button
	today_label.text = style.words(style.today_text, blanks)
	_build_days()
	_build_choices()


func _build_days() -> void:
	for holder: Container in [week, days_grid]:
		for child in holder.get_children():
			holder.remove_child(child)
			child.queue_free()
	week_scroll.visible = not _expanded
	days_grid.visible = _expanded
	week.add_theme_constant_override("separation", style.week_gap)
	days_grid.columns = maxi(style.weekdays.size(), 1)
	days_grid.add_theme_constant_override("h_separation", style.month_gap)
	days_grid.add_theme_constant_override("v_separation", style.month_gap)
	# The week: this chapter's days. The month: the whole calendar.
	var first := _calendar.calendar_day(1)
	var last := _calendar.calendar_day(_calendar.rules.days_per_chapter)
	if _expanded:
		first = 1
		last = _calendar.calendar_length()
	var today_number := _calendar.calendar_today()
	var today_box: DayBox = null
	for number in range(first, last + 1):
		var look := DayBox.Look.AHEAD
		if number < today_number:
			look = DayBox.Look.PAST
		elif number == today_number:
			look = DayBox.Look.TODAY
		elif not _calendar.is_revealed(number):
			look = DayBox.Look.HIDDEN
		var day_box := (month_day_scene if _expanded else week_day_scene).instantiate() as DayBox
		(days_grid if _expanded else week).add_child(day_box)
		day_box.setup(style, number, _calendar.day_at(number), look, _calendar.is_boss(number), _expanded)
		if look == DayBox.Look.TODAY:
			today_box = day_box
	# Today's row stays in view when the week doesn't fit.
	if today_box and not _expanded:
		await get_tree().process_frame
		if is_instance_valid(today_box):
			week_scroll.ensure_control_visible(today_box)


## The day boxes on show (the week's rows, or the month's squares).
func _day_boxes() -> Array[Node]:
	return days_grid.get_children() if _expanded else week.get_children()


func _build_choices() -> void:
	for child in choices_list.get_children():
		choices_list.remove_child(child)
		child.queue_free()
	_choices.clear()
	choices_list.add_theme_constant_override("separation", style.choice_gap)
	var options := _calendar.today_day().options
	for i in options.size():
		var choice := choice_scene.instantiate() as DayChoice
		choices_list.add_child(choice)
		choice.setup(style, options[i], i + 1, _calendar.fits(options[i]))
		choice.picked.connect(_on_picked)
		choice.blocked.connect(func(_choice: DayChoice) -> void: _play(style.blocked_sound))
		_choices.append(choice)


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
	await _pop_in_today()
	_busy = false


# A line from dialogue/calendar.dialogue in the calendar's box, at the bottom of the
# phone where today's choices were. The lines can use {{action}}, {{changes}},
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
	# The choices make way (keeping their room, so the week doesn't jump).
	today_panel.modulate.a = 0.0
	dialogue_box.start(messages, action.dialogue_title, [], [details])
	await dialogue_box.finished
	today_panel.modulate.a = 1.0


# Today's box pops up to its size, and the new choices fade in.
func _pop_in_today() -> void:
	await get_tree().process_frame
	for day_box: DayBox in _day_boxes():
		if day_box.look == DayBox.Look.TODAY:
			day_box.inner.scale = Vector2.ONE
			create_tween().tween_property(day_box.inner, "scale", day_box.grown_scale(), 0.25) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	choices_list.modulate.a = 0.0
	var fade := create_tween()
	fade.tween_property(choices_list, "modulate:a", 1.0, 0.2)
	await fade.finished


func _toggle_expanded() -> void:
	if _busy:
		return
	_expanded = not _expanded
	_play(style.expand_sound)
	# The whole month uses the room today's choices had; they come back when it closes.
	today_panel.visible = not _expanded
	_refresh()
	if not _expanded:
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


func _on_expand_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_toggle_expanded()


func _unhandled_input(event: InputEvent) -> void:
	if _busy or contacts.visible or not (event is InputEventKey) or not event.pressed or event.echo:
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
	var box := style.box_style
	var ui := phone_screen.style
	# The app's own words (title, how long to the boss, the button, "TODAY") are the
	# phone's; the boxes are the calendar's box style.
	ui.style_label(title, ui.ui_text_color, ui.title_font_size)
	ui.style_label(days_left, Color(ui.ui_text_color, 0.6), style.choice_detail_size + 6)
	ui.style_label(expand_button, ui.accent_color, style.choice_detail_size + 6)
	ui.style_label(today_label, Color(ui.ui_text_color, 0.5), style.choice_detail_size + 2)
	expand_button.mouse_filter = Control.MOUSE_FILTER_STOP
	expand_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# The page the days sit on: Page Image (calendar art) or the box style.
	var page := style.make_page_box()
	if not page:
		page = box.make_box()
		page.set_content_margin_all(style.page_box_padding)
	month_box.add_theme_stylebox_override("panel", page)
	chapter_plate.add_theme_stylebox_override("panel", box.make_name_plate())
	chapter_plate.visible = box.show_name_plate and style.show_chapter
	_font(chapter_label, box.name_font if box.name_font else box.text_font(), box.name_font_size, box.name_color)
	month_box.queue_redraw()


# The outline over a picture box, like a dialogue box's (not over calendar art).
func _draw_outline() -> void:
	if style.page_image:
		return
	var outline := style.box_style.make_outline()
	if outline:
		month_box.draw_style_box(outline, Rect2(Vector2.ZERO, month_box.size))


func _font(label: Label, font: Font, font_size: int, color: Color) -> void:
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)


func _play(stream: AudioStream) -> void:
	if stream:
		sound.stream = stream
		sound.volume_db = style.volume_db
		sound.play()
