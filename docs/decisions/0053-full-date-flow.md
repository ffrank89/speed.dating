# 0053: How a full first date runs, and what happens after

- **Status:** Accepted
- **Date:** 2026-10-20
- **Affects:** [dates.md](../design/dates.md), [plans/first-date.md](../plans/first-date.md), [core-loop.md](../design/core-loop.md), [0052](0052-result-is-her-contact-card.md)

## Decision

A first date is one scene, `scenes/Dates/Date/Date.tscn`, opened by the dating app. The test bench (`FirstDateTest.tscn`) wraps the same scene with debug sliders, so what you test is what plays.

It runs from the girl's first-date `.dialogue` file, found by title names:

1. `~ opener`
2. **5 exchanges**, drawn at random with no repeats: **2** from the `~ microgame_...` titles (exchanges with a microgame option) and **3** from the `~ exchange_...` titles, shuffled together.
3. **One of 3 closers**, by how it went: `~ closer_failed` (score below her Number Threshold), `~ closer_no_hearts` (number, no hearts), `~ closer_hearts` (1 heart or more).
4. Her contact card ([0052](0052-result-is-her-contact-card.md)).

After the card: if she gave her number she **joins the party** (saved in your Contacts: [0054](0054-party-is-your-contacts.md)); a failed date means she's **gone for the run** (the dating app skips her). Then the game goes **back to the calendar**.

The counts and title names are in `data/date_rules.tres` → Flow.

## Why

Frank's answers (2026-10-20): "Shes in, failed date shes gone"; "5 is fine with 2 of them being micro games"; 3 closers; "Back to calendar". Naming titles by prefix lets writers add exchanges to the pool without touching anything else.

## Not chosen

A fixed exchange order; a separate list of exchanges in the girl file; 0 hearts sending her away (only a failed date does; 0 hearts still gets her number).

## Revisit when

Follow-up dates are built (fixed scenes, not a drawn pool), or the party is full and a new girl needs someone dumped.
