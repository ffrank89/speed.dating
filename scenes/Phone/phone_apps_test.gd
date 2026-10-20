extends Control
## Test bench for the "open app" animation: a pretend home screen with one icon per file
## in data/apps/. Click an icon to open its app (a placeholder screen in its launch colour),
## then press Home (or Escape) to close it back into its icon. Press F6 to run it.
## Tune the feel in data/app_transition_style.tres and each app in data/apps/.

var _open_icon: AppIcon

@onready var grid: GridContainer = %Grid
@onready var app_screen: ColorRect = %AppScreen
@onready var app_title: Label = %AppTitle
@onready var home_button: Button = %HomeButton


func _ready() -> void:
	app_screen.visible = false
	home_button.pressed.connect(_go_home)
	for file in DirAccess.get_files_at(AppLauncher.APPS_FOLDER):
		if not file.ends_with(".tres"):
			continue
		var icon := AppIcon.new()
		icon.app = load(AppLauncher.APPS_FOLDER + file)
		icon.custom_minimum_size = Vector2(260, 320)
		icon.pressed.connect(_open.bind(icon))
		grid.add_child(icon)


func _open(icon: AppIcon) -> void:
	if AppLauncher.is_busy() or app_screen.visible:
		return
	_open_icon = icon
	var show_app := func() -> void:
		app_screen.color = icon.app.launch_color.darkened(0.15)
		app_title.text = "%s\n(the real app goes here)" % icon.app.app_name
		app_screen.visible = true
	await AppLauncher.open(icon.app, show_app, icon.tile_rect())


func _go_home() -> void:
	if AppLauncher.is_busy() or not app_screen.visible:
		return
	var hide_app := func() -> void: app_screen.visible = false
	await AppLauncher.close(_open_icon.app, hide_app, _open_icon.tile_rect())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_home()
