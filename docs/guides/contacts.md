# Your contacts (the party)

For writers, artists and designers. **No code needed.**

Your party is the **Contacts** app on your phone. Every girl who gave you her
number on a date is saved there. That's who's in your party.

```
Date ends ─► she types her number into a New Contact (or doesn't)
               │
               ├─ got her number → saved in Contacts, with the hearts she gave you
               └─ failed date    → gone for the run

Calendar ─► Contacts icon (bottom right) ─► the app opens like an iPhone app
               │
               ├─ the list: A to Z under letter headers, each girl in her own box and
               │  font, her initials (or photo), a heart if she gave you one;
               │  "3 Contacts" underneath
               ├─ click a girl ─► her saved card slides in: what your hearts unlocked
               │                  on her date, her number and address
               │                  "‹ Contacts" (or Escape) goes back
               └─ the bar at the bottom (or Escape) closes the app
```

A girl in your contacts doesn't show up in the dating app any more:
she's taken.

## Try it

- **On its own:** open `scenes/Phone/Contacts/ContactsApp.tscn` and press
  **F6**. Click the top node → **Testing (F6)**: **Test Contacts** is who's
  in the list (Split Ends now; add girl files with **Add Element**), **Test
  Hearts** is the hearts they each got. Close it and it opens again a second
  later.
- **In the game:** play a date to the end and get her number. Back on the
  calendar, click **Contacts** (bottom right).

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

The rest of the look is shared with the end-of-date card: the sheet's
colour and corners, the font for the phone's own words, the heart. Each
row and her card use **her dialogue style** (box, outline, font, colours),
so changing her dialogue box changes her contact too. Her photo is her girl
file → **Contact Card → Contact Photo** (empty = her initials).

**Where things sit:** open `ContactsApp.tscn` and move or resize **Sheet**,
or the rows under **Sheet → Margin → Column**. The Contacts icon on the
calendar is **ContactsIcon** in `scenes/Calendar/calendar.tscn`: drag it to
move it.

**The app icon and its launch screen** are `data/apps/contacts.tres` (the
Godot logo for now). See [phone apps](phone-apps.md).

## Putting Contacts on another screen

1. Drag `scenes/Phone/Contacts/ContactsApp.tscn` into the scene.
2. Add an icon: a **Control** node with the script `scenes/Phone/app_icon.gd`,
   and drag `data/apps/contacts.tres` onto its **App** slot.
3. Click the ContactsApp node and pick the icon in its **Icon** slot.

That's all: clicking the icon opens the app from it, and closing shrinks it
back.

## Something's wrong

| Problem | Fix |
|---|---|
| She's not in the list | She didn't give her number (a failed date), or the date was on the test bench (F5), which doesn't save anyone. Play it from the dating app. |
| The icon does nothing | Click the ContactsApp node and check its **Icon** slot points at the icon. |
| Her row looks like the dark default box | She has no **Dialogue Style** in her girl file. |
| Smokey shows up as Split Ends | Smokey has no girl file yet, so her date uses Split Ends'. |

## Not built yet

These are planned for the party: breaking up with someone (your party will
hold 3), picking who comes to the boss fight and in what order, and the
synergy report.

## For programmers

- `PartyMember` (`scripts/data/party_member.gd`): `girl: GirlData`,
  `affection` (0–3 hearts), `profile: DateCharacter` (her dating-app entry).
- `PlayerManager.party: Array[PartyMember]`;
  `add_party_member(girl, affection, profile)` (keeps the higher hearts if
  she's already there), `is_in_party(date_name)`, signal `party_changed`.
  The date scene calls `add_party_member` when she gives her number.
- `ContactsApp` (`scenes/Phone/Contacts/contacts_app.gd`, a CanvasLayer on
  layer 19): `open(from_rect)`, `close()`, `show_list(members)`,
  `hide_app()`; signals `contact_opened(member)`, `closed`. It holds a
  `ContactCard` (layer 20) and calls `ContactCard.show_saved(girl, hearts,
  rules)`, which sends `back_pressed`.
