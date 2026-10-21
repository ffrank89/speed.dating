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
## phone.app_rect() (where apps go, in screen pixels), await phone.switch_in(...) /
## switch_out(...) (moving between open apps, like the iPhone's app switcher).

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
## Which app this screen is (a file name in data/apps/, e.g. calendar): its icon and name
## show above its card when you switch between apps. Empty = no icon or name.
@export var app_name: String = ""

var _minute := -1
# The app switcher's parts, made the first time they're needed.
var _switcher: Dictionary = {}

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
	_place_body()
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


## Moving to this app from another one, like the iPhone's app switcher: `previous` (a
## picture of the other app's screen) shrinks to a card, this app's card slides in
## beside it and grows to fill the phone. `previous_app` / `this_app` give the icons and
## names above the cards (either can be null). Its feel: data/app_transition_style.tres
## → Switching Apps. Use with await.
func switch_in(previous: Texture2D, previous_app: AppInfo, this_app: AppInfo) -> void:
	await _switch(previous, previous_app, this_app, true)


## Back to the other app: this app shrinks to a card and slides away, and `previous`
## slides back and grows to fill the phone. Hide this screen afterwards.
func switch_out(previous: Texture2D, previous_app: AppInfo, this_app: AppInfo) -> void:
	await _switch(previous, previous_app, this_app, false)


func _switch(previous: Texture2D, previous_app: AppInfo, this_app: AppInfo, coming_in: bool) -> void:
	var feel: AppTransitionStyle = AppLauncher.style
	show_up()
	_build_switcher()
	var parts := _switcher
	parts.card_picture.texture = previous
	_fill_label(parts.previous_label, previous_app, feel)
	_fill_label(parts.this_label, this_app, feel)
	for node: CanvasItem in [parts.background, parts.card, parts.rim, parts.previous_label, parts.this_label]:
		node.visible = true
	# Nothing outside the phone while the cards move.
	phone.clip_contents = true
	if feel.switch_sound:
		sound.stream = feel.switch_sound
		sound.volume_db = feel.volume_db
		sound.play()
	var total := feel.switch_shrink_seconds + feel.switch_slide_seconds + feel.switch_grow_seconds
	_set_switch(0.0 if coming_in else 1.0)
	var move := create_tween()
	move.tween_method(_set_switch, 0.0 if coming_in else 1.0, 1.0 if coming_in else 0.0, total)
	await move.finished
	for node: CanvasItem in [parts.background, parts.card, parts.rim, parts.previous_label, parts.this_label]:
		node.visible = false
	parts.card_picture.texture = null
	phone.clip_contents = false
	body.scale = Vector2.ONE
	body.modulate.a = 1.0
	_place_body()


# 0 = the other app fills the screen; 1 = this app does. In between: shrink to cards,
# slide across, grow.
func _set_switch(p: float) -> void:
	var feel: AppTransitionStyle = AppLauncher.style
	var parts := _switcher
	var rect := _body_rect()
	var total := feel.switch_shrink_seconds + feel.switch_slide_seconds + feel.switch_grow_seconds
	var t := p * total
	var shrink := clampf(t / feel.switch_shrink_seconds, 0.0, 1.0)
	var slide := clampf((t - feel.switch_shrink_seconds) / feel.switch_slide_seconds, 0.0, 1.0)
	var grow := clampf((t - feel.switch_shrink_seconds - feel.switch_slide_seconds) / feel.switch_grow_seconds, 0.0, 1.0)
	shrink = ease(shrink, 0.4)
	slide = ease(slide, -2.0)
	grow = ease(grow, 0.4)
	var small := feel.switch_card_scale
	var step := rect.size.x * feel.switch_card_spacing
	var middle := rect.get_center()

	# The other app's card: shrinks, then slides off to the left.
	var card_scale := lerpf(1.0, small, shrink)
	_place_card(parts.card, rect, middle - Vector2(step * slide, 0.0), card_scale)
	# This app's card: waits on the right, slides to the middle, then grows to fill.
	var this_scale := lerpf(small, 1.0, grow)
	_place_card(body, rect, middle + Vector2(step * (1.0 - slide), 0.0), this_scale)
	body.modulate.a = shrink
	# The icons and names over the cards, while they're cards.
	var label_alpha := shrink * (1.0 - grow)
	_place_label(parts.previous_label, rect, middle - Vector2(step * slide, 0.0), card_scale, label_alpha)
	_place_label(parts.this_label, rect, middle + Vector2(step * (1.0 - slide), 0.0), this_scale, label_alpha)


