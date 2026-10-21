@tool
class_name AppTransitionStyle
extends Resource
## How every app opens and closes: the iPhone-style animation used for the intro, the
## calendar, the dating app, Contacts and microgames. Apps open inside the phone's
## screen (Screen → Open Into Phone). Going into real life (a date) isn't an app: the
## phone goes down instead (data/phone_style.tres → Phone Up / Down).
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
## of the phone's screen (or the whole screen with Open Into Phone off).
## (0.5, 0.85) = the middle of the bottom, like the iPhone's dock.
@export var default_origin: Vector2 = Vector2(0.5, 0.85)

@export_group("Screen")
## On = apps open inside the phone's screen (Phone below), and grow from inside it when
## nothing was clicked. Off = they fill the whole screen, minus the insets below.
@export var open_into_phone: bool = true
## The phone apps open into (data/phone_style.tres).
@export var phone: PhoneStyle
## Only with Open Into Phone off: where an open app ends up, in pixels in from each edge
## of the screen. All 0 = the whole screen.
@export var screen_inset_left: int = 0
@export var screen_inset_top: int = 0
@export var screen_inset_right: int = 0
@export var screen_inset_bottom: int = 0
## Only with Open Into Phone off: how rounded an open app's corners are, in pixels.
## 0 = square, right for the whole screen. (Into the phone, it's the phone's Corner.)
@export_range(0, 400) var screen_corner: int = 0
## Optional: phone art (e.g. an iPhone frame) drawn over everything while an app opens
## or closes. It's stretched to fill the screen, so draw it at 3000 × 1700.
@export var device_frame: Texture2D

@export_group("Switching Apps")
## On = Contacts and Profile open over the calendar like moving between open apps on an
## iPhone (the app switcher): the screen shrinks to a card, the row of open apps (most
## recent on the right) slides to the next app's card, and it grows to fill the phone.
## Back (Escape, the home bar) goes to the app you were on before.
## Off = they open like any app (Contacts: its Open As App setting).
@export var switch_between_apps: bool = true
## How small the cards get, as a share of the phone's screen.
@export_range(0.3, 1.0, 0.01) var switch_card_scale: float = 0.78
## How far apart the cards are, as a share of the screen's width.
@export_range(0.2, 1.5, 0.01) var switch_card_spacing: float = 0.72
## Seconds for each part: the screen shrinking to a card, the cards sliding across, the
## new card growing to fill the screen.
@export_range(0.05, 1.0, 0.01) var switch_shrink_seconds: float = 0.2
@export_range(0.05, 1.0, 0.01) var switch_slide_seconds: float = 0.3
@export_range(0.05, 1.0, 0.01) var switch_grow_seconds: float = 0.22
## Behind the cards.
@export var switch_background: Color = Color(0.09, 0.09, 0.11)
## The app's icon and name above each card (from its file in data/apps/). Icon size in
## pixels; 0 = no icon.
@export_range(0, 200) var switch_icon_size: int = 64
@export_range(8, 100) var switch_name_size: int = 36
@export var switch_name_color: Color = Color.WHITE
## Played as the cards start to move.
@export var switch_sound: AudioStream

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


## True when apps open inside the phone.
func into_phone() -> bool:
	return open_into_phone and phone != null


## The rectangle an open app fills, in screen pixels.
func screen_rect(screen_size: Vector2) -> Rect2:
	if into_phone():
		return phone.screen_rect(screen_size)
	var top_left := Vector2(screen_inset_left, screen_inset_top)
	var bottom_right := screen_size - Vector2(screen_inset_right, screen_inset_bottom)
	return Rect2(top_left, bottom_right - top_left)


## How rounded an open app's corners are, in pixels.
func open_corner() -> int:
	return phone.corner if into_phone() else screen_corner


## Where apps open from when nothing was clicked: Default Origin, inside the phone's
## screen (Open Into Phone) or the whole screen.
func origin_point(screen_size: Vector2) -> Vector2:
	var area := phone.screen_rect(screen_size) if into_phone() else Rect2(Vector2.ZERO, screen_size)
	return area.position + area.size * default_origin
