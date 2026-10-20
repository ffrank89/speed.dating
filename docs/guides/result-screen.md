# The result screen: getting her number

For writers, artists and designers. **No code needed.**

When a date ends, the player's phone opens **Contacts** (with the same
iPhone-style "open app" animation as everything else) on a **New Contact**
screen, and she fills it in:

| How the date went | What she does |
|---|---|
| **Failed** (below her Number Threshold) | Types **"not a chance!"** where her name would go and taps **Cancel**. No number, no info. "She didn't give you her number." |
| **0 hearts** | Types her name. Her **type** pops into its field, but her **tags** say *"you dont know me like that!"*. Then her number and address, and **Done**. |
| **1 heart or more** | The same, with her real **tags**: *boop, boop, boop*, each a little higher |
| **3 hearts** | All that, plus a heart after her name |

Abilities don't show yet: they're not listed in **Trait Hearts** (below).

**Then it waits for you.** When she's done, your **✕** (the X art, drawing
itself in) appears at the card's top-right corner. Click it, or press
**Escape**, to close the app and go back to the calendar. (Contact card
style → **Closing → Close By Hand** off = it closes by itself after **End
Hold Seconds**, like before.)

During the date, the [heart meter](heart-meter.md) in the top right shows
the hearts she'd give you so far.

Every letter types out one at a time with a key-click sound, in **her
font**. The boxes look like **her dialogue box**: same colour, outline,
corners, or picture. Split Ends' card is cream with a red outline and
Patrick Hand.

## Try it

- **On its own:** open `scenes/Results/ContactCard.tscn` and press **F6**.
  Click the top node → **Testing (F6) → Test Hearts** (0–3) to see each ending.
  **Test Girl** picks whose card it is.
- **In the date:** press **F5** and play to the end (after the closer), or
  press **End date now** in the debug panel. The hearts come from the date
  score so far. What happens after the card (party, gone for the run, back
  to the calendar) is in [the-full-date.md](the-full-date.md).

## Her details

Her girl file (`data/girls/split_ends.tres`) → **Contact Card**:

| Setting | What it does |
|---|---|
| **Phone Number** | What she types as her number. Split Ends' is a made-up 555 number. |
| **Address** | What she types as her address. Press Enter in the box for a second line. |
| **Contact Photo** | Optional round photo. Empty = her initials in a circle in her name-plate colour. |
| **Traits** | Her type, tags, abilities… one row each, right under her name (above her number and address). Add one: **Traits** → **Add Element** → **New GirlTrait**. Each has a **Kind** (the small coloured word, e.g. `type`, `tag`, `ability`), a **Title**, an optional **Description** and an optional **Icon**. Split Ends has four placeholder ones. |

Her name is her **Display Name**. Her box, font and colours are her
**Dialogue Style**, so changing her dialogue box changes her card too.

## What each ending takes

