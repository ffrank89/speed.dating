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

The player's attribute against the option's `#check` sets the
**difficulty** (0 = easiest, 1 = hardest) instead of the odds.

## Files

| File | What it is |
|---|---|
| `scenes/Microgames/_template/` | **The example to copy.** "CATCH IT!": click a bouncing logo. |
| `scenes/Microgames/microgame.gd` | `Microgame`, the base every microgame extends. Read its comments for the full toolbox. |
| `scenes/Microgames/MicrogameHost.tscn` | The shared frame, on the phone. Move the **Banner**, **TimerBar** and **Stamp** here (under **PhoneScreen → Phone → Body → Screen**). |
| `data/microgames.tres` | The list of microgames by name. A dialogue tag `[#microgame=name]` looks the name up here. |
| `data/microgame_style.tres` | How the frame looks and sounds (no code). |
| `data/date_rules.tres` → **Microgames** | How the player's attribute turns into difficulty. |
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

## Make your own: Light Her Cigarette

### 1. Copy the template

1. In the FileSystem panel, right-click `scenes/Microgames` → **Create New →
   Folder** → `light_cigarette`.
2. Right-click `_template/TemplateMicrogame.tscn` → **Duplicate…** → name it
   `light_cigarette/LightCigarette.tscn`.
3. Right-click `_template/template_microgame.gd` → **Duplicate…** → name it
   `light_cigarette/light_cigarette.gd`.
4. Open `LightCigarette.tscn`, click the top node, and drag
   `light_cigarette.gd` onto its **Script** slot (bottom of the Inspector).
   Rename the top node `LightCigarette`.

> Duplicate the two files one at a time like this. A duplicated scene would
> otherwise still point at the template's script, and editing it would
> change the example.

### 2. Set the frame

Click the top node. Under **Frame**:

| Setting | Set it to |
|---|---|
| **Banner Text** | `LIGHT IT!` |
| **Seconds** | `5` |
| **Pass When Time Runs Out** | off (the player has to *do* something in time) |
| **App** | optional: its own app file (icon and launch screen for the open animation). Duplicate `data/apps/microgame.tres`, set the lighter as its icon, and drag it here. |

### 3. Put it on the list

Click `data/microgames.tres` → **Games** → **Add Key/Value Pair** → type
`light_cigarette` on the left → drag `LightCigarette.tscn` onto the right.

That's the name her first date already uses, so **"Light it for her."**
plays your microgame from now on (until now it rolled, with a warning in the
Output panel).

### 4. Add the art

Delete the template's **Target** (the Godot logo). Keep **Window** (the
frame the game sits in) and **PlayArea**, or replace them. Drag in what you
need from the FileSystem panel:

| Art | File |
|---|---|
| Lighter | `assets/loghter.png` |
| Cigarette | `assets/cig_gif/cig1.png`, `cig2.png` |
| Her holding it | `assets/splitends/splitends_cig_updated.png` (crop or scale it into the window) |
| Flame, ember | not made yet: use `assets/placeholders/godot_logo.svg` for now |

Use **TextureRect** for still pictures and **AnimatedSprite2D** for
animations (flame flicker). Your game fills the phone's screen, **964 ×
1414**, portrait: the template's **Window** and **PlayArea** fill it with a
margin (and leave room at the top for the timer bar). Lay things out with
anchors (e.g. **Full Rect**, **Center**) so the game still fits if the phone
changes size.

> **Light Her Cigarette:** if you started it on the old full screen (3000 ×
> 1700, wide), it now plays on the phone's tall screen. Move its parts to
> fit 964 × 1414: e.g. her hand with the cigarette at the top, the lighter
> at the bottom.

### 5. Write the game

Open `light_cigarette.gd`. Keep `extends Microgame` at the top and replace
the template's code. The shape is always the same:

```gdscript
extends Microgame

# Numbers to tune in the Inspector: the easiest and hardest version of each.
@export var easiest_sway := ...
@export var hardest_sway := ...

func start(p_difficulty: float, _p_modifiers: Dictionary) -> void:
	# Runs once, before the banner. Turn difficulty into numbers:
	#   lerpf(easiest_sway, hardest_sway, p_difficulty)
	# and put everything in its starting place.
	pass

func _process(delta: float) -> void:
	# The game. Only runs while the timer runs.
	# Call win() when they've done it. Running out of time is a fail.
	pass
```

What the plan says it should feel like: **flick the lighter until it
catches, then hold the flame on the cigarette tip while she sways; fill a
meter before time runs out.** Pieces you'll want:

| To do this | Use |
|---|---|
| Flick the lighter (click **or** Space) | `Input.is_action_just_pressed("microgame_press")` |
| Hold something down | `Input.is_action_pressed("microgame_press")` |
| Is the flame on the tip? | `is_pointing_at($PlayArea/Tip)` (true when the mouse, or the keyboard pointer, is over that node) |
| Where the player is aiming | `pointer` (in the microgame's own space) or `pointer_on_screen()` |
| Move the flame with the player | set the flame node's `global_position` from `pointer_on_screen()` |
| Her swaying | change the cigarette's `position` with `sin(...)` over time; sway more at higher `difficulty` |
| A fill meter | a **ProgressBar** node; add to its `value` while the flame is on the tip |
| Time left | `time_left` (seconds) |
| End it | `win()` or `lose()` |

**Decisions that are yours** (they change how it plays, not how it's wired):
1. Does the lighter catch after a **fixed** number of flicks, or is each
   flick a **random** chance? Should difficulty change that?
2. When the flame leaves the tip, does the meter **drain** or just **pause**?
3. How much does she sway at difficulty 0, and at 1?

### 6. Test

- **F6** on `LightCigarette.tscn`: plays it over and over. Try **Test
  Difficulty** 0, 0.5 and 1. Check it's readable within half a second and
  fair at 1.
- Try it with **only the keyboard** (arrows/WASD + Space) and with **only
  the mouse**.
- **F6** on the date test bench: pick **"Light it for her."** when she asks for a light (or set
  the test bench's **Start Title** to `microgame_light_it`). Drag the **Seduction**
  slider (top left) to change the difficulty: at 5 or more the player meets
  the requirement and gets the easiest version.

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
| Max Difficulty | 1.0 | The player's attribute is the lowest (1) |
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
