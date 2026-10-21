# Changing a girl's dialogue box, font, voice and poses

For artists and writers. **No code needed**: everything here is done by
clicking files in Godot's **FileSystem** panel (bottom left) and changing
settings in the **Inspector** panel (right). Hover over any setting in the
Inspector to see a short explanation of what it does.

## See your changes

1. Press **F5** (or open `scenes/Dates/FirstDate/FirstDateTest.tscn`, the
   test bench, and press **F6**). It plays a whole date.
2. Click the dialogue box or press **Space** to move through her lines.
3. Change something, close the game window, press F5 again.

Her room, her portrait and the dialogue box sit in the date scene,
`scenes/Dates/Date/Date.tscn`. Move things there.

## Where everything lives

| What | Where | What it controls |
|---|---|---|
| **Her girl file** | `data/girls/split_ends.tres` | Everything about her. **Art → Poses** holds her poses and their sizes; the **Dialogue** section points at her style, voice and lines. |
| **Dialogue styles** | `data/dialogue_styles/` | How a dialogue box looks. `default.tres` is used for anyone without their own (including the player). |
| **Fonts** | `assets/fonts/` | One folder per font, with its licence file next to it. |
| **Letter sounds** | `assets/audio/voice/default/` | The 26 sounds her voice is made of: `a.wav` … `z.wav`. |
| **Dialogue lines** | `dialogue/split_ends/` | The text she says, in `.dialogue` files. |

How they connect:

```
data/girls/split_ends.tres
└─ Dialogue
   ├─ Dialogue Style  →  data/dialogue_styles/split_ends.tres
   │                     ├─ Box: colours, outline, corners (or a picture)
   │                     ├─ Text: font → assets/fonts/patrick_hand/…ttf
   │                     ├─ Name Plate
   │                     ├─ Heart Meter: her colour on the date's heart meter
   │                     └─ Next Arrow
   ├─ Voice           →  pitch, speed, letter sounds folder → assets/audio/voice/default/
   └─ First Date Dialogue → dialogue/split_ends/….dialogue
```

---

## Change her box colours and outline

1. In FileSystem, click `data/dialogue_styles/split_ends.tres`.
2. In the Inspector, open **Box**.
3. Click a colour swatch to change it, or drag a number left and right.

| Setting | What it does |
|---|---|
| Background Color | The box's fill. Lower **A** (alpha) to make it see-through. |
| Outline Color / Outline Width | The line around the box. Width 0 = no line. |
| Corner Radius | How round the corners are. 0 = square. |
| Padding | Space between the box edge and the text. |

The **Text**, **Name Plate** and **Next Arrow** sections work the same way.
**Heart Meter → Meter Color** is the colour her [heart meter](heart-meter.md)
rings fill with on her dates.

## Use a picture as her box

Instead of a flat colour, the box can be any picture: a torn notebook page,
a phone screen, a sticker.

1. Draw the box as a PNG, roughly the shape of the box (it can be small,
   e.g. 600 × 300). Transparent corners are fine.
2. Drag the PNG into the project (e.g. `assets/ui/dialogue/`).
3. Drag it from FileSystem onto **Box → Background Image** in her style.
4. Set **Image Corner Size** to the thickness of your frame's border in pixels.

The picture stretches like a picture frame. The corners (the Image Corner
Size squares) never stretch, the edges stretch in one direction, and the
middle stretches to fill:

```
┌────┬──────────────┬────┐
│ ✕  │  ← stretch → │ ✕  │   ✕ = never stretches
├────┼──────────────┼────┤
│ ↕  │   stretches  │ ↕  │
├────┼──────────────┼────┤
│ ✕  │  ← stretch → │ ✕  │
└────┴──────────────┴────┘
```

When a picture is set, Background Color is ignored. The outline is up to you:

| Keep Outline With Image | Result |
|---|---|
| Off (default) | The picture is the whole box. Draw any border into the picture itself. |
| On | The outline (Outline Color, Outline Width) is drawn on top of the picture. Set **Corner Radius** to match the picture's rounded corners, or the outline and the picture won't line up. |

If the corners look squashed or blurry, raise Image Corner Size.