**A failed date:** her girl file → Dating → **Number Threshold** (now 0).
A date score below it fails (she won't give her number), so a date that ends
in minus points fails.

**Hearts** (0–3) are how many of her **Affection Thresholds** (her girl file →
Dating, now 3 / 6 / 9 points) the date score reached.

`data/date_rules.tres` → **Result**:

| Setting | Now | What it does |
|---|---|---|
| **Trait Hearts** | type: 0, tag: 1 | Which kinds of trait show, and how many hearts each needs. Below that, the field says *"you dont know me like that!"*. Kinds not listed (ability, for now) don't show at all. Add `ability` with a number when abilities exist. |
| **Heart Emoji At Hearts** | 3 | She adds the heart after her name at this many hearts or more. 4 = never. |

## The card's look, typing and sounds

`data/contact_card_style.tres`:

| Section | What's in it |
|---|---|
| Sheet | The phone screen's colour (iPhone grey) and corners, the dim behind it, and the font, size and colour for the iPhone's own words |
| Words | "New Contact", "Cancel", "Done", "Add Photo", the grey hints ("First name"…), "mobile", "home", and the two endings' messages |
| Fields | The size of what she types, and how faint the grey hints are |
| Typing | How fast she types (a random wait per key, between Min and Max), the pause between boxes, the heart (below), and **Failed Name Text** (*"not a chance!"*), what she types on a failed date |
| Closing | **Close By Hand** (on: wait for the player's ✕ or Escape), **Close Image** (`assets/x1/x1_7.png`), **Close Animation** (`icons/x/x.tres`, the X drawing itself; plays once), **Close Size**, **Close Sound** (Kenney `close_002` for now) |
| Traits | Show them or not; pop in (boop, boop, boop) or have her **type** them; the wait between pops (0.2 s); how much higher each boop is (**Trait Pitch Step**); **Secret Text** (*"you dont know me like that!"*); description and icon sizes |
| Sounds | Key, space, delete, next box, Done and Cancel |

**Where things sit on the card:** open `ContactCard.tscn`. Drag the rows in
**Sheet → Margin → Column**, or resize **Sheet**.

**The heart** after her name can be one of three things. The first one
that's set wins:

1. **Heart Animation:** an animated icon, from a SpriteFrames file. For
   example, drag in `data/reactions.tres`. **Heart Animation Name** picks the
   animation (`heart`), and **Heart Size** sets its size. It pops in, then
   loops.
2. **Heart Image:** a still picture at **Heart Size**.
3. **Heart Text:** the ❤️ emoji (the default). It uses the computer's
   colour emoji font (Apple's on a Mac), not her font, because many fonts
   have a plain black heart that would win.

**Room for more:** the middle of the card scrolls, like a phone. As she
types and her traits appear, it follows her down, and it ends scrolled to
the bottom. Add as many traits as you like.

## The typing sounds

The sounds are **stand-ins** from Kenney's Interface Sounds (CC0). The iPhone's
own keyboard sounds are Apple's sound files, so they aren't included. To use
other sounds, drag them onto the **Sounds** slots:

| Slot | Now |
|---|---|
| Key Sound | `click_002.wav` |
| Trait Sound (the boop) | `drop_003.wav` |
| Space Sound | `click_005.wav` |
| Next Field Sound | `switch_002.wav` |
| Done Sound | `confirmation_003.wav` |
| Cancel Sound | `minimize_002.wav` |

Keep any new sound's licence next to it, and add a line to `CREDITS.md`.

## The Contacts app

The card opens and closes like an app: `data/apps/contacts.tres`, with the
Godot logo as a placeholder icon. See [phone apps](phone-apps.md). Your party is
saved in your Contacts (press C on the calendar): [contacts.md](contacts.md).

## Something's wrong

| Problem | Fix |
|---|---|
| A square box or a plain black heart instead of ❤️ | That computer has no colour emoji font, or **Emoji Font** is set to a font without one. Use **Heart Image**. |
| Her number or address is blank | Fill in her girl file → **Contact Card**. |
| The boxes look like the dark default | She has no **Dialogue Style**; the card uses the same fallback as her dialogue box. |
| She never gives her number | The score is below her **Number Threshold** (girl file → Dating). Check the score in the debug panel. |

## For programmers

`ContactCard` (`scenes/Results/contact_card.gd`, a CanvasLayer on layer 20):

- `show_card(girl, rules)`
- `show_saved(girl, hearts, rules)`: her saved contact, filled in at once, with "‹ Contacts" (`back_pressed`). Used by the Contacts app.
- `await play(hearts) -> bool` (hearts -1 = a failed date), which also emits `finished(got_number)`. With Close By Hand it returns once the player closes the card (`closed_by_player`).

The boxes use `DialogueBoxStyle.make_box()` and `make_outline()` (drawn on
each group's `draw` signal). `DateScorer.hearts()` counts reached thresholds.
The date scene's `_end_date()` (`scenes/Dates/Date/date_scene.gd`) runs, in order:

1. `AppLauncher.open("contacts", show_card)`
2. `play()`
3. `PlayerManager.add_party_member()` or `mark_gone()`
4. `AppLauncher.close`
