extends CanvasLayer
## AppLauncher (autoload): the iPhone-style "open app" and "close app" animation, shared by
## everything that opens like an app: the calendar, the dating app, a new date, the boss
## fight and microgames.
##
## Opening: the app's icon grows from where the player tapped until it fills the screen
## with the app's launch screen (the screen behind zooms and dims), the swap happens
## underneath, then the launch screen fades to show the app.
## Closing: the app shrinks back into its icon.
##
## Apps are files in data/apps/ (icon, launch screen, sounds). The animation's timing and
## feel are in data/app_transition_style.tres. Full guide: docs/guides/phone-apps.md
##
## From code (an app is its file name in data/apps/, or an AppInfo):
##   AppLauncher.open_scene("calendar", "res://scenes/Calendar/calendar.tscn")
##   await AppLauncher.open(app, func(): show_my_overlay(), from_rect)
##   await AppLauncher.close(app, func(): hide_my_overlay(), to_rect)

## Sent when an open or close animation starts and ends.
signal opening(app: AppInfo)
signal opened(app: AppInfo)
signal closing(app: AppInfo)
signal closed(app: AppInfo)

const APPS_FOLDER := "res://data/apps/"

## How every app opens and closes (data/app_transition_style.tres).
@export var style: AppTransitionStyle

var _busy := false
var _app: AppInfo
var _from := Rect2()
var _to := Rect2()
var _closing := false
var _last_tap := Vector2.ZERO
var _last_tap_time := -100.0

@onready var blocker: Control = $Blocker
@onready var behind: TextureRect = $Behind
@onready var dim: ColorRect = $Dim
@onready var tile: Panel = $Tile
@onready var content: TextureRect = $Tile/Content
@onready var icon: TextureRect = $Tile/Icon
@onready var frame: TextureRect = $Frame
@onready var sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	if not style:
		style = AppTransitionStyle.new()
	frame.texture = style.device_frame
	_hide_all()


## The app saved as data/apps/<app_name>.tres, or null (with a warning) if there isn't one.
func get_app(app_name: String) -> AppInfo:
	var path := APPS_FOLDER + app_name + ".tres"
	if not ResourceLoader.exists(path):
		push_warning("AppLauncher: no app file %s" % path)
		return null
	return load(path)


## True while an app is opening or closing.
func is_busy() -> bool:
	return _busy


## Opens `app` (a name in data/apps/ or an AppInfo) and changes to `scene_path` while
## the launch screen covers the screen. `from` = where it grows from (screen pixels);
## empty = where the player last clicked, or Default Origin.
func open_scene(app: Variant, scene_path: String, from := Rect2()) -> void:
	ResourceLoader.load_threaded_request(scene_path)
	await open(app, func() -> void: await _change_scene(scene_path), from)


## Opens `app`, calling `swap` once the launch screen covers the screen (show your
## overlay, change scene...). Use with await to wait for the whole animation.
func open(app: Variant, swap: Callable, from := Rect2()) -> void:
	var info := _resolve(app)
	if _busy or not info:
		await swap.call()
		return
	_busy = true
	_app = info
	_closing = false
	_from = from if from.has_area() else _tap_rect()
	_to = style.screen_rect(_screen_size())

	# What's on screen now becomes the picture behind the growing icon.
	behind.texture = await _screenshot()
	behind.pivot_offset = _from.get_center()
	behind.visible = behind.texture != null
	content.texture = info.launch_image
	content.visible = info.launch_image != null
	icon.texture = info.icon
	icon.visible = info.icon != null
	_show_layers()
	opening.emit(info)
	_play(info.open_sound if info.open_sound else style.open_sound)

	_set_progress(0.0)
	var grow := create_tween()
	grow.tween_method(_set_progress, 0.0, 1.0, style.open_seconds) \
		.set_trans(style.open_transition).set_ease(style.open_ease)
	await grow.finished

	await swap.call()
	behind.visible = false
	if style.launch_hold_seconds > 0.0:
		await get_tree().create_timer(style.launch_hold_seconds).timeout
	var reveal := create_tween().set_parallel()
	reveal.tween_property(tile, "modulate:a", 0.0, style.reveal_seconds)
	reveal.tween_property(dim, "modulate:a", 0.0, style.reveal_seconds)
	reveal.tween_property(frame, "modulate:a", 0.0, style.reveal_seconds)
	await reveal.finished
	_hide_all()
	_busy = false
	opened.emit(info)


