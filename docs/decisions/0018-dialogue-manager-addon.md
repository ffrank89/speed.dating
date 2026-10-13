# 0018: Dialogue is written in the Dialogue Manager addon's format

- **Status:** Accepted
- **Date:** 2026-10-11
- **Affects:** [dates.md](../design/dates.md)

## Decision

Dialogue is written by the developer and by a writer who doesn't use Godot, in Dialogue Manager's plain-text format.

## Why

Plain text a writer can edit without Godot; the addon handles branching and conditions.

## Not chosen

The current custom DialogueData resources; JSON files.

## Revisit when

The addon doesn't support something we need (e.g. option tags for checks or microgames).
