# Girl Character

## Concept

- Each girl is **two objects**:
  - `GirlData`: a `.tres` resource, the same in every run, editable in the
    Godot Inspector, so **a new girl needs no code**.
  - `PartyMember`: created for *this run* when her date succeeds (she's
    saved in your Contacts). It holds her Affection, HP and buffs.
- Girls carry **tags** (e.g. stoner, artsy, chaotic) that drive girl–girl
  synergy, and **preferences** (which stats she likes) that drive
  player–girl synergy and date scoring.
- Each girl also has **battle stats** and a **type** (Brainy, Wild, Sweet or
  Artsy; placeholder names) that decides whether she crits or fumbles
  against each boss. She has **written lines** for those moments. No unique
  abilities in the first build (see [boss.md](boss.md)).
- Some girls **unlock** only when the player hits a stat or perk
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
| Identity | **Built:** `id`, `display_name`, `age`, `bio`, `interests`, `profile_picture: SpriteFrames` | The dating app |
| Unlock | `unlock_requirement` (stat or perk threshold, optional) | Tinder offer generator |
| Full art | `poses: Dictionary[String, GirlPose]` (each: `image`, `scale`, `offset`, `flip`), `default_pose`, `date_background` | Date Scene (`GirlPortrait`) |
| Pixel art | `battle_sprites: SpriteFrames` (idle, attack, hurt, knocked_out) | Party panel, Boss Scene |
| Dialogue | `dialogue_style: DialogueBoxStyle` (box, outline, font, name plate), `voice: GirlVoice`, `first_date_dialogue: DialogueResource` | Date Scene (`DialogueBox`) |
| Dating | **Built:** `likes: Dictionary[PlayerStat, float]` (0–1 per stat; unlisted = 0), `microgames: Array[PackedScene]`, `item_reactions`, `affection_thresholds: Array[int]` | Date Scene, Synergy |
| Battle | `hp`, `attack`, `type: GirlType`, `barks` (per boss: crit and fumble lines) | Boss Scene |
| Synergy | `tags: Array[TagData]` | Synergy |
| Contact card | **Built:** `phone_number`, `address`, optional `contact_photo`, `traits: Array[GirlTrait]` (kind, title, description, icon; placeholder until tags and type exist as data) | End-of-date contact card ([result-screen.md](../guides/result-screen.md)) |

**`PartyMember` fields:** `girl: GirlData`, `affection: int (0–3)`,
`current_hp`, `buffs: Array`, `follow_ups_done: int`. **Started**
(`scripts/data/party_member.gd`): `girl` and `affection`. Each one is a contact in your phone's Contacts app
([contacts.md](../guides/contacts.md)).

| Function | Notes |
|---|---|
| `PartyMember.battle_stat(stat, report: SynergyReport)` | Applies Affection and synergy to a base stat. |
| `PartyMember.next_follow_up()` | Which written follow-up scene is next (follow-ups are in fixed order). |
| `GirlPool.offer(count, run_state) -> Array[GirlData]` | Picks 2–3 random eligible girls: not in the party, not gone, unlock met. TBD where this lives (Calendar or its own script). |
| Ability system | Not in the first build. Later: Super Auto Pets–style triggers (start of battle, when hurt, when ally faints…). |

**Done (2026-10-21, [0061](../decisions/0061-f5-music-and-clean-up.md)):**
the old `DateCharacter` classes (one per girl) are gone. Everything about a
girl is her girl file: `data/girls/split_ends.tres` and
`data/girls/smokey.tres`. Her dating-app profile (age, bio, interests,
**Profile Picture**) is in **Identity**; the dating app lists girl files in
its **Girls**. Smokey has her profile, poses and background but no first
date yet, so the dating app hides her.

## Art needed

| Asset | Per girl | Used by | Status |
|---|---|---|---|
| Full-art poses | ~4–5 | `GirlPortrait`, changed by `[#pose=...]` in her lines | Split Ends: 7; Smokey: 4 (`assets/green_girl/`); girl 3: TBD |
| Date background | 1+ | Date Scene | Some exist (`picnic_bg.jpg`, `bedroom1.png`, …) |
| Profile picture | 1 | The dating app (**Profile Picture**) | Split Ends and Smokey: their animated pixel sprites |
| Pixel sprite: idle, attack, hurt, knocked out | 1 set | Boss Scene lineup, party panel | Split Ends and Smokey have one pixel sprite each, **no battle animations yet** |
| Tag icons | per tag, shared | Tinder profile, party screen, synergy panel | TBD |
| Type icons ×4 | shared | Tinder profile, party screen, boss preview | TBD (listed in [boss.md](boss.md)) |
| Test girls | none | Use coloured placeholder squares + tag label | — |

## Systems it's part of

- **Relationships**: recruit, follow-ups, break-ups.
- **Build**: tags and preferences are what you draft for.
- **Combat**: battle stats, type, barks, pixel sprite.
- **Content Pipeline**: the main thing artists and writers add.
