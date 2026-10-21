# speed dating

A dating roguelike made in Godot 4.4. Each run is a calendar of days: date
girls on a dating app, train, rest, and face a life-event boss at the end of
the chapter with the girls who gave you their number. Dates are dialogue
with risky options, quick microgames and things that turn up mid-date.

The design is in [docs/design/core-loop.md](docs/design/core-loop.md).

## Play it

1. Install **Godot 4.4** (the standard version) from godotengine.org.
2. Open Godot → **Import** → pick this folder's `project.godot`.
3. Press **F5**. The game starts at **Your Profile** (your starting stats),
   then the calendar.

Any screen can be played on its own: open its scene and press **F6**. The
date's test bench is `scenes/Dates/FirstDate/FirstDateTest.tscn`.

## Change things without code

Almost everything is a file you edit in Godot's Inspector: click it in the
FileSystem panel, change it on the right, and hover any setting to see what
it does.

- **Start here:** [data/README.md](data/README.md) lists every data file
  (girls, styles, rules, music) and every guide.
- **Step-by-step guides:** [docs/guides/](docs/guides/) (the phone, the
  calendar, the dating app, dates, dialogue, microgames, music, placeholders).
- **Why things are the way they are:** [docs/decisions/](docs/decisions/README.md).

## What's where

| Folder | What's in it |
|---|---|
| `data/` | The game's data: girls, looks (styles), rules, music. No code. |
| `dialogue/` | What everyone says (`.dialogue` files, Dialogue Manager format) |
| `scenes/` | The screens and their parts: `Intro`, `Calendar`, `Tinder` (the dating app), `Dates`, `Dialogue`, `Microgames`, `Hazards`, `Results` (her contact card), `Phone` (the phone, Contacts, Profile, how apps open), `Stats` (Stat Bars, the stats hub), `Music`, `Cursor`, `Debug` |
| `scripts/` | Shared code: the data types (`scripts/data/`), date scoring, the run's calendar, the player, `PlayerManager` (the run's state) |
| `assets/` | Pictures, fonts and sounds |
| `addons/` | Dialogue Manager |
| `docs/` | Design (`design/`), guides (`guides/`), decisions (`decisions/`) and plans (`plans/`) |

Placeholder art is the Godot logo; placeholder sounds are Kenney's (CC0).
Every placeholder, and how to replace it, is in
[docs/guides/replacing-placeholders.md](docs/guides/replacing-placeholders.md).
Third-party material and licences: [CREDITS.md](CREDITS.md).

## Early screenshots (2025)

<img width="1234" height="728" alt="Screenshot 2025-11-02 at 6 39 18 PM" src="https://github.com/user-attachments/assets/0d7235bc-d057-4432-a38a-9245fc6b5f35" />
<img width="1501" height="849" alt="Screenshot 2025-11-02 at 6 38 09 PM" src="https://github.com/user-attachments/assets/9275c15e-7c84-4b80-a02c-9f1d77b6c5cf" />
