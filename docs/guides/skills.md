# Skills

For designers. **No code needed.**

Next to their four attributes (Culture, Intellect, Seduction, Heart), the
player has **skills**: the set from Fallout: New Vegas. What they're for
isn't decided yet, so they're built to be switched on and off and to plug
into anything that uses a stat.

| Skill | Its id (for dialogue) |
|---|---|
| Barter | `barter` |
| Energy Weapons | `energy_weapons` |
| Explosives | `explosives` |
| Guns | `guns` |
| Lockpick | `lockpick` |
| Medicine | `medicine` |
| Melee Weapons | `melee_weapons` |
| Repair | `repair` |
| Science | `science` |
| Sneak | `sneak` |
| Speech | `speech` |
| Survival | `survival` |
| Unarmed | `unarmed` |

Like the attributes, skills go from **1 to 9**
(`data/attribute_rules.tres`). Each starts at 1.

## Turn them on and off

| I want to... | Do this |
|---|---|
| Turn **one** skill off | `data/skills/` → click the skill (e.g. `lockpick.tres`) → untick **Enabled**. |
| Turn **all** skills off | `data/skills.tres` → untick **Skills On**. Each skill keeps its own Enabled for when you turn them back on. |
| Change their order | `data/skills.tres` → **Skills**: drag a skill up or down. Profile and the intro list them in this order. |
| Take one out of the game | `data/skills.tres` → **Skills**: remove it from the list (its file stays in `data/skills/`). |

A skill that's off is gone everywhere: Profile and the intro don't list it,
actions don't raise it, and a dialogue check on it warns and has no roll.

## Each skill: `data/skills/`

One file each. Click it to change:

| Setting | What it does |
|---|---|
| **Id** | Its short name, used in dialogue: `[#check=speech:5]` |
| **Display Name** | Its name in the game |
| **Enabled** | On or off (above) |
| **Description** | What it's for. Shows when the mouse rests on it in Profile |
| **Icon** | Its picture (the Godot logo for now) |
| **Starting Value** | What it is at the start of a run (1) |

**A new skill:** duplicate one in `data/skills/`, change its **Id**,
**Display Name**, **Description** and **Icon**, and drag it into
`data/skills.tres` → **Skills**. Nothing else.

## Where they plug in

| Where | How |
|---|---|
| **Profile** (P on the calendar) | Lists the skills that are on, under your attributes. It scrolls. |
| **The intro** | A slider for each skill that's on, under the attributes' sliders. It scrolls. |
| **A calendar action** | `data/day_actions/<action>.tres` → **Skills** → **Add Key/Value Pair**: drag a skill file on the left, type the amount on the right (e.g. Speech 1). A "Train Speech" action is a copy of `train_culture.tres` with Culture 0 and Speech 1. |
| **A dialogue option** | `[#check=speech:5, #value=2]`: the same as an attribute check (the odds are skill ÷ 5). The bubble shows the skill's icon and name. Her **Likes** don't apply to skills (yet). |
| **Any screen** | Drag `scenes/Stats/StatBars.tscn` into it and set **Shows** to **Skills** (below). |

## The lists: Stat Bars

Profile's two lists are both `scenes/Stats/StatBars.tscn`: one shows the
**Attributes**, one the **Skills**. Open
`scenes/Phone/Profile/ProfileApp.tscn` and click **Attributes** or **Skills**
(inside **PhoneScreen → Phone → Body → Screen → Margin → Column → Scroll →
Stats**):

| Setting | What it does |
|---|---|
| **Shows** | **Attributes** or **Skills** |
| **Heading Text** | A heading above it ("Skills"). Empty = none |
| **Phone Style** | Its font and colours (`data/phone_style.tres`) |
| **Icons From** | The attributes' pictures (an option style's **Attribute Icons**). Skills use their own **Icon** |
| **Sizes** | The heading, each name and number, the pictures (0 = none), the bars (0 = none), the space between, and the empty part of the bars |

To move a list, drag it somewhere else in the scene (or into another scene).
To put the skills first, drag **Skills** above **Attributes**.

## For programmers

- `PlayerSkill` (`scripts/data/player_skill.gd`): `id`, `display_name`,
  `enabled`, `description`, `icon`, `starting_value`.
- `SkillList` (`scripts/data/skill_list.gd`, `data/skills.tres`):
  `SkillList.get_default()`, `skills_on`, `skills`, `active()` (the ones
  that are on), `find(id)`, `is_active(skill)`.
- `PlayerCharacter`: `attributes` (name → 1-9), `skills` (skill id → 1-9,
  every skill in the list); `get_skill(skill)`, `raise_skill(skill,
  amount)` (kept to the scale), `get_attribute(name)`,
  `raise_attribute(name, amount)`.
- `DayAction.skills: Dictionary[PlayerSkill, int]`, `skill_changes()` (only
  skills that are on), `change_list()`, `changes_text()`.
- `DateOption.skill` (null = an attribute check); `check_name()`,
  `check_key()` (an `Attr.Id` or a skill id), `check_icon(style)`. The
  date's `attributes` hold both (`DateScene._player_stats()`).
- `StatBars` (`scenes/Stats/stat_bars.gd`): `shows`, `refresh()`.
