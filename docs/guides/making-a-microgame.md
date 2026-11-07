# Making a microgame

For whoever builds the microgames. **You write only the game itself.**
The frame around it (the phone coming up over the date, the banner, the
timer bar, the NICE / OOPS stamp), the scoring, the hookup to dialogue,
mouse-and-keyboard input and the test mode are already built.

**Microgames play on the player's phone.** The phone comes up over the
date (the date dims behind it), the microgame opens on it, and the phone
goes back down afterwards. Your game fills **the phone's screen: 964 × 1414
pixels**, portrait (with the phone in `data/phone_style.tres`; a bigger
phone gives a bigger screen). Build it tall, not wide.

## How it fits together

```
Writer tags an option        - Light it for her. [#check=seduction:5, #value=2, #microgame=light_cigarette]
        │
Player picks it              the bubble says PLAY instead of a % chance
        │
MicrogameHost                phone up over the date, opens it on the phone like an
                             iPhone app, shows your banner ("LIGHT IT!"), starts the
                             timer bar
        │
YOUR SCENE                   plays until it calls win() or lose(), or time runs out
        │
MicrogameHost                freezes it, stamps NICE! or OOPS!, closes it, phone down
        │
DateScorer                   pass = hit, fail = miss (points as usual)
        │
Dialogue                     her "if hit" or "else" reply
```

The player's stat against the option's `#check` sets the
**difficulty** (0 = easiest, 1 = hardest) instead of the odds.

## Files

| File | What it is |
|---|---|
| `scenes/Microgames/_template/` | **The example to copy.** "CATCH IT!": click a bouncing logo. |
| `scenes/Microgames/microgame.gd` | `Microgame`, the base every microgame extends. Read its comments for the full toolbox. |
| `scenes/Microgames/MicrogameHost.tscn` | The shared frame, on the phone. Move the **Banner**, **TimerBar** and **Stamp** here (under **PhoneScreen → Phone → Body → Screen**). |
| `data/microgames.tres` | The list of microgames by name. A dialogue tag `[#microgame=name]` looks the name up here. |
| `data/microgame_style.tres` | How the frame looks and sounds (no code). |
| `data/date_rules.tres` → **Microgames** | How the player's stat turns into difficulty. |
| `dialogue/split_ends/first_date.dialogue` | Her first date. The `~ microgame_...` exchanges have a microgame option; 2 play per date ([the-full-date.md](the-full-date.md)). |

## Try the example first

1. Open `scenes/Microgames/_template/TemplateMicrogame.tscn` and press **F6**.
   It plays on the phone, with your room behind it. The banner shows, the
   timer runs, and you click the logo (or steer with the **arrow keys /
   WASD** and press **Space**). It restarts after each try.
   The **Output** panel says `PASSED` or `FAILED`.
2. Click the top node (**TemplateMicrogame**). In the Inspector, change
   **Testing (F6) → Test Difficulty** to 0 and then 1, and press F6 again to
   feel the difference.
3. Press **F6** on the date test bench (`scenes/Dates/FirstDate/FirstDateTest.tscn`) and pick **"Catch the lighter she tosses
   you."** when she says "Think fast!" The phone comes up over the date with
   the same microgame on it, and her reply depends on whether you caught it. To skip straight
   to it: open `FirstDateTest.tscn`, click the top node and set **Start
   Title** to `microgame_catch`.

## The lighter: "LIGHT IT!"

`scenes/Microgames/lighter/LightCigarette.tscn`, named `light_cigarette` in
`data/microgames.tres`, so **"Light it for her."** on Split Ends' first
date plays it. **Click (or press Space) to flick the lighter.** Each flick
has a chance to catch. When it catches, the flame burns for a moment and you
pass. If time runs out first, you fail.

Click its top node (**LightCigarette**):

| Setting | Now | What it does |
|---|---|---|
| **Easiest Chance** | 0.3 | The chance each flick catches at difficulty 0 (30%) |
| **Hardest Chance** | 0.1 | ...and at difficulty 1 (10%). In between, it's a mix of the two |
| **Flame Seconds** | 0.6 | How long the flame burns before the pass counts |
| **Frame → Banner Text** | LIGHT IT! | The word at the start |
| **Frame → Seconds** | 5 | How long the player has |
| **Frame → Pass When Time Runs Out** | off | Running out of time is a fail |

**Its parts** (move, resize or re-time them in the scene):

| Node | What it is |
|---|---|
| **Hand** | The flick: an AnimatedSprite2D whose animation `flick` is `assets/lighter gif/Rhand1–8.png`, 24 frames a second, not looping. Every click plays it from the start |
| **Hand → Flame** | The flame: animation `burn`, `assets/flame/fire1–4.png`, 10 a second, looping. Hidden until the lighter catches. It's inside Hand, so it moves with the lighter |
| **Window** | The frame the game sits in |