**Try it** with any PNG you have. To see how the stretching works before
real art exists, drag the placeholder `assets/placeholders/godot_logo.svg`
onto Background Image and set Image Corner Size to about **20**. It will look
odd (a logo isn't a frame), but it shows which parts stretch.

## Change her font

1. Get a font file (`.ttf` or `.otf`). [Google Fonts](https://fonts.google.com)
   is a good source: its fonts are free to use in a commercial game.
   Download the **licence file** too (usually `OFL.txt`).
2. Make a folder in `assets/fonts/` (e.g. `assets/fonts/my_font/`) and drag
   the font file and its licence into it.
3. Click her style (`data/dialogue_styles/split_ends.tres`). Drag the font
   onto **Text → Font**.
4. Adjust **Font Size** until it reads well.

- **Her name** uses the same font unless you set **Name Plate → Name Font**.
- **Bold and italics** (`[b]…[/b]`, `[i]…[/i]` in her lines) automatically
  use a thicker or slanted version of her font. No extra font files needed.
- If letters show up as empty boxes, the font doesn't include those
  characters. Pick a different font.
- **Keep the licence file next to the font.** The game must ship with it.

## Make a dialogue style for a new girl

1. In FileSystem, right-click `data/dialogue_styles/split_ends.tres` →
   **Duplicate…** and name it after her (e.g. `smokey.tres`).
2. Change its colours and font.
3. Open her girl file and drag the new style onto **Dialogue → Dialogue Style**.

A girl with an empty Dialogue Style slot uses `default.tres`.

---

## Change her voice

Her voice is set in her girl file: click `data/girls/split_ends.tres`, open
**Dialogue → Voice**.

| Setting | What it does | Try |
|---|---|---|
| Pitch | 1.0 = as recorded. Higher is brighter and younger, lower is deeper. | 0.8–1.6 |
| Pitch Variance | Random wobble per sound so she doesn't sound robotic. | 0.05–0.2 |
| Seconds Per Letter | How fast her text appears. Lower = faster talker. | 0.025–0.06 |
| Letters Per Sound | 1 = a sound every letter (busy). 2 = every other letter (calmer). | 1–2 |
| Volume Db | Loudness. 0 = as recorded, negative = quieter. | −12 to 0 |
| Letter Sounds Folder | Which folder of letter sounds she uses. | |

Two girls can share the same letter sounds and still sound different just
by pitch and speed.

## Replace the letter sounds with real recordings

The sounds in `assets/audio/voice/default/` are generated placeholders.
(Every placeholder, and two ways to replace each, is listed in
[replacing-placeholders.md](replacing-placeholders.md).) To replace them:

1. Record 26 very short sounds, one per letter: a quick syllable like
   "ah", "bee", "see"… Keep each one **under 0.12 seconds**, with **no
   silence at the start**.
2. Name them with the lowercase letter: `a.wav`, `b.wav` … `z.wav`. `.ogg`
   and `.mp3` work too.
3. Either drop them into `assets/audio/voice/default/` (replacing the old
   ones, which changes every girl), **or** put them in a new folder (e.g.
   `assets/audio/voice/smokey/`) and set that girl's **Letter Sounds Folder**
   to it.

A missing letter is simply silent. Spaces, numbers and punctuation are
always silent.

---

## Her poses: size, position and flip

Each pose has its own settings, so a picture drawn bigger, smaller or
off-centre can be fixed here without re-exporting the art.

1. Click her girl file (`data/girls/split_ends.tres`) and open **Art → Poses**.
2. Each entry is a pose name (e.g. `cig`) and a pose. Click the pose to
   expand it.

| Setting | What it does |
|---|---|
| Image | The picture for this pose. Drag a PNG here. |
| Scale | Size of this pose. 1.0 = normal, 1.2 = 20% bigger, 0.8 = 20% smaller. She grows and shrinks from her **feet**, so she stays standing on the same spot. |
| Offset | Nudge her, in pixels. **X**: positive moves right, negative left. **Y**: positive moves down, negative up. |
| Flip | Mirror her left-to-right. |

To **add a pose**: in Poses, click **Add Key/Value Pair**, type the name in
the left box, then in the right box choose **New GirlPose**, expand it and
drag the picture onto Image. Lines can use it straight away with
`[#pose=yourname]`.

**Tip:** compare poses quickly with the **Pose: … (next)** button in the
test bench (F5). It flips through all of her poses in order.

## Writing her lines

Lines live in `.dialogue` files (e.g. `dialogue/split_ends/m1_test.dialogue`).
Double-click one in Godot to edit it in the **Dialogue** tab, or use any
text editor. Her first date is `dialogue/split_ends/first_date.dialogue`;
how its titles (`~ opener`, `~ exchange_...`, closers) become a date is in
[the-full-date.md](the-full-date.md).

```
~ start

Split Ends: [#pose=point] I was SO sure you'd be a catfish.
Split Ends: [#pose=hunched] Sorry. I talk a [i]lot[/i] when I'm nervous.
You: Not weird at all.
Split Ends: Quick test. Are birds real?
- Obviously.
	Split Ends: [#pose=parker] Wow. Okay. They got to you too.
- Absolutely not.
	Split Ends: [#pose=earring] [b]FINALLY.[/b] Someone who gets it.

=> END
```

| You write | What happens |
|---|---|
| `Split Ends: …` | She says it, in her box, font and voice. The name must match her **Display Name** exactly. |
| `You: …` (or any name without a girl file) | Plain default box, no voice. |
| `[#pose=cig]` | She switches to her `cig` pose. Pose names are in her girl file under **Art → Poses**. |
| `[b]…[/b]`, `[i]…[/i]` | Bold, italics. |
| `- An answer` | A choice for the player. Indent (Tab) the lines that follow it. Checks, odds and points are in the [options guide](options-and-scoring.md). |
| `[#react=heart]` | A reaction pops up above her (see the [options guide](options-and-scoring.md#reactions)). |
| `~ start` | Where the conversation begins. |
| `=> END` | The conversation ends. |

The full writing reference is the Dialogue Manager addon's own
[documentation](https://github.com/nathanhoad/godot_dialogue_manager/tree/v3.x/docs).

---

## Something's wrong

| Problem | Fix |
|---|---|
| Her box is the plain dark one | The speaker name in the line doesn't match her **Display Name** exactly, or her **Dialogue Style** slot is empty. |
| No voice | Check **Letter Sounds Folder** points at a folder with `a.wav` … `z.wav`, and Volume Db isn't very low. |
| She doesn't change pose | The pose name in `[#pose=…]` must match a name in her **Poses** list. A wrong name shows her default pose. |
| She's too big or small in one pose | Change that pose's **Scale** (Art → Poses → the pose). |
| One pose sits off to the side or floats | Change that pose's **Offset**. Negative Y moves her up, positive moves her down. |
| The outline and a picture box don't line up | Match **Corner Radius** to the picture's corners, or turn off **Keep Outline With Image**. |
| Letters show as boxes | The font is missing those characters. Try another font. |
| Picture box looks squashed | Raise **Image Corner Size**. |
| Text runs off the bottom of the box | Lower **Font Size** or **Padding**, or split the line in two. |

## For programmers

- `GirlPose` (`scripts/data/girl_pose.gd`) holds a pose's image, scale,
  offset and flip. `GirlData.poses` is `Dictionary[String, GirlPose]`;
  `get_pose(name)` falls back to `default_pose`.
- `GirlPortrait` (`scenes/Dates/Portrait/girl_portrait.gd`) draws a pose
  inside its own rect, scaling from bottom-centre. Reuse it anywhere she's shown.
- `DialogueBoxStyle` (`scripts/data/dialogue_box_style.gd`) builds the
  box's `StyleBox` in `make_box()`, and `make_outline()` returns the optional
  outline drawn over a picture box (the `Outline` panel in `DialogueBox.tscn`).
- `DialogueBox` (`scenes/Dialogue/`) restyles itself per line by matching
  `line.character` to the cast's `GirlData.display_name`.
- `VoicePlayer` (`scripts/dialogue/voice_player.gd`) listens to the addon's
  `DialogueLabel.spoke` signal and plays one sound per letter across 4
  round-robin `AudioStreamPlayer`s.
