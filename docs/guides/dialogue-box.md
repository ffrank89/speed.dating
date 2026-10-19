# Changing a girl's dialogue box, font and voice

For artists and writers. **No code needed**: everything here is done by
clicking files in Godot's **FileSystem** panel (bottom left) and changing
settings in the **Inspector** panel (right). Hover over any setting in the
Inspector to see a short explanation of what it does.

## See your changes

1. In FileSystem, open `scenes/Dates/FirstDate/FirstDateTest.tscn`.
2. Press **F6** (or the "Run Current Scene" button, top right).
3. Click the dialogue box or press **Space** to move through her lines.
4. Change something, close the game window, press F6 again.

## Where everything lives

| What | Where | What it controls |
|---|---|---|
| **Her girl file** | `data/girls/split_ends.tres` | Everything about her. The **Dialogue** section points at her style, voice and lines. |
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

When a picture is set, Background Color and Outline are ignored. If the
corners look squashed or blurry, raise Image Corner Size.

**Try it:** `assets/ui/dialogue/example_sticker_frame.png` is a sample frame
(240 × 160). Drag it onto Background Image, set Image Corner Size to **44**
and Text Color to a dark colour, and press F6.

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
To replace them:

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

## Writing her lines

Lines live in `.dialogue` files (e.g. `dialogue/split_ends/m1_test.dialogue`).
Double-click one in Godot to edit it in the **Dialogue** tab, or use any
text editor.

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
| `- An answer` | A choice for the player. Indent (Tab) the lines that follow it. |
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
| Letters show as boxes | The font is missing those characters. Try another font. |
| Picture box looks squashed | Raise **Image Corner Size**. |
| Text runs off the bottom of the box | Lower **Font Size** or **Padding**, or split the line in two. |

## For programmers

- `DialogueBoxStyle` (`scripts/data/dialogue_box_style.gd`) builds the
  box's `StyleBox` from its settings in `make_box()`.
- `DialogueBox` (`scenes/Dialogue/`) restyles itself per line by matching
  `line.character` to the cast's `GirlData.display_name`.
- `VoicePlayer` (`scripts/dialogue/voice_player.gd`) listens to the addon's
  `DialogueLabel.spoke` signal and plays one sound per letter across 4
  round-robin `AudioStreamPlayer`s.
