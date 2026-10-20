class_name OptionList
extends Control
## The player's choices, as bubbles that pop out above her head and drift slowly
## around this node's rectangle. Each bubble shows its attribute check and, for a
## risky option (player below the requirement), its % chance. Picking one plays the
## roll, then reports what happened through option_resolved.
##
## Click a bubble to pick it. Drag one to throw it around: it drops a trail of its
## attribute icon. Keys 1-4 pick too, or arrow keys then Space/Enter.
##
## Where they float: this node's rectangle (move and resize it in the scene).
## Where they start: the Start At marker. Look, motion and sounds: Style
## (data/option_styles/default.tres), or the girl's own Option Style if she has one.
## From code: show_options(responses, scorer, her_style). Full guide: docs/guides/options-and-scoring.md

## Sent after the roll animation finishes. The dialogue should continue down `response`.
signal option_resolved(response: DialogueResponse, result: DateScorer.Result)

## The shared look, motion and sounds (data/option_styles/default.tres).
## A girl's own Option Style replaces it on her dates.
@export var style: OptionListStyle
## The point the bubbles pop out from: a marker (Marker2D) placed above her head.
## Empty = the top middle of this node.
@export var start_at: Node2D
## Seconds after the options appear before a pick counts, so a player mashing
## Space to skip her text doesn't pick an option by accident.
@export_range(0.0, 2.0, 0.05) var input_delay: float = 0.35

const SOUND_CHANNELS := 3
# Most trail icons on screen at once, so a long drag doesn't flood the screen.
const MAX_TRAIL_ICONS := 80

var _scorer: DateScorer
var _style: OptionListStyle
var _options: Array[DateOption] = []
var _bubbles: Array[OptionBubble] = []
var _hovered: OptionBubble
var _busy := false
var _shown_at := 0.0
var _time := 0.0
var _trail_distance := 0.0
var _sound_players: Array[AudioStreamPlayer] = []
var _next_sound := 0

# Trail icons sit on a layer under the bubbles, so they appear from behind the one being dragged.
var _trail_layer := Control.new()
var _bubble_layer := Control.new()


func _ready() -> void:
	if not style:
		style = OptionListStyle.new()
	for layer in [_trail_layer, _bubble_layer]:
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(layer)
	for i in SOUND_CHANNELS:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sound_players.append(player)
	hide()


## Shows the choices for a line. The scorer works out each option's chance.
## `look` replaces Style for these options (pass the girl's Option Style, or null).
func show_options(responses: Array, scorer: DateScorer, look: OptionListStyle = null) -> void:
	_clear()
	_scorer = scorer
	_style = look if look else style
	var start := _start_point()
	var count := responses.size()
	for i in count:
		var option := DateOption.from_response(responses[i])
		_options.append(option)
		var bubble := OptionBubble.new()
		bubble.setup(option, i, _scorer.chance_of(option), _style)
		bubble.picked.connect(_pick.bind(i))
		bubble.centre = start + Vector2(randf_range(-4, 4), randf_range(-4, 4))
		# Fan out from the start point: first to the upper left, last to the upper right.
		var angle := PI + (i + 0.5) / count * PI
		bubble.velocity = Vector2.from_angle(angle) * _style.burst_speed
		bubble.scale = Vector2(0.3, 0.3)
		bubble.modulate.a = 0.0
		_bubble_layer.add_child(bubble)
		_bubbles.append(bubble)
		bubble.tween_scale(1.0, 0.35, i * 0.06)
		create_tween().tween_property(bubble, "modulate:a", 1.0, 0.15).set_delay(i * 0.06)
	_hovered = null
	_busy = false
	_shown_at = Time.get_ticks_msec() / 1000.0
	show()


func _process(delta: float) -> void:
	if not visible or _bubbles.is_empty():
		return
	_time += delta
	_update_hover()
	if not _busy:
		for bubble in _bubbles:
			_move(bubble, delta)
		_separate(delta)
	for bubble in _bubbles:
		bubble.position = bubble.centre - bubble.size / 2.0


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _busy:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var index: int = event.keycode - KEY_1
		if index >= 0 and index < _bubbles.size():
			get_viewport().set_input_as_handled()
			_pick(index)
			return
	for action in ["ui_down", "ui_up", "ui_left", "ui_right"]:
		if event.is_action_pressed(action):
			if not _bubbles.is_empty() and not _bubbles.any(func(b: OptionBubble) -> bool: return b.has_focus()):
				get_viewport().set_input_as_handled()
				_bubbles[0].grab_focus()
			return


