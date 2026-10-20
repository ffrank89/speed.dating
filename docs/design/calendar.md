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
- The calendar also opens your **Contacts** (the party screen,
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
| `CalendarScene`                                                | Exists (`calendar.gd`). Rewire to `RunState`; stop hardcoding actions.                                                                                                      |
| `ScheduleGenerator.generate(chapter, rng) -> Array[DayAction]` | Per-run schedule. Rules TBD (e.g. at least 2 date days, at most 1 rest).                                                                                                        |
| `DayAction` (`Resource`)                                     | `kind` (date / follow_up / train / event / boss), `icon`, payload. Replaces the `{"action_name", "scene", "icon"}` dicts.                                                 |
| Day selection rule                                               | New Dates take 2 or more days. Training takes 1.  Breakups take 1 day but Breakups + New Date take as much as a New Date does.                                                 |
| `TinderScreen`                                                 | Exists (`scenes/Tinder`). Shows `GirlPool.offer(2–3)` with name, bio, interests, **tags**. Skip option.<br />Is a Phone App Screen. Overlays on top of the calendar. |
| `ContactsApp` (the party screen)                               | **Built.** `scenes/Phone/Contacts/ContactsApp.tscn`, opened from the **Contacts** icon on the calendar like an app. Lists `PlayerManager.party` A to Z in each girl's style; clicking one slides in her saved `ContactCard`. Guide: [contacts.md](../guides/contacts.md), decision [0054](../decisions/0054-party-is-your-contacts.md). Break-ups, lineup pick and synergy report: TBD. |
| Training screen                                                  | TBD. Pick an attribute; how many points?                                                                                                                                        |
| Event pool                                                       | TBD. Random events and their rewards.                                                                                                                                           |
| Month/chapter display                                            | Today uses`assets/january.png`. Chapters may not map to months; TBD.                                                                                                          |

## Art needed

| Asset                                                                       | Used by                           | Status                                                                                   |
| --------------------------------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------- |
| Calendar page background                                                    | `CalendarScene`                 | Exists:`january.png`                                                                   |
| Day action icons: date, follow-up, train (per attribute?), rest/event, boss | `CalendarIcon` in each day cell | Exists: culture, mult, sleepy, split_ends.**Missing: girl/date, follow-up, boss.** |
| "Day done" X                                                                | `DayButtonContainer`            | Exists (`x1`)                                                                          |
| Boss preview card                                                           | Calendar header from day 1        | TBD                                                                                      |
| Tinder profile card + swipe UI                                              | `TinderScreen`                  | Exists (placeholder)                                                                     |
| Tag icons                                                                   | Tinder card, Contacts (her card)  | TBD (shared with[girls.md](girls.md))                                                     |
| Contacts app icon; lineup slots                                             | `data/apps/contacts.tres`, `ContactsApp` | Icon: Godot logo placeholder. The list needs no art. Lineup slots TBD. |

## Systems it's part of

- **Run Loop**: owns days and chapters, triggers the boss.
- **Relationships**: where you choose first dates, follow-ups and break-ups.
- **Build**: training, events and your Contacts (the party).
- **Combat**: the lineup pick happens here, just before the fight.
