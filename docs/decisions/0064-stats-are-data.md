# 0064: Stats are data: the first four plus S.P.E.C.I.A.L., each switchable on or off

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [player.md](../design/player.md), [0063](0063-attributes-one-to-nine.md), [0044](0044-date-scoring-formula.md)

## Decision

The player has **stats**, and only stats: nothing else goes up or down.
Every stat is a data file, so sets of stats can be tried out:

- **One file per stat** (`data/stats/`): id, name, **Enabled**, description,
  icon, starting value (5).
- **One list** (`data/stats.tres`): every stat in order, and the scale,
  **1 to 9** (moved here from `data/attribute_rules.tres`, which is gone).
- **The stats now:** the first four (Culture, Intellect, Seduction, Heart)
  and Fallout: New Vegas's S.P.E.C.I.A.L. (Strength, Perception, Endurance,
  Charisma, Intelligence, Agility, Luck). All on. They share the 1–9 scale
  (SPECIAL's own goes to 10).
- **A stat that's off is gone everywhere**, and everything that uses stats
  reads the list:
  - **Profile:** one movable list, `scenes/Stats/StatBars.tscn`.
  - **The intro and the date test bench:** a slider per stat.
  - **Training:** a calendar action's **Stats** (stat file → amount).
  - **Dialogue checks:** `[#check=strength:5]`.
  - **Her Likes:** stat file → 0–1; a stat she doesn't list is 0.
- **Defaults:** each stat starts at its own Starting Value (5); the intro's
  sliders start there too (they started at 9 before). The fixed `Attr` code
  for the first four, and the per-stat icon slots in the option style, are
  gone: each stat has its own icon.

## Why

Frank, 2026-10-21: "Add the slate of character skills from new vegas to the
player character stats and allow me to enable or disable them. Im not sure
what i want to do with that yet so lets make it modular and easy to move
around." That was first built as New Vegas's 13 *skills*, separate from the
stats. Frank: "Sorry didnt mean new vegas skills, but meant SPECIAL stats!"
and "Skills are not supposed to be different from Stats. A player character
can only increase or decrease his Stats - no such thing as Skills. I wanted
you to add the SPECIAL Stats from fallout new vegas and make them modular so
i could try out different Stats / see what makes sense." The skills were
removed before they were merged.

## Not chosen

- Skills, or any second kind of number next to stats.
- Keeping the first four fixed in code and only SPECIAL as data: then
  trying a set without Culture (say) would need code.
- A 1–10 scale for SPECIAL only: one scale for every stat is easier to read.

## Revisit when

The set is decided (some stats switched off for good, or merged: Intellect
and Intelligence overlap), or stats need groups (e.g. separate headings in
Profile).
