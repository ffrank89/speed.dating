class_name PhoneStyle
extends Resource
## The player's phone: how it looks, where it sits, what's behind it, and how it comes up
## and goes down. Every "on your phone" screen uses it: the intro, the dating app, the
## calendar, Contacts, her contact card after a date, and microgames. Apps open inside
## its screen (data/app_transition_style.tres → Screen → Open Into Phone).
## One shared file: data/phone_style.tres. The phone itself is
## scenes/Phone/PhoneScreen.tscn. Full guide: docs/guides/the-phone.md

@export_group("Phone")
## The whole phone's size, in pixels, edge included. The screen is 3000 × 1700.
@export var phone_size: Vector2 = Vector2(1000, 1600)
## Moves the phone away from the middle of the screen, in pixels (+x = right, +y = down).
@export var phone_offset: Vector2 = Vector2.ZERO
## The screen's colour, behind every app (iPhone's light grey).
@export var screen_color: Color = Color("#f2f2f7")
## Optional: a picture on the screen, behind every app (a wallpaper). It fills the
## screen, cropped to fit. A scene can use its own (its PhoneScreen → Wallpaper).
## Empty = just Screen Color.
@export var wallpaper: Texture2D
## How rounded the screen's corners are, in pixels.
@export_range(0, 300) var corner: int = 70
## The phone's edge around the screen, in pixels. 0 = no edge (just the screen).
@export_range(0, 100) var edge_width: int = 18
@export var edge_color: Color = Color(0.07, 0.07, 0.09)

@export_subgroup("Phone Art")
## Optional: a picture of the phone (e.g. an iPhone frame) drawn over the edge. Draw it
## with the screen part see-through. Empty = the plain edge above.
@export var frame_image: Texture2D
## How far the picture reaches past the phone's edge on each side, in pixels (for art
## with buttons or a shadow sticking out). 0 = exactly the phone's size.
@export_range(0, 400) var frame_spill: int = 0

@export_group("Status Bar")
## The clock and signal along the top of the screen.
@export var show_status_bar: bool = true
## Height of the bar, in pixels. Apps start below it.
@export_range(0, 300) var status_bar_height: int = 90
## The clock. Empty = the computer's real time.
@export var clock_text: String = "9:41"
## Top right of the screen.
@export var status_right_text: String = "5G  100%"
@export var status_text_color: Color = Color(0.1, 0.1, 0.12)
@export_range(8, 120) var status_font_size: int = 38

@export_group("Home Bar")
## The bar along the bottom of the screen. Clicking it goes home (closes Contacts).
@export var show_home_bar: bool = true
## Height of the space it takes, in pixels. Apps end above it.
@export_range(0, 200) var home_bar_height: int = 60
@export var home_pill_color: Color = Color(0.1, 0.1, 0.12, 0.85)
@export_range(20, 800) var home_pill_width: int = 320
@export_range(2, 40) var home_pill_height: int = 14

@export_group("Words")
## The phone's own font, for app titles and buttons. Empty = Godot's default.
@export var ui_font: Font
@export_range(8, 200) var ui_font_size: int = 44
@export var ui_text_color: Color = Color(0.1, 0.1, 0.12)
## Buttons and links in phone apps (iPhone blue).
@export var accent_color: Color = Color("#007aff")
## Size of an app's big title at the top ("Calendar", "Contacts").
@export_range(8, 300) var title_font_size: int = 84

@export_group("Your Room")
## Behind the phone on phone screens (the intro, the dating app, the calendar): the
## player's room. A scene can use its own (its PhoneScreen → Room Image).
@export var room_image: Texture2D
## Laid over the room, so the phone stands out. A = how strong.
@export var room_dim: Color = Color(0, 0, 0, 0.45)
## Laid over real life (the date) while the phone is up over it: her contact card,
## microgames. A = how strong.
@export var real_life_dim: Color = Color(0, 0, 0, 0.35)

@export_group("Phone Up / Down")
## Seconds the phone takes to come up from the bottom of the screen.
@export_range(0.05, 2.0, 0.05) var up_seconds: float = 0.4
## Seconds it takes to go back down.
@export_range(0.05, 2.0, 0.05) var down_seconds: float = 0.35
## The shape of the movement. Back + Out overshoots a little, like lifting a phone.
@export var up_transition: Tween.TransitionType = Tween.TRANS_BACK
@export var up_ease: Tween.EaseType = Tween.EASE_OUT
@export var down_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var down_ease: Tween.EaseType = Tween.EASE_IN
## A small tilt while it moves, in degrees (0 = straight up and down).
@export_range(-30.0, 30.0, 0.5) var tilt_degrees: float = 4.0
@export var up_sound: AudioStream
@export var down_sound: AudioStream
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -6.0


## The whole phone (edge included), in screen pixels.
func phone_rect(screen_size: Vector2) -> Rect2:
	return Rect2((screen_size - phone_size) / 2.0 + phone_offset, phone_size)


## The phone's screen (inside the edge), in screen pixels: where apps open.
func screen_rect(screen_size: Vector2) -> Rect2:
	return phone_rect(screen_size).grow(-edge_width)


## The part of the screen apps use (below the status bar, above the home bar).
func app_rect(screen_size: Vector2) -> Rect2:
	var rect := screen_rect(screen_size)
	var top := status_bar_height if show_status_bar else 0
	var bottom := home_bar_height if show_home_bar else 0
	return Rect2(rect.position + Vector2(0, top), rect.size - Vector2(0, top + bottom))


## The screen's background: Screen Color with rounded corners.
func make_screen_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = screen_color
	box.set_corner_radius_all(corner)
	box.anti_aliasing = true
	return box


## The phone's edge: Edge Color, a little more rounded than the screen.
func make_edge_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = edge_color
	box.set_corner_radius_all(corner + edge_width)
	box.anti_aliasing = true
	box.draw_center = edge_width > 0
	return box


## Puts a label in the phone's font. `font_size` -1 = UI Font Size.
func style_label(label: Label, color: Color = ui_text_color, font_size: int = -1) -> void:
	if ui_font:
		label.add_theme_font_override("font", ui_font)
	label.add_theme_font_size_override("font_size", ui_font_size if font_size < 0 else font_size)
	label.add_theme_color_override("font_color", color)
