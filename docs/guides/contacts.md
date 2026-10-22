# Your contacts (the party)

For writers, artists and designers. **No code needed.**

Your party is the **Contacts** on your phone. Every girl who gave you her
number on a date is saved there. That's who's in your party. Press **W** on
the calendar to see them (W flips through your apps: Contacts, Profile, then
back to the calendar).

```
Date ends ─► she types her number into a New Contact (or doesn't)
               │
               ├─ got her number → saved in Contacts, with the hearts she gave you
               └─ failed date    → gone for the run

Calendar ─► press W ─► the phone switches to Contacts, like moving between
               │         open apps on an iPhone
               │
               ├─ the list: A to Z under letter headers, each girl in her own box and
               │  font, her initials (or photo), a heart if she gave you one;
               │  "3 Contacts" underneath
               ├─ click a girl ─► her saved card slides in: what your hearts unlocked
               │                  on her date, her number and address
               │                  "‹ Contacts" (or Escape) goes back
               ├─ Escape or the phone's home bar goes back to the app before
               └─ W again goes on to Profile, then back to the calendar
```

A girl in your contacts doesn't show up in the dating app any more:
she's taken.

## Try it

- **On its own:** open `scenes/Phone/Contacts/ContactsApp.tscn` and press
  **F6**. Click the top node → **Testing (F6)**: **Test Contacts** is who's
  in the list (Split Ends now; add girl files with **Add Element**), **Test
  Hearts** is the hearts they each got. Press **W** to put it away and bring
  it back.
- **In the game:** play a date to the end and get her number. Back on the
  calendar, press **W**.

**Only on the calendar, for now.** W reaches Contacts on any screen that has
`ContactsApp.tscn` in it, and right now that's only the calendar.

## What her saved card shows

The same card she filled in at the end of the date, already filled in:

| Her hearts | Her saved card |
|---|---|
| 0 | Her name, her **type**, *"you dont know me like that!"* for her tags, her number and address |
| 1 or more | The same, with her real **tags** |
| 3 | All that, and the heart after her name (in the list too) |

What each heart unlocks is `data/date_rules.tres` → **Result** (Trait Hearts,
Heart Emoji At Hearts), the same settings as the
[result screen](result-screen.md). If she's saved again after a better date,
her hearts go up; they never go down.

A saved card doesn't show the empty **Last name** and **Company** rows, the
"New Contact" title, **Done** or **Add Photo**.

## Changing how it looks and sounds

`data/contact_card_style.tres` → **Contacts App**:

| Setting | Now | What it does |
|---|---|---|
| **Open As App** | on | On = it opens like an iPhone app inside the phone. Off = the phone comes up with Contacts on it (phone up). |
| **List Title** | Contacts | The big title at the top |
| **Back Text** | ‹ Contacts | Top left of her saved card |
| **No Contacts Text** | No Contacts | The list when your party is empty |
| **One Contact Text** / **Many Contacts Text** | 1 Contact / %d Contacts | The count under the list (`%d` = the number) |
| **Section Letters** | on | The letter headers (M, S, T…) |
| **Row Font Size** | 60 | Her name in the list (in her font) |
| **Row Photo Size** | 120 | The round photo or initials in the list |
| **Slide Seconds** | 0.25 | How long her card takes to slide in and out |

**Sounds** in the same file: **Open Contact Sound** (clicking a girl,
Kenney `select_001` for now) and **Back Sound** (`back_001`).

