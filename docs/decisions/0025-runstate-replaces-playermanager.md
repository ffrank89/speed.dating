# 0025: RunState autoload replaces PlayerManager

- **Status:** Accepted, not built yet: `PlayerManager` still holds the run, trimmed to just that in [0061](0061-f5-music-and-clean-up.md)
- **Date:** 2026-10-11
- **Affects:** [core-loop.md](../design/core-loop.md)

## Decision

One autoload, RunState, holds the player, party, day, chapter and perks. Scenes read and write it and never call each other directly. Scene changes move to a separate SceneRouter.

## Why

Each module can be built and tested alone; today's PlayerManager mixes state with scene changes and re-initializes things (the perk-duplication bug).

## Not chosen

Keep and extend PlayerManager; pass state scene to scene.

## Revisit when

RunState grows into a god object; split it by area if so.
