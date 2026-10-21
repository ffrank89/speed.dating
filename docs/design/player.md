# Player Character

## Concept

- The player is a **stat sheet that dates test against**, not a fighter.
  Only the girls fight.
- **Stats**, and only stats: Culture, Intellect, Seduction, Heart, and
  Fallout: New Vegas's S.P.E.C.I.A.L. (Strength, Perception, Endurance,
  Charisma, Intelligence, Agility, Luck). 1–9 each, so they're easy to keep
  track of over a short run. Each is a data file that can be switched on or
  off, so the set can be tried out and changed
  ([stats.md](../guides/stats.md)). Which set the game keeps is TBD.
  They decide which dialogue options are safe vs risky, how hard microgames
  are, which girls can appear, and part of player–girl synergy.
- **Perks** are the player's build-arounds (see [perks.md](perks.md)).
- **Inventory** holds items shown to a girl for a reaction. Flavor only in
  the first build.
- Stats go up through **training days** and some date outcomes.

## Code needed

### Shared functions it uses

- `RunState.get_stat(stat)`, `RunState.raise_stat(stat, amount)`
- `RunState.add_perk(perk)`, `RunState.add_item(item)`
- `RunState` signals `stats_changed`, `perks_changed` (UI refresh)

### Shared objects it inherits or holds

- `PlayerData` (`Resource`, created per run, held by `RunState`)
- **Built:** `PlayerStat` (one per stat, `data/stats/`) and `StatList` (`data/stats.tres`: the stats and their scale)
- Holds lists of `PerkData` and `ItemData` (stored on `RunState`, not on `PlayerData`; TBD which is cleaner)

### Custom objects and functions

| Thing | Notes |
|---|---|
| `PlayerData.stats: Dictionary[StringName, int]` | Stat id → value, clamped to `data/stats.tres` (1–9). Training is +1. |
| `PlayerData.raise(stat: PlayerStat, amount: int)` | Only called through `RunState` so the signal fires. |
| `PlayerPanel` (UI scene) | **Started as the Profile app** (W on the calendar, `scenes/Phone/Profile/ProfileApp.tscn`): every stat that's on, as bars (`StatBars`). Perks and items: TBD. The old `player_panel.gd` was removed. |
| Intro / starting stats | Today `IntroQuestions` sets stats (debug sliders, starting at each stat's Starting Value, 5). TBD: keep the questionnaire, or random start, or pick a starting "archetype"? |
| Stat caps and starting values | TBD. Needs tuning with the date difficulty curve. |

**Today:** `PlayerCharacter` (`scripts/characters/player_character.gd`, a
small `RefCounted`: `name`, `stats`, `get_stat()`, `raise_stat()`),
held by `PlayerManager.player`. Later it becomes `PlayerData` on
`RunState`.

## Art needed

| Asset | Used by | Status |
|---|---|---|
| Stat icons, one per stat | Profile, option bubbles (shows the check), Tinder unlock hints | Culture and Heart exist (`culture stat gif`, `lovestat gif`); the rest are the Godot logo (each stat's **Icon**) |
| Stat-up feedback (sparkle / number pop) | Calendar training result, `DateResult` summary | TBD |
| Player panel frame | The Profile app | No art needed (the phone's look) |
| Item icons | Items (TBD), item reactions in the date | Art exists: `drugs.png`, `weed.png`, `cig_gif`, `loghter.png`. The old inventory code was removed (2026-10-21) |
| Player portrait? | `PlayerPanel` | TBD. Do we ever show the player? |

## Systems it's part of

- **Skill Test**: stats set option risk and microgame difficulty.
- **Build**: stats feed player–girl synergy; perks live here.
- **Relationships**: stat thresholds unlock certain girls.
