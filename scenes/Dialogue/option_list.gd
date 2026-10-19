class_name OptionList
extends Control
## The player's choices. Shows each option as a button with its attribute check and,
## for a risky option (player below the requirement), its % chance. Picking one plays
## the roll, then reports what happened through option_resolved.
##
## Pick with the mouse, number keys 1-4, or arrow keys then Space/Enter.
## Its look and sounds come from Style (data/option_styles/default.tres).
## From code: show_options(responses, scorer). Full guide: docs/guides/options-and-scoring.md

## Sent after the roll animation finishes. The dialogue should continue down `response`.
signal option_resolved(response: DialogueResponse, result: DateScorer.Result)

@export var style: OptionListStyle
## Seconds after the options appear before a pick counts, so a player mashing
## Space to skip her text doesn't pick an option by accident.
@export_range(0.0, 2.0, 0.05) var input_delay: float = 0.35

const SOUND_CHANNELS := 3

var _scorer: DateScorer
var _options: Array[DateOption] = []
var _buttons: Array[Button] = []
var _badges: Array[PanelContainer] = []
var _busy := false
var _shown_at := 0.0
var _sound_players: Array[AudioStreamPlayer] = []
var _next_sound := 0

@onready var list: VBoxContainer = $Buttons


func _ready() -> void:
	if not style:
		style = OptionListStyle.new()
	for i in SOUND_CHANNELS:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sound_players.append(player)
	hide()


## Shows the choices for a line. The scorer works out each option's chance.
func show_options(responses: Array, scorer: DateScorer) -> void:
	_clear()
	_scorer = scorer
	list.add_theme_constant_override("separation", style.spacing)
	for i in responses.size():
		var option := DateOption.from_response(responses[i])
		_options.append(option)
		list.add_child(_make_slot(i, option))
	_busy = false
	_shown_at = Time.get_ticks_msec() / 1000.0
	show()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _busy:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var index: int = event.keycode - KEY_1
		if index >= 0 and index < _buttons.size():
			get_viewport().set_input_as_handled()
			_pick(index)
			return
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		if not _buttons.is_empty() and not _buttons.any(func(b: Button) -> bool: return b.has_focus()):
			get_viewport().set_input_as_handled()
			_buttons[0 if event.is_action_pressed("ui_down") else -1].grab_focus()


func _pick(index: int) -> void:
	if _busy or Time.get_ticks_msec() / 1000.0 - _shown_at < input_delay:
		return
	_busy = true
	var result := _scorer.resolve(_options[index])
	_play(style.select_sound)
	for i in _buttons.size():
		_buttons[i].disabled = true
		if i != index:
			create_tween().tween_property(_buttons[i].get_parent(), "modulate:a", 0.0, 0.2)

	if result.rolled:
		await _play_roll(index, result)
	else:
		_flash(index, style.hit_color)
		await get_tree().create_timer(0.35).timeout

	hide()
	_clear()
	option_resolved.emit(result.option.response, result)


# Spins the badge numbers, lands on the roll, then shows HIT or MISS.
func _play_roll(index: int, result: DateScorer.Result) -> void:
	var label: Label = _badges[index].get_child(0)
	var ticks := 14
	var wait := style.roll_seconds / 40.0
	for i in ticks:
		label.text = str(randi_range(1, 100))
		_play(style.roll_tick_sound)
		await get_tree().create_timer(wait).timeout
		wait *= 1.18
	label.text = str(result.roll)
	await get_tree().create_timer(0.3).timeout

	var color := style.hit_color if result.hit else style.miss_color
	_badges[index].add_theme_stylebox_override("panel", style.make_badge(color))
	label.text = style.hit_text if result.hit else style.miss_text
	_flash(index, color)
	_play(style.hit_sound if result.hit else style.miss_sound)
	await get_tree().create_timer(0.8).timeout


func _flash(index: int, color: Color) -> void:
	var box := style.make_button(style.hover_color, color)
	box.set_border_width_all(style.outline_width * 2)
	_buttons[index].add_theme_stylebox_override("disabled", box)


# Each button sits in a slot so it can slide sideways on hover without fighting the list's layout.
func _make_slot(index: int, option: DateOption) -> Control:
	var chance := _scorer.chance_of(option)
	var risky := chance < 100
	var line := style.risky_outline_color if risky else style.outline_color

	var button := Button.new()
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_stylebox_override("normal", style.make_button(style.button_color, line))
	button.add_theme_stylebox_override("hover", style.make_button(style.hover_color, style.hover_outline_color))
	button.add_theme_stylebox_override("pressed", style.make_button(style.hover_color, style.hover_outline_color))
	button.add_theme_stylebox_override("focus", style.make_button(style.hover_color, style.hover_outline_color))
	button.add_theme_stylebox_override("disabled", style.make_button(style.button_color, line))
	button.pressed.connect(_pick.bind(index))
	button.mouse_entered.connect(_on_hover.bind(button, true))
	button.mouse_exited.connect(_on_hover.bind(button, false))
	button.focus_entered.connect(_on_hover.bind(button, true))
	button.focus_exited.connect(_on_hover.bind(button, false))

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 20)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	button.add_child(row)

	if style.show_number_keys:
		row.add_child(_label(str(index + 1), style.number_key_color))
	var icon := style.icon_for(option.attribute)
	if icon:
		var picture := TextureRect.new()
		picture.texture = icon
		picture.custom_minimum_size = Vector2(style.icon_size, style.icon_size)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(picture)
	var text := _label(option.text, style.text_color)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(text)
	if option.has_check():
		row.add_child(_label("%s %d" % [Attr.display_name(option.attribute), option.requirement], style.check_color))

	var badge := PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", style.make_badge(style.badge_color))
	badge.add_child(_label("%d%%" % chance, style.badge_text_color))
	badge.visible = risky
	row.add_child(badge)

	var height := maxf(style.icon_size if icon else 0, style.font_size * 1.4) + style.padding * 2
	var slot := Control.new()
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.custom_minimum_size.y = height
	slot.add_child(button)
	slot.resized.connect(func() -> void:
		button.size = slot.size
		row.position = Vector2(style.padding, 0)
		row.size = Vector2(slot.size.x - style.padding * 2, slot.size.y)
	)
	_buttons.append(button)
	_badges.append(badge)
	return slot


func _label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", style.font_size)
	if style.font:
		label.add_theme_font_override("font", style.font)
	return label


func _on_hover(button: Button, on: bool) -> void:
	if _busy:
		return
	if on:
		_play(style.hover_sound)
	create_tween().tween_property(button, "position:x", -style.hover_slide if on else 0.0, 0.12) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _play(stream: AudioStream) -> void:
	if not stream:
		return
	var player := _sound_players[_next_sound]
	_next_sound = (_next_sound + 1) % _sound_players.size()
	player.stream = stream
	player.volume_db = style.volume_db
	player.play()


func _clear() -> void:
	for child in list.get_children():
		child.queue_free()
	_options.clear()
	_buttons.clear()
	_badges.clear()
