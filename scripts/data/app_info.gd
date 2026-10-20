@tool
class_name AppInfo
extends Resource
## One app on the player's phone: the calendar, the dating app, a date, the boss fight,
## a microgame... Opening one plays the iPhone-style "open app" animation: its icon
## grows from where the player tapped until it fills the screen with its launch screen,
## then the real screen appears.
##
## One file per app in data/apps/. Hover any setting to see what it does.
## Full guide: docs/guides/phone-apps.md

## The app's name, e.g. "Calendar". Shown under its icon on a home screen.
@export var app_name: String = ""

@export_group("Icon")
## The app's icon art. Square pictures with a see-through background work best.
@export var icon: Texture2D
## The rounded tile behind the icon art.
@export var icon_background: Color = Color.WHITE
## How far the icon art sits in from the tile's edge, as a share of the tile's size.
## 0 = the art fills the tile (use 0 for finished app-icon art that has its own background).
@export_range(0.0, 0.4, 0.01) var icon_padding: float = 0.12

@export_group("Launch Screen")
## Colour that fills the screen while the app opens.
@export var launch_color: Color = Color.WHITE
## Optional: art that fills the screen while the app opens (covers Launch Color).
@export var launch_image: Texture2D
## Size of the icon art in the middle of the launch screen, in pixels. 0 = no icon.
@export_range(0, 1500) var launch_icon_size: int = 360

@export_group("Sounds")
## Optional: replaces the default open sound (data/app_transition_style.tres) for this app.
@export var open_sound: AudioStream
## Optional: replaces the default close sound for this app.
@export var close_sound: AudioStream
