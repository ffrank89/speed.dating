# Plan: The First Date (vertical slice)

**Goal:** one complete first date with Split Ends that looks, sounds and
feels finished: dialogue, picking options, microgames, and a result. It's
the part of the game players spend the most time in, so it's where the
game's feel gets decided.

**Not in this slice:** calendar, Tinder screen, party, boss, follow-up
dates, perks beyond a debug toggle, items. The date runs from its own test
scene with debug attributes.

## Decided for this slice

| | Decision | Record |
|---|---|---|
| Girl | **Split Ends**. She has 5 poses, including a `cig` pose for the lighter microgame. | [0041](../decisions/0041-split-ends-first.md) |
| Voice | **Letter sounds (Animalese-style)**: one short sound per letter, shared by every girl. Each girl's voice is a pitch, a variance and a speed. | [0039](../decisions/0039-animalese-voice.md) |
| Risky options | **A shown % chance.** At or above the requirement there's no roll. Below it, the button shows your odds; a hit gives the full reward, a miss loses points and gets a bad reaction. | [0040](../decisions/0040-risk-shown-chance.md) |
| Dialogue tool | **Dialogue Manager v3.10.5**, the version for Godot 4.4. (v4 needs Godot 4.6+.) | [0018](../decisions/0018-dialogue-manager-addon.md) |
| Microgames | **Light her cigarette** and **Hold eye contact**; the third is TBD. | — |

## How a first date plays

```
Opener (fixed) ─► 5 exchanges drawn at random from her pool ─► Closer ─► Result card
                      │
                      └─ each exchange: she talks (letters + voice + pose)
                                       → you pick 1 of 2–4 options
                                       → maybe a % roll, maybe a microgame
                                       → she reacts, score moves
```

- **Turns:** 5 exchanges plus the opener and closer, about 3–4 minutes.
  The current 10 turns felt long; this is tunable.
- **Score → Affection:** the end score maps to 0–3 hearts using her
  thresholds. 0 hearts on a first date means she's gone for the run.
- **Odds:** `chance = your attribute ÷ requirement`, clamped to 5–95%. At or
  above the requirement it's a sure thing (no roll). Example: Culture 25 vs
  a Culture 40 option shows **62%**.

---

## Milestones

Each milestone ends with something you can press F6 on and judge.

### M0: Setup ✅ Done (2026-10-19)

Built: Dialogue Manager v3.10.5 in `addons/` (the old `DialogueManager` class is
renamed `LegacyDialogueManager` to free the name for the addon until M4 retires
it); `scripts/data/` (`Attr`, `GirlData`, `GirlVoice`, `DateResult`);
`data/girls/split_ends.tres` using the `_updated` art (7 poses: backshot, cig,
earring, hunched, parker, point, reach); `scenes/Dates/FirstDate/FirstDateTest.tscn`.

| Code | Art | Writing / audio |
|---|---|---|
| Install Dialogue Manager **v3.10.5** in `addons/` and enable it. | none | none |
| Add `Attr` enum, a minimal `GirlData` (identity, poses, background, preferences, `voice`, `dialogue`, `microgames`, `affection_thresholds`) and `DateResult`. | | |
| Create `split_ends.tres` from `SplitEndsCharacter`. | | |
| `FirstDateTest.tscn`: starts a date with any `GirlData`, with on-screen sliders for the 4 attributes and a "restart date" button. | | |

**Done when:** F6 on `FirstDateTest.tscn` shows Split Ends and her
background, and the debug sliders change the attributes.

### M1: Dialogue box and voice ✅ Done (2026-10-19)

Built, beyond the original plan: every girl's **box, outline, font and name
plate** come from a `DialogueBoxStyle` file in her GirlData's Dialogue section
(`data/dialogue_styles/`), and a picture can replace the flat box. Fonts:
Nunito (default) and Patrick Hand (Split Ends), both OFL. 26 generated
placeholder letter sounds in `assets/audio/voice/default/`. Non-coder guide:
[docs/guides/dialogue-box.md](../guides/dialogue-box.md).
Moved to later milestones: `[#react=…]` reaction icons (M2) and the
scroll-back history log (M4).

| Code | Art | Writing / audio |
|---|---|---|
| `DialogueBox` scene built on Dialogue Manager's `DialogueLabel`: typewriter text, punctuation pauses, click or Space to finish the line, again to continue. | **Dialogue box** (9-slice panel) | **26 letter sounds**, ~0.1 s each, one per letter. Placeholder: generated tones until recorded. |
| `VoicePlayer`: listens to `DialogueLabel.spoke`, plays the letter's sound at the girl's pitch ± variance; skips spaces and punctuation. One `AudioStreamPlayer` with polyphony 4. | **Name plate** | Split Ends' voice settings: pitch, variance, speed (we tune these by ear). |
| `GirlVoice` resource: `pitch`, `pitch_variance`, `seconds_per_letter`, `volume_db`. | **"Next" arrow** (small bouncing indicator) | 3–4 test lines for her. |
| Line tags drive her: `[#pose=cig]` changes pose, `[#react=question]` shows a reaction. | **Body font** (readable; `script-VF.ttf` stays for titles) | |
| Keep `DialogueHistory` as a scroll-back log. | | |

