class_name DatingAppStyle
extends Resource
## How the dating app looks and sounds: the profile cards you swipe through on your phone
## before a date. The phone itself (its screen, font, status bar, your room behind it) is
## data/phone_style.tres. One file: data/dating_app_style.tres. Where the parts sit is the
## scene scenes/Tinder/Screen.tscn. Full guide: docs/guides/dating-app.md

@export_group("Words")
## The big title at the top of the app.
@export var title: String = "Discover"
## Next to her name. {age} = her age.
@export var age_text: String = ", {age}"
## Above her interests.
@export var interests_title: String = "Interests"
## Before each interest.
@export var bullet: String = "• "
## The button that skips to the next profile.
@export var pass_text: String = "Ewwwwwww...."
## The button that starts the date with her.
@export var start_text: String = "Start Dating!"
## When everyone's in your contacts or gone for the run.
@export var no_one_text: String = "No one left to swipe on."
## Start, when there's no one left: back to the calendar.
@export var back_text: String = "Back to the calendar"

@export_group("Profile Card")
## On = her card uses HER dialogue style (her box, font and colours, like her contact).
## Off = Card Color and the phone's font.
@export var use_her_style: bool = true
## Only with Use Her Style off: the card's colour.
@export var card_color: Color = Color.WHITE
## Only with Use Her Style off: the words' colour.
@export var card_text_color: Color = Color(0.1, 0.1, 0.12)
## How rounded the card's corners are, in pixels.
@export_range(0, 200) var card_corner: int = 40
## Behind her picture.
@export var photo_background: Color = Color(0.2, 0.2, 0.22)
## Her picture's height, in pixels.
@export_range(100, 1200) var photo_height: int = 460
## How much of the picture's box her picture fills (1 = touches the edges).
@export_range(0.1, 1.0, 0.05) var photo_fill: float = 0.9
@export_range(8, 200) var name_font_size: int = 64
@export_range(8, 200) var bio_font_size: int = 40
@export_range(8, 200) var interests_font_size: int = 36

@export_group("Buttons")
@export var pass_color: Color = Color(0.4, 0.4, 0.6)
@export var start_color: Color = Color(0.2, 0.6, 0.3)
@export var button_text_color: Color = Color.WHITE
@export_range(8, 200) var button_font_size: int = 40
## Height of the buttons, in pixels.
@export_range(40, 400) var button_height: int = 120
## How rounded the buttons are, in pixels.
@export_range(0, 200) var button_corner: int = 60

@export_group("Swiping")
## Seconds her card takes to swipe away (Pass) and the next one to come in.
@export_range(0.05, 2.0, 0.05) var swipe_seconds: float = 0.3
## How far the card turns as it swipes away, in degrees.
@export_range(0.0, 45.0, 0.5) var swipe_tilt: float = 12.0

@export_group("Sounds")
## Pass: her card swipes away.
@export var pass_sound: AudioStream
## Start Dating!
@export var start_sound: AudioStream
## A button under the mouse.
@export var hover_sound: AudioStream
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -6.0


## A rounded button box in `color`.
func make_button_box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(button_corner)
	box.anti_aliasing = true
	box.content_margin_left = 30
	box.content_margin_right = 30
	return box
