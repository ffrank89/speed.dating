# Options, odds and scoring

For writers, artists and designers. **No code needed.** This covers the
player's choices on a date: how to write them, how they're scored, how to
tune the numbers, and how to change how the buttons look and sound.

See your changes the usual way: open
`scenes/Dates/FirstDate/FirstDateTest.tscn` and press **F6**. Drag the
attribute sliders (top left) to see how the odds change.

## How it works, in one picture

```
She asks something  →  2–4 options appear  →  player picks one
                                               │
                     at/above the requirement ─┼─ below the requirement
                     lands for sure            │  shows a % chance and rolls
                                               ▼
                     HIT: she likes it, points go up
                     MISS: she doesn't, points go down
                                               ▼
                     her reply to a hit or a miss, then the date goes on
```

---

## Writing options

Options go in the `.dialogue` file, under her line, each starting with `-`.
Tags in square brackets say what each one checks and what it's worth:

```
Split Ends: My dad's boat has a name. Guess it.
- Guess "The Unsinkable II". [#check=culture:40, #value=2]
	if hit
		Split Ends: [#react=exclamation] HOW did you know there was a first one?!
	else
		Split Ends: [#react=question] ...There wasn't a first one. Now I'm sad.
- Guess "Boat". [#value=1]
	Split Ends: Honestly? Respect.
- Ask if she'll take you out on it sometime. [#check=seduction:70, #value=3]
	if hit
		Split Ends: [#react=heart] ...Yeah. Okay. I'd like that.
	else
		Split Ends: [#react=anger] Whoa. Buy me a drink first, sailor.
```

| Tag | Meaning |
|---|---|
| `#check=culture:40` | This option tests **Culture** and needs **40**. Attributes: `culture`, `intellect`, `seduction`, `heart`. Leave `#check` out for an option with no roll. |
| `#value=2` | What it's worth if it lands, from **−3** (rude) to **+3** (perfect). Leave it out and it's worth 0. |
| `if hit` / `else` | Her reply when the option lands / misses. Indent with **Tab**. Options without a check always "hit". |
| `if missed` | The same as `else`, if it reads better. |
| `[#react=heart]` | A reaction pops up above her: `exclamation`, `question`, `anger` or `heart`. |
| `[#pose=cig]` | She changes pose (see the [dialogue box guide](dialogue-box.md)). |

**Tips**
- Keep options to about **50 characters**. Longer ones get cut off with "…".
- Write **2–4 options**. Players pick with keys 1–4, so a 5th can't be picked
  by number.
- A tempting high-value option with a high requirement (`#check=seduction:70,
  #value=3`) next to a safe low-value one (`#value=1`) is what makes a choice
  interesting.
- An option name that isn't an attribute (e.g. `#check=charm:40`) shows a
  warning in Godot's Output panel and is treated as having no check.

---

## How points are worked out

Everything below uses the numbers in `data/date_rules.tres` (next section).

**1. The chance.** At or above the requirement: **100%**, no roll, no badge.
Below it: your attribute ÷ the requirement.

> Seduction **50**, option needs **70** → 50 ÷ 70 = **71%**

The chance never goes below **Min Chance** (5%) or above **Max Chance** (95%).

**2. What a hit earns.** The option's value, boosted by how much **she**
likes that attribute (her **Likes** in her girl file, 0–1):

> value × (1 + her like × Likes Weight)
> Split Ends likes Seduction **0.3**: +3 × (1 + 0.3 × 1.0) = **+3.9**

So the same option is worth more to a girl who cares about that attribute.

**3. What a miss costs.** A share of what it would have earned, never less
than **Min Miss Cost**:

> −(3.9 × Miss Penalty 0.5) = **−1.95**

**4. The roll.** A number from 1 to 100. At or below the chance: hit.

> Rolled **51** vs 71% → **HIT**. Rolled **98** → **MISS**.

All of a date's points add up to one **date score**. In milestone M4 it
turns into 0–3 hearts using her **Affection Thresholds**.

