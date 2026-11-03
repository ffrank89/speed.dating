# 0075: The fly no longer needs the action cursor (for now); its picture is back on it

- **Status:** Accepted
- **Date:** 2026-11-03
- **Affects:** [0057](0057-action-cursor.md), [0071](0071-fly-paths-safe-to-edit.md), [stage-hazards.md](../guides/stage-hazards.md), [cursor.md](../guides/cursor.md)

## Decision

- **The fly's Needs Action Cursor is off.** Waving the normal cursor at it
  shoos it; there's no S step. The action cursor itself is unchanged (S
  still switches it on and off during a date), and ticking Needs Action
  Cursor in `Fly.tscn` brings the S step back.
- **The fly's picture is back on the fly.** An edit had moved `Fly.tscn` →
  Body → Sprite to (-471, 183). The fly was still where the game thought it
  was, but its picture was drawn about 500 pixels away. Waving at the
  picture missed, the picture jumped across the screen whenever the fly
  turned round, and annoyance used the hidden spot. The Sprite is at (0, 0)
  again. Frank's path edits are kept as he drew them.

## Why

Frank, 2026-11-03: "the fly situation seems off, I ran through one date and
it just did not seem to be reacting to the cursor as expected. Also, lets
turn off the requirement to change your cursor for now."

A test waved the mouse through the fly. Before: waving at the picture did
nothing, with or without S; waving at the hidden spot only worked with S.
After: waving at the picture works, with or without S.
