# 0052: The date's result is her filling in your Contacts

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [dates.md](../design/dates.md), [plans/first-date.md](../plans/first-date.md), [0049](0049-open-like-an-iphone-app.md)

## Decision

A date ends by opening **Contacts** like an app on an iPhone-style **New Contact** screen whose boxes use the girl's own dialogue style (box, outline or picture, font, text colour). She types her name in her font, letter by letter with key-click sounds:

- **Failed** (score below her **Number Threshold**, girl file → Dating, default 0): she types "not a chance!" where her name goes and taps Cancel. No number, no info.
- **0 hearts:** her name, her **type**, then her number and address, and Done. Her **tags** say "you dont know me like that!".
- **1 heart or more:** the same with her real tags. At **Heart Emoji At Hearts** (3), a heart after her name.
- Which kinds show and how many hearts each needs is **Trait Hearts** in `data/date_rules.tres` → Result (type: 0, tag: 1). Abilities aren't listed yet, so they don't show.

Right under her name (above her number and address), her **traits** (type, tags, abilities: `GirlTrait` rows in her girl file) have empty fields from the start and pop into them one by one once her name is written (boop, boop, boop, each a little higher). Below a kind's hearts its field says "you dont know me like that!" (Secret Text in the style), and the card's middle scrolls to make room for any number of them. The heart after her name can be the emoji, a still picture or an animated icon (a SpriteFrames, e.g. `data/reactions.tres`).

Hearts are how many of her Affection Thresholds the date score reached (`DateScorer.hearts()`). Look, words, typing speed and sounds are in `data/contact_card_style.tres`; the thresholds in `data/date_rules.tres` → Result.

The typing sounds are Kenney CC0 stand-ins: Frank asked for iOS system sounds from GitHub, but those are Apple's sound files, so they aren't included.

## Why

"Did I get her number?" is the clearest possible result for a date, and seeing her type it (or delete it) in her own style is a payoff the player can feel. It replaces the planned hearts result card.

## Not chosen

A hearts summary card; showing the hearts count on the card; Apple's keyboard sounds.

## Revisit when

Follow-up dates need a different ending, or the run needs to show attribute gains and perks at the end of a date.
