# 0066: A hazard sitting on her annoys her: the date stops, she says ".....ew", and loses points

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [0050](0050-stage-hazards.md), [0065](0065-stat-slow-motion.md), [stage-hazards.md](../guides/stage-hazards.md)

## Decision

- **The fly annoys her if it stays on her body for 1 second** (her drawn
  pixels, the same test as dropping a bubble on her; moving off her starts
  the count again). Once per appearance. When it does:
  1. Her dialogue and the option bubbles freeze, and her dialogue box at
     the bottom grays out.
  2. She turns around (her **backshot** pose) and shows the **anger**
     reaction.
  3. She says **".....ew"** in a little bubble by her head, in her own box
     style and voice.
  4. The date loses **1 point**, and the heart meter drains.
  5. After **1 second** (at least as long as her line takes) the date
     carries on: she turns back to her pose and her box comes back.
- **Every stage hazard has this**, on its top node → **Annoying Her**:
  - **Annoy Seconds**: 0 means never; the fly uses 1.
  - **Annoy Limit**, **Annoy Points**, **Annoy Reaction**, **Annoy Line**,
    **Annoy Pose** (the fly: backshot), **Annoy Pose Back** (on) and **Annoy
    Pause Seconds**.
  - The gray is the date's **When She's Annoyed → Annoyed Box Color**.
- **Her bubble is the date's Bark node** (`scenes/Dates/Bark/Bark.tscn`):
  move it in the date scene. It can say any line in her style, not just
  this one.

## Why

Frank, 2026-10-21: "For the fly, if it hovers over the Girl's body for more
than 1 second (modular) - make the options stop for a sec - have her get
angry and say .....ew - then drop some points from the current date, then
allow the options / dialogue to continue". Then: "Her pose should change to
the one where shes turned around when this happens and the bottom dialogue
box should gray out during the ...ewww being written out".

## Not chosen

- Saying it in her dialogue box: it would have to break into whatever line
  is typing and put it back; a bubble by her head says it without touching
  the conversation.
- Counting the box around her picture: the fly would annoy her while
  buzzing past the empty space beside her.
- Counting hover time in slow-motion time: it's how long the player lets it
  sit on her, in real seconds.

## Revisit when

Girls should react differently (their own line or reaction), or other
things than hazards should be able to interrupt the date the same way.
