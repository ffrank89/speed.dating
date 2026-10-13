# 0026: Girls are GirlData (.tres) + PartyMember (per run)

- **Status:** Accepted
- **Date:** 2026-10-11
- **Affects:** [girls.md](../design/girls.md)

## Decision

Each girl is a GirlData resource (same every run, edited in the Inspector) plus a PartyMember created when she joins.

## Why

A new girl needs no code; per-run state can't leak into the shared definition.

## Not chosen

One Node subclass per girl (today's DateCharacter / SmokeyCharacter).

## Revisit when

GirlData needs per-girl logic that resources can't express cleanly.
