# 0069: With no one left on the dating app, going back gives the date's days back

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [the-calendar.md](../guides/the-calendar.md), [dating-app.md](../guides/dating-app.md)

## Decision

- **Picking Date still spends its 2 days at once**, like every calendar
  choice.
- **If the dating app has no one left** (everyone's in your Contacts or
  gone for the run), its **Back to the calendar** gives those days back.
  You're on the same day, with the same choices, as if you hadn't picked
  it.
- **It's a setting:** the dating app's top node → **Give Days Back** (on).
  Off = the days stay spent.
- **Underneath, `RunCalendar.give_back()`** undoes the last `spend()`: its
  days, not stats. It works once, and only if nothing else has happened
  since.

## Why

Frank, 2026-10-21: "If theres no one left to swipe on, we still lose the 2
days from the date currently."

## Not chosen

- **Spending a date's days only when the date starts**: every action that
  opens a screen would need that screen to spend its days, or they'd never
  be spent.
- **Greying out the Date choice when no one's left**: the calendar would
  need to know who's on the dating app (its **Girls** list is in the dating
  app's scene). The dating app's "No one left to swipe on." also tells the
  player why.
- **Passing on everyone**: it isn't possible. Pass goes round the same
  girls, so the app only empties when no one's left.

## Revisit when

Another screen opened from the calendar can be left without doing anything,
or the Date choice should be greyed out ahead of time.
