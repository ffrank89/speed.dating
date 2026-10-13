# Boss Scene

## Concept

- Bosses are **life events**: a concert or party, meeting the parents,
  Valentine's Day. Several per run in a **fixed, escalating order**; the
  first build has **one**.
- Each boss has a **type**. Girls do better or worse against it
  (Pokémon-style strengths and weaknesses). A **special rule per boss**
  (like Balatro boss blinds) comes later.
- The boss is **shown from the chapter's first day**, so you plan your dates
  around it.
- Before the fight you pick **3 girls and their order**. Then it's a
  **Super Auto Pets–style lineup** with **no player input**: girls attack in
  order, the boss hits whoever is in front, abilities fire on triggers.
- Each girl's strength comes from her battle stats, her Affection and the
  party's synergy:
  `attack = base attack × (1 + 0.25 × Affection) × synergy multiplier`
  (0.25 is a tuning number).
- **Lose and the run ends.** Win and you go to the next chapter (or win the
  run).
- **Build it alone first**: a test scene that loads a hand-made party, so the
  fight can be tuned without playing dates.

## Code needed

### Shared functions it uses

- `Synergy.calculate(lineup, player, perks)`
- Perk hook `modify_battle` (TBD whether perks act in battle)
- `RunState` → `run_ended(won)` or next chapter; `SceneRouter.go_to(...)`

### Shared objects it inherits or holds

- `BossData` (`Resource`, `.tres` per boss)
- `PartyMember` ×3 (the lineup), their `GirlData` battle fields
- `SynergyReport`

### Custom objects and functions

| Thing | Notes |
|---|---|
| `BossData` | `id`, `display_name`, `life_event`, `type`, `hp`, `attack`, `speed`, `abilities`, `special_rule` (later), art refs |
| `BossScene` | Lays out lineup vs boss, runs the fight, plays animations. |
| `Battle` (pure logic, no nodes) | `Battle.new(lineup, boss, report).step()` until done; emits events the scene animates. Pure logic means it can be simulated thousands of times for balancing. |
| Turn/tick rules | Who acts when (speed? fixed order?). TBD. |
| Ability triggers | `on_start`, `on_hurt`, `on_ally_faint`, `on_kill`… TBD list. |
| Type chart | `type_multiplier(girl, boss) -> float`. Comes from girl tags or a separate girl "type"? TBD. |
| `BossTestScene` | Drop 3 `GirlData` files in the Inspector, press F6, watch. First thing to build after the data model. |
| Win/lose screen | TBD. Should show *why* (which synergy carried, who fell first). |

## Art needed

| Asset | Used by | Status |
|---|---|---|
| Boss art per boss (idle, attack, hurt, defeated) | `BossScene` | TBD |
| Boss preview card | Calendar header from day 1, pre-fight screen | TBD |
| Arena background per life event | `BossScene` | TBD |
| Girls' pixel sprites: idle, attack, hurt, knocked out | Lineup in `BossScene` | Not yet animated (see [girls.md](girls.md)) |
| Hit numbers, ability procs, type-advantage flash | `BossScene` | TBD |
| Lineup slots ×3 | Party screen and `BossScene` | TBD |
| Win / lose screen | End of fight | TBD |

## Systems it's part of

- **Combat**: this is the combat.
- **Run Loop**: ends each chapter; a loss ends the run.
- **Build**: the exam that grades your party, perks and attributes.
