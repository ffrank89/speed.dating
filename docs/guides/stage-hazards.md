# Stage hazards (the fly, and friends)

For designers and artists. **No code needed** to tune a hazard, draw its
paths or put it in a date.

A **stage hazard** is something that turns up during a date and gets in the
way, like a fly buzzing around her. If the player deals with it, **she
reacts and the date earns points**. If it goes away on its own, nothing
happens. Each hazard is its own scene in `scenes/Hazards/`, and a date lists
the ones it can have.

The first one is the **fly** (`scenes/Hazards/Fly/Fly.tscn`). It flies in from
the edge of the screen and buzzes along a path you drew. Press **S** to
switch to the **action cursor**, then **wave it at the fly** to shoo it
([the cursor guide](cursor.md)). Shoo it **off the screen**, and she reacts and the date gets
a point. If you stop, it flies back to its path. If it sits on her for a
second, she says ".....ew" and the date loses a point (below).

## Try it

- **On its own:** open `Fly.tscn` and press **F6**. It flies over a faded
  picture of her room and her, so you can see your paths against the date.
  Press **S**, shoo it off, and it comes back a second later. The Output
  panel prints `CLEARED`.
- **In the date:** press **F6** on the date test bench
  (`scenes/Dates/FirstDate/FirstDateTest.tscn`) and answer one question. A second later the
  fly turns up. Press **S** and shoo it off: the score goes up by 1 and she
  shows a heart.
  The debug panel's **Stage hazards now** button brings it on at once.

## Needing the action cursor

Each hazard's top node → **Dealing With It → Needs Action Cursor**: on (the
fly) = the player has to press **S** first; off = the normal cursor works.
A new hazard checks `can_act()` before letting the player deal with it.

## When it turns up

Open `Fly.tscn`, click the top node (**Fly**), and look under **When**:

| Setting | Now | What it does |
|---|---|---|
| **Appears After Answers** | 1 | It turns up after the player has answered this many questions |
| **Again Every Answers** | 0 | Then again every this many answers. 0 = once per date. |
| **Delay Seconds** | 1.0 | The wait between that answer and it turning up |
| **Chance** | 1.0 | 1 = always when it's due, 0.5 = half the time |
| **Leaves After Seconds** | 0 | It gives up and flies away after this long (no reward). 0 = it stays until shooed. |

## Drawing its paths

Every **Path2D** under **Paths** in `Fly.tscn` is one path. Each time the fly
turns up, it **picks one at random**. It flies in from the nearest edge of the
screen to the path's first point, then follows the path **back and forth**. If
the path's last point sits on its first, it goes **round and round** instead.

There are three to start with:

| Path | What it does |
|---|---|
| **AroundHerHead** | A loop around her face |
| **Swoop** | Over her head, from left to right and back |
| **Zigzag** | Across the top of the room |

The faded room and Split Ends behind them (**DrawingGuide**) show you where
things are on the date screen. They're hidden during the date.

**Change a path:** open `Fly.tscn` → click a path (e.g. **Swoop**) under
**Paths**. Its points show in the 2D view, with the **Path2D toolbar** above
the view:

- **Select Points:** drag points to move them.
- **Select Control Points:** drag a point's handles to bend the curve.
- **Add Point:** click to add points to the end.
- **Delete Point:** click a point to remove it.
- **Close Curve:** joins the end to the start, making a loop.

**Add a path:** click **Swoop** and press **Ctrl+D** to duplicate it. Rename
the copy and reshape it. Or right-click **Paths** → **Add Child Node** →
**Path2D**, then in the Inspector set **Curve** → **New Curve2D** and add
points with **Add Point**.

**Remove a path:** delete its Path2D. The fly needs at least one.

**Save a path to reuse it** (e.g. in another fly): click the Path2D → in the
Inspector, click the arrow next to **Curve** → **Save As…** → for example
`data/hazards/fly_paths/swoop.tres`. Then drag that file into another fly's
**Flying → Extra Paths** list. That list is added to its drawn paths.

## How it flies and how hard it is to shoo

Click **Fly** (the top node):

