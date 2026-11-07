# 0078: The lighter microgame, "LIGHT IT!": spam clicks to flick, each flick has a chance to catch

- **Status:** Accepted
- **Date:** 2026-11-07
- **Affects:** [making-a-microgame.md](../guides/making-a-microgame.md)

## Decision

Built from Frank's design, with the artist's hand and flame frames.

- **`scenes/Microgames/lighter/LightCigarette.tscn`** (script
  `light_cigarette.gd`). The template files in that folder were renamed to
  it, so it keeps their place.
- **How it plays:** each click (or Space) is one flick. The hand plays its
  flick animation (Rhand1–8) from the start, and the flick may catch. When
  it catches, the flame (fire1–4) burns for a moment and you win. If time
  runs out first, you lose.
- **Difficulty sets the chance per flick**, on the scene's top node:
  - **Easiest Chance** (0.3 = 30%) at the easiest difficulty.
  - **Hardest Chance** (0.1 = 10%) at the hardest.
  - In between, it's part way between the two.
- **Flame Seconds** (0.6): how long the flame burns before the win counts.
  The game freezes the moment you win, so the flame plays first. It never
  waits past the timer.
- **In the game:** it's in the microgame library (`data/microgames.tres`)
  as `light_cigarette`, so a dialogue option can start it by that name.
- The left-hand frames (Lhand) aren't used yet.
- These numbers are starting points for Frank to tune; the game design is
  his.

## Why

Frank, 2026-11-07: "this is what I have in mind for the lighter microgame
at a base level: spam clicks to attempt lighter flicks. If the lighter
lights you win. Lighter flick animation has been added in the latest artist
push. When you have lit the flame animation runs. Can tweak chance of light
with difficulty." After seeing the tested change: "Implement".

## Not chosen

- A new folder and scene next to the template: the template in
  `lighter/` was already meant to become this game.
