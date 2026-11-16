# 0079: A scene of Split Ends spinning, with speed and direction buttons in her style

- **Status:** Accepted
- **Date:** 2026-11-16
- **Affects:** [girl-spin.md](../guides/girl-spin.md), [dialogue-box.md](../guides/dialogue-box.md)

## Decision

- **`scenes/Spin/SplitEndsSpin.tscn`** stands on its own, like the clock
  (press F6). It isn't in a date.
- **She spins** through the artist's four turnaround frames
  (`assets/split ends spin/`), held in one SpriteFrames file,
  `splitends_spin.tres`, in order: front, facing right, back, facing left.
- **Speed buttons:** Stop, Slow, Medium and Fast (0, 2, 4 and 8 frames a
  second). It starts at Medium. They're a list on the top node (**Speeds**),
  so buttons can be added, renamed or retimed there.
- **Direction buttons:** Left and Right. Right plays the frames in order,
  Left plays them backwards. It starts turning right.
- **The buttons use her style file**, `data/dialogue_styles/split_ends.tres`:
  - Her box, outline, corners, font and text colour.
  - The chosen button uses her name plate's colours.
  - The button under the mouse gets a thicker outline.
- The script, `girl_spin.gd` (`GirlSpin`), works for any girl: give a copy
  of the scene her frames and her style.

## Why

Frank, 2026-11-16: "Like the clock scene, I want to make an individual scene
that shows split ends spinning. There should be buttons to decide the speed
and direction of the spinning. These buttons should use her style from her
style resource". After seeing the tested scene: "implement".

The speeds, the words, the colours for the chosen and hover buttons, and the
layout were picked to have something to look at. They're Frank's to change.

## Not chosen

- **Her option style** (`OptionListStyle`): that's the player's choice
  bubbles, not her. Her style file is her dialogue style.
- **Fixing frame 4's position in code.** It's drawn about 330 px right of
  the others, so she hops. That's for the art to fix, not the scene.