`assets/lighter gif/Lhand.png` (the other hand) isn't used yet.

**Difficulty:** "Light it for her." checks Seduction 5. At Seduction 5 or
more the difficulty is 0.2 (`data/date_rules.tres` → **Min Difficulty**), so
the chance is a little under Easiest Chance. Each point below 5 moves it
towards Hardest Chance.

**Try it:** press **F6** on `LightCigarette.tscn` and change **Testing (F6)
→ Test Difficulty**. In a date: on the date test bench, set **Start Title**
to `microgame_light_it`, and use the **Seduction** slider for the difficulty.

## Make your own

### 1. Copy the template

1. In the FileSystem panel, right-click `scenes/Microgames` → **Create New →
   Folder**, e.g. `my_game`.
2. Right-click `_template/TemplateMicrogame.tscn` → **Duplicate…** into it,
   e.g. `my_game/MyGame.tscn`.
3. Right-click `_template/template_microgame.gd` → **Duplicate…** into it,
   e.g. `my_game/my_game.gd`.
4. Open the new scene, click the top node, and drag the new script onto its
   **Script** slot. Rename the top node.

> Duplicate the two files one at a time like this. A duplicated scene still
> points at the template's script until you swap it, and editing that would
> change the example.

### 2. Set the frame

Click the top node. Under **Frame**: **Banner Text** (1–3 words), **Seconds**,
**Pass When Time Runs Out** (off = the player has to *do* something in time;
on = they have to *survive* until it runs out), and optionally **App** (its
own icon and launch screen: duplicate `data/apps/microgame.tres`).

### 3. Put it on the list

`data/microgames.tres` → **Games** → **Add Key/Value Pair**: its name on the
left (the one dialogue uses, `[#microgame=my_game]`), the scene on the right.

### 4. Add the art

Delete the template's **PlayArea** (the bouncing logo); keep **Window**.
Use **TextureRect** for still pictures and **AnimatedSprite2D** for
animations. The game fills the phone's screen, **964 × 1414**, portrait,
with room at the top for the timer bar.

### 5. Write the game

Keep `extends Microgame` at the top. The shape is always the same (the
lighter's script, `scenes/Microgames/lighter/light_cigarette.gd`, is a short
real example):

```gdscript
extends Microgame

# Numbers to tune in the Inspector: the easiest and hardest version of each.
@export var easiest_... := ...
@export var hardest_... := ...

func start(p_difficulty: float, _p_modifiers: Dictionary) -> void:
	# Runs once, before the banner. Turn difficulty into numbers:
	#   lerpf(easiest_..., hardest_..., p_difficulty)
	# and put everything in its starting place.
	pass

func _process(delta: float) -> void:
	# The game. Only runs while the timer runs.
	# Call win() or lose() when it's decided.
	pass
```

