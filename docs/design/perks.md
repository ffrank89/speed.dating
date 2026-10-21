# Perks

## Concept

- Perks are **build-arounds like Balatro jokers**. One good perk can define
  a whole run's plan.
- A perk can touch **any module**: add or remove dialogue options, change
  microgame difficulty, change scoring, boost girls with a certain tag, and
  (TBD) affect the boss fight.
- Examples today: **Inebriated** (success pays more, mistakes cost more; boosts
  Stoner girls) and **Sleepy** (mistakes forgiven more; more time in
  microgames).
- Earned from **dates** and **calendar events**.
- Adding a perk should **never mean editing a scene**. Each perk carries its
  own logic.

## Code needed

### Shared functions it uses

- `RunState.add_perk(perk)`, `RunState.perks`, signal `perks_changed`
- Called *by* the modules through the hook functions below

### Shared objects it inherits or holds

- `PerkData extends Resource`, one `.tres` per perk. A perk with custom logic
  uses a small script that extends `PerkData` and overrides hooks.

### Custom objects and functions

| Hook | Called by | Default |
|---|---|---|
| `modify_options(options: Array, girl: GirlData) -> Array` | Date Scene, before showing options | returns `options` unchanged |
| `modify_microgame(modifiers: Dictionary) -> Dictionary` | Date Scene, before `Microgame.start` | unchanged |
| `modify_score(delta: float, context: Dictionary) -> float` | Date scorer, each turn | unchanged |
| `modify_synergy(report: SynergyReport, party) -> void` | `Synergy.calculate` | no-op |
| `modify_battle(battle_state) -> void` | Boss Scene | no-op. **TBD:** do perks act in battle at all? |

| Field | Notes |
|---|---|
| `id`, `display_name`, `description` | Shown in the perk tooltip |
| `icon_animation: StringName` | Animation name in the shared perk `SpriteFrames` |
| `rarity` | TBD. Do we need rarity for event drops? |
| `stackable: bool` | TBD. Today the bug was duplicated perks; decide whether duplicates are ever allowed. |

**Old code removed (2026-10-21, [0061](../decisions/0061-f5-music-and-clean-up.md)):**
the first prototype's `Perk` classes (Inebriated, Sleepy), `PerkBorder` and
`PerkIcon` weren't used by the game any more and were deleted. They're in
the git history. Perks will be built fresh as `PerkData` with the hooks
above.

Perk pool for the first build: TBD (aim for ~8–10 so runs differ).

## Art needed

| Asset | Used by | Status |
|---|---|---|
| Perk icon animation per perk | Perk display, perk tooltip, event reward screen | Frames exist for Inebriated (`inebriated stat gif`) and Sleepy (`sleepy stat gif`); more stat gifs in `assets/` could become perks |
| Perk border / frame | Perk display | TBD (the old `PerkBorder` was removed) |
| "Perk triggered" flash | Date Scene and Boss Scene when a hook changes something | TBD. Balatro-style feedback is a big part of the fun. |
| Perk reward card | Calendar event screen | TBD |

## Systems it's part of

- **Build**: the main lever for run-to-run variety.
- **Skill Test**: changes options and microgames.
- **Combat**: only if `modify_battle` is kept (TBD).
- **Content Pipeline**: new perk = new `.tres` (+ small script if it needs logic).
