class_name PlayerStyle
extends Resource
## The player's own look. Each girl's dialogue style decides her boxes; the player's style
## decides the look of the player's things: the calendar's day cards and their buttons,
## the calendar's Contacts / Profile buttons, and the whole month's squares. Colours,
## font, corners, borders, shadows. (Pictures for the calendar are its Calendar Art.)
## (Sizes, words and what shows are the calendar's style: data/calendar_style.tres.
## The phone itself is data/phone_style.tres.)
## One file: data/player_style.tres. Full guide: docs/guides/the-calendar.md

@export_group("Cards")
## A day card's colour (inside its coloured border).
@export var card_color: Color = Color("#33424a")
## The darker panels inside a card (behind each choice, the boss, the X).
@export var panel_color: Color = Color("#1f292e")
## How rounded cards and panels are, in pixels.
@export_range(0, 100) var corner: int = 18
## The coloured border around each card, in pixels. Its colour says what the day is
## (Day Colours below).
@export_range(0, 40) var border_width: int = 8
## A shadow under each card. A = how dark; 0 = none.
@export var shadow_color: Color = Color(0, 0, 0, 0.45)
## How far the shadow falls, in pixels (down and right).
@export var shadow_offset: Vector2 = Vector2(0, 8)

@export_group("Day Colours")
## The border and name tab of each kind of day.
@export var today_color: Color = Color("#0093ff")
@export var upcoming_color: Color = Color("#d9a520")
@export var boss_color: Color = Color("#e0453a")
## A day too far ahead to see (an X).
@export var hidden_color: Color = Color("#5d6a72")
## A day already gone (only in the whole month).
@export var past_color: Color = Color("#4a565c")
## Upcoming days fade to this, so today stands out (1 = not faded).
@export_range(0.2, 1.0, 0.05) var upcoming_alpha: float = 0.85
## Days already gone fade to this, in the whole month.
@export_range(0.0, 1.0, 0.05) var past_alpha: float = 0.45

@export_group("Words")
## Font for the cards, tabs and buttons. Empty = the phone's font.
@export var font: Font
@export var text_color: Color = Color.WHITE
## Lines under titles ("2 days · Swipe for someone new"), "Upcoming".
@export var faint_text_color: Color = Color("#a9b8bf")
## A dark edge around the words, for a chunky look. 0 = none.
@export_range(0, 20) var text_outline_width: int = 6
@export var text_outline_color: Color = Color(0, 0, 0, 0.55)

@export_group("Choices")
## Today's choices light up with a border in this colour under the mouse.
@export var choice_hover_color: Color = Color("#ff9800")
## How thick that border is, in pixels.
@export_range(0, 30) var choice_hover_width: int = 6

@export_group("Buttons")
## The calendar's Month button.
@export var month_button_color: Color = Color("#ff9800")
@export var button_text_color: Color = Color.WHITE
## How rounded buttons are, in pixels.
@export_range(0, 100) var button_corner: int = 16
## The darker edge under each button, in pixels (chunky, like a key).
@export_range(0, 20) var button_depth: int = 6


## The colour of a kind of day (today, upcoming, boss...): its border and tab.
func day_color(today: bool, boss: bool, hidden: bool, past := false) -> Color:
	if hidden:
		return hidden_color
	if past:
		return past_color
	if boss:
		return boss_color
	return today_color if today else upcoming_color


## A day card: Card Color with a border in `edge`, and a shadow. (Calendar art, the
## calendar style's Day Image, replaces it when it's set.)
func make_card(edge: Color, padding: int) -> StyleBoxFlat:
	var box := _flat(card_color, corner)
	box.border_color = edge
	box.set_border_width_all(border_width)
	box.shadow_color = shadow_color
	box.shadow_size = 1 if shadow_color.a > 0.0 else 0
	box.shadow_offset = shadow_offset
	box.set_content_margin_all(padding)
	return box


## A darker panel inside a card. `lit` = under the mouse: a little lighter, with a border
## in Choice Hover Color.
func make_panel(padding: int, lit := false) -> StyleBoxFlat:
	var box := _flat(panel_color.lightened(0.08) if lit else panel_color, maxi(corner - 6, 0))
	box.set_content_margin_all(padding)
	if lit:
		box.border_color = choice_hover_color
		box.set_border_width_all(choice_hover_width)
		# The border sits inside the panel; the words keep their place.
		box.set_content_margin_all(padding)
	return box


## A name tab in `color` (the weekday on a card).
func make_tab(color: Color) -> StyleBoxFlat:
	var box := _flat(color, maxi(corner - 6, 4))
	box.content_margin_left = 22
	box.content_margin_right = 22
	box.content_margin_top = 4
	box.content_margin_bottom = 6
	return box


## A chunky button in `color`: a darker edge underneath, lighter under the mouse
## (`state`: "normal", "hover", "pressed" or "disabled").
func make_button(color: Color, state := "normal") -> StyleBoxFlat:
	var fill := color
	match state:
		"hover":
			fill = color.lightened(0.12)
		"pressed":
			fill = color.darkened(0.12)
		"disabled":
			fill = color.darkened(0.5)
	var box := _flat(fill, button_corner)
	box.border_color = fill.darkened(0.35)
	box.border_width_bottom = 0 if state == "pressed" else button_depth
	box.content_margin_left = 18
	box.content_margin_right = 18
	box.content_margin_top = 8 + (button_depth if state == "pressed" else 0)
	box.content_margin_bottom = 8
	return box


## The cards' font: Font, or `fallback` (the phone's) when it's empty.
func font_or(fallback: Font) -> Font:
	return font if font else fallback


## Puts a label in the player's look: Font (or `fallback`), size, colour, the dark edge.
func style_label(label: Label, fallback: Font, font_size: int, color: Color = text_color) -> void:
	var chosen := font_or(fallback)
	if chosen:
		label.add_theme_font_override("font", chosen)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", text_outline_width)
	label.add_theme_color_override("font_outline_color", text_outline_color)


func _flat(fill: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.set_corner_radius_all(radius)
	box.anti_aliasing = true
	return box
