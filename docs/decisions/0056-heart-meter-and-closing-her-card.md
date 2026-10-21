# 0056: A heart meter on dates; the player closes her card

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [dates.md](../design/dates.md), [0052](0052-result-is-her-contact-card.md), [0053](0053-full-date-flow.md)

## Decision

**Heart meter.** In the top right of a date, one **ring per heart** she can give (her Affection Thresholds). Each ring fills as the date score climbs toward its threshold; when it's full, the **grey heart** in its middle turns to colour, pops, and the **heart sound** plays (the "you got her number" sound to start, changeable). Dropping back below a threshold greys that heart again, since hearts are counted at the end. Each girl's fill colour is her dialogue style's **Meter Color**; size, thickness, colours, the heart picture and sound are `data/heart_meter_style.tres`; one ring's design is `HeartRing.tscn` (swappable via Ring Scene). Guide: [heart-meter.md](../guides/heart-meter.md).

**Closing her card.** When she's done with the contact card, it no longer closes by itself: the **✕** (the existing X art, drawing itself in) appears on the card's corner, and the player clicks it or presses **Escape** to close the app and go back to the calendar. Contact card style → **Closing → Close By Hand** off brings back the timed close.

## Why

Frank, 2026-10-20: "Lets make it so the user has to themselves hit escape or close the app (use the 'X' icon we have) once we get her number. Also top right of the screen should show a meter that fills up. It should be a circle and for each circle completed, we get a heart! Allow this circle to be modular, the fill color should be set by the girls style. In the center is the heart, it is grey until the meter is filled. Use the same you got her number sound effect for that, but allow me to change it if i want."

## Not chosen

One ring that empties and starts again for each heart (all rings at once shows progress and hearts won together); a straight bar; the card closing on its own.

## Revisit when

Perks change the thresholds mid-date, or follow-up dates need a different meter.
