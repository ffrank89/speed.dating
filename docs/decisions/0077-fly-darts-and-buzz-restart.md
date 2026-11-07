# 0077: The fly darts about near its path, and its buzz keeps going even when it doesn't loop

- **Status:** Accepted
- **Date:** 2026-11-07
- **Affects:** [0071](0071-fly-paths-safe-to-edit.md), [0076](0076-fly-buzz-settings.md), [stage-hazards.md](../guides/stage-hazards.md)

## Decision

- **Darts.** On top of its smooth jitter (Flying → Buzz Amount / Buzz
  Speed), the fly now darts suddenly to a spot near its path every so often,
  like a real fly. The settings are on the fly's top node, under **Jerking**:
  - **Jerk Distance** (70 px): how far it darts. 0 = no darts.
  - **Jerks Per Second** (2): how often, on average. The gaps are uneven
    (0.4 to 1.6 times the average), so it doesn't look like a beat.
  - **Jerk Seconds** (0.06): how long each dart takes. Lower = snappier.
- Darts only move the drawn fly. Shooing still measures the mouse against
  the point on the path, so darts don't make it harder to reach. Annoying
  her checks where the fly is drawn, so a dart can carry it on or off her.
- In slow motion, darts slow down with everything else.
- **Buzz restart.** When the buzz recording ends and the fly is still
  around, the fly plays it again. A recording imported without looping
  (a GarageBand .wav comes in as "Detect From WAV") no longer goes silent;
  you hear a tiny gap each time instead. Setting the import's **Loop Mode**
  to **Forward** removes the gap. The guide has the steps.

## Why

Frank, 2026-11-07: "I think the fly needs to jerk around a little more on
its path and The audio seems to stop after some time". After seeing the
tested change: "Implement".

## Not chosen

- More jitter (raising Buzz Amount): it's a smooth wobble, so more of it
  looks floatier, not jerkier.
- Making the buzz loop from the fly's script: whether a recording loops is
  set when it's imported. The fly only covers for a recording that doesn't.
