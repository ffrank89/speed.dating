class_name DayChoice
extends PanelContainer
## One of today's choices on the calendar: a bubble on today's card with the action's
## picture, title, how many days it takes, what it does, and a Pick button. Click it,
## or press its number key.
##
## Its parts are nodes in scenes/Calendar/DayChoice.tscn: move, resize or reorder them
## there. To use a different design, make your own choice scene with this script (and
## the same node names) and put it in the calendar's Choice Scene slot. Which parts show,
## sizes and words are data/calendar_style.tres; colours, font and the button are the
## player's style (data/player_style.tres).

## Clicked (or its key pressed) and it fits.
signal picked(choice: DayChoice)
## Clicked but it doesn't fit before the boss.
signal blocked(choice: DayChoice)

var action: DayAction
## False when it doesn't fit before the boss day.
var fits := true

var _style: CalendarStyle
var _player: PlayerStyle

@onready var icon: TextureRect = %Icon
@onready var title: Label = %Title
## How many days it takes (or "Not enough days left").
@onready var days: Label = %Days
## Its description, or what it changes.
@onready var detail: Label = %Detail
## The number key that picks it.
@onready var key: PanelContainer = %Key
@onready var key_label: Label = %KeyLabel
@onready var pick: Button = %Pick


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	resized.connect(func() -> void: pivot_offset = size / 2.0)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))
	pick.pressed.connect(press)
	pick.mouse_entered.connect(_on_hover.bind(true))


## Fills the choice in. Call it once it's in the scene. `font` = the font to use when the
## player's style has none (the phone's).
func setup(style: CalendarStyle, player: PlayerStyle, day_action: DayAction, key_number: int,
		does_fit: bool, font: Font = null) -> void:
	_style = style
	_player = player
	action = day_action
	fits = does_fit
	add_theme_stylebox_override("panel", player.make_panel(style.choice_padding))

	icon.texture = action.icon
	icon.visible = action.icon != null
	icon.custom_minimum_size = Vector2.ONE * style.choice_icon_size

	title.text = action.title
	player.style_label(title, font, style.choice_title_size)

	days.text = style.one_day_text if action.days == 1 else style.words(style.many_days_text, {"days": action.days})
	if not fits:
		days.text = style.not_enough_days_text
	player.style_label(days, font, style.choice_detail_size,
		player.today_color.lightened(0.45) if fits else player.boss_color.lightened(0.3))
	days.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	detail.text = action.description if not action.description.is_empty() else action.changes_text()
	detail.visible = style.show_details and not detail.text.is_empty()
	player.style_label(detail, font, style.choice_detail_size, player.faint_text_color)

	key.visible = style.show_keys
	key.add_theme_stylebox_override("panel", player.make_tab(player.panel_color.lightened(0.15)))
	key_label.text = str(key_number)
	player.style_label(key_label, font, style.pick_size)

	pick.text = style.pick_text
	pick.disabled = not fits
	for state in ["normal", "hover", "pressed", "disabled"]:
		pick.add_theme_stylebox_override(state, player.make_button(player.pick_color, state))
	pick.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var button_font := player.font_or(font)
	if button_font:
		pick.add_theme_font_override("font", button_font)
	pick.add_theme_font_size_override("font_size", style.pick_size)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		pick.add_theme_color_override(color_name, player.pick_text_color)
	pick.add_theme_color_override("font_disabled_color", Color(player.pick_text_color, 0.5))
	pick.add_theme_constant_override("outline_size", player.text_outline_width)
	pick.add_theme_color_override("font_outline_color", player.text_outline_color)

	modulate.a = 1.0 if fits else 0.6
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if fits else Control.CURSOR_FORBIDDEN


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
	# Still over the bubble when moving onto its button.
	if not on and get_global_rect().has_point(get_global_mouse_position()):
		return
	create_tween().tween_property(self, "scale", Vector2.ONE * (1.04 if on else 1.0), 0.1)
	if on and _style.hover_sound and scale.is_equal_approx(Vector2.ONE):
		var player := AudioStreamPlayer.new()
		player.stream = _style.hover_sound
		player.volume_db = _style.volume_db
		add_child(player)
		player.finished.connect(player.queue_free)
		player.play()
