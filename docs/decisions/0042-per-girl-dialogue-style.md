# 0042: Each girl styles her own dialogue box

- **Status:** Accepted
- **Date:** 2026-10-19
- **Affects:** [dates.md](../design/dates.md), [girls.md](../design/girls.md)

## Decision

A girl's dialogue box background, outline, font, name plate and next-arrow come from a `DialogueBoxStyle` resource linked in her GirlData. The box can be a flat colour with an outline or a stretchable picture. Anyone without a style (including the player) uses `data/dialogue_styles/default.tres`. Everything is editable in the Inspector by non-coders, with tooltips on every setting and a guide at [guides/dialogue-box.md](../guides/dialogue-box.md).

## Why

Each girl should feel distinct the moment she speaks, and artists should be able to restyle her without a programmer.

## Not chosen

A Godot `Theme` per girl (too many unrelated settings for a non-coder); one shared box for everyone.

## Revisit when

A girl needs something a style can't express (animated boxes, per-line styles).
