@tool
class_name ContactCardStyle
extends Resource
## How the end-of-date contact card looks, types and sounds: the iPhone "New Contact"
## screen where she types in (or doesn't) her name, number and address.
## The boxes, her font and text colour come from HER dialogue style; this file sets
## everything else. One file: data/contact_card_style.tres.
## Full guide: docs/guides/result-screen.md

@export_group("Sheet")
## The phone screen's background (iPhone's light grey).
@export var sheet_color: Color = Color("#f2f2f7")
## How rounded the sheet's corners are, in pixels.
@export_range(0, 300) var sheet_corner: int = 70
## Laid over the date behind the sheet.
@export var behind_dim: Color = Color(0, 0, 0, 0.55)
## Font for the iPhone's own words (Cancel, New Contact, the grey hints). Empty = Godot's default.
@export var ui_font: Font
@export_range(8, 200) var ui_font_size: int = 44
@export var ui_text_color: Color = Color(0.1, 0.1, 0.12)

@export_group("Words")
@export var title: String = "New Contact"
@export var cancel_text: String = "Cancel"
@export var done_text: String = "Done"
@export var add_photo_text: String = "Add Photo"
@export var first_name_hint: String = "First name"
@export var last_name_hint: String = "Last name"
@export var company_hint: String = "Company"
@export var phone_kind: String = "mobile"
@export var address_kind: String = "home"
@export var got_number_text: String = "You got her number!"
@export var no_number_text: String = "She didn't give you her number."

@export_group("Fields")
## Size of what she types (in her font).
@export_range(8, 200) var field_font_size: int = 54
## How faint the grey hints ("First name") are. 0 = invisible, 1 = as strong as her text.
@export_range(0.0, 1.0, 0.05) var hint_alpha: float = 0.35

@export_group("Typing")
## She types each key after a random wait between these, in seconds.
@export_range(0.02, 1.0, 0.01) var min_seconds_per_key: float = 0.07
@export_range(0.02, 1.0, 0.01) var max_seconds_per_key: float = 0.17
## Pause before she moves to the next box, in seconds.
@export_range(0.0, 3.0, 0.05) var pause_between_fields: float = 0.5
## Typed after her name on a really good date (see data/date_rules.tres → Result).
@export var heart_text: String = "❤️"
## Font for Heart Text. Empty = the computer's colour emoji font (Apple's on a Mac,
## Noto on Linux, Segoe on Windows). Her own font isn't used: many fonts have a plain
## black heart that would win over the colourful emoji.
@export var emoji_font: Font
## Optional: a picture to show instead of Heart Text (looks the same on every computer).
@export var heart_image: Texture2D
## On a bad date she types her name, thinks better of it, deletes it and taps Cancel.
## Off = the card just closes with nothing typed.
@export var type_then_delete_when_no: bool = true
## How long the finished card stays up, in seconds.
@export_range(0.0, 10.0, 0.1) var end_hold_seconds: float = 2.0

@export_group("Sounds")
## Each letter or number she types.
@export var key_sound: AudioStream
## The space bar.
@export var space_sound: AudioStream
## Each letter she deletes.
@export var delete_sound: AudioStream
## Moving to the next box.
@export var next_field_sound: AudioStream
## Tapping Done (she gave you her number).
@export var done_sound: AudioStream
## Tapping Cancel (she didn't).
@export var cancel_sound: AudioStream
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -6.0
