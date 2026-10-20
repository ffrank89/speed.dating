@tool
class_name AppTransitionStyle
extends Resource
## How every app opens and closes: the iPhone-style animation used for the calendar,
## the dating app, starting a date, the boss fight and microgames.
## One shared file: data/app_transition_style.tres. Each app's own look (icon, launch
## screen, sounds) is in its file in data/apps/. Full guide: docs/guides/phone-apps.md

@export_group("Opening")
## How long the icon takes to grow to fill the screen, in seconds.
@export_range(0.1, 2.0, 0.05) var open_seconds: float = 0.5
## The shape of the growth. Expo + Out starts fast and settles gently, like an iPhone.
@export var open_transition: Tween.TransitionType = Tween.TRANS_EXPO
@export var open_ease: Tween.EaseType = Tween.EASE_OUT
## How long the launch screen stays once it fills the screen, in seconds.
@export_range(0.0, 2.0, 0.05) var launch_hold_seconds: float = 0.1
## How long the launch screen takes to fade away and show the app, in seconds.
@export_range(0.0, 2.0, 0.05) var reveal_seconds: float = 0.2

@export_group("Closing")
## How long an app takes to shrink back into its icon, in seconds.
@export_range(0.1, 2.0, 0.05) var close_seconds: float = 0.45
@export var close_transition: Tween.TransitionType = Tween.TRANS_EXPO
@export var close_ease: Tween.EaseType = Tween.EASE_OUT

@export_group("Icon")
## Size of the icon an app opens from when nothing on screen was tapped, in pixels.
@export_range(40, 800) var icon_size: int = 220
## How rounded icons are, as a share of their size. An iPhone icon is about 0.225.
@export_range(0.0, 0.5, 0.005) var icon_corner: float = 0.225
## Apps open from wherever the player last clicked, if it was this recent (seconds).
## 0 = always open from Default Origin.
@export_range(0.0, 10.0, 0.1) var tap_memory_seconds: float = 1.5
## Where apps open from when there was no recent click (e.g. a key press), as a share
## of the screen. (0.5, 0.85) = the middle of the bottom, like the iPhone's dock.
@export var default_origin: Vector2 = Vector2(0.5, 0.85)

@export_group("Screen")
## Where an open app ends up, in pixels in from each edge of the screen. All 0 = the
## whole screen. Raise them to open apps into a phone screen drawn in the scene.
@export var screen_inset_left: int = 0
@export var screen_inset_top: int = 0
@export var screen_inset_right: int = 0
@export var screen_inset_bottom: int = 0
## How rounded an open app's corners are, in pixels (like the phone screen's corners).
## 0 = square, right for the whole screen.
@export_range(0, 400) var screen_corner: int = 0
## Optional: phone art (e.g. an iPhone frame) drawn over everything while an app opens
## or closes. It's stretched to fill the screen, so draw it at 3000 × 1700.
@export var device_frame: Texture2D

@export_group("Behind")
## How much the screen behind zooms while an app opens. 1.0 = no zoom.
@export_range(0.5, 2.0, 0.01) var behind_zoom: float = 1.08
## Colour laid over the screen behind as an app opens. Lower the A (alpha) for less.
@export var behind_dim: Color = Color(0, 0, 0, 0.5)

@export_group("Sounds")
## Played when any app opens or closes, unless the app has its own.
@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -6.0


## The rectangle an open app fills, in screen pixels.
func screen_rect(screen_size: Vector2) -> Rect2:
	var top_left := Vector2(screen_inset_left, screen_inset_top)
	var bottom_right := screen_size - Vector2(screen_inset_right, screen_inset_bottom)
	return Rect2(top_left, bottom_right - top_left)
