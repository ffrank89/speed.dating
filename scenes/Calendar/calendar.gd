class_name CalendarScene
extends Control
## The run's calendar, in its own dialogue-box style (data/dialogue_styles/calendar.tres).
##
## At the top: this chapter's days, each in a box with its weekday on a name tab. Today
## is highlighted, days gone are faded, and the boss sits on the last day. "See the
## whole month" opens up the rest of the calendar; days past this chapter show an X
## (data/calendar_rules.tres → Foresight Days lets you see further).
## At the bottom: today's 2-3 choices. Click one (or press 1-3) and it uses up its days:
##   a date opens the dating app (2 days),
##   training raises an attribute and a rest day passes, each with a line from
##     dialogue/calendar.dialogue,
##   the boss day (placeholder) says so and starts the next chapter.
## Press C for your Contacts.
##
## Look and words: data/calendar_style.tres. What's offered: data/calendar_rules.tres
## and data/day_actions/. Full guide: docs/guides/the-calendar.md

## The look, words and sounds (data/calendar_style.tres).
@export var style: CalendarStyle
## The lines for training, rest and the boss (dialogue/calendar.dialogue).
@export var messages: DialogueResource

var _calendar: RunCalendar
var _expanded := false
var _busy := false
var _choices: Array[DayChoice] = []
# Top's bottom edge with today's choices showing (the whole calendar takes their room).
var _top_bottom := 0.0

@onready var top: Control = $Top
@onready var month_box: PanelContainer = %MonthBox
@onready var chapter_plate: PanelContainer = %ChapterPlate
@onready var chapter_label: Label = %ChapterLabel
@onready var days_left: Label = %DaysLeft
@onready var expand_button: Label = %ExpandButton
@onready var days_grid: GridContainer = %Days
@onready var today_panel: Control = %TodayPanel
@onready var today_box: PanelContainer = %TodayBox
@onready var today_plate: PanelContainer = %TodayPlate
@onready var today_label: Label = %TodayLabel
@onready var choices_row: HBoxContainer = %Choices
@onready var dialogue_box: DialogueBox = %DialogueBox
@onready var contacts: ContactsApp = %ContactsApp
@onready var sound: AudioStreamPlayer = %Sound


func _ready() -> void:
	if not style:
		style = CalendarStyle.new()
	if not style.box_style:
		style.box_style = DialogueBoxStyle.new()
	_calendar = PlayerManager.get_calendar()
	dialogue_box.default_style = style.box_style
	_top_bottom = top.offset_bottom
	expand_button.gui_input.connect(_on_expand_input)
	_apply_style()
	_refresh()


## Rebuilds the days and today's choices from the run's calendar.
func _refresh() -> void:
	chapter_label.text = style.chapter_text % _calendar.chapter
	days_left.text = style.boss_today_text if _calendar.is_boss_day() else style.days_left_text % _calendar.days_until_boss()
	expand_button.text = style.collapse_text if _expanded else style.expand_text
	_build_days()
	_build_choices()
	today_label.text = style.today_text % [_weekday(_calendar.calendar_today()), _calendar.calendar_today()]


func _build_days() -> void:
	for child in days_grid.get_children():
		days_grid.remove_child(child)
		child.queue_free()
	days_grid.columns = maxi(style.weekdays.size(), 1)
	days_grid.add_theme_constant_override("h_separation", style.day_gap)
	days_grid.add_theme_constant_override("v_separation", style.day_gap + 20)
	var first := _calendar.calendar_day(1)
	var last := _calendar.calendar_day(_calendar.rules.days_per_chapter)
	if _expanded:
		first = 1
		last = _calendar.calendar_length()
	var today_number := _calendar.calendar_today()
	for number in range(first, last + 1):
		var look := DayBox.Look.AHEAD
		if number < today_number:
			look = DayBox.Look.PAST
		elif number == today_number:
			look = DayBox.Look.TODAY
		elif not _calendar.is_revealed(number):
			look = DayBox.Look.HIDDEN
		var day_box := DayBox.new()
		day_box.setup(style, number, _calendar.day_at(number), look, _calendar.is_boss(number))
		days_grid.add_child(day_box)


