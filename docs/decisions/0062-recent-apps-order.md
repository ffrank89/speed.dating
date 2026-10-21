# 0062: The app switcher remembers the order you used apps in

- **Status:** Accepted, amended by [0068](0068-one-key-for-apps.md) (W flips through the apps instead of C and P; back is Escape or the home bar)
- **Date:** 2026-10-21
- **Affects:** [0060](0060-switching-apps.md), [the-phone.md](../guides/the-phone.md)

## Decision

Switching between open apps (Contacts **C**, Profile **P**, over the
calendar) keeps the iPhone's order of recently used apps:

- Each screen keeps a list of its open apps, most recently used first
  (`scenes/Phone/recent_apps.gd`). The screen underneath (the calendar) is
  always in it.
- **Switching with a key** makes the app you were on the most recent. The
  switcher shows the open apps as a row of cards in that order: the newest
  on the right, older ones to its left, each a little under the newer one.
  The row slides to the app's card and it grows to fill the phone. A new
  app comes in on the right.
- **Back** (the key again, Escape, the home bar) goes to the app you were
  on before without reordering, like swiping back along an iPhone's home
  bar: the app slides off to the right and the one before comes in from the
  left. Calendar → C → P, then Escape goes to Contacts, and Escape again to
  the calendar.
- The list belongs to the scene: after a date, the calendar starts a new
  one.

No new settings: the cards use **Switching Apps** in
`data/app_transition_style.tres` (card size, spacing, timings).

## Why

Frank, 2026-10-21: "Does the iphone app switching retain order of recently
used apps when switching between?" It didn't: closing always went back to
the calendar, and only two cards ever showed. "Yeah. Should look like it
does on an iphone".

## Not chosen

- Back always going to the calendar (the old way).
- Reordering on back too, so Escape would flip between the two most recent
  apps and never reach the calendar.
- Keeping the list across scenes: the apps belong to the calendar screen.

## Revisit when

More apps join the switcher, or players want to see and pick from all the
open apps at once (the iPhone's swipe-up-and-hold view).
