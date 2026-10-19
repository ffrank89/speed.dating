# 0045: Microgames are overlays on the date, built by hand

- **Status:** Accepted
- **Date:** 2026-10-19
- **Affects:** [dates.md](../design/dates.md), [plans/first-date.md](../plans/first-date.md)

## Decision

A microgame plays as an overlay on top of the date scene: the date (her, the background, the dialogue box) stays loaded underneath, and the microgame draws over it, then removes itself. The game never switches to a separate microgame scene. Frank builds the microgames himself, with Claude giving guidance rather than writing them.

## Why

Keeping the date underneath means no loading or state hand-off, and the microgame reads as a moment inside the date. Building them by hand keeps the feel of each one in the designer's hands.

## Not chosen

Changing to a separate scene per microgame and back.

## Revisit when

A microgame needs something the date scene can't keep running underneath (e.g. a full-screen 3D moment).
