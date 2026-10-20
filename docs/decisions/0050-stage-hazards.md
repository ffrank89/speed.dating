# 0050: Stage hazards (starting with a fly)

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [dates.md](../design/dates.md), [plans/first-date.md](../plans/first-date.md)

## Decision

Dates can have **stage hazards**: things that turn up mid-date and get in the way. Dealing with one earns a bonus (she reacts, the date score goes up by the hazard's points); if it goes away on its own, nothing happens.

- Each hazard is its own full-screen scene extending `StageHazard` (`scenes/Hazards/`), with **When** settings (after how many answers, again every N answers, delay, chance, leaves after N seconds) and **Reward** settings (points, reaction, optional pose and sound). F6 plays one on its own on a loop.
- A date lists its hazards on a `StageHazards` node, which counts answers, brings hazards on when due, and freezes them while a microgame plays. The date applies the reward.
- **The fly** follows a path picked at random from the Path2D drawings under its `Paths` node (drawn in its scene over a guide picture of the date) plus any saved Curve2D files in **Extra Paths**. It flies in from the nearest screen edge, goes back and forth (or loops, if the path is closed), and is pushed by fast mouse movement near it. Pushed off screen = cleared (+1 point, heart). Placeholder art is the Godot logo.

## Why

A small, optional skill moment between choices keeps the player's hands busy and gives her something to react to. Paths drawn in the editor and settings in the Inspector keep it tunable without code.

## Not chosen

Clicking the fly (shooing with the cursor reads better); hazards that cost points if ignored (for now); per-girl hazard lists (the date scene's list for now).

## Revisit when

Hazards need to differ per girl or per date, or ignoring one should have a cost.
