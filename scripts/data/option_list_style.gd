@tool
class_name OptionListStyle
extends Resource
## How the player's choice bubbles look, float and sound, including the roll for risky options.
## Works like a girl's dialogue style: a flat colour box or a picture, with or without an
## outline, plus fonts and colours. The shared file is data/option_styles/default.tres;
## a girl can have her own in her GirlData's "Option Style" slot.
## Hover any setting to see what it does.
## Full guide: docs/guides/options-and-scoring.md

@export_group("Bubbles")
## A bubble's fill colour. Lower the A (alpha) value to let the scene show through.
@export var background_color: Color = Color(0.07, 0.08, 0.1, 0.9)
## Fill colour while the mouse is over it, it's being dragged, or it's selected with the arrow keys.
@export var hover_color: Color = Color(0.16, 0.18, 0.24, 0.95)
## Optional: a picture to use as the bubble instead of the flat colour and outline.
## It stretches like a picture frame: the corners stay sharp and the middle stretches.
@export var background_image: Texture2D
## Optional: the picture to use while the mouse is over a bubble. Empty = Background Image.
@export var hover_image: Texture2D
## Only used with Background Image: how many pixels in from each edge of the picture
## are "frame" that must never stretch. Raise it if the corners look squashed.
@export_range(0, 512) var image_corner_size: int = 32
## Only used with Background Image: also draw the outline (colours, width and corner
## radius below) on top of the picture. Off = the picture is the whole bubble, and
## risky options are marked by their % badge only.
@export var keep_outline_with_image: bool = false
## Colour of the line around a bubble.
@export var outline_color: Color = Color(1, 1, 1, 0.7)
## Colour of the line around a bubble while the mouse is over it.
@export var hover_outline_color: Color = Color.WHITE
## Thickness of the line around a bubble, in pixels. 0 = no outline.
@export_range(0, 20) var outline_width: int = 3
## How rounded the corners are, in pixels. 0 = square corners.
## With a picture bubble and Keep Outline With Image, match this to the picture's corners.
@export_range(0, 100) var corner_radius: int = 18
## Empty space between the edge of the bubble and its contents, in pixels.
@export_range(0, 80) var padding: int = 22
## Widest a bubble gets, in pixels. Longer options wrap onto more lines.
@export_range(200, 2000) var bubble_max_width: int = 760
## Least space kept between two bubbles, in pixels. They nudge each other apart.
@export_range(0, 80) var spacing: int = 16
## How much a bubble grows while the mouse is over it. 1.0 = no change.
@export_range(1.0, 1.5, 0.01) var hover_grow: float = 1.06

@export_group("Floating")
## How fast the bubbles drift once they've settled, in pixels per second.
## They stop while the mouse is over one, so they're easy to click.
@export_range(0.0, 400.0, 5.0) var drift_speed: float = 45.0
## How fast they fly out from the start point (above her head) when they appear.
@export_range(0.0, 3000.0, 50.0) var burst_speed: float = 650.0
## How quickly they slow from the burst (or a throw) down to the drift speed.
## Higher = they settle sooner.
@export_range(0.1, 10.0, 0.1) var settle: float = 1.5
## How much they curve while drifting. 0 = straight lines, 1 = lazy loops.
@export_range(0.0, 3.0, 0.05) var wander: float = 0.6

@export_group("Text")
## Font for the choices. Leave empty to use Godot's default font.
@export var font: Font
@export_range(8, 120) var font_size: int = 38
@export var text_color: Color = Color.WHITE
## Colour of the attribute name and requirement, e.g. "Culture 40".
@export var check_color: Color = Color(1, 1, 1, 0.65)
## Optional outline around each letter, which helps text read over busy pictures. 0 = none.
@export_range(0, 20) var text_outline_width: int = 0
## Colour of the outline around each letter.
@export var text_outline_color: Color = Color.BLACK
## Show 1, 2, 3, 4 on the bubbles so players know they can press those keys.
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

@export_group("Dragging")
## Size of the little icons a bubble drops while it's dragged, in pixels.
## Each bubble drops its attribute icon (see Attribute Icons above).
@export_range(8, 200) var trail_icon_size: int = 44
## Distance the mouse moves between two trail icons, in pixels. Lower = more icons.
@export_range(10, 400) var trail_spacing: int = 60
## How long each trail icon lasts before it fades away, in seconds.
@export_range(0.1, 5.0, 0.05) var trail_seconds: float = 0.9
## Icon dropped by options with no attribute check.
@export var trail_fallback_icon: Texture2D
## Fastest a bubble can be thrown when it's let go, in pixels per second. 0 = no throwing.
@export_range(0.0, 5000.0, 50.0) var max_throw_speed: float = 1400.0
## Dropping a bubble onto her picks that option. Only her drawn pixels count,
## not the empty space around her picture.
@export var drop_on_her_picks: bool = true
## Outline colour while a dragged bubble is over her, so the player knows letting go picks it.
@export var drop_outline_color: Color = Color("#ff7eb6")

@export_group("Sounds")
## Played when the mouse moves onto a bubble.
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


## A bubble's background: her picture if one is set, otherwise the flat colour with
## its outline in `line`. `hovered` picks the hover colour or hover picture.
## `width` is the outline's thickness; -1 = Outline Width.
func make_bubble(hovered: bool, line: Color, width := -1) -> StyleBox:
	var picture := hover_image if hovered and hover_image else background_image
	if picture:
		var box := StyleBoxTexture.new()
		box.texture = picture
		box.set_texture_margin_all(image_corner_size)
		box.set_content_margin_all(padding)
		return box
	var flat := _flat(hover_color if hovered else background_color, line, outline_width if width < 0 else width)
	flat.set_content_margin_all(padding)
	return flat


## The outline drawn on top of a picture bubble, or null when there shouldn't be one.
## (A flat bubble already includes its outline.)
func make_outline(line: Color, width := -1) -> StyleBox:
	if not background_image or not keep_outline_with_image or outline_width == 0:
		return null
	return _flat(Color.TRANSPARENT, line, outline_width if width < 0 else width)


## The thick line in the hit or miss colour drawn around the picked bubble.
func make_result_outline(color: Color) -> StyleBox:
	return _flat(Color.TRANSPARENT, color, maxi(outline_width, 3) * 2)


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


func _flat(fill: Color, line: Color, width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.draw_center = fill.a > 0.0
	box.border_color = line
	box.set_border_width_all(width)
	box.set_corner_radius_all(corner_radius)
	box.anti_aliasing = true
	return box
