class_name PhoneOverlayApp
extends CanvasLayer
## An app that opens on the phone over another phone screen, with its own key: Contacts
## (C) and Profile (P) over the calendar. It opens like moving between open apps on an
## iPhone (the app switcher: data/app_transition_style.tres → Switching Apps), or, with
## that off, like any app. Its key again, Escape or the phone's home bar closes it, back
## to the screen underneath. Pressing another app's key while one is open switches
## straight to the other.
##
## A scene that's one of these needs a PhoneScreen node (unique name %PhoneScreen, Behind
## = Nothing) with the app inside it. Override _show_now() / _hide_now() to fill it in.

## Sent when it has opened, and when it has closed.
signal opened
signal closed

## The key that opens and closes it: an action in Project Settings → Input Map.
@export var open_action: StringName = &""
## The app it is (its icon, name and launch screen): a file name in data/apps/.
@export var app_name: String = ""

var _busy := false
# Where it grew from (opening like any app), to close back into.
var _from := Rect2()
# What's underneath, to switch back to: a picture of it and which app it is.
var _back_picture: Texture2D
var _back_app: AppInfo

## The phone the app is on (its look: data/phone_style.tres).
@onready var phone_screen: PhoneScreen = %PhoneScreen


func _enter_tree() -> void:
	add_to_group(&"phone_overlay")


## Opens it over what's on screen. Use with await to wait for it.
func open() -> void:
	if visible or _busy or AppLauncher.is_busy():
		return
	var other := _open_overlay()
	if other and other._busy:
		return
	_busy = true
	var feel: AppTransitionStyle = AppLauncher.style
	if feel.switch_between_apps:
		var picture := await AppLauncher.capture_rect(phone_screen.screen_rect())
		var from_app: AppInfo
		if other:
			# Switching from one of these straight to another: closing goes back to what
			# was under the first one.
			_back_picture = other._back_picture
			_back_app = other._back_app
			from_app = other._app()
			other._hide_now()
		else:
			_back_picture = picture
			_back_app = _app_underneath()
			from_app = _back_app
		_show_now()
		await phone_screen.switch_in(picture, from_app, _app())
	elif _open_as_app():
		if other:
			other._hide_now()
		_from = AppLauncher.origin_rect()
		await AppLauncher.open(app_name, _show_now, _from)
	else:
		if other:
			other._hide_now()
		_show_now()
		await phone_screen.raise()
	_busy = false
	opened.emit()


## Closes it, back to the screen underneath.
func close() -> void:
	if not visible or _busy or AppLauncher.is_busy():
		return
	_busy = true
	var feel: AppTransitionStyle = AppLauncher.style
	if feel.switch_between_apps and _back_picture:
		_before_close()
		await phone_screen.switch_out(_back_picture, _back_app, _app())
		_hide_now()
	elif _open_as_app():
		await AppLauncher.close(app_name, _hide_now, _from)
	else:
		_before_close()
		await phone_screen.lower()
		_hide_now()
	_back_picture = null
	_busy = false
	closed.emit()


## Override: show the app at once (fill it in, make it visible).
func _show_now() -> void:
	phone_screen.show_up()
	visible = true


## Override: hide the app at once.
func _hide_now() -> void:
	visible = false


## Override: tidy up just before it closes (e.g. put away an open page).
func _before_close() -> void:
	pass


## Override: false to come up with the phone instead of opening like an app (only when
## Switching Apps is off).
func _open_as_app() -> bool:
	return true


## Override: false while Escape should do something else (e.g. go back a page).
func _escape_closes() -> bool:
	return true


func _app() -> AppInfo:
	return AppLauncher.get_app(app_name) if not app_name.is_empty() else null


# The app on the phone underneath: the scene's own PhoneScreen and its App Name.
func _app_underneath() -> AppInfo:
	var scene := get_tree().current_scene
	if not scene:
		return null
	for node in scene.find_children("*", "PhoneScreen", true, false):
		var screen := node as PhoneScreen
		if screen != phone_screen and not is_ancestor_of(screen) and not screen.app_name.is_empty():
			return AppLauncher.get_app(screen.app_name)
	return null


# Another of these that's open now.
func _open_overlay() -> PhoneOverlayApp:
	for app in get_tree().get_nodes_in_group(&"phone_overlay"):
		if app != self and app.visible:
			return app
	return null


# Keys are read here, before the rest of the screen: a tooltip showing under the mouse
# would otherwise swallow Escape.
func _input(event: InputEvent) -> void:
	if not open_action.is_empty() and InputMap.has_action(open_action) and event.is_action_pressed(open_action):
		get_viewport().set_input_as_handled()
		if visible:
			close()
		else:
			open()
	elif visible and _escape_closes() and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
