# 0021: Perks are build-arounds with hooks

- **Status:** Accepted
- **Date:** 2026-10-11
- **Affects:** [perks.md](../design/perks.md)

## Decision

Perks are Balatro joker–style build-arounds. Each is a PerkData resource with hook functions (modify_options, modify_microgame, modify_score, …) so adding a perk never means editing a scene.

## Why

Run-defining perks drive replay; hooks keep perk logic out of the scenes.

## Not chosen

Small flat stat bonuses; perk logic in ScoreCalculator if-checks (today's code).

## Revisit when

Perks need a hook we don't have, or interactions get hard to reason about.
