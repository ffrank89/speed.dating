# 0064: The player has New Vegas's skills, each switchable on or off

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [player.md](../design/player.md), [0063](0063-attributes-one-to-nine.md)

## Decision

Next to the four attributes, the player has Fallout: New Vegas's 13 skills:
Barter, Energy Weapons, Explosives, Guns, Lockpick, Medicine, Melee Weapons,
Repair, Science, Sneak, Speech, Survival, Unarmed. What they're for isn't
decided, so they're data that plugs into anything that uses a stat:

- **One file per skill** (`data/skills/`): id, name, **Enabled**,
  description, icon (Godot logo for now), starting value (1). The 1–9 scale
  is the attributes' (`data/attribute_rules.tres`).
- **One list** (`data/skills.tres`): which skills the game has, in order, and
  **Skills On** for all of them. A skill that's off is gone everywhere.
- **Where they plug in:** Profile lists them; the intro has a slider for
  each; a calendar action can raise them (its **Skills**); a dialogue option
  can check one (`[#check=speech:5]`), with the same odds as an attribute.
- **The lists are a scene of their own** (`scenes/Stats/StatBars.tscn`, Shows
  Attributes or Skills), so they can be moved or dropped into any screen.
  Profile is two of them in a scrolling list.
- In code the player's four attributes are now `attributes` (they were
  called `skills`), and `skills` are these.

## Why

Frank, 2026-10-21: "Add the slate of character skills from new vegas to the
player character stats and allow me to enable or disable them. Im not sure
what i want to do with that yet so lets make it modular and easy to move
around".

## Not chosen

- Fixing the skills in code like the four attributes (an enum): adding,
  removing or reordering one would need code.
- Leaving out the hooks (actions, dialogue checks) until there's a use: they
  are small, and a skill does nothing until a writer or designer uses it.
- Girls' Likes for skills: not until skills have a job on dates.

## Revisit when

Skills get a job (dates, the boss, perks, events), or some of them become
attributes (or the other way round).
