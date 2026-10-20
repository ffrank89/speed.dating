# The full date

For writers and designers. **No code needed.**

A first date now plays from start to finish:

```
Dating app: Start ─► her room opens like an app
                      │
                      ├─ the opener
                      ├─ 5 exchanges, drawn at random, no repeats
                      │    (2 of them microgame exchanges, 3 regular ones, shuffled)
                      ├─ one closer, picked by how it went
                      └─ her contact card (she gives you her number, or doesn't)
                           │
                           ├─ got her number → saved in your Contacts (your party)
                           └─ failed date    → she's gone for the run
                                                (the dating app stops showing her)
                      ─► back to the calendar
```

The fly and the other stage hazards can turn up during any exchange. The
[heart meter](heart-meter.md) in the top right fills as the score climbs:
one ring per heart.

## Try it

- **Test bench:** press **F5** (or open `scenes/Dates/FirstDate/FirstDateTest.tscn`
  and press **F6**). It plays a whole date with the debug sliders for the
  player's attributes. At the end it stays put instead of going to the
  calendar. **Restart** plays another, with a new draw.
  - **End date now** jumps straight to her contact card.
  - To play just one title, click the top node and type it in **Start Title**
    (e.g. `exchange_boat`). Empty = the whole date.
  - **Dialogue** plays another file (e.g. `m3_test.dialogue`, with
    **Start Title** `start`). Empty = her own first date.
- **In the game:** calendar → a date day → the dating app → **Start**.

## Her first-date file

Each girl's first date is one `.dialogue` file, set in her girl file
(`data/girls/split_ends.tres`) → **Dialogue → First Date Dialogue**. Split
Ends' is `dialogue/split_ends/first_date.dialogue`. Right now it's a **test
pool** (placeholder lines) until the real one is written.

The date finds the parts by their **title names** (the `~` lines):

| Title | How many | When it plays |
|---|---|---|
| `~ opener` | 1 | Always first |
| `~ exchange_...` (any name after `exchange_`) | as many as you like (plan: 12) | 3 per date, at random |
| `~ microgame_...` | as many as you like (plan: 2–3) | 2 per date, at random. These are the exchanges with a `#microgame=` option. |
| `~ closer_failed` | 1 | The date failed (score below her **Number Threshold**). She won't give her number. |
| `~ closer_no_hearts` | 1 | She gives her number, but no hearts |
| `~ closer_hearts` | 1 | 1 heart or more |

**End every title with `=> END`.** That's how the date knows to move on to
the next one.

Example exchange:

```
~ exchange_boat

Split Ends: [#pose=point] Okay. Speed round. My dad's boat has a name. Guess it.
- Guess "The Unsinkable II". [#check=culture:40, #value=2]
	if hit
		Split Ends: [#react=exclamation] HOW did you know there was a first one?!
	else
		Split Ends: [#react=question] ...There wasn't a first one. Now I'm sad.
- Guess "Boat". [#value=1]
	Split Ends: Honestly? Respect.
=> END
```

The option tags (`#check`, `#value`, `#microgame`) and `if hit` / `else` are
in [options-and-scoring.md](options-and-scoring.md); poses and reactions are
in [dialogue-box.md](dialogue-box.md); microgames in
[making-a-microgame.md](making-a-microgame.md).

**A microgame that isn't built yet** (e.g. `#microgame=light_cigarette`) is
fine: that option rolls its % chance instead, until the microgame is in
`data/microgames.tres`.

**Too few exchanges?** If her file has fewer than 2 microgame exchanges, the
rest come from regular ones (and the other way round). If there still aren't
5, the date is shorter, and Godot prints a warning.

## The numbers

`data/date_rules.tres` → **Flow**:

| Setting | Now | What it does |
|---|---|---|
| **Exchanges** | 5 | Exchanges per date, between the opener and the closer |
| **Microgame Exchanges** | 2 | How many of those are `microgame_` ones |
| **Opener Title** | `opener` | The title name of the opener |
| **Exchange Prefix** | `exchange_` | Titles starting with this are regular exchanges |
| **Microgame Prefix** | `microgame_` | Titles starting with this are microgame exchanges |
| **Closer Failed / No Hearts / Hearts Title** | `closer_failed`, `closer_no_hearts`, `closer_hearts` | The three closers' title names |

Other titles in the file (like `start` in the old test files) are never
drawn, so you can keep notes or spare exchanges under another name.

When a date fails and how many hearts it earns are in her girl file →
Dating (**Number Threshold**, **Affection Thresholds**); what each ending
shows on the card is in [result-screen.md](result-screen.md).

## After the date

Her contact card stays up until you close it: click the **✕** on its corner
or press **Escape** ([result-screen.md](result-screen.md)). Then:

| How it went | What happens |
|---|---|
| She gave her number (0 hearts or more) | She's saved in your **Contacts** (press C on the calendar): that's your party ([contacts.md](contacts.md)). The dating app stops offering her. |
| Failed (no number) | She's **gone for the run**: the dating app skips her from now on. If no one's left, it says "No one left to swipe on." |

Then the game goes back to the calendar, which opens like an app
(`data/apps/calendar.tres`).

## Where things sit

The date itself is `scenes/Dates/Date/Date.tscn`: her room, her portrait,
the dialogue box, the option bubbles, the stage hazards, the microgame frame
and her contact card. Move things there (e.g. **OptionsStart**,
**ReactionIcon**, **StageHazards** → **Fly**), and both the test bench and
the real game pick it up. The test bench only adds the debug panel.

The top **Date** node's settings:

| Setting | What it does |
|---|---|
| **Girl** | Who the date is with. Empty = the girl picked in the dating app. |
| **Fallback Girl** | Used when the picked girl has no girl file yet (Smokey, for now, gets Split Ends). |
| **Dialogue** | Empty = her **First Date Dialogue** |
| **Rules** | `data/date_rules.tres` |

A girl's date character (`scripts/characters/girls/`) points to her girl
file with **girl_data_path**. Smokey has none yet.

## Something's wrong

| Problem | Fix |
|---|---|
| The date starts with an exchange, not the opener | The opener's title isn't `opener` (or **Opener Title**). Godot prints a warning. |
| Fewer than 5 exchanges | Not enough `exchange_` / `microgame_` titles in her file. |
| The date never ends, or skips a part | A title is missing its `=> END`. |
| No closer, straight to her card | That closer's title is missing; Godot prints which one. |
| "No dialogue" in the debug panel | Set her girl file → **Dialogue → First Date Dialogue**. |
| Smokey's date is Split Ends | She has no girl file yet (**Fallback Girl**). |

## For programmers

- `DateScene` (`scenes/Dates/Date/date_scene.gd`): `begin()` plans the titles
  (`_plan_titles()`), plays each with `DialogueBox.start()` and moves on when
  `finished` fires; then the closer (`_closer_title()`), then `_end_date()`:
  `AppLauncher.open("contacts")`, `ContactCard.play(hearts)`, a `DateResult`
  (`got_number`, `affection`, `score`), `PlayerManager.add_party_member()` or
  `mark_gone()`, `AppLauncher.close`, `date_finished(result)`, and
  `AppLauncher.open_scene("calendar", PlayerManager.CALENDAR)` when **Go To
  Calendar** is on.
- The girl comes from `PlayerManager.current_date.girl_data_path`; the
  player's attributes from `PlayerManager.player.skills` (50 each without
  a player).
- `FirstDateTest` sets `girl`, `dialogue`, `only_title` and `attributes` on
  its Date (Auto Start and Go To Calendar off), then calls `begin()`.
- Date music: `MusicManager` is switched off (all commented out), so dates
  have no music loop yet.
