# 0044: How options score

- **Status:** Accepted
- **Date:** 2026-10-19
- **Affects:** [dates.md](../design/dates.md)

## Decision

Hit points = value × (1 + her like for the attribute × likes_weight). Odds below the requirement = attribute ÷ requirement, clamped to 5–95%. A miss costs max(hit points × 0.5, 1). All numbers live in `data/date_rules.tres`.

## Why

Her likes make the same option worth more to the right girl; half-cost misses keep risky options tempting (a +3 at 71% is worth +2.2 on average vs +3.9/−1.95).

## Not chosen

Hard attribute locks; symmetric misses (miss = −full value); no effect from her likes.

## Revisit when

Playtests show players always pick safe options, or always gamble.
