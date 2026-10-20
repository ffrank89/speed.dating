# 0051: The player's cursor is a swappable style

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [core-loop.md](../design/core-loop.md)

## Decision

The game shows its own cursor everywhere, from a `CursorStyle` file in `data/cursors/` (`default.tres` unless code switches with `PlayerCursor.use(style)`). A style has a picture, a hotspot and a size, optional hover, pressed and drag pictures, and a choice between the computer's own cursor (no lag, at most 256 × 256) and one drawn by the game (any size, squishes on click). The placeholder is the Godot logo.

Frank asked for the Toontown cursor as the default. It isn't included because it's Disney's art; a self-drawn glove or Kenney's CC0 Cursor Pack hands are the suggested replacements.

## Why

The cursor is the player's hand in the game: it shoos the fly, drags bubbles and taps apps, so it should have character and be easy to swap per character or perk later.

## Not chosen

Shipping the Toontown cursor; only a system cursor (no squish or large sizes); only a drawn cursor (a frame of lag).

## Revisit when

Player characters become data with their own look: give each one a cursor style.
