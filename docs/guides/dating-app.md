# The dating app

For writers, artists and designers. **No code needed.**

The dating app is an app on your phone ([the-phone.md](the-phone.md)). It
shows one girl's profile at a time:

```
┌──────────────────┐
│ Discover         │
│ ┌──────────────┐ │
│ │   (picture)  │ │
│ │ Split Ends, 24│ │
│ │ bio          │ │
│ │ Interests    │ │
│ │ • yapping    │ │
│ └──────────────┘ │
│ [Ewwww] [Start!] │
└──────────────────┘
```

- **Ewwwwwww....** swipes her card away and the next girl's comes in.
- **Start Dating!** puts the phone down: the date with her begins (real
  life).
- Girls in your Contacts, and girls whose first date failed, aren't shown.
  When there's no one left, it says **No one left to swipe on.** and Start
  becomes **Back to the calendar**.

It opens from the calendar's **Date** choice. Press **F6** on
`scenes/Tinder/Screen.tscn` to try it on its own.

## Her card

Her card is drawn in **her dialogue style** (her box, font and colours,
like her contact), so Split Ends' card is hers. A girl with no girl file
yet (Smokey) gets the default style. Turn **Use Her Style** off for one
plain card for everyone.

What's on it comes from her date character
(`scripts/characters/girls/`): **name**, **age**, **bio**, **interests**
and **icon_path** (her picture, an animated SpriteFrames file).

## Change it: `data/dating_app_style.tres`

| Section | What's in it |
|---|---|
| **Words** | The title ("Discover"), what follows her name (", {age}"), "Interests", the bullet before each interest, the two buttons ("Ewwwwwww....", "Start Dating!"), "No one left to swipe on.", "Back to the calendar" |
| **Profile Card** | **Use Her Style** (on), the plain card's colour and text colour (with it off), how rounded it is, the colour behind her picture, the picture's height and how much of it she fills, the name / bio / interests sizes |
| **Buttons** | Pass and Start colours, text colour and size, height, how rounded |
| **Swiping** | How long a card takes to swipe away, and how far it turns |
| **Sounds** | Pass, Start, and a button under the mouse (Kenney stand-ins) |

The phone itself (its screen, the phone's font for the title, your room
behind it) is `data/phone_style.tres`.

**Where things sit:** `scenes/Tinder/Screen.tscn`, inside **PhoneScreen →
Phone → Body → Screen → Margin → Column**: **Title**, **Card** (**Photo**,
and **Info**: **NameLabel**, **Bio**, **InterestsTitle**, **Interests**),
**Empty** (no one left), and **Buttons** (**Pass**, **Start**). Move,
resize or reorder them there.

## Something's wrong

| Problem | Fix |
|---|---|
| Her picture is missing | Her date character's **icon_path** isn't a SpriteFrames file (Godot prints which). |
| The buttons are pushed off the bottom | Her card is too tall: lower **Photo Height** or the font sizes. |
| A girl never shows | She's in your Contacts, or her first date failed (she's gone for the run). |

## For programmers

`scenes/Tinder/screen.gd`: `character_classes` (who's in it),
`load_characters()` (skips `PlayerManager.is_gone()` / `is_in_party()`),
`update_display()`, `_on_next_pressed()` (the swipe),
`_on_start_pressed()` → `PlayerManager.select_date()` then
`AppLauncher.phone_down(first_date_path)`. Her picture: `icon_panel.gd`
(`update_display(frames_path)`, `fill`).
