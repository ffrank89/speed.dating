class_name PhoneScreen
extends Control
## The player's phone. Every "on your phone" screen is built on it: the intro, the dating
## app, the calendar, Contacts, her contact card after a date, microgames. Real life
## (dates, boss fights, stage hazards) isn't.
##
## The phone sits in the middle of the screen, with your room (dimmed) behind it, or the
## date dimmed behind it when it comes up during real life. An app's own nodes go inside
## Phone → Body → Screen, between the status bar and the home bar.
##
## Its size, colours, edge, phone art, wallpaper, status bar, font, room and the phone
## up / down movement are Style (data/phone_style.tres), shared by every phone screen.
## What's behind it, and a scene's own room or wallpaper, are set per scene (Behind,
## Room Image, Wallpaper). Full guide: docs/guides/the-phone.md
##
## From code: await phone.raise() (phone up), await phone.lower() (phone down),
## phone.app_rect() (where apps go, in screen pixels).

## The home bar at the bottom was clicked.
signal home_pressed
## The phone finished coming up / going down.
signal raised
signal lowered

enum Behind {
	## Your room (Style → Your Room, or this scene's Room Image), dimmed.
	ROOM,
	## Whatever is under this scene (e.g. the date), dimmed: Style → Real Life Dim.
	DIM,
	## Nothing: just the phone, e.g. an app opened over another phone screen.
	NOTHING,
}

## The phone's look (data/phone_style.tres, shared by every phone screen).
@export var style: PhoneStyle
## What's behind the phone.
@export var behind: Behind = Behind.ROOM
## Only with Behind = Room: this scene's own room. Empty = Style → Room Image.
@export var room_image: Texture2D
## This scene's own picture on the phone's screen, behind the app. Empty = Style → Wallpaper.
@export var wallpaper: Texture2D

var _minute := -1

## The room behind the phone.
@onready var room: TextureRect = %Room
## Over the room, or over real life.
@onready var dim: ColorRect = %Dim
## The phone itself: the part that moves when it comes up and goes down.
@onready var phone: Control = %Phone
## The phone's edge (when there's no Phone Art).
@onready var edge: Panel = %Edge
## The phone's screen. Everything in it is cut to its rounded corners.
@onready var body: Panel = %Body
@onready var wallpaper_image: TextureRect = %Wallpaper
@onready var status_bar: HBoxContainer = %StatusBar
@onready var clock: Label = %Clock
@onready var status_right: Label = %StatusRight
## Where an app's nodes go: the screen between the status bar and the home bar.
@onready var screen: Control = %Screen
@onready var home_bar: Control = %HomeBar
@onready var home_pill: Panel = %HomePill
## Phone Art, over the edge.
@onready var frame: TextureRect = %Frame
@onready var sound: AudioStreamPlayer = %Sound


func _ready() -> void:
	if not style:
		style = PhoneStyle.new()
	home_bar.gui_input.connect(_on_home_bar_input)
	apply_style()


## Re-reads Style and lays the phone out again (e.g. after changing the style while playing).
func apply_style() -> void:
	room.texture = room_image if room_image else style.room_image
	room.visible = behind == Behind.ROOM and room.texture != null
	dim.visible = behind != Behind.NOTHING
	dim.color = style.room_dim if behind == Behind.ROOM else style.real_life_dim
	# Nothing behind = clicks outside the phone reach the screen underneath.
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE if behind == Behind.NOTHING else Control.MOUSE_FILTER_STOP

	_place_phone()
	edge.add_theme_stylebox_override("panel", style.make_edge_box())
	edge.visible = style.edge_width > 0 and not style.frame_image
	for side in [SIDE_LEFT, SIDE_TOP]:
		body.set_offset(side, style.edge_width)
	for side in [SIDE_RIGHT, SIDE_BOTTOM]:
		body.set_offset(side, -style.edge_width)
	body.add_theme_stylebox_override("panel", style.make_screen_box())
	wallpaper_image.texture = wallpaper if wallpaper else style.wallpaper
	wallpaper_image.visible = wallpaper_image.texture != null

	status_bar.visible = style.show_status_bar
	status_bar.offset_bottom = style.status_bar_height
	# Clear of the rounded corners.
	status_bar.offset_left = style.corner
	status_bar.offset_right = -style.corner
	for label: Label in [clock, status_right]:
		style.style_label(label, style.status_text_color, style.status_font_size)
	status_right.text = style.status_right_text
	_minute = -1
	_update_clock()

	screen.offset_top = style.status_bar_height if style.show_status_bar else 0
	screen.offset_bottom = -style.home_bar_height if style.show_home_bar else 0
	home_bar.visible = style.show_home_bar
	home_bar.offset_top = -style.home_bar_height
	home_pill.offset_left = -style.home_pill_width / 2.0
	home_pill.offset_right = style.home_pill_width / 2.0
	home_pill.offset_top = -style.home_pill_height / 2.0
	home_pill.offset_bottom = style.home_pill_height / 2.0
	var pill := StyleBoxFlat.new()
	pill.bg_color = style.home_pill_color
	pill.set_corner_radius_all(100)
	pill.anti_aliasing = true
	home_pill.add_theme_stylebox_override("panel", pill)

	frame.texture = style.frame_image
	frame.visible = style.frame_image != null
	for side in [SIDE_LEFT, SIDE_TOP]:
		frame.set_offset(side, -style.frame_spill)
	for side in [SIDE_RIGHT, SIDE_BOTTOM]:
		frame.set_offset(side, style.frame_spill)


