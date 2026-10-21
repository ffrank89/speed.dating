class_name RecentApps
extends RefCounted
## The apps open on one screen, most recently used first, like the iPhone's app switcher:
## the screen underneath (e.g. the calendar) and the apps opened over it (Contacts,
## Profile).
##
## Switching to an app (W) makes the app you were on the most recent, and the switcher's
## cards are in this order: newest on the right, older ones to its left. Going back
## (Escape, the home bar) steps to the app before without changing the order, like
## swiping back along an iPhone's home bar: calendar → W → W (Contacts, then Profile),
## then back goes to Contacts, then to the calendar.
##
## Each scene has its own (RecentApps.of(node)); it goes when the scene does.

## One open app.
class Entry:
	## The app over the screen. Null = the screen underneath.
	var overlay: PhoneOverlayApp
	## Its icon and name (a file in data/apps/), or null.
	var app: AppInfo
	## How it looked when you left it.
	var picture: Texture2D

	func _init(its_overlay: PhoneOverlayApp, its_app: AppInfo) -> void:
		overlay = its_overlay
		app = its_app


## Most recently used first.
var entries: Array[Entry] = []
## The one on screen now.
var current := 0
## A switch is playing.
var busy := false


## This scene's recent apps, made the first time with just the screen underneath.
static func of(node: Node) -> RecentApps:
	var scene := node.get_tree().current_scene
	if scene and scene.has_meta(&"recent_apps"):
		return scene.get_meta(&"recent_apps")
	var recents := RecentApps.new()
	recents.entries.append(Entry.new(null, _app_underneath(scene)))
	if scene:
		scene.set_meta(&"recent_apps", recents)
	return recents


## Where this app is in the list (-1 = not open yet).
func find(overlay: PhoneOverlayApp) -> int:
	for i in entries.size():
		if entries[i].overlay == overlay:
			return i
	return -1


## The app on screen has been used: it becomes the most recent.
func settle() -> void:
	bring_to_front(current)


## Moves the app at `index` to the front (the most recent) and makes it the one on screen.
func bring_to_front(index: int) -> void:
	var entry := entries[index]
	entries.remove_at(index)
	entries.push_front(entry)
	current = 0


## Going back from the app at `index`: the one used before it (the next card to the
## left), or the screen underneath if there's none.
func back_from(index: int) -> int:
	if index + 1 < entries.size():
		return index + 1
	for i in entries.size():
		if not entries[i].overlay:
			return i
	return 0


## The cards for PhoneScreen.switch_apps(), in this order.
func cards() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for entry in entries:
		list.append({"picture": entry.picture, "app": entry.app})
	return list


# The app on the phone underneath: the first PhoneScreen in the scene that isn't in one
# of these apps and has an App Name.
static func _app_underneath(scene: Node) -> AppInfo:
	if not scene:
		return null
	for node in scene.find_children("*", "PhoneScreen", true, false):
		var screen := node as PhoneScreen
		if not screen.app_name.is_empty() and not _in_overlay(screen):
			return AppLauncher.get_app(screen.app_name)
	return null


static func _in_overlay(node: Node) -> bool:
	while node:
		if node is PhoneOverlayApp:
			return true
		node = node.get_parent()
	return false
