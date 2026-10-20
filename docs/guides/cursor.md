# The player's cursor

For artists and designers. **No code needed.**

The game swaps the computer's arrow for the player's own cursor, everywhere.
It's set by a **cursor file** in `data/cursors/`. The game uses
`data/cursors/default.tres`.

**Right now the default is the Godot logo**, our placeholder for missing
art. The Toontown glove can't go in: it's Disney's art. Two ways to get a
glove-style cursor:

- **Your own drawing.** A hand or glove, about 64 × 64 pixels, see-through
  background, pointing up and to the left.
- **Kenney's Cursor Pack** (free, CC0, the same maker as our interface
  sounds): [kenney.nl/assets/cursor-pack](https://kenney.nl/assets/cursor-pack).
  It has cartoon hands, including pointing, open and grabbing ones. Put its
  files in `assets/cursors/kenney/` with its `License.txt`, and add a line to
  `CREDITS.md`.

## Change the cursor

Click `data/cursors/default.tres`:

| Setting | What it does |
|---|---|
| **Pointer → Image** | The cursor picture. Drag a PNG here. |
| **Pointer → Hotspot** | The pixel that does the clicking, counted from the picture's top-left corner. For a pointing hand, that's the fingertip, e.g. (6, 2). The placeholder uses its middle (64, 64). |
| **Pointer → Size** | 1 = the picture's own size. The placeholder is shown at 0.5. |
| **States → Hover Image** | Optional: over something clickable (option bubbles, app icons). E.g. an open hand. |
| **States → Pressed Image** | Optional: while the mouse button is held. E.g. a closed hand. |
| **States → Drag Image** | Optional: while dragging an option bubble. E.g. a grabbing hand. |
| **Drawn In Game** | Off = the computer draws it (no lag, but at most 256 × 256 pixels). On = the game draws it: any size, and it squishes when you click (**Click Squish**). |

Draw every state at the **same size with the tip in the same place**: one
Hotspot is used for all of them.

## More than one cursor

Make another file: right-click `default.tres` → **Duplicate…**, e.g.
`data/cursors/glove.tres`. Then either:

- make it the default: open `scenes/Cursor/PlayerCursor.tscn` and drag it
  onto **Style**, or
- switch to it from code at the right moment (e.g. a perk, or a different
  player character):
  `PlayerCursor.use(load("res://data/cursors/glove.tres"))`.

## Something's wrong

| Problem | Fix |
|---|---|
| Clicks land in the wrong spot | Fix **Hotspot**: it's the clicking pixel in the picture, before **Size**. |
| "at most 256 × 256" warning | The picture × Size is too big for the computer's cursor. Lower **Size**, or turn on **Drawn In Game**. |
| The cursor lags a little | That's **Drawn In Game**. Turn it off for the computer's own, lag-free cursor. |
| No hover picture on a button | Hover shows over things whose **Mouse → Default Cursor Shape** is **Pointing Hand**. Set that on the button in the Inspector. |

## For programmers

`PlayerCursor` (autoload, `scenes/Cursor/PlayerCursor.tscn`, a CanvasLayer on
layer 128) applies a `CursorStyle`:

- **System mode:** sets custom cursors with `Input.set_custom_mouse_cursor`
  for the ARROW, POINTING_HAND, DRAG and CAN_DROP shapes. Pictures are resized
  by `size`. On press and release it swaps in the pressed picture.
- **Drawn mode:** hides the OS cursor and draws a TextureRect at the mouse.
  It picks the picture from `Input.get_current_cursor_shape()` and squishes
  on press.

`use(style)` switches cursors. Option bubbles use the DRAG shape while
they're dragged.