## Tuning the numbers

Click `data/date_rules.tres` in FileSystem. Hover any setting for help.

| Setting | Default | Raise it to… | Lower it to… |
|---|---|---|---|
| Min Chance | 5 | make hopeless options less hopeless | make low stats really hurt |
| Max Chance | 95 | make "nearly there" feel safer | keep every roll a little scary |
| Likes Weight | 1.0 | make her likes matter more | make every girl score the same |
| Miss Penalty | 0.5 | make risks riskier | make risks cheaper |
| Min Miss Cost | 1.0 | make every miss sting | make small misses forgivable |

---

## Changing how the options look and sound

Click `data/option_styles/default.tres`. One style is shared by every
date: the options are the player's voice, not hers.

| Section | What's in it |
|---|---|
| Buttons | Fill and outline colours (normal and hover), corners, padding, spacing, how far a button slides on hover |
| Text | Font, size, colours, whether to show the 1–4 key numbers |
| Risky Options | The outline and % badge colours for options the player might miss |
| Roll | How long the numbers spin, the hit and miss colours, and the words (HIT / MISS) |
| Attribute Icons | The small picture for each attribute, and its size |
| Sounds | Hover, pick, roll tick, hit and miss sounds, and volume |

**Attribute icons:** Culture uses the statue and Heart the winged heart.
**Intellect and Seduction show the Godot logo**, which is the placeholder for
art that doesn't exist yet. Drag real art onto **Attribute Icons → Intellect
Icon / Seduction Icon** to replace them. Square pictures work best.

**Sounds:** hover, tick, hit and miss come from Kenney's Interface Sounds
(CC0, `assets/audio/ui/kenney_interface_sounds/`). To try others, drag any
sound from that folder onto the **Sounds** slots; its `README.md` suggests
alternatives. [Replacing placeholders](replacing-placeholders.md) explains
the two ways to swap a sound.

**Where the options appear:** open `scenes/Dates/FirstDate/FirstDateTest.tscn`,
click **OptionList** in the Scene panel, and drag it or change its size.
Options stack upward from its bottom edge.

## Reactions

Reactions (`[#react=heart]`) are animations in `data/reactions.tres`.
Double-click it to open the **SpriteFrames** panel at the bottom of Godot.

- **Change one:** select the animation (e.g. `heart`) and replace its frames.
- **Add one:** click **Add Animation**, name it (e.g. `sweat`), drag its
  frames in, and set the speed. Writers can use `[#react=sweat]` straight away.
- **Move them / resize them:** in the test scene, click **ReactionIcon**.
  Drag it to where reactions should appear, and change **Icon Scale** and
  **Seconds Shown** in the Inspector.

## Something's wrong

| Problem | Fix |
|---|---|
| No % badge on an option I expected to be risky | The player's attribute is at or above the requirement, so it can't miss. Lower the slider to test. |
| Her reply is the same whatever happens | Use `if hit` / `else` under the option, with the replies indented one Tab further. |
| "unknown attribute" warning | The `#check=` name must be `culture`, `intellect`, `seduction` or `heart`. |
| Reaction doesn't show | The name in `[#react=…]` must match an animation in `data/reactions.tres` exactly. |
| Number keys don't pick | Only options 1–4 have keys. Also, picks are ignored for a moment (**Input Delay** on OptionList) right after options appear, so players mashing Space don't pick by accident. |

## For programmers

- `DateOption.from_response()` (`scripts/date/date_option.gd`) parses the tags.
- `DateScorer` (`scripts/date/date_scorer.gd`) owns the one date score:
  `chance_of()`, `points_if_hit()`, `resolve()` → `DateScorer.Result`.
- `DateState` (`scripts/date/date_state.gd`) is passed to the dialogue as a
  game state, which is why `if hit` works in `.dialogue` files.
- `OptionList` (`scenes/Dialogue/`) shows options, plays the roll and emits
  `option_resolved(response, result)`; the date scene then sets
  `DateState.hit` and calls `DialogueBox.choose(response)`.
