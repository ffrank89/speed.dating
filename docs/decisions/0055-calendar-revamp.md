# 0055: The calendar: a chapter strip in dialogue-box style, and today's choices

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [calendar.md](../design/calendar.md), [core-loop.md](../design/core-loop.md), [0037](0037-phone-app-overlays.md), [0054](0054-party-is-your-contacts.md)

## Decision

The calendar is rebuilt (`scenes/Calendar/calendar.tscn`), drawn in **its own dialogue-box style** (`data/dialogue_styles/calendar.tres`, the same settings as a girl's dialogue box) so it matches the dialogue boxes.

- **Layout:** the top box is this **chapter** (7 days): each day a box with its weekday on a name tab, what it offers, today highlighted, days gone faded, the boss on the last day. **"See the whole month"** opens up the rest of the calendar (28 days); every day past this chapter shows an **X**. `Foresight Days` (`data/calendar_rules.tres`) is how far past the chapter you can see: 0 now, for a future "see into the future" ability (next week's options, the next boss).
- **Choosing:** each day offers **2–3 actions**, drawn at random per run by weight from `data/day_actions/`. Pick one (click, or 1–3) and it uses up its days: a **date** (2 days) opens the dating app; **training** (1 day) raises an attribute by 5; **rest** (1 day) passes; the **boss** is fixed on the last day. Something that doesn't fit before the boss day is greyed out.
- **Scope of this pass:** the look and the run's structure. Training, rest and the boss day are placeholders (a line from `dialogue/calendar.dialogue` in the calendar's box); the boss day starts the next chapter until the boss exists.
- **Modular** (Frank: "Ensure this is very modular. Remove the numbers from the dates"): days show **no numbers**, just the weekday (Show Day Numbers brings them back); one day and one choice are their own scenes (`DayBox.tscn`, `DayChoice.tscn`) that the calendar's **Day Scene** / **Choice Scene** slots can swap; actions are **made of parts** (days, attribute changes, a message, ends the chapter, opens a screen) instead of fixed kinds, so a new action needs no code; the style's words use named blanks (`{weekday}`, `{days}`…) and every part can be switched off (What Shows).
- **Bigger** (Frank: "Make the calendar bigger and the icons bigger within the squares. Remove the BOSS caption. Remove the chapter 1 blurb."): days 330×300 (300×250 in the whole month), pictures 84 / 150; the CHAPTER tab and the BOSS caption are off (switches in What Shows). The calendar can take **its own art** (Calendar Art: a Page Image the days sit on, a Day Image for each day, with margins that don't stretch and padding), to be drawn later like the iPhone frame, plus a Background Image behind the screen. `scenes/Calendar/CalendarTest.tscn` flips through pictures for the page, the days and the scene (Frank: "I meant test the calendar object itself with different backgrounds. At some point i intend to update this like we will the iphone").
- The run starts on the calendar (after the intro). The run's calendar is a `RunCalendar` kept on `PlayerManager`; the old `current_day` / `calendar_action()` and the hand-placed 30-day grid are gone.

## Why

Frank, 2026-10-20: "I think the calendar needs a big revamp before anything else. I propose we keep that in line with the dialogue boxes stylistically." Answers: a chapter strip, "with the rest of the calendar expandable but with x's in their days for now. I.e imagine if the player got an ability to see into the future and can see what his options are for the next week or what the boss may be"; pick today's action; look + run structure; its own style file.

## Not chosen

A month grid as the main view; one day at a time (Persona-style); a fixed schedule; clicking any upcoming day; restyling the old calendar only; a real training screen and events in this pass.

## Revisit when

Follow-up dates, events (perks and items), the training screen or the boss fight are built, or a foresight ability exists.

## Note (2026-10-21)

The layout changed again: three day cards stacked, Balatro-style, with the look in the player's style ([0059](0059-three-day-calendar.md)).
