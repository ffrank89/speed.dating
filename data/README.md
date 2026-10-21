# Game data: start here

Everything in this folder is **data you can change without code**. Click a
file in the FileSystem panel and edit it in the Inspector on the right.
Hover over any setting to see what it does.

| Folder | What's in it |
|---|---|
| `girls/` | One file per girl, everything about her: name, age, bio, interests and picture (her dating-app profile), her contact card, poses (each with its own size, nudge and flip), background, dialogue style, option style (optional), voice and first-date lines. Who's on the dating app: `scenes/Tinder/Screen.tscn` → **Girls**. |
| `dialogue_styles/` | How each girl's dialogue box looks: colours, outline, font, name plate. `default.tres` is for anyone without their own. |
| `option_styles/` | How the player's choice bubbles look, float and sound, including the roll and the drag trail. `default.tres` is shared; a girl can have her own. |
| `attribute_rules.tres` | The scale of the player's four attributes: **1 to 9** (Lowest, Highest), and the value they start at when a screen is played on its own (Default Value). The intro, training, Profile, the date test bench and the `#check` numbers in dialogue all use it. |
| `date_rules.tres` | How a date runs and scores: how many exchanges (and how many are microgames), the opener and closer names, odds limits, how much her likes matter, what a miss costs, how hard microgames get, and what her contact card shows. |
| `phone_style.tres` | **The player's phone**, shared by every phone screen (intro, dating app, calendar, Contacts, her card, microgames): its size and place, screen colour, wallpaper, rim, phone art, status bar, home bar, font, the room behind it, and how it comes up and goes down. |
| `dating_app_style.tres` | The dating app: its words, her profile card (in her dialogue style, or plain), the Pass / Start buttons, the swipe, and sounds. |
| `contact_card_style.tres` | The phone's Contacts: the end-of-date contact card (its words, typing speed, heart emoji and key sounds) and the Contacts app where your party is saved (the list's words, sizes and sounds). Her boxes and font come from her dialogue style; the phone from `phone_style.tres`. |
| `cursors/` | The player's cursor: picture, clicking spot, size, and optional hover, pressed and drag pictures. `default.tres` is the one the game uses. |
| `apps/` | One file per phone app (calendar, dating app, Contacts, Profile, microgame; date and boss kept for icons): its icon, tile colour, launch screen and sounds for the iPhone-style open animation. |
| `app_transition_style.tres` | How every app opens and closes inside the phone: timing, motion, icon size and roundness, the zoom and dim behind; and **Switching Apps**, how Contacts and Profile switch in like the iPhone's app switcher. |
| `microgames.tres` | Every microgame by the name writers use: `[#microgame=light_cigarette]`. Add one like a pose: Add Key/Value Pair. |
| `microgame_style.tres` | How the frame around every microgame looks and sounds (on the phone): dim over the date, banner, timer bar, NICE/OOPS stamp. |
| `reactions.tres` | The reaction animations (`[#react=heart]`). Double-click to edit. |
| `heart_meter_style.tres` | The heart meter on dates (top right): ring size, thickness and colours, the heart picture, the heart sound. Each girl's fill colour is her dialogue style's **Meter Color**. |
| `calendar_rules.tres` | How the calendar runs: days per chapter, the boss day, what each day can offer and how many choices, how much of the whole calendar shows, and how far ahead you can see. |
| `day_actions/` | One file per thing you can spend a day on (date, training, rest, boss): its name, picture, how many days it takes, how often it's offered, and what it does. |
| `player_style.tres` | **The player's own look**, the way a girl's dialogue style is hers: the calendar's day cards (colours, font, borders, shadow), the day colours (today, coming up, boss, X), the highlight on a choice under the mouse, and the Month button. |
| `calendar_style.tres` | How the calendar app is laid out and sounds: its words, the three day cards and today's choices (sizes, how many days come up), the whole month's squares, calendar art, the X on days you can't see. Its lines play in `dialogue_styles/calendar.tres`. |
| `music.tres` | **Every music track by name**, how one fades into the next, and how loud the music is. Which track plays on a screen is that scene's **Music Cue**. |

**Try your change:** press **F5** to play the game from the start (the
intro, then the calendar). Every screen can also be played on its own:
open it and press **F6**. For dates, the test bench
`scenes/Dates/FirstDate/FirstDateTest.tscn` plays a whole date with sliders
for the player's attributes.

**Step-by-step guides** in `docs/guides/` (in the project folder, or on GitHub):

| Guide | What's in it |
|---|---|
| `the-phone.md` | The player's phone: its look, your room, phone up and down, your apps (Contacts, Profile) |
| `phone-apps.md` | How apps open and close inside the phone |
| `the-calendar.md` | The calendar: days, choices, the month, its words and sounds |
| `dating-app.md` | The dating app: who's on it, her card, swiping |
| `the-full-date.md` | How a whole date plays: opener, exchanges, closers, her card |
| `dialogue-box.md` | Box colours, picture boxes, fonts, voices, letter sounds, poses, writing lines |
| `options-and-scoring.md` | Writing options, odds, scoring, tuning, option bubbles, reactions |
| `heart-meter.md` | The hearts on a date |
| `result-screen.md` | Her contact card at the end of a date |
| `contacts.md` | Your Contacts (your party) |
| `stage-hazards.md` | Things that turn up during a date (the fly) |
| `making-a-microgame.md` | Making a new microgame, step by step |
| `cursor.md` | The player's cursor |
| `music.md` | The music on each screen |
| `replacing-placeholders.md` | Every placeholder picture (the Godot logo), sound and music, and how to swap in the real ones |
