extends StageHazard
## A fly that buzzes around the date along one of its paths. Switch to the action cursor
## (S), then wave the mouse at it to shoo it; shoo it off the screen and she reacts and
## the date earns a point. (Dealing With It → Needs Action Cursor off = no S needed.)
##
## Paths: every Path2D under Paths is one path. Draw them right here in this scene with
## the Path2D tool, over the DrawingGuide (her room and her). Saved paths (Curve2D files)
## dropped into Extra Paths count too. Each time it turns up it picks one at random,
## flies in from the nearest edge of the screen to the path's first point, then follows
## the path back and forth (or round and round, if the last point sits on the first).
##
## Press F6 on this scene to try it on its own. Full guide: docs/guides/stage-hazards.md

enum State { ENTERING, FOLLOWING, PUSHED, RETURNING, LEAVING }

@export_group("Flying")
## Saved paths (Curve2D files) to choose from, as well as the Path2D drawings under Paths.
@export var extra_paths: Array[Curve2D] = []
## How fast it flies along its path, in pixels per second.
@export_range(10.0, 3000.0, 10.0) var speed: float = 420.0
## How much it jitters off its path, in pixels. 0 = smooth.
@export_range(0.0, 200.0, 1.0) var buzz_amount: float = 22.0
## How fast it jitters.
@export_range(0.0, 40.0, 0.5) var buzz_speed: float = 11.0

@export_group("Shooing")
## How close the mouse has to come to push it, in pixels.
@export_range(20.0, 1500.0, 10.0) var shoo_radius: float = 260.0
## The mouse has to move at least this fast to push it, in pixels per second
## (a wave, not a hover).
@export_range(0.0, 5000.0, 50.0) var min_wave_speed: float = 500.0
## How much of the mouse's speed it's pushed with. Higher = easier to shoo.
@export_range(0.0, 5.0, 0.05) var shoo_strength: float = 1.4
## How quickly it slows after a push. Higher = it stops sooner, so it's harder to get it off screen.
@export_range(0.0, 20.0, 0.1) var air_drag: float = 2.2
## Seconds it stays dazed after a push before flying back to its path.
@export_range(0.0, 5.0, 0.05) var comeback_delay: float = 0.5
## How fast it flies back to its path, in pixels per second.
@export_range(10.0, 3000.0, 10.0) var comeback_speed: float = 700.0
## How far past the edge of the screen counts as "off screen", in pixels.
@export_range(0.0, 500.0, 5.0) var off_screen_margin: float = 60.0

@export_group("Sounds")
## Optional: a looping buzz while it's on screen.
@export var buzz_sound: AudioStream

var _state := State.ENTERING
var _curve: Curve2D
var _length := 0.0
var _along := 0.0
var _direction := 1.0
var _closed := false
# Where it is, before the jitter is added.
var _position := Vector2.ZERO
var _velocity := Vector2.ZERO
var _dazed := 0.0
var _exit := Vector2.ZERO
var _last_mouse := Vector2.ZERO
var _last_position := Vector2.ZERO
var _time := 0.0

@onready var body: Node2D = $Body
@onready var paths: Node2D = $Paths
@onready var buzz_player: AudioStreamPlayer = $Buzz


func _ready() -> void:
	# The guide only shows in the editor and when playing this scene on its own (F6).
	$DrawingGuide.visible = false


func begin() -> void:
	var choices := _all_paths()
	if choices.is_empty():
		push_warning("Fly: no paths. Draw a Path2D under Paths, or add one to Extra Paths.")
		leave()
		return
	_curve = choices.pick_random()
	_length = _curve.get_baked_length()
	var last := _curve.point_count - 1
	_closed = last > 1 and _curve.get_point_position(0).distance_to(_curve.get_point_position(last)) < 10.0
	_along = 0.0
	_direction = 1.0
	_position = _outside_near(_curve.sample_baked(0.0))
	_last_position = _position
	_velocity = Vector2.ZERO
	_state = State.ENTERING
	_last_mouse = get_local_mouse_position()
	body.position = _position
	if buzz_sound:
		buzz_player.stream = buzz_sound
		buzz_player.play()


func time_to_go() -> void:
	_exit = _outside_near(_position)
	_state = State.LEAVING


