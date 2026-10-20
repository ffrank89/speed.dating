# The heart meter

For writers, artists and designers. **No code needed.**

In the top right of a date: **one ring per heart** she can give. Each ring
fills as the date score climbs toward her next **Affection Threshold** (her
girl file → Dating, now 3 / 6 / 9 points). When a ring is full, the **grey
heart** in its middle turns to colour with a pop and the **heart sound**
plays: you've got that heart. If the score drops back below a threshold
(a missed option), that heart goes grey again. Hearts are counted at the
end of the date, so the meter always shows what she'd give you right now.

```
  ◯ ♡   ◔ ♡   ○ ♡        score 0: all empty, grey hearts
  ● ❤   ◑ ♡   ○ ♡        score 4.5: first heart won, second ring half full
  ● ❤   ● ❤   ● ❤        score 9+: three hearts
```

## Try it

- **On its own:** open `scenes/Dates/HeartMeter/HeartMeter.tscn` and press
  **F6**. It fills up a step at a time with **Testing → Test Girl**'s
  thresholds and colour, then starts over. **Test Step** is how many points
  each step adds.
- **In a date:** press **F5** and pick options. Good picks fill the rings.

## The colour: her style

Each girl's rings fill with her own colour: her dialogue style (e.g.
`data/dialogue_styles/split_ends.tres`) → **Heart Meter → Meter Color**.
Split Ends' is her red. A girl without her own style uses the default
style's (pink).

## Everything else: `data/heart_meter_style.tres`

| Setting | Now | What it does |
|---|---|---|
| **Ring Size** | 150 | Each ring's size, in pixels |
| **Ring Width** | 16 | How thick the ring is |
| **Track Color** | faint white | The part not filled yet |
| **Ring Outline Color** | faint black | A thin dark line so the ring shows on any background. A = 0 for none |
| **Ring Gap** | 18 | Space between the rings |
| **Fill Seconds** | 0.6 | How long a ring takes to fill or empty |
| **Heart Image** | `love react1.png` | The heart in the middle |
| **Empty Heart Image** | empty | The heart before its ring fills. Empty = Heart Image in grey |
| **Heart Size** | 104 | The heart's size |
| **Empty Heart Alpha** | 0.85 | How see-through the grey heart is |
| **Heart Pop** | 1.5 | How much the heart pops when it's won (1 = none) |
| **Heart Sound** | `confirmation_003.wav` | When you win a heart. The same sound as getting her number; drag another sound here to change it |

**How many rings:** one per number in her **Affection Thresholds**. Add a
fourth threshold and she has a fourth ring.

## Where it sits and how it's laid out

- **Where:** open `scenes/Dates/Date/Date.tscn`, click **HeartMeter** and
  move it (it's anchored to the top right).
- **A column instead of a row:** HeartMeter → **Vertical** on.
- **One ring's design:** `scenes/Dates/HeartMeter/HeartRing.tscn` (move or
  resize the **Heart** in it). For a different design, duplicate it and
  drop yours into HeartMeter's **Ring Scene** slot.

## For programmers

- `HeartMeter` (`scenes/Dates/HeartMeter/heart_meter.gd`, an
  HBoxContainer): `setup(girl)` builds a `HeartRing` per threshold;
  `show_score(score, animate)` fills them (ring *i* spans threshold *i-1*
  to *i*); `hearts()`; signal `heart_won(hearts)`. `DateScene` calls
  `setup` in `begin()` and `show_score` after each option and hazard.
- `HeartRing` (`heart_ring.gd`): draws its arcs in `_draw()`;
  `fill_to(amount, animate)`; greys the heart with a small grayscale
  shader; signal `heart_won`.
- `DialogueBoxStyle.meter_color`, `HeartMeterStyle`.
