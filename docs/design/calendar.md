# Calendar Scene (incl. Tinder screen and the Contacts app, your party)

## Concept

- The calendar is the **run's clock and hub**. Each day costs one action.
- About **5 actions per chapter** (to tune). The **boss is shown from the
  chapter's first day** and is forced on the last day.
- Actions:

  | Action         | What happens                               | Leads to                    |
  | -------------- | ------------------------------------------ | --------------------------- |
  | Date           | Pick 1 of 2–3 random profiles, or skip    | Tinder screen → Date Scene |
  | Follow-up date | Date a party member to raise her Affection | Date Scene                  |
  | Train          | Add points to one stat                | *animation* Back to calendar        |
  | Rest / event   | A perk, an item or a random event          | *animation* Back to calendar            |
  | Boss           | Forced on the last day                     | Contacts (pick the lineup) → Boss Scene  |
- **Which actions appear on which days is generated per run**, so no two
  chapters play the same.
- **Built (2026-10-20, [0055](../decisions/0055-calendar-revamp.md)):** the
  calendar in its own dialogue-box style, a chapter of 7 days with the boss
  on the last; the whole month (28 days) is X'd out past this chapter
  (Foresight Days, for a future "see the future" ability). Since
  [0059](../decisions/0059-three-day-calendar.md) it's three day cards on the
  phone, with the month behind the **Month ▾** button (below). Each day offers 2–3 actions, picked at random per run; pick one
  and it uses its days (date 2, training 1, rest 1). Training, rest and the
  boss are placeholders. Guide: [the-calendar.md](../guides/the-calendar.md).
- **On the phone (2026-10-21, [0058](../decisions/0058-phone-and-real-life.md),
  [0059](../decisions/0059-three-day-calendar.md)):** the calendar is an app
  on the player's portrait phone, laid out like Balatro's blinds: three day
  cards stacked (today with its choices, then two "Upcoming"), and the whole
  month as a small grid. Its look is the player's style
  (`data/player_style.tres`). Your stats are their own app, **Profile** (P).
- On the calendar, **press C** for your **Contacts** (or W to flip through your apps) (the party screen,
  [0054](../decisions/0054-party-is-your-contacts.md)): every girl who gave
  you her number, and her saved card. **Built:** the list, her card, and
  synergy streams between girls who share tags. Still to come there: the
  synergy report, breaking up with someone, and picking the 3 for the boss.

## Code needed

### Shared functions it uses

- `RunState.advance_day()`, `RunState.day`, `RunState.chapter`
- `RunState.raise_stat(stat, n)` (training), `add_perk`, `add_item` (events)
- `RunState.break_up(member)` (party screen)
- `Synergy.calculate(...)` (party screen)
- `SceneRouter.go_to(...)`

### Shared objects it inherits or holds

- `RunState` (day, chapter, schedule, party)
- `GirlData` pool (Tinder offers), `PartyMember` (follow-ups, Contacts)
- `BossData` (shown from day 1)
- `SynergyReport` (party screen)

### Custom objects and functions

| Thing                                                            | Notes                                                                                                                                                                           |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CalendarScene`                                                | **Rebuilt** (`scenes/Calendar/calendar.gd`): `DayCard` per day on the main view (today and the next two), `DayChoice` per choice, `DayBox` per day in the month, lines from `dialogue/calendar.dialogue`. Reads `RunCalendar` (on `PlayerManager` until `RunState` exists). |
| `ScheduleGenerator.generate(chapter, rng) -> Array[DayAction]` | **Built as `RunCalendar`** (`scripts/calendar/run_calendar.gd`): each day draws Options Per Day actions by Weight, the boss on the last day (`data/calendar_rules.tres`). Rules like "at least 2 date days" still TBD. |
| `DayAction` (`Resource`)                                     | **Built** (`scripts/data/day_action.gd`, files in `data/day_actions/`): made of optional parts, applied in order: stat changes, a message (`dialogue/calendar.dialogue`), days used up or **Ends Chapter**, then a screen it **Opens** like an app. Date, train, rest and boss are mixes of these; follow-ups and events will be too. |
| Day selection rule                                               | New Dates take 2 or more days. Training takes 1.  Breakups take 1 day but Breakups + New Date take as much as a New Date does. **Built:** each `DayAction` has **Days** (date 2, training 1); it must end before the boss day. Breakups TBD. |
| `TinderScreen`                                                 | **Built** as the dating app (`scenes/Tinder/Screen.tscn`, [dating-app.md](../guides/dating-app.md)): an app on the phone, one girl's profile at a time from her girl file (name, age, bio, interests, picture), Pass or Start. Who's on it is its **Girls** list for now; `GirlPool.offer(2–3)` and **tags** are still to come. |
| `ContactsApp` (the party screen)                               | **Built.** `scenes/Phone/Contacts/ContactsApp.tscn`, pulled up with **C** on the calendar: it opens on the phone like an app, over the calendar. Lists `PlayerManager.party` A to Z in each girl's style; clicking one slides in her saved `ContactCard`. Guide: [contacts.md](../guides/contacts.md), decision [0054](../decisions/0054-party-is-your-contacts.md). Break-ups, lineup pick and synergy report: TBD. |
| Training screen                                                  | TBD. For now a train action raises one stat by 1 (its **Stats**) with a line from `dialogue/calendar.dialogue`; there's one per first-build stat (Culture, Intellect, Seduction, Heart), none yet for S.P.E.C.I.A.L. |
| Event pool                                                       | TBD. Random events and their rewards.                                                                                                                                           |
| Month/chapter display                                            | **Built:** "CHAPTER n" next to the title (off by default); the **Month ▾** button swaps the day cards for the whole month, 4 weeks (Calendar Days 28). `january.png` is only the calendar app's icon now. |

## Art needed

| Asset                                                                       | Used by                           | Status                                                                                   |
| --------------------------------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------- |
| Calendar boxes                                                              | `CalendarScene`, `DayCard`, `DayBox`, `DayChoice` | No art needed: drawn in the player's style (`data/player_style.tres`; **Calendar Art** in `data/calendar_style.tres` takes pictures). The old `january.png` page isn't used. |
| Day action icons: date, train ×4, rest, boss (follow-up, event later) | Each file in `data/day_actions/` → **Icon** | Placeholders from our icons: love react (date), culturestat, lovestat (heart), sleepy, sword stat (boss); **Godot logo** for Intellect and Seduction training. |
| "Can't see that far" X                                                      | `DayCard`, `DayBox` (**Hidden Mark**) | Exists (`assets/x1/`)                                                                  |
| Boss preview card                                                           | Calendar header from day 1        | TBD                                                                                      |
| Dating-app profile card + swipe                                             | `TinderScreen` (the dating app) | Built; no art needed (her card is in her dialogue style). Her picture is her girl file's **Profile Picture**. |
| Tag icons                                                                   | Tinder card, Contacts (her card)  | TBD (shared with[girls.md](girls.md))                                                     |
| Lineup slots                                                                | `ContactsApp`                   | The list needs no art. Lineup slots TBD. |

## Systems it's part of

- **Run Loop**: owns days and chapters, triggers the boss.
- **Relationships**: where you choose first dates, follow-ups and break-ups.
- **Build**: training, events and your Contacts (the party).
- **Combat**: the lineup pick happens here, just before the fight.
