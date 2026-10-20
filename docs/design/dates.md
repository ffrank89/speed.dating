# Date Scene (incl. Microgames)

## Concept

- A date is a **fixed number of turns** (10 today, to tune) that ends with
  one number: **Affection 0–3**. Affection 1+ means she joins the party; 0 on
  a first date means **she's gone for the run**.
- **Each turn:**
  1. She says a line and changes pose. Letters type out one at a time, each
     with a little sound in **her voice** (Animalese-style).
  2. You pick an option. Each option shows its attribute check. Options above
     your attributes **stay clickable but show a % chance** (Disco
     Elysium–style): hit for the full reward, miss and lose points. Perks
     can add or remove options.
  3. Some options start a **microgame**: a WarioWare-style test of a few
     seconds taken from the date itself (light her cigarette, catch her
     drink). It passes or fails.
  4. The date score moves; she reacts with a pose and a reaction icon.
- **First dates** draw short exchanges from her pool, so they're different
  each run. **Follow-ups** are written scenes in a fixed order.
- **One score.** The final score converts to Affection using her thresholds.

## Code needed

### Shared functions it uses

- `RunState.get_attribute(a)`, `RunState.perks`, `RunState.inventory`
- `RunState.apply_date_result(result)`
- `SceneRouter.go_to(:calendar)`
- Perk hooks: `modify_options`, `modify_microgame`, `modify_score`
- `Microgame.start(difficulty, modifiers)` / `finished(passed)`; `MicrogameHost.play(name, difficulty, modifiers)`

### Shared objects it inherits or holds

- `GirlData` (her lines, preferences, poses, microgames, thresholds)
- `PartyMember` (for follow-ups: current Affection, which scene is next)
- `DateResult` (output)
- Dialogue Manager addon's `DialogueResource`
- `Microgame` base scene

### Custom objects and functions

| Thing | Notes |
|---|---|
| `DateScene` (root `Control`) | Owns the turn loop. Replaces `dating_scene.gd`. |
| `DateScorer` | **Built (M2).** One score per date (`scripts/date/date_scorer.gd`): `chance_of`, `points_if_hit`, `resolve`. Points = value × (1 + her like × likes_weight); miss = −max(points × miss_penalty, min_miss_cost). Numbers in `data/date_rules.tres` (`DateRules`). Perks' `modify_score` hook still to come. |
| Odds | **Built (M2).** At or above the requirement: no roll. Below: `chance = attribute ÷ requirement`, clamped 5–95%, shown on the button. |
| `OptionList` + `DateOption` + `DateState` | **Built (M2).** Options parsed from response tags (`#check`, `#value`, `#microgame`); shown as floating bubbles (`OptionBubble`) that pop out above her head, drift, and can be dragged to drop a trail of attribute icons; dropping one on her picks it; styled by `OptionListStyle` (`data/option_styles/default.tres`, or her own **Option Style**), which has the same box options as her dialogue style; roll animation; `if hit` / `else` in dialogue via `DateState`. `ReactionIcon` plays `[#react=…]` from `data/reactions.tres`. Guide: [options-and-scoring.md](../guides/options-and-scoring.md). |
| `score_to_affection(score, thresholds) -> int` | 0–3. |
| `GirlPortrait` | **Built.** `scenes/Dates/Portrait/girl_portrait.gd`. Shows a `GirlPose` with its own scale (from her feet), offset and flip. Together with `ReactionIcon` it replaced the old `DatePresenter` (removed). |
| `DialogueHistory` | Exists (`scenes/Dates/BaseDate/dialogue_history.gd`), kept for the M4 scroll-back log. The old `DialogueOptionUI` / `DialogueDataUI` were removed: `OptionList` and `DialogueBox` replace them. |
| Dialogue Manager integration | **v3.10.5** (the Godot 4.4 version). Lines and options in `.dialogue` files. Tags: `[#pose=cig]`, `[#react=heart]` on her lines; `[#check=culture:40, #value=2, #microgame=light_cigarette]` on options. |
| `DialogueBox` + `VoicePlayer` | **Built (M1).** `scenes/Dialogue/DialogueBox.tscn`. Typewriter via the addon's `DialogueLabel`; restyles per speaker from her `DialogueBoxStyle` (box colour/outline or a 9-slice picture, font, name plate, next arrow). `VoicePlayer` plays a letter sound on each `spoke` signal. `GirlVoice`: `letter_sounds_folder`, `pitch`, `pitch_variance`, `seconds_per_letter`, `letters_per_sound`, `volume_db`. Guide: [dialogue-box.md](../guides/dialogue-box.md). |
| Microgame framework | **Built (M3 setup).** Opens like an iPhone app from the picked bubble ([0049](../decisions/0049-open-like-an-iphone-app.md)). `Microgame` base (`scenes/Microgames/microgame.gd`), `MicrogameHost` overlay (dim, banner, timer bar, NICE/OOPS stamp; look in `data/microgame_style.tres`), library `data/microgames.tres` (name → scene), `microgame_press` / `microgame_up…right` input actions and a keyboard-steerable `pointer`, F6 plays one alone on a loop. `OptionList` plays an option's microgame instead of the roll; `DateScorer.difficulty_of()` / `resolve_microgame()`. Template: `scenes/Microgames/_template/` (CATCH IT!). Guide: [making-a-microgame.md](../guides/making-a-microgame.md). |
| Microgames ×3 for v1 | Each its own scene extending `Microgame`, built by hand. **Light her cigarette** and **Hold eye contact**; the third is TBD. |
| Item reactions | Show an item → her reaction from `GirlData.item_reactions`. Flavor only in the first build. |
| Turn count | Shared constant or per date type (first vs follow-up). TBD. |

**Microgame contract**

```gdscript
class_name Microgame extends Control
signal finished(passed: bool)
func start(difficulty: float, modifiers: Dictionary) -> void  # override: set up
func win() / lose()                                          # end it
var pointer: Vector2         # mouse, or arrow keys / WASD
func is_pointing_at(node: Control) -> bool
```

`difficulty` (0–1) comes from the player's attribute against the option's
requirement (`date_rules.tres` → Microgames). `modifiers` comes from perks
(e.g. Sleepy: `{"extra_time": 1.5}`; the host already adds `extra_time` to
the timer).

## Art needed

| Asset | Used by | Status |
|---|---|---|
| Girl poses and date backgrounds | `DatePresenter` | See [girls.md](girls.md) |
| Reaction icons (exclamation, question, heart, anger…) | `DatePresenter.show_reaction` | Some exist: `exclamation point gif`, `question mark gif`, `anger icon` |
| Option buttons with attribute icon and risk tint | `DialogueOptionUI` | TBD (needs a "risky" look) |
| Score pop / Affection meter | `ScoreDisplay`, compatibility meter | Placeholder exists |
| Microgame frame: banner, timer bar, NICE/OOPS stamps (optional pictures; words and flat colours until then) | `MicrogameHost` via `data/microgame_style.tres` | Not made. Works without art. |
| Microgame art, per microgame | Each microgame scene | TBD. Cig + lighter art exist (`cig_gif`, `loghter.png`). |
| Date-end summary card (Affection hearts 0–3, gains, perks) | End of date, before returning to calendar | TBD |

## Systems it's part of

- **Skill Test**: this *is* the moment-to-moment game.
- **Relationships**: recruits girls and raises Affection.
- **Build**: earns perks and attribute gains.
- **Content Pipeline**: dialogue is written in plain text by a non-Godot writer.