func _build_choices() -> void:
	for child in choices_row.get_children():
		choices_row.remove_child(child)
		child.queue_free()
	_choices.clear()
	var options := _calendar.today_day().options
	for i in options.size():
		var choice := DayChoice.new()
		choice.setup(style, options[i], i + 1, _calendar.fits(options[i]))
		choice.picked.connect(_on_picked)
		choice.blocked.connect(func(_choice: DayChoice) -> void: _play(style.blocked_sound))
		choices_row.add_child(choice)
		_choices.append(choice)


func _on_picked(choice: DayChoice) -> void:
	if _busy or AppLauncher.is_busy():
		return
	_busy = true
	_play(style.pick_sound)
	var action := choice.action
	match action.kind:
		DayAction.Kind.DATE:
			# The date's days are used up now; the date scene comes back to the calendar.
			_calendar.spend(action)
			AppLauncher.open_scene(action.app_name, action.scene, choice.get_global_rect())
			return
		DayAction.Kind.TRAIN:
			var player := PlayerManager.ensure_player()
			player.increase_skill(Attr.display_name(action.attribute), action.amount)
			await _say(action)
			_calendar.spend(action)
		DayAction.Kind.REST:
			await _say(action)
			_calendar.spend(action)
		DayAction.Kind.BOSS:
			# Placeholder until the boss fight exists: on to the next chapter.
			await _say(action)
			_calendar.next_chapter()
	_play(style.day_done_sound)
	_refresh()
	await _pop_in_today()
	_busy = false


# A line from dialogue/calendar.dialogue in the calendar's box, where today's choices
# were. The lines can use {{action}}, {{attribute}} and {{amount}}.
func _say(action: DayAction) -> void:
	if not messages or action.dialogue_title.is_empty() or not messages.get_titles().has(action.dialogue_title):
		return
	var details := {
		"action": action.title,
		"attribute": Attr.display_name(action.attribute),
		"amount": action.amount,
	}
	today_panel.visible = false
	dialogue_box.start(messages, action.dialogue_title, [], [details])
	await dialogue_box.finished
	today_panel.visible = true


# Today's box pops up to its size, and the new choices fade in.
func _pop_in_today() -> void:
	await get_tree().process_frame
	for day_box: DayBox in days_grid.get_children():
		if day_box.look == DayBox.Look.TODAY:
			day_box.inner.scale = Vector2.ONE
			create_tween().tween_property(day_box.inner, "scale", day_box.grown_scale(), 0.25) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	choices_row.modulate.a = 0.0
	var fade := create_tween()
	fade.tween_property(choices_row, "modulate:a", 1.0, 0.2)
	await fade.finished


func _toggle_expanded() -> void:
	if _busy:
		return
	_expanded = not _expanded
	_play(style.expand_sound)
	# The whole calendar uses the room today's choices had; they come back when it closes.
	today_panel.visible = not _expanded
	top.offset_bottom = -top.offset_top if _expanded else _top_bottom
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
	month_box.add_theme_stylebox_override("panel", box.make_box())
	today_box.add_theme_stylebox_override("panel", box.make_box())
	for plate: PanelContainer in [chapter_plate, today_plate]:
		plate.add_theme_stylebox_override("panel", box.make_name_plate())
		plate.visible = box.show_name_plate
	for label: Label in [chapter_label, today_label]:
		_font(label, box.name_font if box.name_font else box.text_font(), box.name_font_size, box.name_color)
	_font(days_left, box.text_font(), style.choice_detail_size, box.text_color)
	# The accent colour of the box's "next" arrow, which is made to show up on the box.
	_font(expand_button, box.text_font(), style.choice_detail_size, box.next_arrow_color)
	expand_button.mouse_filter = Control.MOUSE_FILTER_STOP
	expand_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for panel: PanelContainer in [month_box, today_box]:
		panel.draw.connect(func() -> void:
			var outline := box.make_outline()
			if outline:
				panel.draw_style_box(outline, Rect2(Vector2.ZERO, panel.size)))


func _weekday(number: int) -> String:
	if style.weekdays.is_empty():
		return ""
	return style.weekdays[(number - 1) % style.weekdays.size()]


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
