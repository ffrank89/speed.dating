# 0058: On your phone, or in real life

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [0049](0049-open-like-an-iphone-app.md), [0045](0045-microgames-overlay-handmade.md), [0052](0052-result-is-her-contact-card.md), [0054](0054-party-is-your-contacts.md), [0055](0055-calendar-revamp.md)

## Decision

Every screen is either **on your phone** or **real life**:

| On your phone | Real life |
|---|---|
| The intro, the dating app, the calendar, Contacts, her contact card, microgames | Dates, boss fights, stage hazards |

- **One phone for every phone screen:** a portrait phone (1000 × 1600) in
  the middle of the screen, with a status bar and a home bar, and **your
  room, dimmed** behind it. Its look (size, colours, rim, phone art,
  wallpaper, font, room, how it comes up and goes down) is one file,
  `data/phone_style.tres`; the phone is one scene,
  `scenes/Phone/PhoneScreen.tscn`, that every phone screen is built on.
  Each scene can still use its own room or wallpaper.
- **Apps open inside the phone:** the open-app animation (0049) now grows
  into the phone's screen (`data/app_transition_style.tres` → **Open Into
  Phone**).
- **Phone down / phone up:** starting a date puts the phone down (it drops
  away and the date is there); the end of a date brings it back up with her
  contact card; the calendar then opens on it. Microgames bring the phone up
  over the date, play on its screen, and put it down again.
- **Portrait for all:** the calendar is a vertical week list with today's
  choices below and a small month grid when opened; the dating app is a
  profile card with Pass / Start; the intro is a "Your Profile" app.
- Each app keeps its own style file (calendar, dating app, contact card,
  microgames); the phone's own words use the phone's font.

## Why

Frank, 2026-10-21: "Lets consider when we are on Tinder / Contacts /
Calendar that the player is On Their Phone. When they are on their phone the
screen should look like an App, very much like the Contacts scene is."
Answers: portrait for all; your room, dimmed, behind the phone; microgames
inside the phone screen with the date visible around it; phone down / phone
up between them. "Ensure these changes retain their modular nature of this
project. If we want to change the phone / phones background / fonts / etc."

## Consequences

- A microgame's play area is the phone's screen (964 × 1414, portrait), not
  the whole 3000 × 1700 screen. The template was refitted; Light Her
  Cigarette (being built by hand) needs laying out for the tall screen.
- The contact card's Sheet settings (screen colour, corners, dim, the
  phone's font) moved to the phone style. The calendar's Background
  settings are gone (the room behind the phone replaces them).
- `data/apps/date.tres` and `boss.tres` are no longer opened as apps.

## Not chosen

Landscape phone for the calendar; the phone hidden at the edge of the
screen; microgames full screen with the phone only for apps; a quick fade
between phone and real life.

## Revisit when

The real phone art arrives (fit **Phone Size** and **Edge Width** to it), or
a screen needs to be wider than the phone.
