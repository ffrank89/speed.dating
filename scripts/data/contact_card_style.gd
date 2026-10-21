@tool
class_name ContactCardStyle
extends Resource
## How the phone's Contacts look, type and sound: the end-of-date card (the iPhone "New
## Contact" screen where she types in, or doesn't, her name, number and address), and
## your Contacts, where your party is saved (press W on the calendar: the list, and each
## girl's saved card).
## The boxes, her font and text colour come from HER dialogue style; the phone, its
## screen colour and the phone's own font (Cancel, New Contact, the grey hints) are the
## phone's style (data/phone_style.tres); this file sets everything else.
## One file: data/contact_card_style.tres.
## Full guides: docs/guides/result-screen.md, docs/guides/contacts.md

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
## Used when there's no Heart Animation or Heart Image.
@export var heart_text: String = "❤️"
## Font for Heart Text. Empty = the computer's colour emoji font (Apple's on a Mac,
## Noto on Linux, Segoe on Windows). Her own font isn't used: many fonts have a plain
## black heart that would win over the colourful emoji.
@export var emoji_font: Font
## Optional: a picture to show instead of Heart Text (looks the same on every computer).
@export var heart_image: Texture2D
## Optional: an animated heart instead (a SpriteFrames file, e.g. data/reactions.tres).
## Wins over Heart Image and Heart Text.
@export var heart_animation: SpriteFrames
## Which animation in Heart Animation to play. Empty = its first one.
@export var heart_animation_name: String = "heart"
## How big the heart picture or animation is, in pixels.
@export_range(16, 300) var heart_size: int = 72
## On a failed date she types this where her name would go, then taps Cancel.
## Empty = she types nothing.
@export var failed_name_text: String = "not a chance!"
## With Close By Hand off: how long the finished card stays up, in seconds.
@export_range(0.0, 10.0, 0.1) var end_hold_seconds: float = 2.0

@export_group("Traits")
## Show her traits (her girl file → Contact Card → Traits) under her name, before her number.
@export var show_traits: bool = true
## Off = once her name is written, each trait pops into its field: boop, boop, boop.
## On = she types each one.
@export var type_traits: bool = false
## Seconds between traits popping in.
@export_range(0.0, 3.0, 0.05) var trait_reveal_seconds: float = 0.2
## Each pop's sound plays this much higher than the last (boop, boop, boop going up).
## 0 = all the same pitch.
@export_range(0.0, 0.5, 0.01) var trait_pitch_step: float = 0.12
## What a trait's field says when the date didn't earn enough hearts for that kind
## (data/date_rules.tres → Result → Trait Hearts: tags need 1).
@export var secret_text: String = "you dont know me like that!"
## Size of a trait's description line.
@export_range(8, 200) var trait_description_size: int = 38
## Size of a trait's icon, in pixels.
@export_range(16, 200) var trait_icon_size: int = 64

@export_group("Closing")
## On = when she's done, the card stays until the player clicks Done (top right of the
## card) or presses Escape. Off = it closes by itself after End Hold Seconds.
@export var close_by_hand: bool = true
## Done's colour while the mouse is over it.
@export var done_hover_color: Color = Color(0.2, 0.85, 0.4)
## How far Done's glow spreads while the mouse is over it, in pixels. 0 = no glow.
@export_range(0, 40) var done_glow_size: int = 14
## How strong the glow is (0-1).
@export_range(0.0, 1.0, 0.05) var done_glow_strength: float = 0.4
## Done gently pulses while it's waiting to be clicked, so the player sees it's a button.
@export var done_pulse: bool = true
## Clicking Done (or Escape).
@export var close_sound: AudioStream

@export_group("Contacts App")
## On = pressing C opens your Contacts like an iPhone app inside the phone, and closes
## it back (its icon and launch screen: data/apps/contacts.tres; the feel:
## data/app_transition_style.tres). Off = the phone comes up with Contacts on it
## (data/phone_style.tres → Phone Up / Down).
@export var open_as_app: bool = true
## The big title at the top of the list.
@export var list_title: String = "Contacts"
## Top left of a saved contact: goes back to the list.
@export var back_text: String = "‹ Contacts"
## The list when your party is empty.
@export var no_contacts_text: String = "No Contacts"
## Under the list: how many contacts you have. %d = the number.
@export var one_contact_text: String = "1 Contact"
@export var many_contacts_text: String = "%d Contacts"
## Letter headers (S, T...) above the names, like a phone's contacts.
@export var section_letters: bool = true
## Size of each girl's name in the list (in her font).
@export_range(8, 200) var row_font_size: int = 60
## Size of the round photo (or initials) next to her name in the list, in pixels.
@export_range(40, 300) var row_photo_size: int = 120
## Seconds for a saved contact to slide in over the list (and back out).
@export_range(0.0, 1.0, 0.05) var slide_seconds: float = 0.25

@export_group("Sounds")
## Each letter or number she types.
@export var key_sound: AudioStream
## The space bar.
@export var space_sound: AudioStream
## Moving to the next box.
@export var next_field_sound: AudioStream
## Each trait popping into its field (the "boop").
@export var trait_sound: AudioStream
## Tapping Done (she gave you her number).
@export var done_sound: AudioStream
## Tapping Cancel (she didn't).
@export var cancel_sound: AudioStream
## Your Contacts: tapping a girl in the list to open her contact.
@export var open_contact_sound: AudioStream
## Your Contacts: tapping "‹ Contacts" to go back to the list.
@export var back_sound: AudioStream
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -6.0