# The bubble under the mouse (the top one if they overlap) lights up and stops drifting.
func _update_hover() -> void:
	var now: OptionBubble = null
	var mouse := get_global_mouse_position()
	for i in range(_bubbles.size() - 1, -1, -1):
		var bubble := _bubbles[i]
		var under_mouse := bubble.get_global_rect().has_point(mouse)
		if bubble.ignore_hover:
			bubble.ignore_hover = under_mouse
			under_mouse = false
		if bubble.dragging or (now == null and under_mouse):
			now = bubble
			if bubble.dragging:
				break
	if now == _hovered:
		return
	if _hovered:
		_hovered.set_highlight(false)
	_hovered = now
	if _hovered and not _busy:
		_hovered.set_highlight(true)
		_play(_style.hover_sound)


func _move(bubble: OptionBubble, delta: float) -> void:
	if bubble.dragging:
		var before := bubble.centre
		bubble.centre = _keep_inside(bubble, _bubble_layer.get_local_mouse_position() + bubble.grab_offset)
		var moved := bubble.centre - before
		# Remember how fast it's moving, so letting go throws it.
		bubble.velocity = bubble.velocity.lerp(moved / maxf(delta, 0.001), 0.35).limit_length(_style.max_throw_speed)
		_trail_distance += moved.length()
		if _trail_distance >= _style.trail_spacing:
			_trail_distance = 0.0
			_drop_trail_icon(bubble)
		return
	if _is_still(bubble):
		return

	# Ease from the burst (or a throw) down to drift speed, curving gently as it goes.
	var speed := bubble.velocity.length()
	speed = lerpf(speed, _style.drift_speed, 1.0 - exp(-_style.settle * delta))
	var direction := bubble.velocity.normalized() if bubble.velocity.length() > 0.01 else Vector2.from_angle(randf() * TAU)
	direction = direction.rotated(sin(_time * 0.7 + bubble.wander_phase) * _style.wander * delta)
	bubble.velocity = direction * speed
	var wanted := bubble.centre + bubble.velocity * delta
	bubble.centre = _keep_inside(bubble, wanted)
	# Bounce off the edges of the area.
	if bubble.centre.x != wanted.x:
		bubble.velocity.x = -bubble.velocity.x
	if bubble.centre.y != wanted.y:
		bubble.velocity.y = -bubble.velocity.y


# A bubble holds still while the mouse is over it, it's selected or it's being dragged.
func _is_still(bubble: OptionBubble) -> bool:
	return bubble == _hovered or bubble.dragging or bubble.has_focus()


func _keep_inside(bubble: OptionBubble, point: Vector2) -> Vector2:
	var half := bubble.size / 2.0
	for axis in 2:
		if size[axis] <= bubble.size[axis]:
			point[axis] = size[axis] / 2.0
		else:
			point[axis] = clampf(point[axis], half[axis], size[axis] - half[axis])
	return point


# Gently pushes overlapping bubbles apart and bounces them off each other.
func _separate(delta: float) -> void:
	for i in _bubbles.size():
		for j in range(i + 1, _bubbles.size()):
			var a := _bubbles[i]
			var b := _bubbles[j]
			var a_still := _is_still(a)
			var b_still := _is_still(b)
			if a_still and b_still:
				continue
			var rect_a := Rect2(a.centre - a.size / 2.0, a.size).grow(_style.spacing / 2.0)
			var rect_b := Rect2(b.centre - b.size / 2.0, b.size).grow(_style.spacing / 2.0)
			if not rect_a.intersects(rect_b):
				continue
			var overlap := rect_a.intersection(rect_b).size
			var apart := b.centre - a.centre
			# Push along whichever way they overlap least.
			var axis := Vector2(1.0 if apart.x >= 0.0 else -1.0, 0.0) if overlap.x < overlap.y \
				else Vector2(0.0, 1.0 if apart.y >= 0.0 else -1.0)
			var push := axis * minf(overlap.x, overlap.y) * minf(1.0, delta * 8.0)
			var a_speed := 0.0 if a_still else a.velocity.dot(axis)
			var b_speed := 0.0 if b_still else b.velocity.dot(axis)
			if a_still:
				b.centre = _keep_inside(b, b.centre + push)
			elif b_still:
				a.centre = _keep_inside(a, a.centre - push)
			else:
				a.centre = _keep_inside(a, a.centre - push / 2.0)
				b.centre = _keep_inside(b, b.centre + push / 2.0)
			if b_speed - a_speed < 0.0:
				if a_still:
					b.velocity -= axis * 2.0 * b_speed
				elif b_still:
					a.velocity -= axis * 2.0 * a_speed
				else:
					a.velocity += axis * (b_speed - a_speed)
					b.velocity += axis * (a_speed - b_speed)


