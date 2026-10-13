# Synergy System

## Concept

- Synergy turns the **party into battle bonuses**. It's where the run's
  strategy lives.
- **Girl–girl synergy**: shared **tags** at thresholds, like Teamfight
  Tactics traits (2 Artsy girls → bonus, 4 → bigger bonus). No hand-written
  pairs or rivalries.
- **Player–girl synergy**: her **Affection**, how well **your attributes
  match her preferences**, and **perks that interact with her tags**
  (Inebriated boosts Stoner girls). Multiplies that girl's stats.
- Because Tinder profiles show tags, **choosing who to date is choosing
  your build**. That choice is the roguelike decision.
- It's **a calculation with no scene**, the easiest module to test alone.

## Code needed

### Shared functions it uses

- Perk hook `modify_synergy(report, party)`
- `RunState.party`, `RunState.player`, `RunState.perks` (passed in, not read
  directly, so it can be tested with fake data)

### Shared objects it inherits or holds

- `PartyMember`, `GirlData`, `TagData`, `PlayerData`, `PerkData`
- Produces a `SynergyReport` (`RefCounted`)

### Custom objects and functions

| Thing | Notes |
|---|---|
| `Synergy.calculate(party, player, perks) -> SynergyReport` | Static, pure. Called by the party screen and the boss fight. |
| `count_tags(members) -> Dictionary[TagData, int]` | Counts tags across the **chosen lineup** or the **whole party**? TBD (TFT counts fielded units only). |
| `player_girl_multiplier(member, player, perks) -> float` | Affection + preference match + perk bonuses. Formula TBD. |
| `TagData` | `name`, `icon`, `thresholds: Array[int]`, `bonus_per_threshold` (TBD: stat bonus? ability? applies to tagged girls or all?) |
| `SynergyReport` | `active_tags: Array[{tag, count, tier}]`, `per_girl_multiplier: Dictionary[PartyMember, float]`, `notes` for UI. |
| Tag list for the first build | TBD. Started with stoner, artsy, chaotic; need ~4–6 tags across the first build's ~6 girls. |
| Unit tests | Hand-built parties → expected report. Plain GDScript test or GUT (TBD). |

## Art needed

| Asset | Used by | Status |
|---|---|---|
| Tag icons | Synergy panel, Tinder card, party screen | TBD |
| Synergy panel (tags with count/threshold pips, e.g. "Artsy 2/4") | Party screen, boss pre-fight | TBD |
| Per-girl multiplier badge | Party screen, lineup slots | TBD |
| "Synergy activated" effect | Boss Scene start of fight | TBD |

## Systems it's part of

- **Build**: the main reason one party beats another.
- **Combat**: feeds multipliers into the fight.
- **Relationships**: Affection from dates and follow-ups is an input.
