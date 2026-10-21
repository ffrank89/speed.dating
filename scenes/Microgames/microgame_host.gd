class_name MicrogameHost
extends CanvasLayer
## Plays microgames on the player's phone, over the date: the phone comes up (the date
## dims behind it), the microgame opens on it like an iPhone app (AppLauncher), shows its
## banner ("LIGHT IT!"), runs the timer bar, freezes it on a win or loss, stamps
## NICE/OOPS, closes back into its icon, and the phone goes back down.
##
## Its look and sounds come from Style (data/microgame_style.tres); the phone and how it
## comes up are data/phone_style.tres. Where the banner, timer bar and stamp sit is set
## in this scene (PhoneScreen → Phone → Body → Screen): click them and move them.
## A microgame fills the phone's screen (GameSlot).
## From code: var passed: bool = await host.play("light_cigarette", difficulty)
## Full guide: docs/guides/making-a-microgame.md

## Sent when a microgame's timer starts, and when it's won or lost.
signal started(game: Microgame)
signal ended(game: Microgame, passed: bool)

## The list of microgames by name (data/microgames.tres).
@export var library: MicrogameLibrary
## The frame's look and sounds (data/microgame_style.tres).
@export var style: MicrogameStyle
## The app a microgame opens as when it doesn't name its own (icon, launch screen).
@export var default_app: AppInfo

var _game: Microgame
var _active := false
var _running := false
var _total := 0.0
var _low := false
var _next_tick := 0
var _pointer_from_keys := false

## The phone the microgame plays on.
@onready var phone_screen: PhoneScreen = %PhoneScreen
## Where the microgame goes: the phone's screen.
@onready var game_slot: Control = %GameSlot
@onready var timer_bar: Panel = %TimerBar
@onready var timer_fill: Panel = %Fill
@onready var banner: PanelContainer = %Banner
@onready var banner_text: Label = %BannerText
@onready var stamp: Control = %Stamp
@onready var stamp_image: TextureRect = %StampImage
@onready var stamp_text: Label = %StampText
@onready var pointer_marker: Panel = $PointerMarker
@onready var pointer_image: TextureRect = $PointerMarker/Image
@onready var sound: AudioStreamPlayer = $Sound


func _ready() -> void:
	if not style:
		style = MicrogameStyle.new()
	_apply_style()
	_hide_frame()
	phone_screen.visible = false


## True from the moment play() starts until the date is back (stage hazards freeze meanwhile).
func is_active() -> bool:
	return _active


## True if the library has a microgame with this name.
func has_game(game_name: String) -> bool:
	return library != null and library.has_game(game_name)


## Plays the named microgame on the phone over the date and returns whether the player
## passed. Use with await. An unknown name counts as a fail (with a warning).
func play(game_name: String, difficulty: float, modifiers: Dictionary = {}) -> bool:
	if not has_game(game_name):
		push_warning("MicrogameHost: no microgame named \"%s\" in data/microgames.tres." % game_name)
		return false
	var game := library.games[game_name].instantiate() as Microgame
	if not game:
		push_error("MicrogameHost: the scene for \"%s\" doesn't use a Microgame script." % game_name)
		return false
	var app := game.app if game.app else default_app
	game.visible = false
	game_slot.add_child(game)
	_active = true

	# Phone up, then the microgame opens on it from the bottom of its screen.
	await phone_screen.raise()
	var home: Rect2 = AppLauncher.home_rect()
	var show_game := func() -> void:
		game.visible = true
		game.modulate.a = 1.0
	if style.open_as_app:
		await AppLauncher.open(app, show_game, home)
	else:
		show_game.call()
		game.modulate.a = 0.0
		var fade_in := create_tween()
		fade_in.tween_property(game, "modulate:a", 1.0, style.fade_seconds)
		await fade_in.finished

	var passed := await run(game, difficulty, modifiers)

	var hide_game := func() -> void:
		game.visible = false
		_hide_frame()
	if style.open_as_app:
		await AppLauncher.close(app, hide_game, home)
	else:
		var fade_out := create_tween().set_parallel()
		for part: CanvasItem in [game, stamp, timer_bar]:
			fade_out.tween_property(part, "modulate:a", 0.0, style.fade_seconds)
		await fade_out.finished
		hide_game.call()
	# Phone down: back to the date.
	await phone_screen.lower()
	game.queue_free()
	_active = false
	return passed


## Puts a microgame that's on its own (F6) on this host's phone, up and in place, with
## your room behind it.
func hold(game: Microgame) -> void:
	phone_screen.behind = PhoneScreen.Behind.ROOM
	phone_screen.apply_style()
	phone_screen.show_up()
	game.reparent(game_slot, false)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Runs a microgame that's already on screen: banner, timer, stamp. Returns whether
## the player passed. play() uses this; so does a microgame played on its own (F6).
func run(game: Microgame, difficulty: float, modifiers: Dictionary = {}) -> bool:
	_game = game
	_pointer_from_keys = false
	game.difficulty = difficulty
	game.modifiers = modifiers
	game.pointer = game.size / 2.0
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.start(difficulty, modifiers)

	_total = game.seconds + float(modifiers.get("extra_time", 0.0))
	game.time_left = _total
	_low = false
	_next_tick = ceili(style.timer_low_seconds)
	timer_bar.modulate.a = 1.0
	timer_bar.visible = true
	_update_timer()
	_play(style.start_sound)
	await _show_banner(game.banner_text)

	game.process_mode = Node.PROCESS_MODE_INHERIT
	game.is_playing = true
	_running = true
	started.emit(game)
	var passed: bool = await game.finished
	_running = false
	pointer_marker.visible = false
	game.process_mode = Node.PROCESS_MODE_DISABLED
	ended.emit(game, passed)
	await _show_stamp(passed)
	_game = null
	return passed


