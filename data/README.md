# Game data: start here

Everything in this folder is **data you can change without code**. Click a
file in the FileSystem panel and edit it in the Inspector on the right.
Hover over any setting to see what it does.

| Folder | What's in it |
|---|---|
| `girls/` | One file per girl: name, bio, poses (each with its own size, nudge and flip), background, dialogue style, option style (optional), voice and lines. |
| `dialogue_styles/` | How each girl's dialogue box looks: colours, outline, font, name plate. `default.tres` is for anyone without their own. |
| `option_styles/` | How the player's choice bubbles look, float and sound, including the roll and the drag trail. `default.tres` is shared; a girl can have her own. |
| `date_rules.tres` | How a date runs and scores: how many exchanges (and how many are microgames), the opener and closer names, odds limits, how much her likes matter, what a miss costs, how hard microgames get, and what her contact card shows. |
| `phone_style.tres` | **The player's phone**, shared by every phone screen (intro, dating app, calendar, Contacts, her card, microgames): its size and place, screen colour, wallpaper, rim, phone art, status bar, home bar, font, the room behind it, and how it comes up and goes down. |
| `dating_app_style.tres` | The dating app: its words, her profile card (in her dialogue style, or plain), the Pass / Start buttons, the swipe, and sounds. |
| `contact_card_style.tres` | The phone's Contacts: the end-of-date contact card (its words, typing speed, heart emoji and key sounds) and the Contacts app where your party is saved (the list's words, sizes and sounds). Her boxes and font come from her dialogue style; the phone from `phone_style.tres`. |
| `cursors/` | The player's cursor: picture, clicking spot, size, and optional hover, pressed and drag pictures. `default.tres` is the one the game uses. |
| `apps/` | One file per phone app (calendar, dating app, Contacts, Profile, microgame; date and boss kept for icons): its icon, tile colour, launch screen and sounds for the iPhone-style open animation. |
| `app_transition_style.tres` | How every app opens and closes inside the phone: timing, motion, icon size and roundness, the zoom and dim behind. |
| `microgames.tres` | Every microgame by the name writers use: `[#microgame=light_cigarette]`. Add one like a pose: Add Key/Value Pair. |
| `microgame_style.tres` | How the frame around every microgame looks and sounds (on the phone): dim over the date, banner, timer bar, NICE/OOPS stamp. |
| `reactions.tres` | The reaction animations (`[#react=heart]`). Double-click to edit. |
| `heart_meter_style.tres` | The heart meter on dates (top right): ring size, thickness and colours, the heart picture, the heart sound. Each girl's fill colour is her dialogue style's **Meter Color**. |
| `calendar_rules.tres` | How the calendar runs: days per chapter, the boss day, what each day can offer and how many choices, how much of the whole calendar shows, and how far ahead you can see. |
| `day_actions/` | One file per thing you can spend a day on (date, training, rest, boss): its name, picture, how many days it takes, how often it's offered, and what it does. |
| `player_style.tres` | **The player's own look**, the way a girl's dialogue style is hers: the calendar's day cards (colours, font, borders, shadow), the day colours (today, coming up, boss, X), and the buttons (Pick, Contacts, Profile, Month). |
| `calendar_style.tres` | How the calendar app is laid out and sounds: its words, the three day cards and today's choices (sizes, how many days come up), the whole month's squares, calendar art, the X on days you can't see. Its lines play in `dialogue_styles/calendar.tres`. |

**Try your change:** press **F5**. It plays a whole date on the test bench (`scenes/Dates/FirstDate/FirstDateTest.tscn`) with sliders for the player's attributes.

**Step-by-step guides** in the project folder (or on GitHub):
- `docs/guides/dialogue-box.md`: box colours, picture boxes, fonts, voices,
  letter sounds, poses, writing lines
- `docs/guides/options-and-scoring.md`: writing options, odds, scoring,
  tuning, option buttons, reactions
- `docs/guides/replacing-placeholders.md`: every placeholder picture (the
  Godot logo) and sound, and how to swap in the real ones
