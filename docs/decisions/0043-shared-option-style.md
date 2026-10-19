# 0043: The player's options share one look

- **Status:** Accepted
- **Date:** 2026-10-19
- **Affects:** [dates.md](../design/dates.md)

## Decision

Choice buttons use one shared `OptionListStyle` (`data/option_styles/default.tres`) on every date, rather than each girl's style.

## Why

The options are the player's voice, so they should look the same everywhere; her box already carries her look. Keeping it a separate style file means per-girl option styles can be added later without rework.

## Not chosen

Per-girl option styles from the start.

## Revisit when

A girl's date needs options that look different (e.g. texting her on a phone).
