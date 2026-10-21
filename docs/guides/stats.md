# Stats

For designers. **No code needed.**

The player has **stats**, and that's all: there's nothing else to raise or
lower. Each stat is its own file, so you can switch stats on and off, add
new ones, and try different sets to see what makes sense.

| Stat | Its id (for dialogue) | Where it's from |
|---|---|---|
| Culture | `culture` | The first build |
| Intellect | `intellect` | The first build |
| Seduction | `seduction` | The first build |
| Heart | `heart` | The first build |
| Strength | `strength` | Fallout: New Vegas's S.P.E.C.I.A.L. |
| Perception | `perception` | S.P.E.C.I.A.L. |
| Endurance | `endurance` | S.P.E.C.I.A.L. |
| Charisma | `charisma` | S.P.E.C.I.A.L. |
| Intelligence | `intelligence` | S.P.E.C.I.A.L. |
| Agility | `agility` | S.P.E.C.I.A.L. |
| Luck | `luck` | S.P.E.C.I.A.L. |

All of them are **on** now. They go from **1 to 9** and start at **5**.
(Fallout's SPECIAL goes to 10; here every stat shares the 1–9 scale.)

## The list: `data/stats.tres`

| Setting | What it does |
|---|---|
| **Lowest** / **Highest** | The scale: 1 to 9. The intro's sliders, training, Profile's bars, the test bench and dialogue checks all use it |
| **Stats** | Every stat, in order. Profile, the intro and the test bench list them in this order. Drag one up or down to move it; remove one to take it out of the game (its file stays in `data/stats/`) |

## Each stat: `data/stats/`

One file each. Click it to change:

| Setting | What it does |
|---|---|
| **Id** | Its short name, used in dialogue: `[#check=strength:5]` |
| **Display Name** | Its name in the game |
| **Enabled** | On or off (below) |
| **Description** | What it's for. Shows when the mouse rests on it in Profile |
| **Icon** | Its picture: in Profile, and on option bubbles that check it. Culture's statue and Heart's winged heart are real; the rest are the Godot logo for now |
| **Starting Value** | What it is at the start of a run, and where the intro's slider starts (5) |

## Try different stats

| I want to... | Do this |
|---|---|
| Turn a stat **off** | Click its file in `data/stats/` (e.g. `luck.tres`) → untick **Enabled**. |
| Try just SPECIAL | Untick **Enabled** on Culture, Intellect, Seduction and Heart. (Split Ends' dialogue checks those four, so her options would lose their rolls; Godot warns which.) |
| Try just the first four | Untick **Enabled** on the seven SPECIAL stats. |
| A **new** stat | Duplicate a file in `data/stats/`, change its **Id**, **Display Name**, **Description** and **Icon**, and drag it into `data/stats.tres` → **Stats**. |
| Merge two that overlap (e.g. Intellect and Intelligence) | Turn one off, and rewrite the dialogue checks and actions that use it to use the other. |

**A stat that's off is gone everywhere:** Profile, the intro and the test
bench don't list it, actions don't change it, her Likes for it don't count,
and a dialogue check on it warns in Godot's Output panel and has no roll.

## Where stats are used

| Where | How |
|---|---|
| **Profile** (W on the calendar, twice) | Lists every stat that's on, with a bar. It scrolls. |
| **The intro** | A slider for each stat that's on. It scrolls. |
| **Training** (calendar actions) | `data/day_actions/<action>.tres` → **Stats** → **Add Key/Value Pair**: drag a stat file on the left, type the amount on the right (Train Culture is Culture 1). |
| **Dialogue checks** | `[#check=strength:5, #value=2]`. Odds are your stat ÷ 5. The bubble shows the stat's icon and name. |
| **Her Likes** | Her girl file → **Dating → Likes** → **Add Key/Value Pair**: a stat file, and 0–1 for how much she cares. An option checking a stat she likes is worth more. Stats she doesn't list are 0. |
| **The date test bench** | A slider for each stat that's on. |
| **Microgames** | An option's check sets its microgame's difficulty: `[#check=seduction:5, #microgame=light_cigarette]` is easiest at Seduction 5 or more, hardest at 1. Any stat works. |
| **Stage hazards** | Each hazard's **Slow Motion**: a stat that slows it down. The fly moves in slow motion with Perception above 5 ([stage-hazards.md](stage-hazards.md)). |
| **Any screen** | Drag `scenes/Stats/StatBars.tscn` into it (below). |

## Stat Bars: the list you can move

Profile's list is `scenes/Stats/StatBars.tscn`. Open
`scenes/Phone/Profile/ProfileApp.tscn` and click **StatBars** (inside
**PhoneScreen → Phone → Body → Screen → Margin → Column → Scroll → Stats**):

| Setting | What it does |
|---|---|
| **Heading Text** | A heading above it ("S.P.E.C.I.A.L."). Empty = none |
| **Only These** | Only these stats, in this order (drag stat files in). Empty = every stat that's on |
| **Phone Style** | Its font and colours (`data/phone_style.tres`) |
| **Sizes** | The heading, each name and number, the pictures (0 = none), the bars (0 = none), the space between, and the empty part of the bars |

To split Profile into groups (e.g. "Dating" and "S.P.E.C.I.A.L."), drag in a
second StatBars next to the first, give each a **Heading Text**, and fill
their **Only These**. To show stats on another screen, drag StatBars into that
scene.

## For programmers

- `PlayerStat` (`scripts/data/player_stat.gd`): `id`, `display_name`,
  `enabled`, `description`, `icon`, `starting_value`.
- `StatList` (`scripts/data/stat_list.gd`, `data/stats.tres`):
  `StatList.get_default()`, `lowest`, `highest`, `stats`, `active()`,
  `find(id)`, `is_active(stat)`, `clamp_value(value)`.
- `PlayerCharacter.stats` (stat id → value, every stat in the list);
  `get_stat(stat)`, `raise_stat(stat, amount)` (kept to the scale).
- `DayAction.stats: Dictionary[PlayerStat, int]`, `stat_changes()` (only
  stats that are on), `change_list()`, `changes_text()`.
- `GirlData.likes: Dictionary[PlayerStat, float]`, `like_for(stat)`.
- `DateOption.stat`, `check_name()`, `check_key()` (the stat's id),
  `check_icon()`. `DateScorer.stats` and `DateScene.stats` are stat id → value
  (`DateScene._player_stats()`).
- `StatBars` (`scenes/Stats/stat_bars.gd`): `heading_text`, `only_these`,
  `refresh()`.
