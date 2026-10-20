# 0048: How the microgame framework works

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [dates.md](../design/dates.md), [plans/first-date.md](../plans/first-date.md), [0045](0045-microgames-overlay-handmade.md), [0046](0046-microgame-replaces-roll.md)

## Decision

- **Lookup by a library file.** `data/microgames.tres` maps the name writers use (`[#microgame=light_cigarette]`) to a scene, edited like her poses. An unknown name warns and falls back to the roll.
- **Difficulty from the check.** 0–1, from `min_difficulty` (meets the requirement, 0.2) rising in a straight line to `max_difficulty` (none of the attribute, 1.0); `unchecked_difficulty` (0.5) when there's no `#check`. All in `data/date_rules.tres`. Each microgame decides what difficulty changes.
- **One frame, drawn by the host.** `MicrogameHost` (a CanvasLayer in the date scene) dims the date, shows the microgame, a banner while the game is frozen (0.8 s), then the timer bar, and a NICE/OOPS stamp after. Look in `data/microgame_style.tres`; positions in `MicrogameHost.tscn`; banner words and length per microgame.
- **Mouse and keyboard for free.** The `microgame_press` action is Space, Enter and left click; `pointer` follows the mouse and the arrow keys / WASD steer it. Microgames use these instead of raw mouse or key checks.
- **F6 plays a microgame alone, on a loop**, at its own Test Difficulty.
- **Microgame options show a PLAY badge** instead of a % chance.

## Why

Frank asked for everything around the microgames to be ready so building one is only the game itself. A library file and Inspector settings keep it editable without code; shared input rules make "mouse and keyboard both work" true by default.

## Not chosen

Finding microgames by folder name (invisible, easy to break by renaming); each microgame drawing its own timer and banner; showing a % on microgame options.

## Revisit when

A microgame needs input the shared actions can't express, or difficulty needs a curve rather than a straight line.
