# 0047: Options are floating bubbles

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [dates.md](../design/dates.md), [plans/first-date.md](../plans/first-date.md), [0043](0043-shared-option-style.md)

## Decision

The player's options appear as bubbles that pop out from a marker above her head (`OptionsStart`), fan out, then drift slowly inside the OptionList rectangle, nudging each other apart and bouncing off its edges. A bubble stops while the mouse is over it. Click picks; dragging throws it around and drops a fading trail of its attribute icon; letting go doesn't pick. Keys 1–4 and arrow keys still work.

Bubbles have the same box options as a girl's dialogue style: flat colour and outline, or a 9-slice picture (plus an optional hover picture) with the outline kept or dropped, and a letter outline. `data/option_styles/default.tres` stays the shared look, but a girl may override it with her own **Option Style** slot.

## Why

Options coming out of her head reads as the player reacting to her, and floating, throwable bubbles make choosing feel playful instead of like a menu. Matching the dialogue box's options keeps one way of styling boxes for a non-coder to learn.

## Not chosen

A fixed list of buttons (the M2 version); dropping a bubble on her to pick it; a separate look per bubble state beyond normal and hover.

## Revisit when

Players misclick moving bubbles, or long options make bubbles too big to float comfortably.
