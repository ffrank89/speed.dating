@tool
class_name CursorStyle
extends Resource
## How the player's mouse cursor looks: one picture, plus optional ones for hovering
## something clickable, holding the button down, and dragging.
## One file per cursor in data/cursors/. The game uses data/cursors/default.tres
## (set in scenes/Cursor/PlayerCursor.tscn); code can switch with PlayerCursor.use(style).
## Hover any setting to see what it does. Full guide: docs/guides/cursor.md

@export_group("Pointer")
## The normal cursor picture. See-through background; draw every state at the same size.
## The system cursor can't be bigger than 256 × 256 pixels (after Size).
@export var image: Texture2D
## The pixel in the picture that does the clicking (e.g. the fingertip), counted from
## the picture's top-left corner. The same spot is used for every state's picture.
@export var hotspot: Vector2 = Vector2.ZERO
## How big to show it. 1 = the picture's own size.
@export_range(0.1, 4.0, 0.05) var size: float = 1.0
## Colours the pictures (white = as drawn). Handy for telling placeholder cursors apart.
@export var tint: Color = Color.WHITE

@export_group("States")
## Optional: over something clickable (option bubbles, app icons). Empty = Image.
@export var hover_image: Texture2D
## Optional: while the mouse button is held down. Empty = no change.
@export var pressed_image: Texture2D
## Optional: while dragging something (an option bubble). Empty = Pressed Image, or Image.
@export var drag_image: Texture2D

@export_group("Drawn In Game")
## Off = the computer's own cursor shows the picture (no lag, fixed size).
## On = the game draws the cursor itself: any size, and it squishes when clicking.
@export var drawn_in_game: bool = false
## How much the drawn cursor squishes while the button is held. 1 = not at all.
@export_range(0.5, 1.0, 0.01) var click_squish: float = 0.85


## The picture for a state, falling back to the plain Image.
func image_for(hovering: bool, pressed: bool, dragging: bool) -> Texture2D:
	if dragging and drag_image:
		return drag_image
	if (pressed or dragging) and pressed_image:
		return pressed_image
	if hovering and hover_image:
		return hover_image
	return image