**Done when:** her lines type out letter by letter in her voice, pause at
punctuation, can be skipped, and change her pose.

### M2: Picking options ✅ Done (2026-10-19)

Built: `OptionList` (keys 1–4, mouse, arrows; hover slide; % badge; spinning
roll that lands on HIT/MISS), `DateScorer` with tunable `data/date_rules.tres`,
`DateOption` tags (`#check=culture:40`, `#value=2`), `if hit` / `else` replies
via `DateState`, and `[#react=…]` reactions (`ReactionIcon`,
`data/reactions.tres`, moved here from M1). One shared option style
(`data/option_styles/default.tres`). Placeholders (see [replacing-placeholders.md](../guides/replacing-placeholders.md)): Intellect and
Seduction icons (Godot logo). Option sounds: Kenney Interface Sounds (CC0).
Guide: [options-and-scoring.md](../guides/options-and-scoring.md).

**Changed 2026-10-20:** options are now floating bubbles that pop out above
her head and drift; click or drop one on her to pick, drag to throw them
and drop a trail of attribute icons. Bubbles take the same box options as the dialogue box
(picture, keep/drop outline, text outline), and a girl can have her own
option style ([0047](../decisions/0047-floating-option-bubbles.md)).

| Code | Art | Writing / audio |
|---|---|---|
| `OptionList` scene: 2–4 buttons, keys 1–4 or mouse, hover lift and highlight, focus for keyboard. | **Option button**: normal, hover, pressed, disabled | Option hover tick and select click (`clickApr42025.ogg` exists) |
| Each button shows the text, the **attribute icon**, the requirement, and a **% badge** when you're below it. | **Risky variant** of the button (different tint or edge) | Roll sounds: tick, success sting, fail sting |
| On select: other buttons fade out, then the **roll plays** (a short % ticker landing on hit or miss), then she reacts. | **Attribute icons ×4**, small (Culture, Intellect, Seduction, Heart). Some stat gifs exist. | |
| `DateScorer`: the **one** score. `option value × her preference weight`, with miss penalties. Replaces `ScoreCalculator` and the date half of `DialogueManager`. | **% badge** | |
| Option tags in the dialogue file: `[#check=culture:40, #value=3]`. | Hit / miss flash | |

**Done when:** options look good, show odds honestly, the roll feels tense,
and the score moves correctly (checked with the debug sliders).

### M3: Microgames

> **How M3 is being built (2026-10-19):** Frank builds the microgames by
> hand; Claude answers questions and gives guidance but doesn't write the
> microgame code. A microgame is an **overlay on top of the date scene**
> (her, the room and the dialogue stay underneath), not a separate scene
> the game switches to. See [decision 0045](../decisions/0045-microgames-overlay-handmade.md).
>
> Settled with Frank: **Light her cigarette** first. A microgame **replaces
> the % roll** for its option (pass = hit, fail = miss; the attribute sets
> difficulty instead of odds). Each lasts **5 seconds**. **Mouse and keyboard
> both work**, for every input. The banner, timer bar and NICE/OOPS stamp
> are **one shared frame** used by every microgame, but **modular**: its look
> lives in a style file and each microgame can set its own banner text and
> length. See [decision 0046](../decisions/0046-microgame-replaces-roll.md).

| Code | Art | Writing / audio |
|---|---|---|
| `Microgame` base scene: `start(difficulty, modifiers)` in, `finished(success)` out. | **Instruction banner** ("LIGHT IT!", "EYE CONTACT!") | Banner text per microgame |
| `MicrogameHost`: dims the date, shows the banner, runs a **timer bar**, freezes, stamps **NICE / OOPS**, then returns. Difficulty comes from the attribute; Sleepy-style perks add time. | **Timer bar** | Start jingle, tick, success and fail stings |
| Each microgame runs on its own with F6. | **Success / fail stamps** | |
| **Light her cigarette**: flick the lighter (click) until it catches, then hold the flame on the cigarette tip while she sways; fill a meter before time runs out. | Lighter (`loghter.png` exists), flame animation (3–4 frames), cigarette (`cig_gif` exists), close-up of Split Ends' `cig` pose, ember glow | Lighter flick, flame, inhale |
| **Hold eye contact**: keep the cursor on her eyes for 4 s while they drift and glance away; leaving the zone drains the meter. Drifting down to her chest fails instantly (the joke). | Close-up of her face, eye target, "glance away" frames (2–3) | Heartbeat loop that speeds up |
| Microgame #3: TBD | TBD | TBD |
| Dialogue triggers one with an option tag: `[#microgame=light_cigarette]`. | | |

**Done when:** both microgames are fun in isolation, readable within half
a second of starting, and feed pass/fail into the date score.

### M4: The full date