# A small copy of the bubble's attribute icon that pops up behind it and fades away.
func _drop_trail_icon(bubble: OptionBubble) -> void:
	var texture := _style.icon_for(bubble.option.attribute)
	if not texture:
		texture = _style.trail_fallback_icon
	if not texture or _trail_layer.get_child_count() >= MAX_TRAIL_ICONS:
		return
	var icon := TextureRect.new()
	icon.texture = texture
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size = Vector2(_style.trail_icon_size, _style.trail_icon_size)
	icon.pivot_offset = icon.size / 2.0
	icon.position = bubble.centre - icon.size / 2.0 + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	icon.rotation = randf_range(-0.4, 0.4)
	icon.scale = Vector2(0.4, 0.4)
	_trail_layer.add_child(icon)
	var tween := icon.create_tween().set_parallel()
	tween.tween_property(icon, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "position", icon.position + Vector2(randf_range(-30, 30), randf_range(-60, -20)), _style.trail_seconds) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "modulate:a", 0.0, _style.trail_seconds).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(icon.queue_free)


func _pick(index: int) -> void:
	if _busy or Time.get_ticks_msec() / 1000.0 - _shown_at < input_delay:
		return
	_busy = true
	var result := _scorer.resolve(_options[index])
	_play(_style.select_sound)
	for i in _bubbles.size():
		_bubbles[i].locked = true
		if i != index:
			create_tween().tween_property(_bubbles[i], "modulate:a", 0.0, 0.2)

	if result.rolled:
		await _play_roll(index, result)
	else:
		_bubbles[index].flash(_style.hit_color)
		await get_tree().create_timer(0.35).timeout

	hide()
	_clear()
	option_resolved.emit(result.option.response, result)


# Spins the badge numbers, lands on the roll, then shows HIT or MISS.
func _play_roll(index: int, result: DateScorer.Result) -> void:
	var bubble := _bubbles[index]
	var label := bubble.badge_label
	var ticks := 14
	var wait := _style.roll_seconds / 40.0
	for i in ticks:
		label.text = str(randi_range(1, 100))
		_play(_style.roll_tick_sound)
		await get_tree().create_timer(wait).timeout
		wait *= 1.18
	label.text = str(result.roll)
	await get_tree().create_timer(0.3).timeout

	var color := _style.hit_color if result.hit else _style.miss_color
	bubble.badge.add_theme_stylebox_override("panel", _style.make_badge(color))
	label.text = _style.hit_text if result.hit else _style.miss_text
	bubble.flash(color)
	_play(_style.hit_sound if result.hit else _style.miss_sound)
	await get_tree().create_timer(0.8).timeout


func _start_point() -> Vector2:
	if start_at:
		return get_global_transform().affine_inverse() * start_at.global_position
	return Vector2(size.x / 2.0, 0.0)


func _play(stream: AudioStream) -> void:
	if not stream:
		return
	var player := _sound_players[_next_sound]
	_next_sound = (_next_sound + 1) % _sound_players.size()
	player.stream = stream
	player.volume_db = _style.volume_db
	player.play()


func _clear() -> void:
	for layer in [_trail_layer, _bubble_layer]:
		for child in layer.get_children():
			child.queue_free()
	_options.clear()
	_bubbles.clear()
	_hovered = null
	_trail_distance = 0.0
