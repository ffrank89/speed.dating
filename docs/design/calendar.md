# Calendar Scene (incl. Tinder screen and Party screen)

## Concept

- The calendar is the **run's clock and hub**. Each day costs one action.
- About **5 actions per chapter** (to tune). The **boss is shown from the
  chapter's first day** and is forced on the last day.
- Actions:

  | Action | What happens | Leads to |
  |---|---|---|
  | Date | Pick 1 of 2–3 random profiles, or skip | Tinder screen → Date Scene |
  | Follow-up date | Date a party member to raise her Affection | Date Scene |
  | Train | Add points to one attribute | Back to calendar |
  | Rest / event | A perk, an item or a random event | Back to calendar |
  | Boss | Forced on the last day | Party screen → Boss Scene |

- **Which actions appear on which days is generated per run**, so no two
  chapters play the same.
- The calendar also opens the **party screen**: see your girls, the synergy
  report, break up with someone, and pick the 3 for the boss.

## Code needed

### Shared functions it uses

- `RunState.advance_day()`, `RunState.day`, `RunState.chapter`
- `RunState.raise_attribute(a, n)` (training), `add_perk`, `add_item` (events)
- `RunState.break_up(member)` (party screen)
- `Synergy.calculate(...)` (party screen)
- `SceneRouter.go_to(...)`

### Shared objects it inherits or holds

- `RunState` (day, chapter, schedule, party)
- `GirlData` pool (Tinder offers), `PartyMember` (follow-ups, party screen)
- `BossData` (shown from day 1)
- `SynergyReport` (party screen)

### Custom objects and functions

| Thing | Notes |
|---|---|
| `CalendarScene` | Exists (`calendar.gd`). Rewire to `RunState`; stop hardcoding actions. |
| `ScheduleGenerator.generate(chapter, rng) -> Array[DayAction]` | Per-run schedule. Rules TBD (e.g. at least 2 date days, at most 1 rest). |
| `DayAction` (`Resource`) | `kind` (date / follow_up / train / event / boss), `icon`, payload. Replaces the `{"action_name", "scene", "icon"}` dicts. |
| Day selection rule | Today clicking any future day only advances one day. TBD: can you only click *today*, or choose among the next few days? |
| `TinderScreen` | Exists (`scenes/Tinder`). Shows `GirlPool.offer(2–3)` with name, bio, interests, **tags**. Skip option. |
| `PartyScreen` | TBD. Party list, synergy panel, break-up button, lineup picker (3 + order) before the boss. |
| Training screen | TBD. Pick an attribute; how many points? |
| Event pool | TBD. Random events and their rewards. |
| Month/chapter display | Today uses `assets/january.png`. Chapters may not map to months; TBD. |

## Art needed

| Asset | Used by | Status |
|---|---|---|
| Calendar page background | `CalendarScene` | Exists: `january.png` |
| Day action icons: date, follow-up, train (per attribute?), rest/event, boss | `CalendarIcon` in each day cell | Exists: culture, mult, sleepy, split_ends. **Missing: girl/date, follow-up, boss.** |
| "Day done" X | `DayButtonContainer` | Exists (`x1`) |
| Boss preview card | Calendar header from day 1 | TBD |
| Tinder profile card + swipe UI | `TinderScreen` | Exists (placeholder) |
| Tag icons | Tinder card, party screen | TBD (shared with [girls.md](girls.md)) |
| Party screen layout, lineup slots | `PartyScreen` | TBD |

## Systems it's part of

- **Run Loop**: owns days and chapters, triggers the boss.
- **Relationships**: where you choose first dates, follow-ups and break-ups.
- **Build**: training, events and the party screen.
- **Combat**: the lineup pick happens here, just before the fight.
