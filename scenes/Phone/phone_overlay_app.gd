class_name PhoneOverlayApp
extends CanvasLayer
## An app that opens on the phone over another phone screen: Contacts and Profile over
## the calendar. Each can have a key of its own (Open Action: C for Contacts, P for
## Profile) that opens it, or goes back if it's open. One key (W, the switch_apps action)
## also flips through them all: each press
## goes to the next app, from the screen underneath (the calendar) to each of these in
## the order they sit in the scene (top to bottom in the Scene panel), then back round to
## the calendar. It opens like moving between open apps on an iPhone (the app switcher:
## data/app_transition_style.tres → Switching Apps), or, with that off, like any app.
##
## Like an iPhone, the phone remembers the order you used its apps in (RecentApps).
## Switching makes the app you were on the most recent; the switcher's cards are in that
## order (newest on the right), and the row slides to the next app's card. Going back
## (Escape or the phone's home bar) steps to the app you were on before, like swiping
## back along the home bar: calendar → W → W (Contacts, then Profile), then Escape goes
## back to Contacts, and Escape again to the calendar.
##
## A scene that's one of these needs a PhoneScreen node (unique name %PhoneScreen, Behind
## = Nothing) with the app inside it. Override _show_now() / _hide_now() to fill it in.

## Sent when it has opened, and when it has closed.
signal opened
signal closed

## The key that flips through the apps on this screen (W): an action in Project Settings
## → Input Map. Every app with the same key is in the round, in scene order. Empty = the
## key skips this app.
@export var switch_action: StringName = &"switch_apps"
## Its own key, opening it (or going back, if it's open): an action in Project Settings
## → Input Map (open_contacts: C, open_profile: P). Empty = none.
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
	for action in [switch_action, open_action]:
		if not action.is_empty() and not InputMap.has_action(action):
			push_warning("%s: no input action \"%s\" (Project Settings → Input Map)." % [name, action])


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


# The switch key, from this app to the screen underneath (the calendar), like picking its
# card in the app switcher: this app counts as used (the most recent), the row slides to
# the screen's card, and it grows to fill the phone.
func _switch_to_underneath() -> void:
	if not visible or _busy or AppLauncher.is_busy():
		return
	var feel: AppTransitionStyle = AppLauncher.style
	if not feel.switch_between_apps:
		await close()
		return
	var recents := RecentApps.of(self)
	if recents.busy:
		return
	var here := recents.find(self)
	if here < 0:
		# Opened while Switching Apps was off: it's the newest now.
		recents.entries.push_front(RecentApps.Entry.new(self, _app()))
		here = 0
	recents.busy = true
	_busy = true
	_before_close()
	recents.bring_to_front(here)
	recents.entries[0].picture = await AppLauncher.capture_rect(phone_screen.screen_rect())
	var to := recents.find(null)
	await phone_screen.switch_apps(recents.cards(), 0, 0, to)
	_hide_now()
	recents.bring_to_front(to)
	_busy = false
	recents.busy = false
	closed.emit()


func _app() -> AppInfo:
	return AppLauncher.get_app(app_name) if not app_name.is_empty() else null


# Another of these that's open now.
func _open_overlay() -> PhoneOverlayApp:
	for app in get_tree().get_nodes_in_group(&"phone_overlay"):
		if app != self and app.visible:
			return app
	return null


# Where `action` (the switch key) goes next from what's on screen: the screen underneath
# (null), then each of these with that key in scene order, then round again.
func _next_app(action: StringName) -> PhoneOverlayApp:
	var order: Array = [null]
	var apps: Array = get_tree().get_nodes_in_group(&"phone_overlay")
	apps.sort_custom(func(a: Node, b: Node) -> bool: return b.is_greater_than(a))
	for app: PhoneOverlayApp in apps:
		if app.switch_action == action:
			order.append(app)
	var on_screen: PhoneOverlayApp = self if visible else _open_overlay()
	return order[(order.find(on_screen) + 1) % order.size()]


func _pressed(event: InputEvent, action: StringName) -> bool:
	return not action.is_empty() and InputMap.has_action(action) and event.is_action_pressed(action)


# Keys are read here, before the rest of the screen: a tooltip showing under the mouse
# would otherwise swallow Escape. Every one of these reads the switch key; only the one
# it concerns acts on it (the next app, or the app on screen going back to the screen
# underneath).
func _input(event: InputEvent) -> void:
	if _pressed(event, switch_action):
		var next := _next_app(switch_action)
		if next == self and not visible:
			get_viewport().set_input_as_handled()
			open()
		elif next == null and visible:
			get_viewport().set_input_as_handled()
			_switch_to_underneath()
	elif _pressed(event, open_action):
		get_viewport().set_input_as_handled()
		if visible:
			close()
		else:
			open()
	elif visible and _escape_closes() and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
