# Girl Character

## Concept

- Each girl is **two objects**:
  - `GirlData`: a `.tres` resource, the same in every run, editable in the
    Godot Inspector, so **a new girl needs no code**.
  - `PartyMember`: created for *this run* when her date succeeds. It holds
    her Affection, HP and buffs.
- Girls carry **tags** (e.g. stoner, artsy, chaotic) that drive girl–girl
  synergy, and **preferences** (which attributes she likes) that drive
  player–girl synergy and date scoring.
- Each girl also has **battle stats** and a **type** (Brainy, Wild, Sweet or
  Artsy; placeholder names) that decides whether she crits or fumbles
  against each boss. She has **written lines** for those moments. No unique
  abilities in the first build (see [boss.md](boss.md)).
- Some girls **unlock** only when the player hits an attribute or perk
  threshold.
- First build: **3 girls with full art** (Split Ends, Smokey, +1) and
  **~3 art-less test girls** with tags, for testing synergy and the fight.

## Code needed

### Shared functions it uses

- `RunState.add_party_member(girl, affection)`, `RunState.break_up(member)`
- `RunState` signal `party_changed`
- `Synergy.calculate(...)` reads her tags and preferences

### Shared objects it inherits or holds

- `GirlData extends Resource`
- `PartyMember extends Resource`, holds a `GirlData` reference
- References `TagData`, `Microgame` scenes, a Dialogue Manager `.dialogue` file

### Custom objects and functions

**`GirlData` fields**

| Group | Fields | Read by |
|---|---|---|
| Identity | `id`, `display_name`, `age`, `bio`, `interests` | Tinder screen |
| Unlock | `unlock_requirement` (attribute or perk threshold, optional) | Tinder offer generator |
| Full art | `poses: Dictionary[StringName, Texture2D]`, `date_background` | Date Scene (`DatePresenter`) |
| Pixel art | `battle_sprites: SpriteFrames` (idle, attack, hurt, knocked_out) | Party panel, Boss Scene |
| Dialogue | `dialogue_style: DialogueBoxStyle` (box, outline, font, name plate), `voice: GirlVoice`, `first_date_dialogue: DialogueResource` | Date Scene (`DialogueBox`) |
| Dating | `likes_culture` … `likes_heart` (0–1), `microgames: Array[PackedScene]`, `item_reactions`, `affection_thresholds: Array[int]` | Date Scene, Synergy |
| Battle | `hp`, `attack`, `type: GirlType`, `barks` (per boss: crit and fumble lines) | Boss Scene |
| Synergy | `tags: Array[TagData]` | Synergy |

**`PartyMember` fields:** `girl: GirlData`, `affection: int (0–3)`,
`current_hp`, `buffs: Array`, `follow_ups_done: int`.

| Function | Notes |
|---|---|
| `PartyMember.battle_stat(stat, report: SynergyReport)` | Applies Affection and synergy to a base stat. |
| `PartyMember.next_follow_up()` | Which written follow-up scene is next (follow-ups are in fixed order). |
| `GirlPool.offer(count, run_state) -> Array[GirlData]` | Picks 2–3 random eligible girls: not in the party, not gone, unlock met. TBD where this lives (Calendar or its own script). |
| Ability system | Not in the first build. Later: Super Auto Pets–style triggers (start of battle, when hurt, when ally faints…). |

**Migrating:** `DateCharacter` (a `Node` with a subclass per girl, e.g.
`SmokeyCharacter`) becomes `smokey.tres` / `split_ends.tres`. Today's
`compatibility_weights` become `preferences`; `poses` and
`first_date_background` move over directly; `max_turns` and
`success_threshold` become `affection_thresholds` (and a shared turn count).

## Art needed

| Asset | Per girl | Used by | Status |
|---|---|---|---|
| Full-art poses | ~4–5 | `DatePresenter` changes pose each turn | Split Ends: 5+; Smokey: 4; girl 3: TBD |
| Date background | 1+ | Date Scene | Some exist (`picnic_bg.jpg`, `bedroom1.png`, …) |
| Profile picture | 1 | Tinder screen | TBD (could reuse a pose) |
| Pixel sprite: idle, attack, hurt, knocked out | 1 set | Boss Scene lineup, party panel | Split Ends and Smokey have one pixel sprite each, **no battle animations yet** |
| Tag icons | per tag, shared | Tinder profile, party screen, synergy panel | TBD |
| Type icons ×4 | shared | Tinder profile, party screen, boss preview | TBD (listed in [boss.md](boss.md)) |
| Test girls | none | Use coloured placeholder squares + tag label | — |

## Systems it's part of

- **Relationships**: recruit, follow-ups, break-ups.
- **Build**: tags and preferences are what you draft for.
- **Combat**: battle stats, type, barks, pixel sprite.
- **Content Pipeline**: the main thing artists and writers add.
