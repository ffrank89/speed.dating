# 0070: A stats hub beside the phone; training flies the stat into it

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [0059](0059-three-day-calendar.md), [0064](0064-stats-are-data.md), [stats.md](../guides/stats.md), [the-calendar.md](../guides/the-calendar.md)

## Decision

- **The stats hub** (`scenes/Stats/StatHub.tscn`) is a panel to the right
  of the phone on the calendar. It shows every stat that's on, each as its
  picture and its number. It's in the player's style (panel, colours) and
  can be dropped into any screen.
- **Training plays into it.** When a choice raises a stat:
  1. The stat's picture flies from the choice you picked, in an arc over
     the phone, to that stat in the hub.
  2. The hub's picture of the stat swallows it: it gulps, squashes and
     settles.
  3. The number next to it goes up with a green flash.

  It plays while the calendar's line types. A stat that goes down just
  changes its number, with a red flash.
- **Everything is a setting on the StatHub node:**
  - **Heading Text**, **Only These**, and the layout (**Columns** 2,
    sizes, gaps).
  - The animation: **Fly Seconds**, **Arc Height**, **Swallow Seconds**,
    **Swallow Scale**, **Number Pop Scale**, the flash colours, **Between
    Seconds** and **Swallow Sound** (Kenney `drop_004`, a stand-in).
- **Kept light on purpose.** It's a first version: pictures and numbers
  only, on the calendar only.

## Why

Frank, 2026-10-21: "We need a player stats hub, when we train it should
show that stat getting boosted with a small animation. Dont do much on this
now but maybe just make the stat's icon travel from the phone to the stat
hub and have the stat hub's icon "Swallow" the phone stat's icon and the
number next to it increases by 1?"

## Not chosen

- **Reusing Profile's Stat Bars:** they're drawn for inside the phone
  (names, bars, the phone's colours). The hub sits outside the phone,
  beside it.
- **The hub updating itself whenever a stat changes:** it would show the
  new number before the picture lands. The calendar tells it what changed,
  and the number changes on the swallow.
- **Waiting for the animation before the line:** it plays with the line,
  so training takes no longer than before.

## Revisit when

The hub should be on other screens (the date, the dating app), show more
than numbers (names, bars, perks), or have real art for its panel and
icons.
