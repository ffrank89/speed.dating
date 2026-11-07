# 0076: The fly's buzz is a settings file, with pitch, wobble and volume like a voice

- **Status:** Accepted
- **Date:** 2026-11-07
- **Affects:** [0065](0065-stat-slow-motion.md), [0039](0039-animalese-voice.md), [stage-hazards.md](../guides/stage-hazards.md)

## Decision

- **The fly's Sounds → Buzz points at a buzz file**, `data/sounds/fly_buzz.tres`
  (a `LoopSound`), the way a girl points at her voice. The file holds:
  - **Stream:** the recording (set to loop when it's imported).
  - **Pitch** and **Volume dB**, like a voice.
  - **Pitch Wobble** and **Wobble Speed:** the pitch drifts smoothly up and
    down while it plays, so it sounds alive. This is a voice's Pitch Variance
    made smooth: a buzz is one continuous sound, not one per letter.
- **It behaves as before:** it starts when the fly flies in, pauses while a
  microgame plays, stops when the fly is shooed or leaves, and plays at half
  speed in slow motion.
- **No recording yet.** Frank is recording one in GarageBand; until it's
  dropped into **Stream**, the fly is silent.
- Any other hazard can use a file like this for its own sound.

## Why

Frank, 2026-11-07: "Going to do fly now and record buzz ourselves with
garageband. We should be able to edit this noise with similar affects as
girlvoice". Then: "You can just make those changes".

## Not chosen

- A random pitch on every frame (a voice's Pitch Variance as it is): on a
  sound that never stops it crackles. The drift is smooth instead.
- Settings on the fly itself: a file can be shared and swapped, like voices.
