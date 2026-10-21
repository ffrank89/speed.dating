# 0059: The calendar shows three days, Balatro-style; the player's style decides its look

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [0055](0055-calendar-revamp.md), [0058](0058-phone-and-real-life.md)

## Decision

- **Three days at a time, stacked:** the calendar's main view is today's
  card (its 2-3 choices side by side as big bubbles with a **Pick** button)
  and the next two days, dimmed and marked **Upcoming**, showing what
  they'll offer. Like Balatro's blinds, each card's border and name tab are
  coloured by what the day is: today (blue), coming up (gold), the boss
  (red), too far ahead to see (grey, an X). **Month ▾** still opens the
  whole month as a small grid. The vertical week list is gone.
- **The player's style** (`data/player_style.tres`, a new `PlayerStyle`)
  decides the look: card and panel colours, the day colours, font,
  borders, corners, shadow and buttons. The calendar's style keeps the
  layout, words, what shows, calendar art and sounds. The default look is
  Balatro-like: dark slate cards, thick coloured borders, chunky orange
  Pick buttons.
- **Your stats are their own app, Profile:** a light first version (your
  four attributes with bars) that opens on the phone like Contacts, with
  **P** or the calendar's **Profile** button. The calendar has
  **Contacts**, **Profile** and **Month** buttons at the top.

## Why

Frank, 2026-10-21: "Calendar is very ugly." "For calendar lets show three
days at a time for the main screen so the bubbles can be bigger and we have
more freedom. Take inspiration from balatro." Answers: **Stacked**; the
look: "Player's style can decide these. Encapsulate these configs with
player style."; stats: "Should be another App scene like contacts, keep
this light for now".

## Not chosen

Three columns side by side (too narrow in the portrait phone); turning the
phone sideways for the calendar; stats in the calendar's header.

## Revisit when

A chunky or pixel font is chosen (the player's style → **Font**), the
player's style grows to cover more of the player's things (their option
bubbles, the phone), or Profile needs more than the four attributes.
