# 0052: The date's result is her filling in your Contacts

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [dates.md](../design/dates.md), [plans/first-date.md](../plans/first-date.md), [0049](0049-open-like-an-iphone-app.md)

## Decision

A date ends by opening **Contacts** like an app on an iPhone-style **New Contact** screen whose boxes use the girl's own dialogue style (box, outline or picture, font, text colour). She types her name in her font, letter by letter with key-click sounds:

- **Number At Hearts** (1) or more: she types her name, a ❤️ after it at **Heart Emoji At Hearts** (3) or more, then her phone number and address (her girl file → Contact Card), and taps Done.
- Fewer: she types her name, deletes it, and taps Cancel (a Style toggle can skip the typing).

Hearts are how many of her Affection Thresholds the date score reached (`DateScorer.hearts()`). Look, words, typing speed and sounds are in `data/contact_card_style.tres`; the thresholds in `data/date_rules.tres` → Result.

The typing sounds are Kenney CC0 stand-ins: Frank asked for iOS system sounds from GitHub, but those are Apple's sound files, so they aren't included.

## Why

"Did I get her number?" is the clearest possible result for a date, and seeing her type it (or delete it) in her own style is a payoff the player can feel. It replaces the planned hearts result card.

## Not chosen

A hearts summary card; showing the hearts count on the card; Apple's keyboard sounds.

## Revisit when

Follow-up dates need a different ending, or the run needs to show attribute gains and perks at the end of a date.