func _process(delta: float) -> void:
	if not _game:
		return
	_update_pointer(delta)
	if not _running:
		return
	_game.time_left = maxf(_game.time_left - delta, 0.0)
	_update_timer()
	if _game.time_left <= _next_tick and _next_tick > 0:
		_play(style.tick_sound)
		_next_tick -= 1
	if _game.time_left <= 0.0:
		_game.time_up()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_pointer_from_keys = false


# The pointer follows the mouse, until the arrow keys / WASD are used to steer it.
func _update_pointer(delta: float) -> void:
	var keys := Input.get_vector("microgame_left", "microgame_right", "microgame_up", "microgame_down")
	if keys != Vector2.ZERO and _running:
		_pointer_from_keys = true
		_game.pointer = (_game.pointer + keys * style.pointer_speed * delta).clamp(Vector2.ZERO, _game.size)
	elif not _pointer_from_keys:
		_game.pointer = _game.get_local_mouse_position()
	pointer_marker.visible = _pointer_from_keys and _running
	pointer_marker.position = _game.pointer_on_screen() - pointer_marker.size / 2.0


func _update_timer() -> void:
	var left := _game.time_left / _total if _total > 0.0 else 0.0
	timer_fill.anchor_right = left
	var low := _game.time_left <= style.timer_low_seconds
	if low != _low:
		_low = low
		_style_fill()


func _show_banner(words: String) -> void:
	banner_text.text = words
	banner.visible = true
	banner.modulate.a = 1.0
	banner.reset_size()
	banner.pivot_offset = banner.size / 2.0
	banner.scale = Vector2(0.4, 0.4)
	var pop := create_tween()
	pop.tween_property(banner, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_interval(maxf(style.banner_seconds - 0.2, 0.0))
	await pop.finished
	# Fade out while play begins.
	create_tween().tween_property(banner, "modulate:a", 0.0, 0.15)


func _show_stamp(passed: bool) -> void:
	var picture := style.pass_image if passed else style.fail_image
	stamp_image.texture = picture
	stamp_image.visible = picture != null
	stamp_text.visible = picture == null
	stamp_text.text = style.pass_text if passed else style.fail_text
	stamp_text.add_theme_color_override("font_color", style.pass_color if passed else style.fail_color)
	stamp.visible = true
	stamp.modulate.a = 1.0
	stamp.pivot_offset = stamp.size / 2.0
	stamp.rotation_degrees = style.stamp_tilt
	stamp.scale = Vector2(2.5, 2.5)
	_play(style.pass_sound if passed else style.fail_sound)
	var slam := create_tween()
	slam.tween_property(stamp, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	slam.tween_interval(style.stamp_seconds)
	await slam.finished


func _apply_style() -> void:
	# Over the date: the microgame's own dim (Style → Dim), not the phone's.
	phone_screen.dim.color = style.dim_color

	var banner_box := style.make_box(Color.TRANSPARENT, Color.TRANSPARENT, 0, 0, style.banner_image, style.banner_image_corner_size)
	banner_box.set_content_margin_all(style.banner_padding)
	banner.add_theme_stylebox_override("panel", banner_box)
	_style_label(banner_text, style.banner_font, style.banner_font_size, style.banner_outline_width, style.banner_outline_color)
	banner_text.add_theme_color_override("font_color", style.banner_text_color)

	_style_label(stamp_text, style.stamp_font if style.stamp_font else style.banner_font,
		style.stamp_font_size, style.stamp_outline_width, style.stamp_outline_color)

	timer_bar.add_theme_stylebox_override("panel", style.make_box(style.timer_back_color, style.timer_outline_color,
		style.timer_outline_width, style.timer_corner_radius, style.timer_back_image, style.timer_image_corner_size))
	_style_fill()

	pointer_marker.size = Vector2(style.pointer_size, style.pointer_size)
	pointer_image.texture = style.pointer_image
	pointer_image.visible = style.pointer_image != null
	var ring := StyleBoxFlat.new()
	ring.draw_center = false
	ring.border_color = style.pointer_color
	ring.set_border_width_all(0 if style.pointer_image else 6)
	ring.set_corner_radius_all(style.pointer_size)
	ring.anti_aliasing = true
	# A dark halo keeps the ring visible on light and dark backgrounds.
	ring.shadow_color = Color(0, 0, 0, 0.0 if style.pointer_image else 0.7)
	ring.shadow_size = 6
	pointer_marker.add_theme_stylebox_override("panel", ring)

	sound.volume_db = style.volume_db


func _style_fill() -> void:
	var color := style.timer_low_color if _low else style.timer_fill_color
	timer_fill.add_theme_stylebox_override("panel", style.make_box(color, Color.TRANSPARENT, 0,
		style.timer_corner_radius, style.timer_fill_image, style.timer_image_corner_size))
	if style.timer_fill_image:
		timer_fill.self_modulate = color if _low else Color.WHITE


func _style_label(label: Label, font: Font, font_size: int, outline: int, outline_color: Color) -> void:
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("outline_size", outline)
	label.add_theme_color_override("font_outline_color", outline_color)


func _hide_frame() -> void:
	banner.visible = false
	stamp.visible = false
	timer_bar.visible = false
	pointer_marker.visible = false


func _play(stream: AudioStream) -> void:
	if stream:
		sound.stream = stream
		sound.play()
