extends CanvasLayer
## PlayerCursor (autoload): shows the player's cursor everywhere in the game, from a
## CursorStyle (data/cursors/default.tres unless told otherwise).
##
## The picture changes when hovering something clickable (any Control whose Mouse
## Default Cursor Shape is Pointing Hand, e.g. option bubbles and app icons), while the
## button is held, and while dragging. Change the default in this scene's Style slot,
## or switch from code: PlayerCursor.use(load("res://data/cursors/other.tres")).
## Full guide: docs/guides/cursor.md

## The cursor to use (a file from data/cursors/).
@export var style: CursorStyle

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


## Switches to another cursor (null = the computer's normal arrow).
func use(new_style: CursorStyle) -> void:
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
	return picture


func _squish_drawn() -> void:
	if _squish:
		_squish.kill()
	_squish = create_tween()
	var to := Vector2.ONE * (style.click_squish if _pressed else 1.0)
	_squish.tween_property(_drawn, "scale", to, 0.06)