## Closes `app`: what's on screen shrinks back into its icon at `to` (screen pixels;
## empty = Default Origin). `swap` is called first, while a picture of the app covers
## the screen: hide your overlay or change scene there.
func close(app: Variant, swap: Callable, to := Rect2()) -> void:
	var info := _resolve(app)
	if _busy or not info:
		await swap.call()
		return
	_busy = true
	_app = info
	_closing = true
	_from = to if to.has_area() else _default_rect()
	_to = style.screen_rect(_screen_size())

	# A picture of the app shrinks while the real screen behind is already back.
	content.texture = await _screenshot()
	content.visible = content.texture != null
	icon.texture = info.icon
	icon.visible = info.icon != null
	behind.visible = false
	_show_layers()
	_set_progress(1.0)
	closing.emit(info)
	_play(info.close_sound if info.close_sound else style.close_sound)
	await swap.call()

	var shrink := create_tween()
	shrink.tween_method(_set_progress, 1.0, 0.0, style.close_seconds) \
		.set_trans(style.close_transition).set_ease(style.close_ease)
	await shrink.finished
	var vanish := create_tween().set_parallel()
	vanish.tween_property(tile, "modulate:a", 0.0, 0.12)
	vanish.tween_property(tile, "scale", Vector2(0.8, 0.8), 0.12)
	await vanish.finished
	_hide_all()
	_busy = false
	closed.emit(info)


# 0 = the icon at _from, 1 = the open app filling _to.
func _set_progress(p: float) -> void:
	var rect := Rect2(_from.position.lerp(_to.position, p), _from.size.lerp(_to.size, p))
	tile.position = rect.position
	tile.size = rect.size
	tile.pivot_offset = rect.size / 2.0

	var icon_radius := style.icon_corner * minf(_from.size.x, _from.size.y)
	var box := StyleBoxFlat.new()
	box.anti_aliasing = true
	box.set_corner_radius_all(int(lerpf(icon_radius, style.screen_corner, p)))
	# The tile's colour turns from the icon's background into the launch screen.
	box.bg_color = _app.icon_background.lerp(_app.launch_color, clampf(p * 2.0, 0.0, 1.0))
	tile.add_theme_stylebox_override("panel", box)

	# The icon art grows from its tile size to its launch-screen size, staying centred.
	var start_side := minf(_from.size.x, _from.size.y) * (1.0 - _app.icon_padding * 2.0)
	var end_side := float(_app.launch_icon_size)
	var side := lerpf(start_side, end_side, p)
	icon.size = Vector2(side, side)
	icon.position = (rect.size - icon.size) / 2.0
	icon.modulate.a = 1.0 if end_side > 0.0 else 1.0 - clampf(p * 2.0, 0.0, 1.0)

	if _closing:
		# The picture of the app fades into the icon over the second half of shrinking.
		content.modulate.a = clampf(p * 2.0 - 0.6, 0.0, 1.0)
		icon.modulate.a = 1.0 - content.modulate.a
	else:
		# The launch art fades in over the first half of growing.
		content.modulate.a = clampf(p * 2.0, 0.0, 1.0)
	behind.scale = Vector2.ONE * lerpf(1.0, style.behind_zoom, p)
	dim.color = style.behind_dim
	dim.modulate.a = p
	frame.modulate.a = 1.0


func _change_scene(scene_path: String) -> void:
	while ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	var packed := ResourceLoader.load_threaded_get(scene_path) as PackedScene
	if packed:
		get_tree().change_scene_to_packed(packed)
	else:
		get_tree().change_scene_to_file(scene_path)
	# Wait for the new scene to be added and drawn once, so it's ready to be revealed.
	await get_tree().process_frame
	await get_tree().process_frame


func _screenshot() -> Texture2D:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	return ImageTexture.create_from_image(image) if image else null


## Where an app opens from when it isn't given a rectangle: a recent click, or Default
## Origin (e.g. after a key press). Keep it to close the app back into the same place.
func origin_rect() -> Rect2:
	return _tap_rect()


# Where an app opens from with no rectangle given: a recent click, or Default Origin.
func _tap_rect() -> Rect2:
	var recent := Time.get_ticks_msec() / 1000.0 - _last_tap_time <= style.tap_memory_seconds
	if recent and style.tap_memory_seconds > 0.0:
		return _square_at(_last_tap)
	return _default_rect()


func _default_rect() -> Rect2:
	return _square_at(_screen_size() * style.default_origin)


func _square_at(point: Vector2) -> Rect2:
	var side := Vector2(style.icon_size, style.icon_size)
	return Rect2(point - side / 2.0, side)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_last_tap = event.position
		_last_tap_time = Time.get_ticks_msec() / 1000.0


func _resolve(app: Variant) -> AppInfo:
	if app is AppInfo:
		return app
	if app is String or app is StringName:
		return get_app(app)
	return null


func _screen_size() -> Vector2:
	return get_viewport().get_visible_rect().size


func _show_layers() -> void:
	visible = true
	blocker.visible = true
	tile.visible = true
	tile.modulate.a = 1.0
	tile.scale = Vector2.ONE
	dim.visible = true
	dim.modulate.a = 0.0
	frame.visible = style.device_frame != null
	frame.modulate.a = 1.0


func _hide_all() -> void:
	visible = false
	blocker.visible = false
	behind.visible = false
	behind.texture = null
	content.texture = null
	tile.visible = false
	dim.visible = false
	frame.visible = false


func _play(stream: AudioStream) -> void:
	if stream:
		sound.stream = stream
		sound.volume_db = style.volume_db
		sound.play()
