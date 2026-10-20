class_name CalendarScene
extends Control
## The run's calendar, in its own dialogue-box style (data/dialogue_styles/calendar.tres).
##
## At the top: this chapter's days, each in a box with its weekday on a name tab. Today
## is highlighted, days gone are faded, and the boss sits on the last day. "See the
## whole month" opens up the rest of the calendar; days past this chapter show an X
## (data/calendar_rules.tres → Foresight Days lets you see further).
## At the bottom: today's 2-3 choices. Click one (or press 1-3) and it does what its
## action file says (data/day_actions/): changes attributes, plays a line from
## dialogue/calendar.dialogue, uses up its days (or ends the chapter), and opens a
## screen (a date opens the dating app).
## Press C for your Contacts.
##
## Every part is swappable: the layout is this scene, one day is Day Scene
## (DayBox.tscn), one choice is Choice Scene (DayChoice.tscn); words, sizes, which parts
## show and sounds are Style; what's offered is Rules. Full guide: docs/guides/the-calendar.md

## The look, words, which parts show, and sounds (data/calendar_style.tres).
@export var style: CalendarStyle
## How the calendar runs and what it offers (data/calendar_rules.tres). Used when the run
## starts; after that the run keeps its calendar (PlayerManager.get_calendar()).
@export var rules: CalendarRules
## The lines actions can play (dialogue/calendar.dialogue).
@export var messages: DialogueResource
## One day on the calendar. Make your own design from DayBox.tscn and drop it here.
@export var day_scene: PackedScene = preload("res://scenes/Calendar/DayBox.tscn")
## One of today's choices. Make your own design from DayChoice.tscn and drop it here.
@export var choice_scene: PackedScene = preload("res://scenes/Calendar/DayChoice.tscn")

var _calendar: RunCalendar
var _expanded := false
var _busy := false
var _choices: Array[DayChoice] = []
# Top's bottom edge with today's choices showing (the whole calendar takes their room).
var _top_bottom := 0.0

@onready var background: Control = $Background
@onready var background_image: TextureRect = %BackgroundImage
@onready var background_dim: ColorRect = %BackgroundDim
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
	_calendar = PlayerManager.get_calendar(rules)
	dialogue_box.default_style = style.box_style
	_top_bottom = top.offset_bottom
	expand_button.gui_input.connect(_on_expand_input)
	for panel: PanelContainer in [month_box, today_box]:
		panel.draw.connect(_draw_outline.bind(panel))
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
	chapter_label.text = style.words(style.chapter_text, blanks)
	days_left.text = style.boss_today_text if _calendar.is_boss_day() else style.words(style.days_left_text, blanks)
	days_left.visible = style.show_days_left
	expand_button.text = style.collapse_text if _expanded else style.expand_text
	expand_button.visible = style.show_expand_button
	today_label.text = style.words(style.today_text, blanks)
	_build_days()
	_build_choices()


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
		var day_box := day_scene.instantiate() as DayBox
		days_grid.add_child(day_box)
		day_box.setup(style, number, _calendar.day_at(number), look, _calendar.is_boss(number),
			style.month_day_size if _expanded else style.day_size)


func _build_choices() -> void:
	for child in choices_row.get_children():
		choices_row.remove_child(child)
		child.queue_free()
	_choices.clear()
	var options := _calendar.today_day().options
	for i in options.size():
		var choice := choice_scene.instantiate() as DayChoice
		choices_row.add_child(choice)
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
		AppLauncher.open_scene(action.app_name if not action.app_name.is_empty() else "calendar", action.scene, choice.get_global_rect())
		return
	_play(style.day_done_sound)
	_refresh()
	await _pop_in_today()
	_busy = false


# A line from dialogue/calendar.dialogue in the calendar's box, where today's choices
# were. The lines can use {{action}}, {{changes}}, {{attribute}} and {{amount}}.
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
	chapter_plate.visible = box.show_name_plate and style.show_chapter
	# A picture behind everything, or the animated pattern.
	background_image.texture = style.background_image
	background_image.visible = style.background_image != null
	background_dim.color = style.background_dim
	background_dim.visible = style.background_image != null
	background.visible = style.background_image == null
	for label: Label in [chapter_label, today_label]:
		_font(label, box.name_font if box.name_font else box.text_font(), box.name_font_size, box.name_color)
	_font(days_left, box.text_font(), style.choice_detail_size, box.text_color)
	# The accent colour of the box's "next" arrow, which is made to show up on the box.
	_font(expand_button, box.text_font(), style.choice_detail_size, box.next_arrow_color)
	expand_button.mouse_filter = Control.MOUSE_FILTER_STOP
	expand_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	month_box.queue_redraw()
	today_box.queue_redraw()


# The outline over a picture box, like a dialogue box's.
func _draw_outline(panel: PanelContainer) -> void:
	var outline := style.box_style.make_outline()
	if outline:
		panel.draw_style_box(outline, Rect2(Vector2.ZERO, panel.size))


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
