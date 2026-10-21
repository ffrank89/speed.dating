# 0067: How she reacts when annoyed is its own file; a hazard points at one

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [0066](0066-fly-annoys-her.md), [0050](0050-stage-hazards.md), [stage-hazards.md](../guides/stage-hazards.md)

## Decision

- **An annoyance is a file in `data/annoyances/`.** It holds how she reacts
  when something annoys her on a date:
  - **Line**: what she says in the bubble.
  - **Reaction**, **Pose** and **Pose Back**.
  - **Points**: what the date loses.
  - **Pause Seconds**: how long the date stops.
  - **Box Color** and **Box Fade Seconds**: how her dialogue box grays out.
- **`ew.tres` is the fly's**: ".....ew", anger, backshot and back, 1 point,
  1 second, gray. Nothing about how the fly plays has changed.
- **A stage hazard points at one** (top node → **Annoying Her →
  Annoyance**). Several hazards can share one. Empty = it never annoys her.
- **The hazard keeps when it annoys her:**
  - **Annoy Seconds**: on her this long (0 = not this way).
  - **Annoy Limit**: how many times each time it turns up.
  - Its script can call `annoy_her()` for any other trigger.
- **The date plays it** with `DateScene.annoy(annoyance)`, whatever set it off.
- **The gray box setting moved** from the date scene (**When She's Annoyed**)
  into the annoyance, so a different annoyance can gray it differently or
  not at all.
- **Not in dialogue yet.** A line can't set off an annoyance.

## Why

Frank, 2026-10-21, on the fly annoying her: "i think we will have more stage
hazards or specific weird dialogue that sparks an annoyed response". On
making the annoyed moment a file that hazards point at: "Hazard has an
annoyance? Makes sense. Lets not have them in dialogue yet though."

## Not chosen

- **Keeping the settings on each hazard**: ten hazards that should react
  the same way would mean ten copies to keep in step.
- **A dialogue tag** (e.g. `[#annoyed=ew]`): Frank's call, not yet.
  `DateScene.annoy()` takes any annoyance, so a tag can call it later.
- **Only "sitting on her" as a trigger**: a hazard that rings, talks or
  waits too long needs another way, hence `annoy_her()`.

## Revisit when

Dialogue should set off an annoyance, or different girls should react
differently to the same hazard (an annoyance per girl).
