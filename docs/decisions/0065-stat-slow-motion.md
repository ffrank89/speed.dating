# 0065: A stat can slow a stage hazard down; the fly slows with Perception above 5

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [0050](0050-stage-hazards.md), [0064](0064-stats-are-data.md), [stage-hazards.md](../guides/stage-hazards.md)

## Decision

- **The fly moves in slow motion when the player's Perception is above 5**
  (6 or more). Slow motion is half speed for everything about it:
  - its flying, jitter and any animation;
  - the time it stays before giving up;
  - its buzz, which also plays an octave lower.
- **Waving at it still reads the mouse at full speed**, so a high Perception
  makes it easier to shoo.
- **Every stage hazard has this**, on its top node under **Slow Motion**:
  - **Slow Stat:** any stat file; empty means never.
  - **Slow Above:** 5.
  - **Slow Speed:** 0.5.
- **When it's checked:** each time the hazard turns up, from the date's
  stats, so the test bench's sliders count. A stat that's switched off never
  slows anything.
- **Microgames already work with stats this way:** an option's `#check` stat
  sets its microgame's difficulty.

## Why

Frank, 2026-10-21: "Different microgames can become easier / more difficult
based on your Stats already, correct? Make it so the fly moves in slow motion
if your perception is above 5. Should also affect the buzz sound effect."

## Not chosen

- Fixing Perception and 5 in the fly's code: both are settings, and any
  hazard (and any stat) can use them.
- Slowing it gradually with the stat (a little at 6, more at 9): an on/off
  threshold reads more clearly; Slow Speed can be tuned.
- Slowing the whole game (Engine time scale): it would slow her, the
  dialogue and the music too.

## Revisit when

Stats should change hazards in other ways (fewer of them, more points), or
the slow-down should grow with the stat.
