# Phone apps: the "open app" animation

For artists and designers. **No code needed** to change how apps look or
feel; one line of code to make something new open like an app.

Every app on the player's phone opens like an app on an iPhone: the app's
icon grows from where the player tapped until it fills **the phone's
screen** with the app's **launch screen**, what was on the phone zooms and
dims, and then the real app appears. Closing shrinks it back into its icon.
It's one shared animation (`AppLauncher`), used by:

| What opens | App file | Opens from |
|---|---|---|
| The calendar (after the intro, and after a date) | `data/apps/calendar.tres` | Where the player clicked, or the bottom of the phone's screen |
| The dating app (a **Date** on the calendar) | `data/apps/dating_app.tres` | The Date choice (the app named in `data/day_actions/date.tres`) |
| A microgame (once the phone is up over the date) | the microgame's **App**, or `data/apps/microgame.tres` | The bottom of the phone's screen, and closes back into it |
| Your **Contacts** (press **C** on the calendar) | `data/apps/contacts.tres` | Default Origin (a key press has no click), and closes back into it ([contacts.md](contacts.md)) |

Going into **real life** isn't an app: a date starts with **phone down**
(the phone drops away and the date is there), and the end of a date brings
the **phone up** with her card on it ([the-phone.md](the-phone.md)).
`data/apps/date.tres` and `boss.tres` are kept for icons, but nothing opens
them like apps any more.

## Try it

Open `scenes/Phone/PhoneAppsTest.tscn` and press **F6**: a pretend home
screen on the phone with one icon per file in `data/apps/`. Click one to open it, and
press **Home** (or Escape) to close it. Tune things while it runs.

## Change an app's look

Click its file in `data/apps/`:

| Setting | What it does |
|---|---|
| **App Name** | Shown under the icon on a home screen |
| **Icon → Icon** | The icon art. Placeholders now (our existing icons: the January calendar, the winged heart, the red heart, the sword, the exclamation mark; the Godot logo for Contacts). |
| **Icon → Icon Background** | The rounded tile behind the art |
| **Icon → Icon Padding** | How far the art sits in from the tile's edge. **0** for finished app-icon art that has its own background. |
| **Launch Screen → Launch Color** | The colour that fills the screen while it opens |
| **Launch Screen → Launch Image** | Optional full-screen art shown while it opens (covers the colour) |
| **Launch Screen → Launch Icon Size** | How big the icon is in the middle of the launch screen. 0 = none. |
| **Sounds** | Optional open/close sounds just for this app |

**When the real app art arrives:** drag it onto **Icon**, set **Icon
Padding** to 0, and (optionally) drag a launch screen onto **Launch Image**.
Square icons work best; the corners are rounded for you.

## Change how every app opens

`data/app_transition_style.tres`:

| Section | What's in it |
|---|---|
| Opening | How long the icon takes to grow (0.5 s), the shape of the motion (Expo + Out feels like an iPhone), how long the launch screen stays, how long it fades |
| Closing | The same for shrinking back |
| Icon | The size of the icon when nothing was tapped, how rounded icons are (0.225 ≈ iPhone), how long a click is remembered, and **Default Origin**, where apps open from after a key press (bottom middle, like the dock) |
| Screen | **Open Into Phone** (on): apps open inside the phone's screen (**Phone**: `data/phone_style.tres`), with its rounded corners, and Default Origin is inside the phone. Off: apps fill the whole screen minus the insets (and **Screen Corner**). **Device Frame**: optional art drawn over everything while apps open and close (3000 × 1700); with the phone, use the phone's own **Phone Art** instead. |
| Behind | How much what's behind zooms (1.08; inside the phone, just the phone's screen) and the colour it dims to |
| Sounds | The default open and close sounds (Kenney Interface Sounds) |

## Give a microgame its own app

Click the microgame's top node → **Frame → App** → drag in an app file
(make one by duplicating `data/apps/microgame.tres`). Empty = the shared
microgame app. Turn the opening off with `data/microgame_style.tres` →
**Opening → Open As App** (it fades in on the phone instead).

## Make something new open like an app

1. Make its app file: right-click any file in `data/apps/` → **Duplicate…**,
   name it (lowercase, no spaces), and change its icon and colours.
2. Build the scene on the phone ([the-phone.md](the-phone.md) → A new phone
   screen), and wherever the game changes to it, use one line:

```gdscript
AppLauncher.open_scene("notes", "res://scenes/Notes/Notes.tscn")
```

`"notes"` is the file name in `data/apps/`. Add a rectangle to open from a
particular button: `AppLauncher.open_scene("notes", path, button.get_global_rect())`.

A **real-life** scene (the boss fight) uses phone down instead:
`AppLauncher.phone_down("res://scenes/Boss/Boss.tscn")`, or a day action
with **Opens → Real Life** on.

For things that appear over the current scene instead of replacing it (like
microgames):

```gdscript
await AppLauncher.open("my_app", func(): my_overlay.visible = true, from_rect)
await AppLauncher.close("my_app", func(): my_overlay.visible = false, from_rect)
```

## Icons on a home screen

`AppIcon` (`scenes/Phone/app_icon.gd`) draws an app's icon the same way the
animation does (rounded tile, art, name underneath). Drop one in a scene,
drag an app file onto its **App** slot, and open it from its tile:
`AppLauncher.open_scene(icon.app, path, icon.tile_rect())`. The test home
screen is built from these.

## Something's wrong

| Problem | Fix |
|---|---|
| A screen changes with no animation | Check the code calls `AppLauncher.open_scene(...)` and the app name matches a file in `data/apps/` exactly. A missing file shows a warning in the Output panel and the screen just changes. |
| The app grows from the wrong place | It grows from the last click (within **Tap Memory Seconds**) or from **Default Origin**. Pass a rectangle to open from a particular button. |
| The icon art looks squashed or tiny | Square art works best. Lower **Icon Padding** for bigger art. |
| Clicking does nothing for half a second | Clicks are blocked while an app opens or closes, on purpose. Make it faster with **Opening → Open Seconds**. |
| Apps fill the whole screen, not the phone | **Screen → Open Into Phone** is off, or **Phone** is empty. |

## For programmers

- `AppLauncher` (autoload, `scenes/Phone/AppLauncher.tscn`, a `CanvasLayer`
  on layer 100): `open_scene(app, path, from)`, `open(app, swap, from)`,
  `close(app, swap, to)`, `phone_down(scene_path)`, `get_app(name)`,
  `is_busy()`, `origin_rect()`, `home_rect()`; signals `opening`, `opened`,
  `closing`, `closed`, `phone_went_down`. `app` is an `AppInfo` or a file
  name in `data/apps/`.
- Opening screenshots the current screen: the phone's screen part zooms and
  dims in **Window** (cut to the phone's rounded screen), and **Outside**
  (the rest, with a hole for the phone) fades into the new scene after the
  swap. It grows the tile, calls `swap` once the tile covers its target,
  then fades the tile. `open_scene` loads the scene on a thread while the
  tile grows.
- `phone_down` screenshots the screen, cuts the phone out into **Drop**,
  changes scene underneath, then drops the phone and fades **Outside**.
- Closing screenshots the app into the tile, calls `swap` (so the live
  screen behind is back), then shrinks the tile into `to`.
- Wired in: `intro_questions.gd` (→ calendar), `calendar.gd` (a Date choice
  opens its action's **App Name** and **Scene**; **Real Life** → phone
  down), `screen.gd` (Start → `phone_down` into the date), `date_scene.gd`
  (her card → calendar), `ContactsApp` (C), `MicrogameHost.play()`.
