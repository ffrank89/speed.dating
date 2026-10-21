# Player Character

## Concept

- The player is a **stat sheet that dates test against**, not a fighter.
  Only the girls fight.
- **Four attributes**: Culture, Intellect, Seduction, Heart (1–9 each, so
  they're easy to keep track of over a short run; the scale is
  `data/attribute_rules.tres`).
  They decide which dialogue options are safe vs risky, how hard microgames
  are, which girls can appear, and part of player–girl synergy.
- **Skills**: the set from Fallout: New Vegas (Barter, Speech, Sneak…),
  1–9 each, each one switchable on or off. What they do isn't decided yet;
  they plug into Profile, the intro, calendar actions and dialogue checks
  ([skills.md](../guides/skills.md)).
- **Perks** are the player's build-arounds (see [perks.md](perks.md)).
- **Inventory** holds items shown to a girl for a reaction. Flavor only in
  the first build.
- Attributes go up through **training days** and some date outcomes.

## Code needed

### Shared functions it uses

- `RunState.get_attribute(a)`, `RunState.raise_attribute(a, amount)`
- `RunState.add_perk(perk)`, `RunState.add_item(item)`
- `RunState` signals `attributes_changed`, `perks_changed` (UI refresh)

### Shared objects it inherits or holds

- `PlayerData` (`Resource`, created per run, held by `RunState`)
- `Attr` enum for attribute keys
- Holds lists of `PerkData` and `ItemData` (stored on `RunState`, not on `PlayerData`; TBD which is cleaner)

### Custom objects and functions

| Thing | Notes |
|---|---|
| `PlayerData.attributes: Dictionary[Attr, int]` | Clamped 1–9 (`AttributeRules`, `data/attribute_rules.tres`). Training is +1. |
| `PlayerData.raise(a: Attr, amount: int)` | Only called through `RunState` so the signal fires. |
| `PlayerPanel` (UI scene) | **Started as the Profile app** (P on the calendar, `scenes/Phone/Profile/ProfileApp.tscn`): your four attributes as bars. Perks and items: TBD. The old `player_panel.gd` was removed. |
| Intro / starting stats | Today `IntroQuestions` sets stats (debug sliders, starting at 9). TBD: keep the questionnaire, or random start, or pick a starting "archetype"? |
| Attribute caps and starting values | TBD. Needs tuning with the date difficulty curve. |

**Today:** `PlayerCharacter` (`scripts/characters/player_character.gd`, a
small `RefCounted`: `name`, `attributes`, `skills`, `get_attribute()`,
`raise_attribute()`, `get_skill()`, `raise_skill()`),
held by `PlayerManager.player`. Later it becomes `PlayerData` on
`RunState`.

## Art needed

| Asset | Used by | Status |
|---|---|---|
| Attribute icons ×4 (Culture, Intellect, Seduction, Heart) | `PlayerPanel`, dialogue option buttons (shows the check), Tinder unlock hints | Partly exists: `culture stat gif`, `lovestat gif`, others in `assets/` |
| Attribute-up feedback (sparkle / number pop) | Calendar training result, `DateResult` summary | TBD |
| Player panel frame | The Profile app | No art needed (the phone's look) |
| Item icons | Items (TBD), item reactions in the date | Art exists: `drugs.png`, `weed.png`, `cig_gif`, `loghter.png`. The old inventory code was removed (2026-10-21) |
| Player portrait? | `PlayerPanel` | TBD. Do we ever show the player? |

## Systems it's part of

- **Skill Test**: attributes set option risk and microgame difficulty.
- **Build**: attributes feed player–girl synergy; perks live here.
- **Relationships**: attribute thresholds unlock certain girls.