# A card (the other app's picture, or this app's screen) centred on `centre`, scaled.
func _place_card(card: Control, rect: Rect2, centre: Vector2, card_scale: float) -> void:
	card.size = rect.size
	card.pivot_offset = rect.size / 2.0
	card.position = centre - rect.size / 2.0
	card.scale = Vector2.ONE * card_scale


# An app's icon and name, just above its card's top left corner.
func _place_label(label: Control, rect: Rect2, centre: Vector2, card_scale: float, alpha: float) -> void:
	var card_size := rect.size * card_scale
	label.reset_size()
	label.position = centre - card_size / 2.0 - Vector2(0.0, label.size.y + 14.0)
	label.modulate.a = alpha


func _fill_label(label: HBoxContainer, app: AppInfo, feel: AppTransitionStyle) -> void:
	var icon: TextureRect = label.get_child(0)
	var words: Label = label.get_child(1)
	icon.texture = app.icon if app else null
	icon.custom_minimum_size = Vector2.ONE * feel.switch_icon_size
	icon.visible = app != null and app.icon != null and feel.switch_icon_size > 0
	words.text = app.app_name if app else ""
	style.style_label(words, feel.switch_name_color, feel.switch_name_size)
	label.visible = app != null


# The screen's place inside the phone (inside its edge).
func _body_rect() -> Rect2:
	return Rect2(Vector2.ONE * style.edge_width, style.phone_size - Vector2.ONE * style.edge_width * 2.0)


func _place_body() -> void:
	for side in [SIDE_LEFT, SIDE_TOP]:
		body.set_offset(side, style.edge_width)
	for side in [SIDE_RIGHT, SIDE_BOTTOM]:
		body.set_offset(side, -style.edge_width)


# The app switcher's parts, inside the phone: a dark background and the other app's card
# behind this app's screen; the phone's rim and the icons and names in front of it.
func _build_switcher() -> void:
	var feel: AppTransitionStyle = AppLauncher.style
	if _switcher.is_empty():
		var background := Panel.new()
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var card := Panel.new()
		card.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var picture := TextureRect.new()
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_SCALE
		picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(picture)
		var rim := Panel.new()
		rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_switcher = {"background": background, "card": card, "card_picture": picture, "rim": rim,
			"previous_label": _make_label(), "this_label": _make_label()}
		# Behind the screen: the background, then the other app's card.
		phone.add_child(background)
		phone.move_child(background, body.get_index())
		phone.add_child(card)
		phone.move_child(card, body.get_index())
		# In front: the rim (so the cards never cover the phone's edge), the names.
		phone.add_child(rim)
		phone.move_child(rim, frame.get_index())
		for label: Control in [_switcher.previous_label, _switcher.this_label]:
			phone.add_child(label)
			phone.move_child(label, frame.get_index())
	var rect := _body_rect()
	var back := style.make_screen_box()
	back.bg_color = feel.switch_background
	_switcher.background.add_theme_stylebox_override("panel", back)
	_switcher.background.position = rect.position
	_switcher.background.size = rect.size
	_switcher.card.add_theme_stylebox_override("panel", style.make_screen_box())
	var rim_box := StyleBoxFlat.new()
	rim_box.draw_center = false
	rim_box.border_color = style.edge_color
	rim_box.set_border_width_all(style.edge_width + 1)
	rim_box.set_corner_radius_all(style.corner + style.edge_width)
	rim_box.anti_aliasing = true
	_switcher.rim.add_theme_stylebox_override("panel", rim_box)


func _make_label() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 14)
	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	var words := Label.new()
	words.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(words)
	row.visible = false
	return row


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
