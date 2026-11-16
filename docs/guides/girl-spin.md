# Watching a girl spin

For artists and designers. **No code needed.**

`scenes/Spin/SplitEndsSpin.tscn` shows Split Ends spinning on the spot, with
buttons for how fast and which way. It stands on its own, like the clock:
open it and press **F6**. It isn't part of a date (yet).

The buttons are drawn in **her style**, `data/dialogue_styles/split_ends.tres`:
her box colour, outline, rounded corners, font and text colour. The chosen
speed and direction use her **name plate's** colours (red with cream words),
and the button under the mouse gets a thicker outline. Change her style and
the buttons change with it (and so does her dialogue box).

## Her spin frames

`assets/split ends spin/splitends_spin.tres` is a SpriteFrames file holding
the artist's four frames, in order: front, facing right, back, facing left.
It's like the fly's `flyframes.tres`. Double-click it to open the
SpriteFrames panel at the bottom: drag frames in or out, or reorder them.

**Speed (FPS)** in that panel doesn't matter here (as long as it isn't 0):
the buttons set the speed.

Draw every frame on the **same size picture, with her feet on the same line
and her in the middle**. A frame drawn off to one side makes her hop
sideways when she spins. (Right now frame 4 is drawn about 330 pixels further
right than the others, so she hops on it.)

## The settings

Click the top node, **SplitEndsSpin**:

| Setting | Now | What it does |
|---|---|---|
| **Style** | `data/dialogue_styles/split_ends.tres` | Whose style the buttons use. Drag in another girl's file to try hers |
| **Speed → Speeds** | Stop 0, Slow 2, Medium 4, Fast 8 | One button each: its words, and how many frames a second. 0 = stopped. With 4 frames, 4 = one full turn a second. **Add Key/Value Pair** adds a button; they appear in this order |
| **Speed → Start Speed** | Medium | Which speed is chosen when it starts. Must match one of the words above exactly |
| **Direction → Left Text / Right Text** | Left / Right | The words on the two direction buttons |
| **Direction → Start Right** | on | On = it starts turning right (the frames in order). Off = left (backwards) |

**Where things sit:**

| What | Click | Change |
|---|---|---|
| Her | **Girl** | **Position** to move her, **Scale** to size her (0.6 now) |
| The buttons | **Buttons** | **Position** to move both rows. **Theme Overrides → Constants → Separation**: the gap between the rows |
| One row | **Buttons → Speed** or **Direction** | **Separation**: the gap between its buttons |

The buttons only appear when it runs (F6), not in the editor. Keep the names
**Girl**, **Buttons**, **Speed** and **Direction**: the script finds them by
name.

## Another girl's spin

1. Make her frames file: right-click her art folder → **Create New →
   Resource… → SpriteFrames**, then drag her frames in, in order.
2. Click `SplitEndsSpin.tscn` in FileSystem → **Ctrl+D** to duplicate it, and
   name it after her (e.g. `SmokeySpin.tscn`).
3. Open it: click **Girl** → **Sprite Frames**: her frames file. Click the top
   node → **Style**: her file from `data/dialogue_styles/`.

## Something's wrong

| Problem | Fix |
|---|---|
| No buttons | They only appear when it runs: press **F6**. Still none? Check the names **Buttons**, **Speed** and **Direction** |
| Plain grey buttons | **Style** is empty: drag in her file from `data/dialogue_styles/` |
| No button is chosen at the start | **Start Speed** doesn't match a word in **Speeds** exactly (capitals count) |
| She doesn't move | **Stop** is chosen, the frames file has only one frame, or its **Speed (FPS)** is 0 |
| She hops sideways | A frame is drawn off-centre in its picture. Ask the artist to line the frames up |

## For programmers

`GirlSpin` (`scenes/Spin/girl_spin.gd`, a `Control`):

- `_ready()` builds one toggle `Button` per entry in `speeds`, in `$Buttons/Speed`, and a Left and a Right button in `$Buttons/Direction`. Each row has its own `ButtonGroup`, so one button per row is chosen.
- `_update()` sets `$Girl.speed_scale` to `direction × frames_a_second ÷` the frames file's own speed. A negative value plays the frames backwards.
- `_use_her_style(button)` uses `DialogueBoxStyle.make_box()` for normal, a copy with double `outline_width` for hover, and a copy in `name_plate_color` / `name_plate_outline_color` for pressed. A picture box is tinted instead. Fonts and colours come from `text_font()`, `font_size`, `text_color`, `name_color` and the text outline.