| Setting | Now | What it does |
|---|---|---|
| **Flying → Speed** | 420 | How fast it flies along its path (pixels per second) |
| **Flying → Buzz Amount / Buzz Speed** | 22 / 11 | How much and how fast it jitters off the path |
| **Shooing → Shoo Radius** | 260 | How close the mouse must come to push it |
| **Shooing → Min Wave Speed** | 500 | The mouse must be moving at least this fast (a wave, not a hover) |
| **Shooing → Shoo Strength** | 1.4 | How hard a wave pushes it. **Higher = easier.** |
| **Shooing → Air Drag** | 2.2 | How fast it slows after a push. **Higher = harder** to get off screen. |
| **Shooing → Comeback Delay / Comeback Speed** | 0.5 / 700 | How long it stays dazed, then how fast it flies back to its path |
| **Shooing → Off Screen Margin** | 60 | How far past the edge counts as "off screen" |

## Slow motion: Perception

**With Perception above 5, the fly moves in slow motion.** It flies,
jitters, flaps and buzzes at half speed (the buzz an octave lower), and
stays twice as long before it gives up. Waving at it still reads the mouse
at full speed, so it's easier to catch.

Every hazard has this, on its top node → **Slow Motion**:

| Setting | Fly | What it does |
|---|---|---|
| **Slow Stat** | `data/stats/perception.tres` | The stat that slows it. Drag in any stat file to use another (e.g. Agility). Empty = never slowed |
| **Slow Above** | 5 | It's slowed when the player's stat is above this (5 = at 6 or more) |
| **Slow Speed** | 0.5 | How fast it goes in slow motion: 0.5 = half speed. 1 = no change |

It checks the stat each time it turns up, from the date's stats: on the
test bench, drag the **Perception** slider to 6 or more and press **Stage
hazards now**. If the stat is switched off ([stats.md](stats.md)), it's never
slowed. The fly has no buzz sound yet; once one is set, it slows down too.

## Annoying her: the fly sitting on her

**If the fly stays on her for a second, she's annoyed.** The date stops for
a moment: her dialogue and the option bubbles freeze and her dialogue box
grays out, she **turns around** (her **backshot** pose), shows the **anger**
reaction and says **".....ew"** in a little bubble by her head (in her own
box style and voice), and the date loses **1 point** (the heart meter
drains). Then the date carries on: she turns back and her box comes back. "On her" means her drawn pixels,
not the see-through space around her, and it has to stay there the whole
second: moving off her starts the count again. Shoo it before then.

Every hazard has this, on its top node → **Annoying Her**:

| Setting | Fly | What it does |
|---|---|---|
| **Annoy Seconds** | 1 | How long it has to stay on her. 0 = it never annoys her |
| **Annoy Limit** | 1 | How many times it can annoy her each time it turns up |
| **Annoy Points** | 1 | Points taken off the date score |
| **Annoy Reaction** | anger | Her reaction (a name in `data/reactions.tres`). Empty = none |
| **Annoy Line** | .....ew | What she says in the bubble. Empty = nothing |
| **Annoy Pose** | backshot | A pose she switches to (a pose name from her girl file; Split Ends' **backshot** is her turned away). A girl without that pose stays as she is. Empty = no change |
| **Annoy Pose Back** | on | She turns back to the pose she had when the date carries on. Off = she stays in Annoy Pose until a line changes it |
| **Annoy Pause Seconds** | 1 | How long the date stops (at least as long as her line takes to type) |

**Her box graying out:** click the top node of `scenes/Dates/Date/Date.tscn`
(**Date**) → **When She's Annoyed** → **Annoyed Box Color** (grey now; white
= no change) and how fast it fades.

