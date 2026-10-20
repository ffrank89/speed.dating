class_name OptionBubble
extends PanelContainer
## One of the player's choices, drawn as a floating bubble. OptionList builds these
## and moves them around; this script draws one and turns the mouse into
## "picked" (a click) or a drag. Its look comes from OptionListStyle, which works like
## a girl's dialogue style: a flat colour box or a stretchy picture, with or without an outline.

## Clicked (pressed and let go without moving much), or Space/Enter while selected.
signal picked
## Let go after a drag. OptionList checks whether it landed on her.
signal dropped

# How far the mouse must move while held before a click becomes a drag, in pixels.
const DRAG_THRESHOLD := 12.0

var option: DateOption
## Where the bubble's middle is, in OptionList's space. OptionList moves this;
## the bubble is placed around it every frame.
var centre := Vector2.ZERO
var velocity := Vector2.ZERO
## True while the player is dragging it.
var dragging := false
## Where the mouse grabbed it, relative to its middle.
var grab_offset := Vector2.ZERO
## True once an option is picked: no more clicking or dragging.
var locked := false
## True just after a drag ends, so the bubble flies off instead of stopping under
## the mouse. Cleared once the mouse is off it.
var ignore_hover := false
## Gives each bubble its own drifting curve.
var wander_phase := randf() * TAU

var badge: PanelContainer
var badge_label: Label

var _style: OptionListStyle
var _line: Color
var _normal: StyleBox
var _highlight: StyleBox
# Drawn over the background: the outline on a picture bubble, or the hit/miss line.
var _overlay: StyleBox
var _highlighted := false
var _over_target := false
var _held := false
var _pressed_at := Vector2.ZERO
var _scale_tween: Tween


## Builds the bubble's contents. `index` is its 0-based place (key 1 = index 0).
func setup(p_option: DateOption, index: int, chance: int, style: OptionListStyle) -> void:
	option = p_option
	_style = style
	var risky := chance < 100
	_line = style.risky_outline_color if risky else style.outline_color
	_normal = style.make_bubble(false, _line)
	_highlight = style.make_bubble(true, style.hover_outline_color)
	add_theme_stylebox_override("panel", _normal)
	_overlay = style.make_outline(_line)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_entered.connect(func() -> void: set_highlight(true))
	focus_exited.connect(func() -> void: set_highlight(false))
	resized.connect(func() -> void: pivot_offset = size / 2.0)
	# Grow or shrink to fit the text whenever it changes size.
	minimum_size_changed.connect(reset_size)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 6)
	add_child(column)

	# Top row: attribute icon, "Culture 40", and the % badge.
	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 16)
	column.add_child(header)
	var icon := style.icon_for(option.attribute)
	if icon:
		var picture := TextureRect.new()
		picture.texture = icon
		picture.custom_minimum_size = Vector2(style.icon_size, style.icon_size)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		header.add_child(picture)
	if option.has_check():
		header.add_child(_label("%s %d" % [Attr.display_name(option.attribute), option.requirement], style.check_color))
	var gap := Control.new()
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(gap)
	badge = PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", style.make_badge(style.badge_color))
	badge_label = _label("%d%%" % chance, style.badge_text_color)
	badge.add_child(badge_label)
	badge.visible = risky
	header.add_child(badge)
	header.visible = icon != null or option.has_check() or risky

	# The key number, then the option's words, wrapped once they reach the bubble's widest.
	var words := HBoxContainer.new()
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.add_theme_constant_override("separation", 16)
	column.add_child(words)
	var font: Font = style.font if style.font else ThemeDB.fallback_font
	var room := style.bubble_max_width - style.padding * 2.0
	if style.show_number_keys:
		var number := _label(str(index + 1), style.number_key_color)
		number.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		words.add_child(number)
		room -= font.get_string_size(number.text, HORIZONTAL_ALIGNMENT_LEFT, -1, style.font_size).x + 16
	var text := _label(option.text, style.text_color)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var text_width := font.get_string_size(option.text, HORIZONTAL_ALIGNMENT_LEFT, -1, style.font_size).x
	text.custom_minimum_size.x = minf(ceilf(text_width) + 2.0, room)
	words.add_child(text)
	reset_size()


## Hover look: brighter fill, white outline, a little bigger.
func set_highlight(on: bool) -> void:
	on = on or has_focus() or dragging
	if on == _highlighted or locked:
		return
	_highlighted = on
	add_theme_stylebox_override("panel", _highlight if on else _normal)
	_overlay = _style.make_outline(_style.hover_outline_color if on else _line)
	queue_redraw()
	tween_scale(_style.hover_grow if on else 1.0, 0.12)


func tween_scale(to: float, seconds: float, delay := 0.0) -> void:
	if _scale_tween:
		_scale_tween.kill()
	_scale_tween = create_tween()
	_scale_tween.tween_property(self, "scale", Vector2(to, to), seconds).set_delay(delay) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Drop look: shown while it's dragged over her, so the player knows letting go picks it.
func set_over_target(on: bool) -> void:
	if on == _over_target or locked:
		return
	_over_target = on
	var line := _style.drop_outline_color if on else _style.hover_outline_color
	var width := _style.outline_width * (2 if on else 1)
	add_theme_stylebox_override("panel", _style.make_bubble(true, line, width))
	_overlay = _style.make_outline(line, width)
	queue_redraw()
	tween_scale(_style.hover_grow * (1.1 if on else 1.0), 0.1)


## Shows the picked bubble's result with a thick line in `color` (hit or miss).
func flash(color: Color) -> void:
	add_theme_stylebox_override("panel", _highlight)
	_overlay = _style.make_result_outline(color)
	queue_redraw()


func _draw() -> void:
	if _overlay:
		draw_style_box(_overlay, Rect2(Vector2.ZERO, size))


func _gui_input(event: InputEvent) -> void:
	if locked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if event.pressed:
			_held = true
			_pressed_at = event.global_position
			grab_offset = centre - get_parent().get_local_mouse_position()
		elif _held:
			_held = false
			if dragging:
				dragging = false
				ignore_hover = true
				release_focus()
				set_over_target(false)
				set_highlight(false)
				dropped.emit()
			else:
				picked.emit()
	elif event is InputEventMouseMotion and _held and not dragging:
		if event.global_position.distance_to(_pressed_at) > DRAG_THRESHOLD:
			dragging = true
			move_to_front()
			set_highlight(true)
	elif event.is_action_pressed("ui_accept"):
		accept_event()
		picked.emit()


func _label(words: String, color: Color) -> Label:
	var label := Label.new()
	label.text = words
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", _style.font_size)
	if _style.font:
		label.add_theme_font_override("font", _style.font)
	if _style.text_outline_width > 0:
		label.add_theme_constant_override("outline_size", _style.text_outline_width)
		label.add_theme_color_override("font_outline_color", _style.text_outline_color)
	return label