**The phone** (its screen colour, corners, status bar, home bar, and the
font for the phone's own words: the title, the count, the letters) is
`data/phone_style.tres`, shared by every phone screen
([the-phone.md](the-phone.md)). The heart is shared with the end-of-date
card. Each row and her card use **her dialogue style** (box, outline, font,
colours), so changing her dialogue box changes her contact too. Her photo
is her girl file → **Contact Card → Contact Photo** (empty = her initials).

**Where things sit:** open `ContactsApp.tscn`: the list is under
**PhoneScreen → Phone → Body → Screen → Margin → Column**.

**How it opens:** like moving between open apps on an iPhone (the app
switcher: [the-phone.md](the-phone.md) → Your apps). Its icon and name above
its card are `data/apps/contacts.tres` (the Godot logo for now). With
**Switching Apps** off in `data/app_transition_style.tres`, it opens with the
open-app animation instead, growing from **Default Origin** (the bottom
middle of the phone's screen) and closing back into it. See
[phone apps](phone-apps.md).

## Changing the key

W is one key for all your apps: **Project → Project Settings → Input Map**
→ `switch_apps` (W now). Add or change keys there; nothing else needs to
change. Click the ContactsApp node (in `scenes/Calendar/calendar.tscn`):

| Setting | What it does |
|---|---|
| **Switch Action** | The key that flips through the apps (`switch_apps`). Empty = W skips Contacts |
| **Open Action** | Optional: a key of its own that opens and closes just Contacts (add an action in the Input Map, e.g. `open_contacts` on C, and type its name here). Empty now |

**W's order** is the calendar, then the apps in the order they sit in the
calendar scene (top to bottom in the Scene panel: ContactsApp, then
ProfileApp). Drag ProfileApp above ContactsApp to visit Profile first.

## Letting W reach Contacts on another screen

Drag `scenes/Phone/Contacts/ContactsApp.tscn` into that screen's scene.
That's all.

## Something's wrong

| Problem | Fix |
|---|---|
| She's not in the list | She didn't give her number (a failed date), or no date was played this run. Press **F5** and play one from the dating app. |
| W never reaches Contacts | You're not on the calendar (only screens with `ContactsApp.tscn` in them), ContactsApp's **Switch Action** is empty, or `switch_apps` is missing from the Input Map (Godot prints a warning). |
| Her row looks like the dark default box | She has no **Dialogue Style** in her girl file. |

## Synergy: streams between girls who share tags

**Two girls who share tags have synergy**, and the Contacts list shows it:
a **stream of little sprites flows between their photos**, bowing out to
the right. The more tags they share, the **stronger** the stream: more
sprites, bigger, faster and more solid, bowing out further. Half flow each
way.

**Each tag has its own sprites**, so the stream shows what kind of synergy
it is: two Smokers stream **cigarette packs** (`assets/cig_gif/`). Girls who
share two tags get a mix of both tags' sprites. A tag with no sprites of its
own uses its trait's **Icon** (her girl file → **Traits**), or else the
Godot logo (Punk, for now).

**The score, for now:** one point for each tag they both have. A tag is a
trait whose **Kind** is `tag` in her girl file (**Contact Card →
Traits**); the **Title** has to match ("Smoker" and "smoker" do). Split
Ends' tags are Punk and Smoker. Smokey has a placeholder **Smoker** tag, so
she and Split Ends have 1 point.

**Try it:** press **F6** on `scenes/Phone/Contacts/ContactsApp.tscn`. Its
**Test Contacts** are Split Ends and Smokey, so there's one stream. In the
game you'd need two girls in your party who share a tag (Smokey can't be
dated yet).

**Change it:** `data/synergy.tres` (the ContactsApp node's **Synergy**;
empty = no streams):

| Setting | Now | What it does |
|---|---|---|
| **Score → Counted Kinds** | tag | Which kinds of trait count. Add `type` to count shared types too |
| **Each Tag's Sprites → Tag Sprites** | Smoker: the cigarette packs | Each tag's own sprites. **Add Key/Value Pair**: type the tag's title on the left (capitals don't matter), drop a SpriteFrames on the right (click it to add frames and set their speed) |
| **Stream → Sprite Frames** | the Godot logo (placeholder) | The sprites for a tag with none of its own (and no trait Icon) |
| **Animation Name** | (empty) | Which animation plays in any tag's sprites that have one by this name. Empty = the first |
| **Sprites Per Point** | 6 | How many flow for each point (each shared tag adds this many of its own) |
| **Max Points** | 4 | Points past this don't make it look any stronger |
| **Sprite Size** / **Size Per Point** | 56 / 18 | Their size at 1 point, and how much bigger per extra point |
| **Speed** / **Speed Per Point** | 180 / 80 | How fast they flow at 1 point, and how much faster per extra point |
| **Opacity** / **Opacity Per Point** | 0.75 / 0.1 | How solid they are at 1 point, and how much more per extra point |
| **Arc Bulge** | 280 | How far the stream bows out to the right (more for girls further apart on the list) |
| **Wobble** | 16 | How much the sprites wiggle off the line |
| **Both Ways** | on | Half flow each way. Off = from the girl higher on the list |

## Not built yet

These are planned for the party: breaking up with someone (your party will
hold 3), picking who comes to the boss fight and in what order, and the
synergy report (what the synergy does in the boss fight).

## For programmers

- `SynergyStyle` (`scripts/data/synergy_style.gd`, `data/synergy.tres`):
  `score(a, b)` (shared titles of traits whose `kind` is in
  `counted_kinds`, ignoring case), `shared(a, b)`, `frames_for(tag, a, b)`
  (`tag_sprites`, else the trait's `icon` as a one-frame SpriteFrames, else
  `sprite_frames`), and the stream settings.
  `SynergyStreams` (`scenes/Phone/Contacts/synergy_streams.gd`, a `Node2D`):
  `ContactsApp._build_rows()` adds one as the list's last child (so it
  draws over the rows, scrolls and clips with them) and calls
  `setup(synergy, photos, girls)`. Each frame it moves each stream's
  `AnimatedSprite2D`s along a quadratic Bézier between the two photos'
  centres, sized by each frame's drawn part (`Image.get_used_rect()`), so
  art with see-through edges still comes out **Sprite Size**.
- `PartyMember` (`scripts/data/party_member.gd`): `girl: GirlData`,
  `affection` (0–3 hearts).
- `PlayerManager.party: Array[PartyMember]`;
  `add_party_member(girl, affection)` (keeps the higher hearts if
  she's already there), `is_in_party(girl)`, signal `party_changed`.
  The date scene calls `add_party_member` when she gives her number.
- `ContactsApp` (`scenes/Phone/Contacts/contacts_app.gd`, a CanvasLayer on
  layer 19) is a `PhoneOverlayApp` (`scenes/Phone/phone_overlay_app.gd`):
  `switch_action` (`switch_apps`, W: the next app in scene order, round to
  the screen underneath), optional `open_action`, `open()` / `close()` (the app switcher,
  `phone_screen.switch_apps()`, in the order of `RecentApps`; or `AppLauncher.open/close`, or
  `phone_screen.raise()` / `lower()`). Its phone is `phone_screen`
  (`PhoneScreen`, Behind = Nothing; its `home_pressed` closes it),
  `show_list(members)` / `hide_list()` show it at once; signals
  `contact_opened(member)`, `opened`, `closed`. It holds a
  `ContactCard` (layer 20) and calls `ContactCard.show_saved(girl, hearts,
  rules)`, which sends `back_pressed`.
