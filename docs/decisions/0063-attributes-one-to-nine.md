# 0063: The player's attributes go from 1 to 9

- **Status:** Accepted, amended by [0064](0064-stats-are-data.md) (the scale is in `data/stats.tres` now; stats start at their own Starting Value)
- **Date:** 2026-10-21
- **Affects:** [player.md](../design/player.md), [dates.md](../design/dates.md), [0016](0016-risky-attribute-checks.md), [0044](0044-date-scoring-formula.md)

## Decision

Culture, Intellect, Seduction and Heart go from **1 to 9** instead of
0–100. The scale is one file, `data/attribute_rules.tres` (**Lowest** 1,
**Highest** 9, **Default Value** 5), and everything reads it:

- **The intro's sliders** go 1–9 and start at 9 (as before, all at the top).
  Randomize picks 1–9.
- **Training** is **+1** (was +5). An attribute never goes past 1 or 9.
- **Option checks** in dialogue are 1–9: `[#check=culture:4]`. Split Ends'
  first date was divided by 10 (40 → 4, 70 → 7). A check above 9 can never
  be met, so Godot warns about it (catches old 0–100 numbers).
- **The odds** are the same formula: attribute ÷ requirement, 5–95%.
  Seduction 5 against a check of 7 is 71%.
- **Microgame difficulty** is the easiest at or above the requirement and
  the hardest at the lowest attribute (1), in a straight line between.
- **Profile's bars** are full at 9. **The date test bench's sliders** go
  1–9 and start at 5. A screen played on its own gives every attribute 5.

## Why

Frank, 2026-10-21: "Lets make the users stats 1-9 rather than 0-100. This
will make it easier to track for the user across a short run".

## Not chosen

- Keeping 0–100 inside and showing 1–9 (two scales to keep in step).
- Fixing 1–9 in code: it's a data file so the scale can be tuned.
- Changing the odds formula: it already works with small numbers.

## Revisit when

Training feels too fast or too slow at +1 a day, or a run needs more than
nine steps of growth.
