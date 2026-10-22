# 0071: The fly's paths are safe to move, stretch and turn

- **Status:** Accepted
- **Date:** 2026-10-22
- **Affects:** [0050](0050-stage-hazards.md), [stage-hazards.md](../guides/stage-hazards.md)

## Decision

- **Each path's handle is in its middle.** Every Path2D in `Fly.tscn` now
  sits at the middle of its curve, so the cross you drag is on the path.
  Moving, stretching (Scale) and turning (Rotate) happen around the path's
  middle. Before, every handle was at the top-left corner of the screen,
  so stretching or turning a path pulled it towards that corner or swung
  it off the screen. The three paths are where they were on screen.
- **Every Path2D in the fly's scene counts**, wherever it is. **Paths** is
  just a tidy place for them. A path dragged out of it, or **Paths**
  renamed, still works. Before, a renamed **Paths** broke the fly with a
  script error, and the fly sat in the top-left corner.
- **A path it can't use is skipped, with a reason** in the Output panel:
  "Fly: path Swoop is too small (25 pixels long)…" (under 50 pixels) or
  "…is off the screen…". If no path is usable, the fly doesn't come at all,
  rather than sitting still.
- **The fly's picture in the editor** (Body) sits on the AroundHerHead path
  instead of in the top-left corner. When it plays, it always flies in
  from the edge of the screen.

## Why

Frank, 2026-10-22: "I tried editing the fly's path and it made it no longer
show up? I moved all three of the Paths around a little bit, and then i
never saw it move, it just stayed in the top left corner". Moving the paths
alone worked in a test. Shrinking them reproduced the fly buzzing in place in
the top-left corner, and dragging them out of **Paths** made it never show
up.

## Revisit when

Other hazards use drawn paths (they can use the same approach).