| To do this | Use |
|---|---|
| A press (click **or** Space / Enter) | `Input.is_action_just_pressed("microgame_press")` |
| Hold something down | `Input.is_action_pressed("microgame_press")` |
| Is the player aiming at a node? | `is_pointing_at($Node)` (mouse, or the arrow keys / WASD pointer) |
| Where the player is aiming | `pointer` (in the microgame's own space) or `pointer_on_screen()` |
| Time left | `time_left` (seconds) |
| End it | `win()` or `lose()` |

> **Everything freezes the moment it ends** (for the NICE / OOPS stamp). An
> animation that should play out, like the lighter's flame, has to play
> *before* `win()`: the lighter waits Flame Seconds, then calls it.

### 6. Test

- **F6** on its scene: plays it over and over. Try **Test Difficulty** 0,
  0.5 and 1. It should be readable within half a second, and beatable on the
  second or third try.
- Try it with **only the keyboard** and with **only the mouse**.
- In a date: tag an option with `#microgame=my_game` in a `~ microgame_...`
  title, and set the test bench's **Start Title** to that title.

## Mouse and keyboard

Every microgame must work with either. Two rules make that automatic:

- For a press, use the **`microgame_press`** action: it's Space, Enter
  *and* left click. (Project → Project Settings → Input Map lists it, with
  `microgame_up/down/left/right` = arrow keys and WASD.)
- For aiming, use **`pointer`** / **`is_pointing_at()`**, never the raw mouse
  position. The pointer follows the mouse, and the arrow keys / WASD steer it
  (a ring shows where while they do).

## Difficulty

`data/date_rules.tres` → **Microgames**:

| Setting | Now | Meaning |
|---|---|---|
| Min Difficulty | 0.2 | The player meets the option's requirement |
| Max Difficulty | 1.0 | The player's stat is the lowest (1) |
| Unchecked Difficulty | 0.5 | The option has a microgame but no `#check` |

In between it's a straight line: Seduction 3 against a requirement of 5 is
halfway from 5 down to 1, so 0.2 + (1.0 − 0.2) × 0.5 = **0.6**.

Your microgame decides what difficulty *means*. Make an easiest and a
hardest number for each thing that should change, export them, and blend
with `lerpf(easiest, hardest, difficulty)`, as the template does with speed
and size.

## Changing the frame (no code)

`data/microgame_style.tres`:

| Section | What's in it |
|---|---|
| Opening | **Open As App**: once the phone is up, the microgame opens on it like an iPhone app, and shrinks back after (on by default; see [phone apps](phone-apps.md)). Off = a plain fade. How the phone comes up and goes down is `data/phone_style.tres` → **Phone Up / Down**. |
| Dim | The colour laid over the date while the phone is up |
| Banner | How long it shows before play starts (0.8 s), font, size, colours, outline, optional picture behind it |
| Timer Bar | Colours (normal and the last seconds), outline, corners, optional pictures, when it turns "low" |
| Stamp | NICE! / OOPS! words and colours, font, size, tilt, how long it stays, optional pictures instead of words |
| Keyboard Pointer | The ring (or a picture) shown while steering with the keys, and its speed |
| Sounds | Start, last-seconds tick, pass and fail (Kenney Interface Sounds, CC0) |

**Where** the banner, timer bar and stamp sit on the phone: open
`scenes/Microgames/MicrogameHost.tscn` and move **Banner**, **TimerBar** or
**Stamp** (under **PhoneScreen → Phone → Body → Screen**). Each microgame sets its own banner words and length (step 2).

## Writing microgame options

```
Split Ends: [#pose=cig] Got a light?
- Light it for her. [#check=seduction:5, #value=2, #microgame=light_cigarette]
	if hit
		Split Ends: [#react=heart] ...Smooth.
	else
		Split Ends: [#react=anger] You almost torched my bangs.
```

- `#microgame=` is the name in `data/microgames.tres`.
- `#check` sets the difficulty, `#value` the points. Points work exactly as
  for a roll.
- The bubble shows **PLAY** instead of a % (option style → **Microgame
  Options**).

## Something's wrong

| Problem | Fix |
|---|---|
| The option rolls instead of playing | The name after `#microgame=` isn't in `data/microgames.tres` (check spelling and capitals). The Output panel shows a warning saying so. |
| "doesn't use a Microgame script" error | The scene's top node needs a script that starts with `extends Microgame`. |
| My game moves during the banner, or not at all | `_process` only runs while the timer runs. Set things up in `start()`, not `_process`. |
| Clicks do nothing but Space works (or the other way round) | Use `microgame_press`, not a mouse-only or key-only check. |
| The keyboard can't aim | Use `pointer` / `is_pointing_at()` instead of `get_global_mouse_position()`. |
| It never ends | Call `win()` when they succeed. Time running out ends it automatically. |
| F6 plays it once and stops | Turn on **Testing (F6) → Replay After Test** on the top node. |
| Editing my game changed the example | The scene still uses `template_microgame.gd`: drag your own script onto the top node (step 1.4). |

## For programmers

- `Microgame` (`scenes/Microgames/microgame.gd`): `start()`, `win()`,
  `lose()`, `time_up()`, `is_playing`, `time_left`, `difficulty`,
  `modifiers` (perks, e.g. `{"extra_time": 1.5}`), `pointer`,
  `is_pointing_at()`, `finished(passed)`. Played as the main scene, it
  creates its own host and moves onto its phone (`host.hold(self)`;
  `_notification(NOTIFICATION_READY)`, so subclasses needn't call `super`).
- `MicrogameHost` (`scenes/Microgames/microgame_host.gd`, a `CanvasLayer`
  on layer 10): `await play(name, difficulty, modifiers) -> bool` (phone up,
  open, run, close, phone down), `run()` for a game already on screen,
  `hold(game)`, `has_game()`, signals `started` / `ended`. Its phone is
  `phone_screen` (Behind = Dim); the game goes in `game_slot`, the phone's
  screen.
  The game's `process_mode` is disabled during the banner and the stamp,
  which freezes it.
- `OptionList.microgame_host`: an option whose `#microgame` is in the
  library plays it instead of the roll, then calls
  `DateScorer.resolve_microgame(option, passed)`. `Result.played` is true
  for these. Unknown names warn and roll.
- `DateScorer.difficulty_of(option)` uses `DateRules.min_difficulty`,
  `max_difficulty` and `unchecked_difficulty`.