## Where apps go (below the status bar, above the home bar), in screen pixels.
func app_rect() -> Rect2:
	return screen.get_global_rect()


## The phone's whole screen (inside its edge), in screen pixels.
func screen_rect() -> Rect2:
	return body.get_global_rect()


## Phone up: the phone comes up from the bottom of the screen while what's behind it dims.
## Use with await.
func raise() -> void:
	visible = true
	_place_phone()
	var rest := phone.position
	phone.position.y = _below_screen()
	phone.rotation_degrees = style.tilt_degrees
	for part: CanvasItem in [dim, room]:
		part.modulate.a = 0.0
	_play(style.up_sound)
	var up := create_tween().set_parallel().set_trans(style.up_transition).set_ease(style.up_ease)
	up.tween_property(phone, "position:y", rest.y, style.up_seconds)
	up.tween_property(phone, "rotation_degrees", 0.0, style.up_seconds)
	for part: CanvasItem in [dim, room]:
		up.tween_property(part, "modulate:a", 1.0, style.up_seconds * 0.7) \
			.set_trans(Tween.TRANS_LINEAR)
	await up.finished
	raised.emit()


## Phone down: the phone drops off the bottom of the screen while what's behind it
## brightens, then this hides. Use with await.
func lower() -> void:
	_play(style.down_sound)
	var down := create_tween().set_parallel().set_trans(style.down_transition).set_ease(style.down_ease)
	down.tween_property(phone, "position:y", _below_screen(), style.down_seconds)
	down.tween_property(phone, "rotation_degrees", -style.tilt_degrees, style.down_seconds)
	for part: CanvasItem in [dim, room]:
		down.tween_property(part, "modulate:a", 0.0, style.down_seconds).set_trans(Tween.TRANS_LINEAR)
	await down.finished
	visible = false
	# Back in place (hidden), ready to come up again.
	_place_phone()
	for part: CanvasItem in [dim, room]:
		part.modulate.a = 1.0
	lowered.emit()


## The phone up and in place at once, without moving.
func show_up() -> void:
	visible = true
	_place_phone()
	for part: CanvasItem in [dim, room]:
		part.modulate.a = 1.0


func _process(_delta: float) -> void:
	if style.show_status_bar and style.clock_text.is_empty():
		_update_clock()


# The clock: Style → Clock Text, or the computer's time.
func _update_clock() -> void:
	if not style.clock_text.is_empty():
		clock.text = style.clock_text
		return
	var now := Time.get_time_dict_from_system()
	if now.minute != _minute:
		_minute = now.minute
		clock.text = "%d:%02d" % [now.hour, now.minute]


# The phone's size and place (Style → Phone Size, Phone Offset), around the middle.
func _place_phone() -> void:
	phone.set_anchors_preset(Control.PRESET_CENTER)
	phone.offset_left = -style.phone_size.x / 2.0 + style.phone_offset.x
	phone.offset_right = style.phone_size.x / 2.0 + style.phone_offset.x
	phone.offset_top = -style.phone_size.y / 2.0 + style.phone_offset.y
	phone.offset_bottom = style.phone_size.y / 2.0 + style.phone_offset.y
	phone.pivot_offset = style.phone_size / 2.0
	phone.rotation_degrees = 0.0


func _below_screen() -> float:
	return size.y + style.frame_spill + 60.0


func _on_home_bar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		home_pressed.emit()


func _play(stream: AudioStream) -> void:
	if stream:
		sound.stream = stream
		sound.volume_db = style.volume_db
		sound.play()
