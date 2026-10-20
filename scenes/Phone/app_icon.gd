@tool
class_name AppIcon
extends Control
## One app's icon, iPhone-style: a rounded tile with the app's icon art, and its name
## underneath. Click it (or press Space/Enter while it's selected) to send `pressed`.
## Drop it on any home screen; open its app from it with
##   AppLauncher.open_scene(icon.app, scene_path, icon.tile_rect())
## Full guide: docs/guides/phone-apps.md

signal pressed

const STYLE_PATH := "res://data/app_transition_style.tres"

## The app this icon opens (a file from data/apps/).
@export var app: AppInfo:
	set(value):
		app = value
		queue_redraw()
## Show the app's name under the tile.
@export var show_name: bool = true:
	set(value):
		show_name = value
		queue_redraw()
@export var name_color: Color = Color.WHITE:
	set(value):
		name_color = value
		queue_redraw()
@export_range(8, 120) var name_font_size: int = 34:
	set(value):
		name_font_size = value
		queue_redraw()

var _corner := 0.225


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# Same roundness as the open animation, so the icon and the growing tile match.
	if ResourceLoader.exists(STYLE_PATH):
		_corner = (load(STYLE_PATH) as AppTransitionStyle).icon_corner
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


## The tile's rectangle on screen: what the app grows from and shrinks back into.
func tile_rect() -> Rect2:
	var local := _tile_local()
	return Rect2(get_global_transform() * local.position, local.size * get_global_transform().get_scale())


func _tile_local() -> Rect2:
	var label_room := name_font_size * 1.6 if show_name else 0.0
	var side := minf(size.x, size.y - label_room)
	return Rect2(Vector2((size.x - side) / 2.0, 0.0), Vector2(side, side))


func _draw() -> void:
	if not app:
		return
	var tile := _tile_local()
	var box := StyleBoxFlat.new()
	box.bg_color = app.icon_background
	box.set_corner_radius_all(int(_corner * tile.size.x))
	box.anti_aliasing = true
	if has_focus():
		box.border_color = Color.WHITE
		box.set_border_width_all(6)
	draw_style_box(box, tile)
	if app.icon:
		var art := tile.grow(-tile.size.x * app.icon_padding)
		var picture := app.icon.get_size()
		var fit := minf(art.size.x / picture.x, art.size.y / picture.y)
		var drawn := picture * fit
		draw_texture_rect(app.icon, Rect2(art.position + (art.size - drawn) / 2.0, drawn), false)
	if show_name:
		var font := get_theme_default_font()
		var y := tile.end.y + name_font_size * 1.2
		draw_string(font, Vector2(0.0, y), app.app_name, HORIZONTAL_ALIGNMENT_CENTER, size.x, name_font_size, name_color)


func _gui_input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed
	if clicked or event.is_action_pressed("ui_accept"):
		accept_event()
		pressed.emit()
