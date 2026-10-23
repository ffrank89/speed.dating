# 0073: One setting starts every stat at the same value (Lowest, Highest or a number)

- **Status:** Accepted
- **Date:** 2026-10-23
- **Affects:** [0064](0064-stats-are-data.md), [stats.md](../guides/stats.md)

## Decision

- **`data/stats.tres` → Starting Values → Start At** decides where the
  stats start a run, and where the intro's sliders start:
  - **Each Stat's Own** (the default, so nothing changes): each stat file's
    **Starting Value** (5 for all of them now).
  - **Lowest**, **Highest**: every stat starts at the list's Lowest (1) or
    Highest (9).
  - **Starting Number**: every stat starts at **Starting Number**, kept
    between Lowest and Highest.
- **Everything that needs a starting value asks the list**
  (`StatList.starting_value_of(stat)`): the player, the intro, the date and
  its test bench.
- **This is a tool, not a balance change.** Which value to start at is
  Frank's call; the default keeps the game as it was.

## Why

Frank, 2026-10-23: "Can we set the Starting Value in stats.tres to a
constant? I.e if we want them all to be "Lowest" do we need to set them
each to 1 or can we use "Lowest"".

## Not chosen

- Setting each stat file to 1 by hand: 11 files to change and keep in
  step, and it wouldn't follow if Lowest changes.
