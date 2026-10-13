# 0027: One score per date

- **Status:** Accepted
- **Date:** 2026-10-11
- **Affects:** [dates.md](../design/dates.md)

## Decision

A single DateScorer replaces the two parallel scores in DialogueManager and ScoreCalculator. The final score converts to Affection via per-girl thresholds.

## Why

Two scores disagree and confuse both players and code.

## Not chosen

Keep both scores.

## Revisit when

We need a second axis (e.g. mood) that one score can't express.
