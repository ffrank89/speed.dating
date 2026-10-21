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
a point. If you stop, it flies back to its path.

## Try it

- **On its own:** open `Fly.tscn` and press **F6**. It flies over a faded
  picture of her room and her, so you can see your paths against the date.
  Press **S**, shoo it off, and it comes back a second later. The Output
  panel prints `CLEARED`.
- **In the date:** press **F5** and answer one question. A second later the
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
| It flies somewhere odd | Check the path in `Fly.tscn`. It flies in from the screen edge nearest the path's **first** point. |
| "no paths" warning | There's no Path2D under **Paths** and nothing in **Extra Paths**. |
| No reaction | The **Reaction** name must match an animation in `data/reactions.tres` exactly. |

## For programmers

- `StageHazard` (`scenes/Hazards/stage_hazard.gd`): a full-screen `Control`.
  Override `begin()`; call `clear()` (rewarded) or `leave()` (not). Also has
  `time_to_go()`, `is_due(answers)`, signals `cleared` / `left`, the **When**
  and **Reward** exports, and F6 self-play. A child named `DrawingGuide` is
  shown only when the scene is played on its own.
- `StageHazards` (`scenes/Hazards/stage_hazards.gd`): instances its
  `hazards`, counts `OptionList.option_resolved`, brings on due hazards
  after their delay, freezes them while `MicrogameHost.is_active()`, plays
  `cleared_sound`, and emits `hazard_cleared(hazard)`. The date applies the
  reward (`DateScorer.add_bonus`, `ReactionIcon.show_reaction`, the pose).
- The fly (`scenes/Hazards/Fly/fly.gd`) moves through these states:
  - ENTERING: flies in from the nearest edge
  - FOLLOWING: Path2D curves, moved into screen space, plus `extra_paths`
  - PUSHED: velocity from the mouse's motion, slowed by drag; off screen = `clear()`
  - RETURNING, then LEAVING
