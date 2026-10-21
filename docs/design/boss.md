# Boss Scene

## Concept

- Bosses are **life events**
  - Concert / party / meeting the parents / valentines day
  - **First build: one boss, Thanksgiving.**
- Each girl has a **type**, and each boss is weak to some types and strong
  against others (Pokémon-style). See [Girl types](#girl-types) below.
  - A **special rule per boss**
    (like Balatro boss blinds) comes later.
- The boss is **shown from the chapter's first day**, so you plan your dates / training
  around it.
- Before the fight you pick **up to 3 girls and their order** (your whole
  party, or fewer if someone is a bad match). Then it's an autobattle:
  **the front girl and the boss trade hits**; when she's knocked out, the
  next girl steps up. Girls whose type is right for the boss **crit**, girls
  whose type is wrong **fumble**, and each crit or fumble shows a written line.
  - EX:
    - Boss: Thanksgiving
    - Party: Lawyer girl ( critical hit! *she went to Yale?* ) X Affection -> Party Girl ( weak *did she do cocaine in the bathroom?* )
- Each girl's strength comes from her battle stats, her Affection and the
  party's synergy:
  `attack = base attack × (1 + 0.25 × Affection) × synergy multiplier × type multiplier`
  (0.25 and the type multipliers are tuning numbers).
- **Lose and the run ends.** Win and you go to the next chapter (or win the
  run).
- **Build it alone first**: a test scene that loads a hand-made party, so the
  fight can be tuned without playing dates.
- **What the fight represents is TBD.** For now it's a literal fight
  (HP bars, hits, knockouts).

### Girl types

Four types. **The names are placeholders; rename them freely.** Only the
count and the Thanksgiving chart below are decided.

| Type | Reads as | Example girl |
|---|---|---|
| **Brainy** | Smart, accomplished, career | The lawyer (went to Yale) |
| **Wild** | Party, chaotic, stoner | The party girl, Smokey? |
| **Sweet** | Wholesome, kind, family-friendly | TBD |
| **Artsy** | Creative, weird, alternative | Split Ends? |

### Thanksgiving

| | |
|---|---|
| **Weak to** (girl crits ×2) | Brainy, Sweet. The family loves her. |
| **Strong against** (girl fumbles ×0.5) | Wild. Everyone is horrified. |
| **Neutral** (×1) | Artsy |

### Fight rules (first build)

1. The lineup is up to 3 girls in the order you chose. Slot 1 is the front.
2. Each exchange: the **front girl attacks first**, then the **boss attacks
   the front girl**. Girls behind her wait.
3. Girl damage = `attack × (1 + 0.25 × Affection) × synergy × type`, where
   type is 2.0 (boss weak to her), 0.5 (boss strong against her) or 1.0.
4. On a ×2 or ×0.5 hit, show a **crit** or **fumble** effect and one of her
   lines for this boss.
5. At 0 HP she's knocked out; the next girl steps up.
6. **Win** when the boss hits 0 HP; **lose** when every girl is knocked out.
7. No unique abilities in the first build. Type barks only.

Starting numbers (all tuning): girl HP 10, girl attack 3, Thanksgiving HP 40,
Thanksgiving attack 4.

## Code needed

### Shared functions it uses

- `Synergy.calculate(lineup, player, perks)`
- Perk hook `modify_battle` (TBD whether perks act in battle)
- `RunState` → `run_ended(won)` or next chapter; `SceneRouter.go_to(...)`

### Shared objects it inherits or holds

- `BossData` (`Resource`, `.tres` per boss)
- `PartyMember` ×1–3 (the lineup), their `GirlData` battle fields
- `SynergyReport`
- `GirlType` enum (shared, in a constants script)

### Custom objects and functions

| Thing | Notes |
|---|---|
| `GirlType` enum | `BRAINY, WILD, SWEET, ARTSY` (rename with the type names). |
| `BossData` | `id`, `display_name`, `tagline`, `hp`, `attack`, `weak_to: Array[GirlType]`, `strong_against: Array[GirlType]`, `attack_names: Array[String]`, `win_line`, `lose_line`, `art: {idle, attack, hurt, defeated}`, `background`. `special_rule` later. |
| `GirlData` additions | `type: GirlType`, `barks: Dictionary` keyed by boss id → `{crit: Array[String], fumble: Array[String]}`. Fallback generic lines for test girls. |
| `Battle` (pure logic, no nodes) | `Battle.new(lineup, boss, report)`, then `step()` until done. Each step returns events (`attack`, `crit`, `fumble`, `ko`, `step_up`, `win`, `lose`) that the scene animates. Pure logic means it can be simulated thousands of times for balancing. |
| `type_multiplier(girl_type, boss) -> float` | 2.0 / 0.5 / 1.0 from `weak_to` / `strong_against`. |
| `BossScene` | Lays out the lineup (pixel girls) vs the boss (full illustration), plays `Battle` events with tweens, shows barks in a speech bubble. |
| `BossTestScene` | Drop 1–3 `GirlData` files and Affection values in the Inspector, press F6, watch. First thing to build after the data model. |
| Win/lose screen | Shows the result plus the boss's `win_line` / `lose_line` and who crit or fumbled. |
| `thanksgiving.tres` | The one boss for the first build. |

## Art needed

Exact list for the first build.

| # | Asset | Size / format | Used by |
|---|---|---|---|
| 1 | **Thanksgiving boss, full illustration: idle** | Large, to match the girls' date poses | `BossScene` (boss slot), boss preview card (crop) |
| 2 | Thanksgiving: **attack** pose | Same | `BossScene` when the boss hits |
| 3 | Thanksgiving: **hurt** pose | Same | `BossScene` when a girl hits |
| 4 | Thanksgiving: **defeated** pose | Same | `BossScene` win, win screen |
| 5 | **Thanksgiving dining room background** | Full screen | `BossScene` |
| 6 | Girl battle sprites, **per art girl ×3**: idle, attack, hurt, knocked out | Pixel, existing sprite size | `BossScene` lineup, party screen |
| 7 | **Type icons ×4** (Brainy, Wild, Sweet, Artsy) | Small icon | Girl profile (Tinder), party screen, boss preview card ("weak to / strong against") |
| 8 | **Crit effect** and **fumble effect** | Short animation or flash | `BossScene` on ×2 / ×0.5 hits |
| 9 | Speech bubble for barks | 9-slice panel | `BossScene` |
| 10 | HP bar (girl and boss) | 9-slice or two images | `BossScene` |
| 11 | Win screen and lose screen | Full screen or panel | End of fight |

Can reuse: a crop of #1 for the boss preview card on the calendar, and
placeholder squares for the 3 test girls.

**Note:** the boss is a full illustration and the girls are pixel sprites,
so the fight scene mixes two styles. That's a deliberate choice; check how
it looks once #1 and #6 exist.

## Writing needed

Exact list for the first build.

| Who | What | How many |
|---|---|---|
| Thanksgiving | Display name and one-line tagline for the preview card ("The whole family. Grandma has questions.") | 1 + 1 |
| Thanksgiving | Attack names shown when it hits ("Grandma's Interrogation") | 3 |
| Thanksgiving | Win line and lose line | 1 + 1 |
| Each Brainy or Sweet girl | **Crit lines** for Thanksgiving (*"she went to Yale?"*) | 3 each |
| Each Wild girl | **Fumble lines** for Thanksgiving (*"did she do cocaine in the bathroom?"*) | 3 each |
| Artsy girls | None for Thanksgiving (neutral) | 0 |
| Test girls | Generic crit lines and fumble lines shared by all test girls | 3 + 3 |
| Types | Final names and a one-line description for each | 4 |

## Systems it's part of

- **Combat**: this is the combat.
- **Run Loop**: ends each chapter; a loss ends the run.
- **Build**: the exam that grades your party, perks and stats.