**Her bubble** is the date's **Bark** node (`scenes/Dates/Date/Date.tscn` →
**Bark**, a `scenes/Dates/Bark/Bark.tscn`): move or resize it to change where
it appears (the bubble sits at its bottom, centred). Click it for how fast
her line types (**Seconds Per Letter**), how long it stays up (**Seconds
Shown**), the size of her words (0 = her style's) and the pop.

**Try it:** on the date test bench, press **Stage hazards now** and leave
the fly alone until it drifts over her (the **AroundHerHead** path goes
past her face).

## What shooing it earns

Under **Reward**:

| Setting | Now | What it does |
|---|---|---|
| **Points** | 1 | Added to the date score |
| **Reaction** | heart | Her reaction: a name from `data/reactions.tres` (exclamation, question, anger, heart). Empty = none. |
| **Pose** | (empty) | Optional pose she switches to, e.g. `point`. Empty = no change. |
| **Cleared Sound** | (empty) | Optional sound when it's shooed off |

## Art and sound

| What | Now | Where to change it |
|---|---|---|
| The fly | The **Godot logo** (placeholder) | `Fly.tscn` → **Body → Sprite** → **Texture**. Swap Sprite for an **AnimatedSprite2D** for wing flaps. Draw it facing right; it flips itself. |
| Buzz loop | none | **Fly → Sounds → Buzz Sound** (set the file to loop when you import it) |

## Putting hazards in a date

The date scene (`scenes/Dates/Date/Date.tscn`) has a **StageHazards** node. Its **Hazards** list holds the
hazard scenes this date can have (the fly now). Add more by dragging their
`.tscn` files into the list. Hazards freeze while a microgame plays.

**A second kind of fly** (faster, other paths): duplicate `Fly.tscn`,
change its settings and paths, and add it to **Hazards**. It uses the same
script, so nothing else is needed.

## Something's wrong

| Problem | Fix |
|---|---|
| It never turns up | Check **Appears After Answers** against how many questions the dialogue has, and **Chance**. Or use the **Stage hazards now** button. |
| Waving does nothing | Move faster than **Min Wave Speed** and come within **Shoo Radius**. Or raise **Shoo Strength**. |
| It's too easy to shoo off | Raise **Air Drag** or lower **Shoo Strength**. |
| It never annoys her | Its **Annoy Seconds** is 0, it never stays on her drawn pixels for that long without a break, or it already annoyed her **Annoy Limit** times this time. |
| It annoys her too easily | Raise **Annoy Seconds**. |
| It's in slow motion when it shouldn't be (or isn't when it should) | The player's **Slow Stat** (Perception) has to be *above* **Slow Above**: 6 or more for 5. On the test bench it's the slider. |
| It flies somewhere odd | Check the path in `Fly.tscn`. It flies in from the screen edge nearest the path's **first** point. |
| "no paths" warning | There's no Path2D under **Paths** and nothing in **Extra Paths**. |
| No reaction | The **Reaction** name must match an animation in `data/reactions.tres` exactly. |

## For programmers

- `StageHazard` (`scenes/Hazards/stage_hazard.gd`): a full-screen `Control`.
  Override `begin()`; call `clear()` (rewarded) or `leave()` (not). Also has
  `time_to_go()`, `is_due(answers)`, signals `cleared` / `left`, the **When**,
  **Slow Motion** and **Reward** exports, and F6 self-play. Slow Motion:
  `stats` (the date's, stat id → value; set by `StageHazards`), `time_scale`
  (set on `appear()`: Slow Speed or 1; Leaves After Seconds is divided by it),
  `is_slowed()`. A hazard multiplies its own timing by `time_scale`.
  Annoying Her: `her` (the date's `GirlPortrait`, set by `StageHazards`),
  `track_annoying(point, real_delta)` (call each frame; uses
  `GirlPortrait.is_point_on_her()`), signal `annoyed(hazard)`. A child named `DrawingGuide` is
  shown only when the scene is played on its own.
- `StageHazards` (`scenes/Hazards/stage_hazards.gd`): instances its
  `hazards`, counts `OptionList.option_resolved`, brings on due hazards
  after their delay, freezes them while `MicrogameHost.is_active()`, plays
  `cleared_sound`, and emits `hazard_cleared(hazard)` and
  `hazard_annoyed(hazard)`. Its `stats` (from `DateScene.stats`) go to each
  hazard as it turns up; its `portrait` to each hazard's `her`.
- `DateScene._on_hazard_annoyed(hazard)`: sets `DialogueBox` and `OptionList`
  to `PROCESS_MODE_DISABLED`, shows the reaction and pose, `await
  bark.say(line, girl)`, `scorer.add_bonus(-annoy_points)`, waits out
  `annoy_pause_seconds`, then lets them run again.
- `Bark` (`scenes/Dates/Bark/bark.gd`): `say(text, girl)` (her
  `DialogueBoxStyle` box and font, her `GirlVoice` via a `VoicePlayer`). The date applies the
  reward (`DateScorer.add_bonus`, `ReactionIcon.show_reaction`, the pose).
- The fly (`scenes/Hazards/Fly/fly.gd`) moves through these states:
  - ENTERING: flies in from the nearest edge
  - FOLLOWING: Path2D curves, moved into screen space, plus `extra_paths`
  - PUSHED: velocity from the mouse's motion, slowed by drag; off screen = `clear()`
  - RETURNING, then LEAVING
  - Its `_process` runs on `delta × time_scale` (the mouse on real time);
    `begin()` sets the buzz's `pitch_scale` and any AnimatedSprite2D /
    AnimationPlayer `speed_scale` under Body to `time_scale`.
