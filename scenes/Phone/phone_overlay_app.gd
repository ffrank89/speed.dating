class_name PhoneOverlayApp
extends CanvasLayer
## An app that opens on the phone over another phone screen, with its own key: Contacts
## (C) and Profile (P) over the calendar. It opens like moving between open apps on an
## iPhone (the app switcher: data/app_transition_style.tres → Switching Apps), or, with
## that off, like any app.
##
## Like an iPhone, the phone remembers the order you used its apps in (RecentApps).
## Pressing an app's key makes the app you were on the most recent; the switcher's cards
## are in that order (newest on the right), and the row slides to the app's card. Going
## back (its key again, Escape or the phone's home bar) steps to the app you were on
## before, like swiping back along the home bar: calendar → C → P, then Escape goes back
## to Contacts, and Escape again to the calendar.
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

## The phone the app is on (its look: data/phone_style.tres).
@onready var phone_screen: PhoneScreen = %PhoneScreen


func _enter_tree() -> void:
	add_to_group(&"phone_overlay")


## Opens it (switches to it) over what's on screen. Use with await.
func open() -> void:
	if visible or _busy or AppLauncher.is_busy():
		return
	var other := _open_overlay()
	if other and other._busy:
		return
	var feel: AppTransitionStyle = AppLauncher.style
	if feel.switch_between_apps:
		await _switch_to_this()
		return
	_busy = true
	if other:
		other._hide_now()
	if _open_as_app():
		_from = AppLauncher.origin_rect()
		await AppLauncher.open(app_name, _show_now, _from)
	else:
		_show_now()
		await phone_screen.raise()
	_busy = false
	opened.emit()


## Closes it: back to the app you were on before (the screen underneath, or another of
## these).
func close() -> void:
	if not visible or _busy or AppLauncher.is_busy():
		return
	var feel: AppTransitionStyle = AppLauncher.style
	if feel.switch_between_apps:
		await _switch_back()
		return
	_busy = true
	if _open_as_app():
		await AppLauncher.close(app_name, _hide_now, _from)
	else:
		_before_close()
		await phone_screen.lower()
		_hide_now()
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


# The app switcher, to this app: the app on screen counts as used (it becomes the most
# recent) and shrinks to a card, the row of recent apps slides to this app's card (a new
# one comes in on the right, as the newest), and it grows to fill the phone.
func _switch_to_this() -> void:
	var recents := RecentApps.of(self)
	if recents.busy:
		return
	recents.busy = true
	_busy = true
	recents.settle()
	var leaving := recents.entries[0]
	if leaving.overlay:
		leaving.overlay._before_close()
	leaving.picture = await AppLauncher.capture_rect(phone_screen.screen_rect())
	var from := 0
	var to := recents.find(self)
	if to < 0:
		recents.entries.push_front(RecentApps.Entry.new(self, _app()))
		from = 1
		to = 0
	if leaving.overlay:
		leaving.overlay._hide_now()
	_show_now()
	await phone_screen.switch_apps(recents.cards(), to, from, to)
	recents.bring_to_front(to)
	_busy = false
	recents.busy = false
	opened.emit()


# Back to the app used before this one (the next card to the left), like swiping back
# along an iPhone's home bar. The order of the recent apps stays as it is.
func _switch_back() -> void:
	var recents := RecentApps.of(self)
	if recents.busy:
		return
	var here := recents.find(self)
	if here < 0:
		# Opened while Switching Apps was off: it's the newest now.
		recents.entries.push_front(RecentApps.Entry.new(self, _app()))
		here = 0
	var back := recents.back_from(here)
	recents.busy = true
	_busy = true
	_before_close()
	recents.entries[here].picture = await AppLauncher.capture_rect(phone_screen.screen_rect())
	await phone_screen.switch_apps(recents.cards(), here, here, back)
	var going_to := recents.entries[back]
	if going_to.overlay:
		going_to.overlay._show_now()
	_hide_now()
	recents.current = back
	_busy = false
	recents.busy = false
	closed.emit()
	if going_to.overlay:
		going_to.overlay.opened.emit()


func _app() -> AppInfo:
	return AppLauncher.get_app(app_name) if not app_name.is_empty() else null


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
