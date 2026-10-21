class_name ProfileApp
extends CanvasLayer
## Your Profile, an app on your phone: your four attributes (Culture, Intellect,
## Seduction, Heart) with a bar each. Press P (the open_profile action), or the Profile
## button on the calendar, and it opens inside the phone like Contacts does; P again,
## Escape or the phone's home bar closes it.
##
## A light first version: just your attributes. The phone (screen, font, accent colour)
## is data/phone_style.tres; the words and sizes are the settings below; the attribute
## pictures come from Icons From (the option style's Attribute Icons). Move the parts in
## this scene (PhoneScreen → Phone → Body → Screen → Margin). Press F6 to try it.

## Profile closed.
signal closed

## The key that opens and closes it: an action in Project Settings → Input Map
## (open_profile = P).
@export var open_action: StringName = &"open_profile"
## The app it opens as (its icon and launch screen): a file name in data/apps/.
@export var app_name: String = "profile"
## The big title.
@export var title_text: String = "Profile"
## Under the title.
@export var subtitle_text: String = "Your stats"
## The highest an attribute can go (a full bar).
@export var max_value: float = 100.0
## Where the attribute pictures come from (an option style's Attribute Icons).
@export var icons_from: OptionListStyle
## Size of each attribute's name and number.
@export_range(8, 200) var stat_font_size: int = 50
## Size of each attribute's picture, in pixels.
@export_range(16, 300) var stat_icon_size: int = 90
## Height of each bar, in pixels.
@export_range(4, 100) var bar_height: int = 26
## The empty part of each bar.
@export var bar_back_color: Color = Color(0, 0, 0, 0.08)

var _busy := false
var _from := Rect2()

## The phone it's on (data/phone_style.tres).
@onready var phone_screen: PhoneScreen = %PhoneScreen
@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var stats: VBoxContainer = %Stats


func _ready() -> void:
	add_to_group(&"phone_overlay")
	phone_screen.home_pressed.connect(close)
	if not InputMap.has_action(open_action):
		push_warning("ProfileApp: no input action \"%s\" (Project Settings → Input Map)." % open_action)
	visible = false
	if get_parent() == get_tree().root:
		phone_screen.behind = PhoneScreen.Behind.ROOM
		phone_screen.apply_style()
		open.call_deferred()


## Opens it like an iPhone app inside the phone. Use with await to wait for it.
func open() -> void:
	if visible or _busy or AppLauncher.is_busy() or _other_app_open():
		return
	_busy = true
	_from = AppLauncher.origin_rect()
	await AppLauncher.open(app_name, show_profile, _from)
	_busy = false


## Closes it back into where it opened from.
func close() -> void:
	if not visible or _busy or AppLauncher.is_busy():
		return
	_busy = true
	await AppLauncher.close(app_name, func() -> void: visible = false, _from)
	_busy = false
	closed.emit()


## Shows it at once, with your attributes as they are now.
func show_profile() -> void:
	var ui := phone_screen.style
	ui.style_label(title, ui.ui_text_color, ui.title_font_size)
	title.text = title_text
	ui.style_label(subtitle, Color(ui.ui_text_color, 0.5))
	subtitle.text = subtitle_text
	_build_rows()
	phone_screen.show_up()
	visible = true


func _build_rows() -> void:
	for child in stats.get_children():
		stats.remove_child(child)
		child.queue_free()
	var ui := phone_screen.style
	var player := PlayerManager.ensure_player()
	for attr in Attr.NAMES:
		var stat_name := Attr.display_name(attr)
		var value := float(player.skills.get(stat_name, 0))
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 24)
		row.add_child(line)
		var picture: Texture2D = icons_from.icon_for(attr) if icons_from else null
		if picture:
			var icon := TextureRect.new()
			icon.texture = picture
			icon.custom_minimum_size = Vector2.ONE * stat_icon_size
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			line.add_child(icon)
		var name_label := Label.new()
		name_label.text = stat_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ui.style_label(name_label, ui.ui_text_color, stat_font_size)
		line.add_child(name_label)
		var number := Label.new()
		number.text = str(int(value))
		number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ui.style_label(number, ui.accent_color, stat_font_size)
		line.add_child(number)
		row.add_child(_bar(value / maxf(max_value, 1.0), ui.accent_color))
		stats.add_child(row)


# Another of your apps (Contacts) is already open over this screen.
func _other_app_open() -> bool:
	for app in get_tree().get_nodes_in_group(&"phone_overlay"):
		if app != self and app.visible:
			return true
	return false


# A rounded bar, filled to `amount` (0-1).
func _bar(amount: float, fill: Color) -> Control:
	var back := Panel.new()
	back.custom_minimum_size.y = bar_height
	back.add_theme_stylebox_override("panel", _round(bar_back_color))
	var front := Panel.new()
	front.add_theme_stylebox_override("panel", _round(fill))
	front.anchor_bottom = 1.0
	front.anchor_right = clampf(amount, 0.0, 1.0)
	back.add_child(front)
	return back


func _round(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(100)
	box.anti_aliasing = true
	return box


func _unhandled_input(event: InputEvent) -> void:
	if InputMap.has_action(open_action) and event.is_action_pressed(open_action):
		get_viewport().set_input_as_handled()
		if visible:
			close()
		else:
			open()
	elif visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
