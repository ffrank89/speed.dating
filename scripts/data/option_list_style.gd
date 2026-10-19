@tool
class_name OptionListStyle
extends Resource
## How the player's choice buttons look and sound, including the roll for risky options.
## One shared file: data/option_styles/default.tres. Hover any setting to see what it does.
## Full guide: docs/guides/options-and-scoring.md

@export_group("Buttons")
## Fill colour of a choice button.
@export var button_color: Color = Color(0.07, 0.08, 0.1, 0.9)
## Fill colour while the mouse is over it (or it's selected with the arrow keys).
@export var hover_color: Color = Color(0.16, 0.18, 0.24, 0.95)
## Colour of the line around a button.
@export var outline_color: Color = Color(1, 1, 1, 0.7)
## Colour of the line around a button while the mouse is over it.
@export var hover_outline_color: Color = Color.WHITE
## Thickness of the line around a button, in pixels.
@export_range(0, 20) var outline_width: int = 3
## How rounded the corners are, in pixels.
@export_range(0, 100) var corner_radius: int = 18
## Space between the button's edge and its contents, in pixels.
@export_range(0, 80) var padding: int = 22
## Space between buttons, in pixels.
@export_range(0, 80) var spacing: int = 16
## How far a button slides left when the mouse is over it, in pixels. 0 = no slide.
@export_range(0, 60) var hover_slide: int = 18

@export_group("Text")
## Font for the choices. Leave empty to use Godot's default font.
@export var font: Font
@export_range(8, 120) var font_size: int = 38
@export var text_color: Color = Color.WHITE
## Colour of the attribute name and requirement, e.g. "Culture 40".
@export var check_color: Color = Color(1, 1, 1, 0.65)
## Show 1, 2, 3, 4 on the buttons so players know they can press those keys.
@export var show_number_keys: bool = true
@export var number_key_color: Color = Color(1, 1, 1, 0.45)

@export_group("Risky Options")
## Outline colour of an option the player might miss (below its requirement).
@export var risky_outline_color: Color = Color("#ffb347")
## Fill colour of the % badge on a risky option.
@export var badge_color: Color = Color("#ffb347")
## Colour of the % text on the badge.
@export var badge_text_color: Color = Color("#2a1a05")

@export_group("Roll")
## How long the numbers spin before landing, in seconds.
@export_range(0.2, 4.0, 0.1) var roll_seconds: float = 1.1
## Flash colour when an option lands.
@export var hit_color: Color = Color("#4cd47a")
## Flash colour when an option misses.
@export var miss_color: Color = Color("#ff5a5a")
## Word shown when a risky option lands.
@export var hit_text: String = "HIT"
## Word shown when a risky option misses.
@export var miss_text: String = "MISS"

@export_group("Attribute Icons")
## Small picture shown on options that check this attribute.
@export var culture_icon: Texture2D
@export var intellect_icon: Texture2D
@export var seduction_icon: Texture2D
@export var heart_icon: Texture2D
## Size of the attribute icons, in pixels.
@export_range(16, 200) var icon_size: int = 64

@export_group("Sounds")
## Played when the mouse moves onto a choice.
@export var hover_sound: AudioStream
## Played when a choice is picked.
@export var select_sound: AudioStream
## Played on each spin of the roll numbers.
@export var roll_tick_sound: AudioStream
## Played when a risky option lands.
@export var hit_sound: AudioStream
## Played when a risky option misses.
@export var miss_sound: AudioStream
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -6.0


func icon_for(attribute: int) -> Texture2D:
	match attribute:
		Attr.Id.CULTURE:
			return culture_icon
		Attr.Id.INTELLECT:
			return intellect_icon
		Attr.Id.SEDUCTION:
			return seduction_icon
		Attr.Id.HEART:
			return heart_icon
	return null


## A button background in the given fill and outline colours.
func make_button(fill: Color, line: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = line
	box.set_border_width_all(outline_width)
	box.set_corner_radius_all(corner_radius)
	box.set_content_margin_all(padding)
	box.anti_aliasing = true
	return box


## The small rounded badge that shows a risky option's %.
func make_badge(fill: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.set_corner_radius_all(999)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 2
	box.content_margin_bottom = 4
	return box
