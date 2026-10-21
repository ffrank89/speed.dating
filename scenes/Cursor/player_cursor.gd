extends CanvasLayer
## PlayerCursor (autoload): shows the player's cursor everywhere in the game, from a
## CursorStyle (data/cursors/default.tres unless told otherwise).
##
## The picture changes when hovering something clickable (any Control whose Mouse
## Default Cursor Shape is Pointing Hand, e.g. option bubbles and app icons), while the
## button is held, and while dragging. Change the default in this scene's Style slot,
## or switch from code: PlayerCursor.use(load("res://data/cursors/other.tres")).
##
## The action cursor (stage hazard cursor): while something allows it (a date's stage
## hazards), the Action Key (S) switches to Action Style and back. Things like the fly
## can only be dealt with while it's on.
## Full guide: docs/guides/cursor.md

## Sent when the action cursor turns on or off.
signal action_mode_changed(on: bool)

## The cursor to use (a file from data/cursors/).
@export var style: CursorStyle
## The action cursor, for dealing with stage hazards (data/cursors/action.tres).
@export var action_style: CursorStyle
## The key that switches to the action cursor and back: an action in Project Settings →
## Input Map (action_cursor = S).
@export var action_key: StringName = &"action_cursor"

## True while the action cursor is on.
var action_mode := false
## Whether the Action Key works right now. A date's stage hazards turn this on (and off
## during microgames and when the date ends). Turning it off turns the action cursor off.
var action_allowed := false:
	set(value):
		action_allowed = value
		if not value:
			set_action_mode(false)

# The normal cursor (what Style was set to), shown whenever the action cursor is off.
var _normal_style: CursorStyle

var _pressed := false
var _drawn: TextureRect
var _shown_texture: Texture2D
var _squish: Tween


func _ready() -> void:
	layer = 128
	_drawn = TextureRect.new()
	_drawn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drawn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_drawn.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_drawn.visible = false
	add_child(_drawn)
	use(style)


## Switches to another normal cursor (null = the computer's normal arrow).
func use(new_style: CursorStyle) -> void:
	_normal_style = new_style
	if not action_mode:
		_show(new_style)


## Turns the action cursor on or off.
func set_action_mode(on: bool) -> void:
	if on == action_mode:
		return
	action_mode = on
	_show(action_style if on and action_style else _normal_style)
	action_mode_changed.emit(on)


func _unhandled_input(event: InputEvent) -> void:
	if action_allowed and InputMap.has_action(action_key) and event.is_action_pressed(action_key):
		get_viewport().set_input_as_handled()
		set_action_mode(not action_mode)


func _show(new_style: CursorStyle) -> void:
	style = new_style
	_shown_texture = null
	_drawn.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for shape in [Input.CURSOR_ARROW, Input.CURSOR_POINTING_HAND, Input.CURSOR_DRAG, Input.CURSOR_CAN_DROP]:
		Input.set_custom_mouse_cursor(null, shape)
	if not style or not style.image:
		return
	if style.drawn_in_game:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		_drawn.visible = true
		_drawn.modulate = style.tint
	else:
		_set_system_cursors()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_pressed = event.pressed
		if not style or not style.image:
			return
		if style.drawn_in_game:
			_squish_drawn()
		elif style.pressed_image:
			_set_system_cursors()


func _process(_delta: float) -> void:
	if not style or not style.drawn_in_game or not style.image:
		return
	var shape := Input.get_current_cursor_shape()
	var texture := style.image_for(shape == Input.CURSOR_POINTING_HAND, _pressed,
		shape == Input.CURSOR_DRAG or shape == Input.CURSOR_CAN_DROP)
	if texture != _shown_texture:
		_shown_texture = texture
		_drawn.texture = texture
		_drawn.size = texture.get_size() * style.size
	_drawn.pivot_offset = style.hotspot * style.size
	_drawn.position = get_viewport().get_mouse_position() - style.hotspot * style.size


# The computer's own cursor: one picture per cursor shape the game uses.
func _set_system_cursors() -> void:
	var normal := style.image_for(false, _pressed, false)
	var hover := style.image_for(true, _pressed, false)
	var drag := style.image_for(false, _pressed, true)
	for pair in [[Input.CURSOR_ARROW, normal], [Input.CURSOR_POINTING_HAND, hover],
			[Input.CURSOR_DRAG, drag], [Input.CURSOR_CAN_DROP, drag]]:
		var picture := _sized(pair[1])
		if picture:
			Input.set_custom_mouse_cursor(picture, pair[0], style.hotspot * style.size)


# The picture at Size, kept within the 256 × 256 the computer allows.
func _sized(texture: Texture2D) -> Image:
	if not texture:
		return null
	var picture := texture.get_image()
	if not picture:
		return null
	picture = picture.duplicate()
	if picture.is_compressed():
		picture.decompress()
	var target := Vector2(picture.get_size()) * style.size
	var too_big := maxf(target.x, target.y) / 256.0
	if too_big > 1.0:
		push_warning("PlayerCursor: cursor pictures can be at most 256 × 256 after Size; shrinking it.")
		target /= too_big
	picture.resize(maxi(int(target.x), 1), maxi(int(target.y), 1), Image.INTERPOLATE_LANCZOS)
	if style.tint != Color.WHITE:
		if picture.get_format() != Image.FORMAT_RGBA8:
			picture.convert(Image.FORMAT_RGBA8)
		for y in picture.get_height():
			for x in picture.get_width():
				picture.set_pixel(x, y, picture.get_pixel(x, y) * style.tint)
	return picture


func _squish_drawn() -> void:
	if _squish:
		_squish.kill()
	_squish = create_tween()
	var to := Vector2.ONE * (style.click_squish if _pressed else 1.0)
	_squish.tween_property(_drawn, "scale", to, 0.06)
