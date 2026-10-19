# 0046: A microgame replaces the roll

- **Status:** Accepted
- **Date:** 2026-10-19
- **Affects:** [dates.md](../design/dates.md), [plans/first-date.md](../plans/first-date.md)

## Decision

An option with `#microgame=…` plays that microgame instead of the % roll. Passing counts as a hit, failing as a miss, scored the same way. The player's attribute against the option's requirement sets the microgame's difficulty rather than odds. Each microgame lasts 5 seconds and accepts both mouse and keyboard. The banner, timer bar and pass/fail stamp are one shared, modular frame (its look in a style file; each microgame sets its own banner text and length).

## Why

Skill replaces luck for the moments that are physical (lighting her cigarette), while stats still matter through difficulty. A shared frame keeps every microgame instantly readable.

## Not chosen

Microgame after the roll; microgame as a bonus on top of the roll; each microgame drawing its own banner and timer.

## Revisit when

Low-stat players find microgames impossible, or high-stat players find them pointless.
