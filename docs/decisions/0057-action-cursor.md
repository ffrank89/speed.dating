# 0057: The action cursor (S) for stage hazards

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [0050](0050-stage-hazards.md), [0051](0051-player-cursor.md)

## Decision

On a date, **S** switches the player's cursor to the **action cursor** (the stage hazard cursor, `data/cursors/action.tres`) and back. Stage hazards marked **Needs Action Cursor** (the fly) can only be dealt with while it's on: the fly ignores the normal cursor. The action cursor switches off by itself during microgames (S moves down there) and when the date ends.

- `PlayerCursor` owns it: **Action Style**, **Action Key** (`action_cursor` in the Input Map), `action_mode`. A date's `StageHazards` says when the key works (`action_allowed`).
- Each hazard has **Dealing With It → Needs Action Cursor**; a new hazard checks `can_act()`.
- The placeholder action cursor is the Godot logo, bigger and tinted orange (a new **Tint** setting on cursors), so it can't be mistaken for the normal one.

## Why

Frank, 2026-10-21: "you should have to hit 'S' to change your cursor to shoo away the fly, call that the stage hazard cursor or action cursor."

## Not chosen

Holding S instead of pressing it to switch; blocking option bubbles while the action cursor is on.

## Revisit when

More hazards arrive (different actions might want different cursors), or players miss that S exists (a hint when a hazard appears).
