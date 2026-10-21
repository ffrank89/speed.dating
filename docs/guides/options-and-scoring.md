# Options, odds and scoring

For writers, artists and designers. **No code needed.** This covers the
player's choices on a date: how to write them, how they're scored, how to
tune the numbers, and how to change how the option bubbles look, move and sound.

See your changes the usual way: open the date test bench
(`scenes/Dates/FirstDate/FirstDateTest.tscn`) and press **F6**. Drag the attribute sliders
(top left) to see how the odds change. How the whole date is put together
(opener, exchanges, closers) is in [the-full-date.md](the-full-date.md).

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
- Guess "The Unsinkable II". [#check=culture:4, #value=2]
	if hit
		Split Ends: [#react=exclamation] HOW did you know there was a first one?!
	else
		Split Ends: [#react=question] ...There wasn't a first one. Now I'm sad.
- Guess "Boat". [#value=1]
	Split Ends: Honestly? Respect.
- Ask if she'll take you out on it sometime. [#check=seduction:7, #value=3]
	if hit
		Split Ends: [#react=heart] ...Yeah. Okay. I'd like that.
	else
		Split Ends: [#react=anger] Whoa. Buy me a drink first, sailor.
```

| Tag | Meaning |
|---|---|
| `#check=culture:4` | This option tests **Culture** and needs **4**. Attributes go from **1 to 9** (`data/attribute_rules.tres`), so a check is 1–9: 2–3 is easy, 4–6 is middling, 7–9 is hard. Attributes: `culture`, `intellect`, `seduction`, `heart`. Leave `#check` out for an option with no roll. |
| `#value=2` | What it's worth if it lands, from **−3** (rude) to **+3** (perfect). Leave it out and it's worth 0. |
| `if hit` / `else` | Her reply when the option lands / misses. Indent with **Tab**. Options without a check always "hit". |
| `if missed` | The same as `else`, if it reads better. |
| `#microgame=light_cigarette` | Picking it plays that microgame instead of the roll: pass = hit, fail = miss. `#check` then sets how hard it is. The bubble says **PLAY**. See [making a microgame](making-a-microgame.md). |
| `[#react=heart]` | A reaction pops up above her: `exclamation`, `question`, `anger` or `heart`. |
| `[#pose=cig]` | She changes pose (see the [dialogue box guide](dialogue-box.md)). |

**Tips**
- Keep options short. Long ones wrap onto more lines and make a bigger bubble
  (the widest is **Bubble Max Width** in the option style).
- Write **2–4 options**. Players pick with keys 1–4, so a 5th can't be picked
  by number.
- A tempting high-value option with a high requirement (`#check=seduction:7,
  #value=3`) next to a safe low-value one (`#value=1`) is what makes a choice
  interesting.
- An option name that isn't an attribute (e.g. `#check=charm:4`) shows a
  warning in Godot's Output panel and is treated as having no check. So does
  a check above 9 (an old 0–100 number like `:40`), which could never be met.

---

## How points are worked out

Everything below uses the numbers in `data/date_rules.tres` (next section).

**1. The chance.** At or above the requirement: **100%**, no roll, no badge.
Below it: your attribute ÷ the requirement.

> Seduction **5**, option needs **7** → 5 ÷ 7 = **71%**

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

**The attributes' scale:** `data/attribute_rules.tres`. **Lowest** (1) and
**Highest** (9) are what an attribute can be: the intro's sliders, training
and Profile's bars all use them. **Default Value** (5) is every attribute
when a screen is played on its own (F6), and where the date test bench's
sliders start. If you change the scale, rewrite the `#check` numbers in the
dialogue to match.

---

## How the options move

Options appear as **bubbles** that pop out above her head, fan out, then
drift slowly around the screen, nudging each other apart and bouncing off
the edges.

- **Click** a bubble to pick it.
- **Drag a bubble onto her** and let go to pick it. While it's over her it
  glows pink (**Dragging → Drop Outline Color**). Only her drawn pixels
  count, not the see-through space around her picture.
- **Drag** a bubble anywhere else to throw it around. While it's dragged it
  drops a trail of little copies of its attribute icon, which fade away.
  Letting go away from her doesn't pick it.
- A bubble **stops drifting while the mouse is over it**, so it's easy to click.
- Keys **1–4** still pick, and the arrow keys then Space/Enter still work.

**Where they float:** open the date scene, `scenes/Dates/Date/Date.tscn`, and
click **OptionList**. Its rectangle is the area the bubbles stay inside. It
fills the screen above the dialogue box; drag its edges to change that. To
change it for every scene, edit `scenes/Dialogue/OptionList.tscn` instead.

**Where they start:** in the same scene, click **OptionsStart** (the cross
above her head) and drag it. OptionList's **Start At** slot points at it.
Empty = the top middle of the OptionList area.

**What counts as "her":** OptionList's **Drop Target** slot points at the
**Portrait** node. To stop drops from picking, turn off **Dragging → Drop On
Her Picks** in the option style.

## Changing how the options look, move and sound

Click `data/option_styles/default.tres`. This is the shared look on every
date. **A girl can have her own:** duplicate the file (right-click →
Duplicate), change it, and drag it onto her girl file's **Dialogue → Option
Style** slot. Empty = the shared one.

The bubble settings work like a girl's [dialogue style](dialogue-box.md): a
flat colour box with an outline, **or a picture** that stretches like a
picture frame, with the outline kept or dropped.

| Section | What's in it |
|---|---|
| Bubbles | Fill colours (normal and hover), **Background Image** and **Hover Image**, Image Corner Size, Keep Outline With Image, outline colours and width, corners, padding, **Bubble Max Width** (longer options wrap), spacing kept between bubbles, how much a bubble grows on hover |
| Floating | **Drift Speed** (how slowly they float), **Burst Speed** (how fast they pop out of her head), **Settle** (how soon they slow down), **Wander** (straight lines or lazy curves) |
| Text | Font, size, colours, letter outline, whether to show the 1–4 key numbers |
| Risky Options | The outline and % badge colours for options the player might miss |
| Microgame Options | The badge on options that play a microgame (**PLAY**) and its colours |
| Roll | How long the numbers spin, the hit and miss colours, and the words (HIT / MISS) |
| Attribute Icons | The small picture for each attribute, and its size. The drag trail uses these too. |
| Dragging | Trail icon size, **Trail Spacing** (lower = more icons), how long each lasts, the icon for options with no attribute, how hard a bubble can be thrown, and **Drop On Her Picks** with its glow colour |
| Sounds | Hover, pick, roll tick, hit and miss sounds, and volume |

**Picture bubbles:** drag a picture onto **Bubbles → Background Image**. If
its corners look squashed, raise **Image Corner Size** to the thickness of
its frame. Turn on **Keep Outline With Image** to draw the outline on top
(then match **Corner Radius** to the picture's corners). With the outline
dropped, risky options are marked by their % badge only. **Hover Image** is
optional; empty = the same picture.

**Attribute icons:** Culture uses the statue and Heart the winged heart.
**Intellect and Seduction show the Godot logo**, which is the placeholder for
art that doesn't exist yet. Drag real art onto **Attribute Icons → Intellect
Icon / Seduction Icon** to replace them. Square pictures work best. Options
with no attribute drop **Dragging → Trail Fallback Icon** (also the Godot
logo for now).

**Sounds:** hover, tick, hit and miss come from Kenney's Interface Sounds
(CC0, `assets/audio/ui/kenney_interface_sounds/`). To try others, drag any
sound from that folder onto the **Sounds** slots; its `README.md` suggests
alternatives. [Replacing placeholders](replacing-placeholders.md) explains
the two ways to swap a sound.

## Reactions

Reactions (`[#react=heart]`) are animations in `data/reactions.tres`.
Double-click it to open the **SpriteFrames** panel at the bottom of Godot.

- **Change one:** select the animation (e.g. `heart`) and replace its frames.
- **Add one:** click **Add Animation**, name it (e.g. `sweat`), drag its
  frames in, and set the speed. Writers can use `[#react=sweat]` straight away.
- **Move them / resize them:** in the date scene (`scenes/Dates/Date/Date.tscn`), click **ReactionIcon**.
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
| Bubbles float over the dialogue box or off where I can't see them | Resize **OptionList** in the scene: bubbles stay inside its rectangle. |
| Bubbles don't come from her head | Move **OptionsStart** in the scene, and check OptionList's **Start At** slot points at it. |
| My girl's own option style isn't used | Check it's in her girl file's **Dialogue → Option Style** slot, and that she's the girl in the test bench's **Girl** slot (click the top node of `FirstDateTest.tscn`). |
| Dragging a bubble picks it | Letting go on her picks it (that's on purpose). Away from her, it only picks if the mouse barely moved (under 12 pixels): drag further. |
| Dropping on her doesn't pick | Let go with the **mouse pointer** over a drawn part of her (not the see-through space around her). Check OptionList's **Drop Target** is **Portrait** and **Drop On Her Picks** is on. Picks are also ignored for a moment after the bubbles appear (**Input Delay**). |

## For programmers

- `DateOption.from_response()` (`scripts/date/date_option.gd`) parses the tags.
- `DateScorer` (`scripts/date/date_scorer.gd`) owns the one date score:
  `chance_of()`, `points_if_hit()`, `resolve()` → `DateScorer.Result`.
- `DateState` (`scripts/date/date_state.gd`) is passed to the dialogue as a
  game state, which is why `if hit` works in `.dialogue` files.
- `OptionList` (`scenes/Dialogue/`) spawns one `OptionBubble` per option at
  `start_at`, moves them (drift, bounce, separation, drag and throw, icon
  trail), picks on a drop onto `drop_target` (`GirlPortrait.is_point_on_her()`,
  an alpha test on her pose picture), plays the roll and emits `option_resolved(response, result)`.
  `show_options(responses, scorer, look)` takes an optional per-girl
  `OptionListStyle`; the date scene then sets
  `DateState.hit` and calls `DialogueBox.choose(response)`.
