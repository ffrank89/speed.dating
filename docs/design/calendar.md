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
  | Train          | Add points to one attribute                | *animation* Back to calendar        |
  | Rest / event   | A perk, an item or a random event          | *animation* Back to calendar            |
  | Boss           | Forced on the last day                     | Contacts (pick the lineup) → Boss Scene  |
- **Which actions appear on which days is generated per run**, so no two
  chapters play the same.
- **Built (2026-10-20, [0055](../decisions/0055-calendar-revamp.md)):** the
  calendar in its own dialogue-box style. The top box is this chapter (7
  days, the boss on the last); "See the whole month" opens the rest, X'd out
  past this chapter (Foresight Days, for a future "see the future"
  ability). Each day offers 2–3 actions, picked at random per run; pick one
  and it uses its days (date 2, training 1, rest 1). Training, rest and the
  boss are placeholders. Guide: [the-calendar.md](../guides/the-calendar.md).
- On the calendar, **press C** for your **Contacts** (the party screen,
  [0054](../decisions/0054-party-is-your-contacts.md)): every girl who gave
  you her number, and her saved card. **Built:** the list and her card.
  Still to come there: the synergy report, breaking up with someone, and
  picking the 3 for the boss.

## Code needed

### Shared functions it uses

- `RunState.advance_day()`, `RunState.day`, `RunState.chapter`
- `RunState.raise_attribute(a, n)` (training), `add_perk`, `add_item` (events)
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
| `CalendarScene`                                                | **Rebuilt** (`scenes/Calendar/calendar.gd`): `DayBox` per day, `DayChoice` per choice, lines from `dialogue/calendar.dialogue`. Reads `RunCalendar` (on `PlayerManager` until `RunState` exists). |
| `ScheduleGenerator.generate(chapter, rng) -> Array[DayAction]` | **Built as `RunCalendar`** (`scripts/calendar/run_calendar.gd`): each day draws Options Per Day actions by Weight, the boss on the last day (`data/calendar_rules.tres`). Rules like "at least 2 date days" still TBD. |
| `DayAction` (`Resource`)                                     | **Built** (`scripts/data/day_action.gd`, files in `data/day_actions/`): title, description, icon, kind (date / train / rest / boss; follow-up and event to come), days, weight, and per kind: app and scene, attribute and amount, dialogue title. |
| Day selection rule                                               | New Dates take 2 or more days. Training takes 1.  Breakups take 1 day but Breakups + New Date take as much as a New Date does. **Built:** each `DayAction` has **Days** (date 2, training 1); it must end before the boss day. Breakups TBD. |
| `TinderScreen`                                                 | Exists (`scenes/Tinder`). Shows `GirlPool.offer(2–3)` with name, bio, interests, **tags**. Skip option.<br />Is a Phone App Screen. Overlays on top of the calendar. |
| `ContactsApp` (the party screen)                               | **Built.** `scenes/Phone/Contacts/ContactsApp.tscn`, pulled up with **C** on the calendar: it opens over the calendar like an app, the way a microgame opens over the date. Lists `PlayerManager.party` A to Z in each girl's style; clicking one slides in her saved `ContactCard`. Guide: [contacts.md](../guides/contacts.md), decision [0054](../decisions/0054-party-is-your-contacts.md). Break-ups, lineup pick and synergy report: TBD. |
| Training screen                                                  | TBD. For now a train action raises one attribute by its Amount (5) with a line from `dialogue/calendar.dialogue`; there's one action per attribute. |
| Event pool                                                       | TBD. Random events and their rewards.                                                                                                                                           |
| Month/chapter display                                            | **Built:** "CHAPTER n" on the strip's name tab; the whole calendar is 4 weeks (Calendar Days 28). `january.png` is no longer used. |

## Art needed

| Asset                                                                       | Used by                           | Status                                                                                   |
| --------------------------------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------- |
| Calendar boxes                                                              | `CalendarScene`, `DayBox`, `DayChoice` | No art needed: drawn from `data/dialogue_styles/calendar.tres` (a picture box works too). The old `january.png` page isn't used. |
| Day action icons: date, train ×4, rest, boss (follow-up, event later) | Each file in `data/day_actions/` → **Icon** | Placeholders from our icons: love react (date), culturestat, lovestat (heart), sleepy, sword stat (boss); **Godot logo** for Intellect and Seduction training. |
| "Day done" X                                                                | `DayButtonContainer`            | Exists (`x1`)                                                                          |
| Boss preview card                                                           | Calendar header from day 1        | TBD                                                                                      |
| Tinder profile card + swipe UI                                              | `TinderScreen`                  | Exists (placeholder)                                                                     |
| Tag icons                                                                   | Tinder card, Contacts (her card)  | TBD (shared with[girls.md](girls.md))                                                     |
| Lineup slots                                                                | `ContactsApp`                   | The list needs no art. Lineup slots TBD. |

## Systems it's part of

- **Run Loop**: owns days and chapters, triggers the boss.
- **Relationships**: where you choose first dates, follow-ups and break-ups.
- **Build**: training, events and your Contacts (the party).
- **Combat**: the lineup pick happens here, just before the fight.
