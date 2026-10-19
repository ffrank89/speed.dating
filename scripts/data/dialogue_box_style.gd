@tool
class_name DialogueBoxStyle
extends Resource
## How a girl's dialogue box looks: the box, its outline, her font and her name plate.
##
## Make one per girl in data/dialogue_styles/ and drop it into the "Dialogue Style"
## slot of her GirlData. A girl with no style uses data/dialogue_styles/default.tres.
## Hover any setting in the Inspector to see what it does.
## Full guide: docs/guides/dialogue-box.md

@export_group("Box")
## The box's fill colour. Lower the A (alpha) value to let the scene show through.
@export var background_color: Color = Color(0.07, 0.08, 0.1, 0.88)
## Optional: a picture to use as the box instead of the flat colour and outline.
## It stretches like a picture frame: the corners stay sharp and the middle stretches.
@export var background_image: Texture2D
## Only used with Background Image: how many pixels in from each edge of the picture
## are "frame" that must never stretch. Raise it if the corners look squashed.
@export_range(0, 512) var image_corner_size: int = 32
## Only used with Background Image: also draw the outline (colour, width and corner
## radius below) on top of the picture. Off = the picture is the whole box.
@export var keep_outline_with_image: bool = false
## Colour of the line around the box.
@export var outline_color: Color = Color.WHITE
## Thickness of the line around the box, in pixels. 0 = no outline.
@export_range(0, 40) var outline_width: int = 4
## How rounded the corners are, in pixels. 0 = square corners.
## With a picture box and Keep Outline With Image, match this to the picture's corners.
@export_range(0, 200) var corner_radius: int = 24
## Empty space between the edge of the box and the text, in pixels.
@export_range(0, 200) var padding: int = 44

@export_group("Text")
## Her font. Drag a .ttf or .otf file here from the FileSystem panel.
## Leave empty to use the default style's font.
@export var font: Font
## Size of her text.
@export_range(8, 200) var font_size: int = 46
## Colour of her text.
@export var text_color: Color = Color.WHITE
## Optional outline around each letter, which helps text read over busy pictures. 0 = none.
@export_range(0, 20) var text_outline_width: int = 0
## Colour of the outline around each letter.
@export var text_outline_color: Color = Color.BLACK

@export_group("Name Plate")
## Show her name in a small tab above the box.
@export var show_name_plate: bool = true
## Fill colour of the name tab.
@export var name_plate_color: Color = Color(0.07, 0.08, 0.1, 0.95)
## Colour of the line around the name tab. Uses the box's Outline Width.
@export var name_plate_outline_color: Color = Color.WHITE
## Colour of her name.
@export var name_color: Color = Color.WHITE
## Font for her name. Leave empty to use her text font.
@export var name_font: Font
## Size of her name.
@export_range(8, 200) var name_font_size: int = 40

@export_group("Next Arrow")
## The small marker that bobs in the corner once her line has finished typing.
## Leave empty to show a ▼ in the arrow colour.
@export var next_arrow_image: Texture2D
## Colour of the ▼ (ignored when Next Arrow Image is set).
@export var next_arrow_color: Color = Color.WHITE


## The box background, built from the settings above.
func make_box() -> StyleBox:
	if background_image:
		var box := StyleBoxTexture.new()
		box.texture = background_image
		box.set_texture_margin_all(image_corner_size)
		box.set_content_margin_all(padding)
		return box
	var flat := _flat(background_color, outline_color, corner_radius)
	flat.set_content_margin_all(padding)
	return flat


## The outline drawn on top of a picture box, or null when there shouldn't be one.
## (A flat box already includes its outline.)
func make_outline() -> StyleBox:
	if not background_image or not keep_outline_with_image or outline_width == 0:
		return null
	var line := _flat(Color.TRANSPARENT, outline_color, corner_radius)
	line.draw_center = false
	return line


## The name tab background, built from the settings above.
func make_name_plate() -> StyleBox:
	var flat := _flat(name_plate_color, name_plate_outline_color, mini(corner_radius, 20))
	flat.content_margin_left = 28
	flat.content_margin_right = 28
	flat.content_margin_top = 6
	flat.content_margin_bottom = 10
	return flat


func _flat(fill: Color, line: Color, radius: int) -> StyleBoxFlat:
	var flat := StyleBoxFlat.new()
	flat.bg_color = fill
	flat.border_color = line
	flat.set_border_width_all(outline_width)
	flat.set_corner_radius_all(radius)
	flat.anti_aliasing = true
	return flat
