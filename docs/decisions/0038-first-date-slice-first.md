# 0038: Build the first date before anything else

- **Status:** Accepted
- **Date:** 2026-10-19
- **Affects:** [dates.md](../design/dates.md)

## Decision

The first thing built to a finished standard is one complete first date: dialogue, options, microgames and the result, run from its own test scene. Plan: [plans/first-date.md](../plans/first-date.md).

## Why

It's where players spend most of their time, the art for it mostly exists, and it decides the game's feel. It only needs a small piece of the shared data model (GirlData, Attr, DateResult).

## Not chosen

Data model and boss test scene first (the earlier build order).

## Revisit when

The slice is done, or blocked on shared code that should be built properly first.
