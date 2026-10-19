# 0039: Girls 'speak' with Animalese-style letter sounds

- **Status:** Accepted
- **Date:** 2026-10-19
- **Affects:** [dates.md](../design/dates.md)

## Decision

As each letter types out, it plays a short sound for that letter. All girls share one set of 26 letter sounds; each girl's voice is a pitch, a pitch variance and a speed. Driven by Dialogue Manager's DialogueLabel `spoke` signal.

## Why

Gives each girl a voice without voice acting, and it's charming (Animal Crossing).

## Not chosen

One blip per girl (Undertale-style); tones generated in code.

## Revisit when

The letter sounds get annoying over a 3–4 minute date (add a volume or speed setting, or only voice every other letter).
