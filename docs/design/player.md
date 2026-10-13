# Player Character

## Concept

- The player is a **stat sheet that dates test against**, not a fighter.
  Only the girls fight.
- **Four attributes**: Culture, Intellect, Seduction, Heart (0–100 each).
  They decide which dialogue options are safe vs risky, how hard microgames
  are, which girls can appear, and part of player–girl synergy.
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
| `PlayerData.attributes: Dictionary[Attr, int]` | Clamped 0–100. |
| `PlayerData.raise(a: Attr, amount: int)` | Only called through `RunState` so the signal fires. |
| `PlayerPanel` (UI scene) | Shows attributes, perks, inventory. Exists today as `player_panel.gd`. Rewire to `RunState` signals. |
| Intro / starting stats | Today `IntroQuestions` sets stats (debug sets all to 100). TBD: keep the questionnaire, or random start, or pick a starting "archetype"? |
| Attribute caps and starting values | TBD. Needs tuning with the date difficulty curve. |

**Migrating:** `PlayerCharacter` (a `Node`) becomes `PlayerData` (a
`Resource`). `get_skill_level` / `increase_skill` map to `RunState`
calls.

## Art needed

| Asset | Used by | Status |
|---|---|---|
| Attribute icons ×4 (Culture, Intellect, Seduction, Heart) | `PlayerPanel`, dialogue option buttons (shows the check), Tinder unlock hints | Partly exists: `culture stat gif`, `lovestat gif`, others in `assets/` |
| Attribute-up feedback (sparkle / number pop) | Calendar training result, `DateResult` summary | TBD |
| Player panel frame | `PlayerPanel` | Exists (placeholder) |
| Item icons | `InventoryUI`, item reactions in the date | Exists: `ItemIcon` scene + baggy/weed/cigs/lighter art |
| Player portrait? | `PlayerPanel` | TBD. Do we ever show the player? |

## Systems it's part of

- **Skill Test**: attributes set option risk and microgame difficulty.
- **Build**: attributes feed player–girl synergy; perks live here.
- **Relationships**: attribute thresholds unlock certain girls.
