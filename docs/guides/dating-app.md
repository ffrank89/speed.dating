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
- Girls in your Contacts, girls whose first date failed, and girls with no
  **First Date Dialogue** yet (Smokey, for now) aren't shown. When there's
  no one left, it says **No one left to swipe on.** and Start
  becomes **Back to the calendar**. Going back that way **gives back the
  2 days** the Date choice took: you're on the same day, with the same
  choices.

It opens from the calendar's **Date** choice. Press **F6** on
`scenes/Tinder/Screen.tscn` to try it on its own.

## Her card

Her card is drawn in **her dialogue style** (her box, font and colours,
like her contact), so Split Ends' card is hers. A girl with no Dialogue
Style gets the default one. Turn **Use Her Style** off for one plain card
for everyone.

What's on it comes from **her girl file** (`data/girls/`, the same file as
her date and her contact): **Identity → Display Name**, **Age**, **Bio**,
**Interests** and **Profile Picture** (an animated picture: click it to
edit its frames in the **SpriteFrames** panel at the bottom of Godot).

## Who's on it

Click the top node of `scenes/Tinder/Screen.tscn` (**DatingApp**):

| Setting | What it does |
|---|---|
| **Girls** | Everyone on the app, in this order. Drag girl files from `data/girls/` onto it. Now: Split Ends, Smokey |
| **Date Scene** | The date that starts when you press Start Dating! (`scenes/Dates/Date/Date.tscn`) |
| **Give Days Back** | On: with no one left, **Back to the calendar** gives back the days the Date choice took. Off: they stay spent |

**A new girl:** make her girl file ([girls.md](../design/girls.md), or
duplicate `data/girls/split_ends.tres`), fill in her dating-profile
settings and her **Dialogue → First Date Dialogue**, and add her to
**Girls**. She shows up once she has a first date.

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
| Her picture is missing | Her girl file has no **Profile Picture**, or its frames are empty. |
| The buttons are pushed off the bottom | Her card is too tall: lower **Photo Height** or the font sizes. |
| A girl never shows | She isn't in **Girls**, she has no **First Date Dialogue** yet (Smokey), she's in your Contacts, or her first date failed (she's gone for the run). |

## For programmers

`scenes/Tinder/screen.gd`: `girls: Array[GirlData]` (who's in it),
`date_scene`, `_load_profiles()` (skips girls without
`first_date_dialogue`, `PlayerManager.is_gone(girl)` and
`is_in_party(girl)`), `update_display()`, `_on_next_pressed()` (the swipe),
`_on_start_pressed()` → `PlayerManager.select_girl(girl)` then
`AppLauncher.phone_down(date_scene)`. Her picture: `icon_panel.gd`
(`update_display(frames: SpriteFrames)`, `fill`).