func _process(delta: float) -> void:
	_time += delta
	var mouse := get_local_mouse_position()
	var mouse_velocity := (mouse - _last_mouse) / maxf(delta, 0.001)
	_last_mouse = mouse
	_try_shoo(mouse, mouse_velocity)

	match _state:
		State.ENTERING:
			if _fly_towards(_curve.sample_baked(0.0), speed, delta):
				_state = State.FOLLOWING
		State.FOLLOWING:
			_follow_path(delta)
		State.PUSHED:
			_position += _velocity * delta
			_velocity *= exp(-air_drag * delta)
			if _is_off_screen():
				buzz_player.stop()
				clear()
				return
			_dazed -= delta
			if _dazed <= 0.0 and _velocity.length() < comeback_speed:
				_state = State.RETURNING
		State.RETURNING:
			if _fly_towards(_curve.sample_baked(_along), comeback_speed, delta):
				_state = State.FOLLOWING
		State.LEAVING:
			if _fly_towards(_exit, speed * 1.5, delta):
				buzz_player.stop()
				leave()
				return

	_draw_body()


# A wave of the mouse close by pushes it the way the mouse is moving (and away from it).
func _try_shoo(mouse: Vector2, mouse_velocity: Vector2) -> void:
	if _state == State.LEAVING or _is_off_screen() or not can_act():
		return
	var distance := mouse.distance_to(_position)
	var wave := mouse_velocity.length()
	if distance > shoo_radius or wave < min_wave_speed:
		return
	var closeness := 1.0 - distance / shoo_radius
	var push := mouse_velocity * shoo_strength * closeness
	push += (_position - mouse).normalized() * wave * 0.3 * closeness
	if _state != State.PUSHED or push.length() > _velocity.length():
		_velocity = push
	_state = State.PUSHED
	_dazed = comeback_delay


func _follow_path(delta: float) -> void:
	_along += speed * delta * _direction
	if _closed:
		_along = fposmod(_along, _length)
	elif _along >= _length:
		_along = _length
		_direction = -1.0
	elif _along <= 0.0:
		_along = 0.0
		_direction = 1.0
	_position = _curve.sample_baked(_along)


# Moves straight towards `target`. True once it's there.
func _fly_towards(target: Vector2, fly_speed: float, delta: float) -> bool:
	_position = _position.move_toward(target, fly_speed * delta)
	return _position.distance_to(target) < 4.0


func _draw_body() -> void:
	var jitter := Vector2(sin(_time * buzz_speed * 1.37), cos(_time * buzz_speed)) * buzz_amount
	body.position = _position + jitter
	# Face the way it's flying (not the jitter), and tilt a little into the turn.
	var moved := _position - _last_position
	_last_position = _position
	if absf(moved.x) > 0.5:
		body.scale.x = absf(body.scale.x) * (-1.0 if moved.x < 0.0 else 1.0)
	body.rotation = clampf(moved.y * 0.02, -0.4, 0.4)


func _is_off_screen() -> bool:
	return not Rect2(Vector2.ZERO, size).grow(off_screen_margin).has_point(_position)


# A point just off the screen, past the edge nearest to `point`.
func _outside_near(point: Vector2) -> Vector2:
	var out := off_screen_margin + 120.0
	var gaps := [point.x, size.x - point.x, point.y, size.y - point.y]
	match gaps.find(gaps.min()):
		0:
			return Vector2(-out, point.y)
		1:
			return Vector2(size.x + out, point.y)
		2:
			return Vector2(point.x, -out)
	return Vector2(point.x, size.y + out)


# Every path it can take, in screen pixels: the Path2D drawings, then Extra Paths.
func _all_paths() -> Array[Curve2D]:
	var found: Array[Curve2D] = []
	for child in paths.get_children():
		var drawn := child as Path2D
		if drawn and drawn.curve and drawn.curve.point_count > 1:
			found.append(_on_screen(drawn.curve, paths.transform * drawn.transform))
	for curve in extra_paths:
		if curve and curve.point_count > 1:
			found.append(curve)
	return found


# A copy of `curve` moved by `place`, so a Path2D that was dragged around still lines up.
func _on_screen(curve: Curve2D, place: Transform2D) -> Curve2D:
	if place == Transform2D.IDENTITY:
		return curve
	var moved := Curve2D.new()
	for i in curve.point_count:
		moved.add_point(place * curve.get_point_position(i), place.basis_xform(curve.get_point_in(i)),
			place.basis_xform(curve.get_point_out(i)))
	return moved
