class_name DayChoice
extends PanelContainer
## One of today's choices on the calendar: a box on today's card with the action's
## picture, title, how many days it takes, and what it does. Click it to pick it (it
## lights up under the mouse). The number keys 1-3 pick them too.
##
## Its parts are nodes in scenes/Calendar/DayChoice.tscn: move, resize or reorder them
## there. To use a different design, make your own choice scene with this script (and
## the same node names) and put it in the calendar's Choice Scene slot. Which parts show,
## sizes and words are data/calendar_style.tres; colours, font and the highlight are the
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
var _hovered := false

@onready var icon: TextureRect = %Icon
@onready var title: Label = %Title
## How many days it takes (or "Not enough days left").
@onready var days: Label = %Days
## Its description, or what it changes.
@onready var detail: Label = %Detail


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	resized.connect(func() -> void: pivot_offset = size / 2.0)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))


## Fills the choice in. Call it once it's in the scene. `font` = the font to use when the
## player's style has none (the phone's).
func setup(style: CalendarStyle, player: PlayerStyle, day_action: DayAction, does_fit: bool,
		font: Font = null) -> void:
	_style = style
	_player = player
	action = day_action
	fits = does_fit
	_set_panel(false)

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


# The panel, lit up (Choice Hover Color border) while the mouse is over it.
func _set_panel(lit: bool) -> void:
	add_theme_stylebox_override("panel", _player.make_panel(_style.choice_padding, lit))


func _on_hover(on: bool) -> void:
	if not fits or not _style or on == _hovered:
		return
	_hovered = on
	_set_panel(on)
	create_tween().tween_property(self, "scale", Vector2.ONE * (1.05 if on else 1.0), 0.1)
	if on and _style.hover_sound:
		var player := AudioStreamPlayer.new()
		player.stream = _style.hover_sound
		player.volume_db = _style.volume_db
		add_child(player)
		player.finished.connect(player.queue_free)
		player.play()