| Code | Art | Writing / audio |
|---|---|---|
| Date flow: opener, then 5 exchanges drawn from her pool with no repeats, then a closer chosen by how it went. | **Result card**: 0–3 hearts, and "she's in" or "she's gone" | **Split Ends first-date pool** (below) |
| Hearts from `score_to_affection(score, thresholds)`; emits a `DateResult`. | Hearts: empty and full | Date music loop (pick from `assets/audio/loops`) |
| ~~Retire the old date path: `DialogueManager`, `ScoreCalculator`, the JSON dialogue, `DialogueDataUI`.~~ ✅ Done early (branch `remove-legacy-code`): the old date scene, `DatePresenter`, the old dialogue system and `ScoreCalculator` are removed; the Tinder screen now starts dates in `FirstDateTest`. | Background: pick one (`bedroom1.png` today) | |
| Hook `FirstDateTest` and the real flow (`dating_scene`) to the same date scene. | | |

**Done when:** a full date plays start to finish in about 3–4 minutes, two
playthroughs feel different, and the result is right.

### M5: Juice and tuning

- Screen shake and her pose "pop" on big reactions; a small zoom on the
  roll; a hearts fill-up at the end.
- Tune the turn count, odds clamp, scores, thresholds, microgame timings
  and voice.
- Play it 10 times. Fix whatever feels slow.

---

## Writing needed: Split Ends' first-date pool

Written in Dialogue Manager's plain-text format (`.dialogue`), one file:
`dialogue/split_ends/first_date.dialogue`.

| Piece | How many | Notes |
|---|---|---|
| **Opener** | 1 | She arrives and says hi. 1–2 lines, then 2–3 options. |
| **Exchanges** | **12** (we draw 5 per date) | Each: 1–3 of her lines, then **2–4 options**. Each option has an attribute check (`culture`, `intellect`, `seduction`, `heart` + requirement) and a value (−3 to +3). Each needs her **reply to a hit** and **reply to a miss**. |
| …of which trigger a microgame | 2–3 | e.g. she pulls out a cigarette → "Light it for her"; she gets awkward → "Hold her gaze" |
| **Closers** | 3 | Good (2–3 hearts), meh (1 heart), bad (0 hearts). |
| **Pose and reaction tags** | on every line | `[#pose=cig]`, `[#react=heart]`, so the writer directs her acting |

Her preferences (current values, change freely): Culture 0.2,
Intellect 0.3, Seduction 0.3, Heart 0.2 (from `SplitEndsCharacter`).

**Example exchange (format only, not final writing):**

```
~ boat
Split Ends: [#pose=point] Okay so my dad's boat. It has a name. Guess it.
- "The Unsinkable II" [#check=culture:30, #value=2]
	Split Ends: [#pose=reach, #react=heart] HOW did you know there was a first one
- "...Boat?" [#check=heart:10, #value=1]
	Split Ends: [#pose=parker] Honestly? Respect.
- Ask if she wants to smoke on it sometime [#check=seduction:45, #value=3, #microgame=light_cigarette]
	Split Ends: [#pose=cig] ...yeah okay. Light me up then.
=> END
```

(Exact tag spelling gets confirmed in M0 against the addon.)

> **Placeholder rule (2026-10-19):** no generated art. Missing art uses the
> Godot logo (`assets/placeholders/godot_logo.svg`) and is listed in
> [replacing-placeholders.md](../guides/replacing-placeholders.md).

## Art needed: summary

| # | Asset | Milestone | Exists? |
|---|---|---|---|
| 1 | Dialogue box (9-slice) | M1 | No |
| 2 | Name plate | M1 | No |
| 3 | "Next" arrow | M1 | No |
| 4 | Body font | M1 | No (`script-VF.ttf` for titles) |
| 5 | Option button: normal / hover / pressed / disabled | M2 | No |
| 6 | Risky option variant | M2 | No |
| 7 | Attribute icons ×4 (small) | M2 | Partly (stat gifs) |
| 8 | % badge, hit / miss flash | M2 | No |
| 9 | Microgame banner, timer bar, NICE / OOPS stamps | M3 | No |
| 10 | Lighter + flame (3–4 frames) + cigarette + ember | M3 | Lighter and cig yes; flame no |
| 11 | Split Ends close-up: lighting the cig | M3 | No (can crop the `cig` pose) |
| 12 | Split Ends close-up face + eye-glance frames | M3 | No |
| 13 | Result card + hearts (empty and full) | M4 | No |
| 14 | Split Ends poses ×5 and a background | — | **Yes** |
| 15 | Reaction icons (exclamation, question, heart, anger) | — | Mostly (heart?) |

## Audio needed: summary

| Asset | Milestone | Exists? |
|---|---|---|
| 26 letter sounds | M1 | No (generated tones as placeholder) |
| Hover tick, select click | M2 | Click yes |
| Roll tick, success sting, fail sting | M2 | No |
| Microgame jingle, lighter flick, flame, heartbeat | M3 | No |
| Date music loop | M4 | Yes (pick one) |

## Open questions

1. **Third microgame**: catch her drink, pour the drink, or something new?
2. **Letter sounds**: record them yourselves (26 short syllables in one
   voice; pitch-shifting makes each girl), or use a licensed pack?
3. **Microgame input**: mouse only, or keyboard too?
