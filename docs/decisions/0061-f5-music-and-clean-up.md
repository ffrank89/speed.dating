# 0061: F5 plays the game, a new music system, girls are only girl files, and a clean-up (every picture kept)

- **Status:** Accepted
- **Date:** 2026-10-21
- **Affects:** [0025](0025-runstate-replaces-playermanager.md), [0026](0026-girldata-partymember-split.md), [girls.md](../design/girls.md), [perks.md](../design/perks.md), [player.md](../design/player.md)

## Decision

- **F5 plays the game** from the start: the intro (**Your Profile**), then
  the calendar. Every test bench is still **F6** on its own scene (the
  date's is `scenes/Dates/FirstDate/FirstDateTest.tscn`).
- **The window scales.** The game is drawn at 3000 × 1700 and scaled to fit
  the window, keeping its shape (Project Settings → Display → Window →
  Stretch: `canvas_items`, `keep`). The window opens at 1500 × 850 and can
  be resized or made full screen.
- **New music system** (the old `MusicManager` was deleted): every track by
  name in `data/music.tres` (a `MusicLibrary`: each track's file, volume and
  loop, how tracks fade, how loud the music is). A scene picks its music with
  a **Music Cue** (`scenes/Music/MusicCue.tscn`); a scene without one keeps
  what's playing. The **Music** autoload crossfades between tracks, never
  restarts the same file, and goes quieter during microgames. Guide:
  [music.md](../guides/music.md).
- **Girls are only girl files.** The old `DateCharacter` classes are gone:
  her dating-app profile (age, bio, interests and a new **Profile Picture**)
  is in her girl file, the dating app lists girl files in its **Girls**, and
  `PlayerManager` keeps girl files (`current_girl`, the party, gone for the
  run). Smokey has a girl file now (`data/girls/smokey.tres`: profile,
  poses, background), but the dating app hides a girl with no **First Date
  Dialogue**, so she's hidden until she has one.
- **Clean-up:** old prototype code the game no longer used was deleted
  (`image_scenes/`, `icon_scenes/`, `icons/`, `scenes/Border`,
  `scenes/ScoreDisplay`, `scenes/Dates/BaseDate`, the old calendar
  background, perks and inventory items, `spritebackground.tscn`), along
  with the old m1–m3 test dialogues, an unused font (`script-VF.ttf`), a
  duplicate of the calendar music (`second ss free loop.m4a`), leftover
  `print()`s and `.DS_Store` files (now ignored by git). Everything is still
  in the git history. `PlayerManager` keeps just the run's state. Docs that
  had drifted from the code were brought up to date.
- **Every picture stays,** used or not (about 47 MB the game doesn't use
  yet, e.g. old poses, backgrounds, posters and stat frames): they were
  deleted at first, then put back.

## Why

Frank, 2026-10-21, after the audit: "Do 2 and 5. Delete the current music
manager and come up with a new one with the same modular design patterns as
the rest of the project". Item 2 was "Make F5 start the real game, and add
a stretch mode so the window scales"; item 5 was the clean-up: legacy
folders, unused assets, `print()`s, `.DS_Store`, merging the girl info into
the girl files, and the doc drift. Then: "Add all the unused pictures
back."

## Not chosen

- Keeping each girl's old class next to her girl file (two places to
  change one girl).
- Showing a girl with no first date and sending her date to Split Ends'
  file (what happened to Smokey before): picking her played the wrong girl.
- Music chosen in code per scene, or one big music scene: a cue in each
  scene keeps "what plays here" next to the scene, and the library keeps
  every file in one place, like the other style files.
- Deleting the unused pictures: they're art that may still be wanted, so
  they all stay. The Kenney sound pack, the letter sounds and the music
  loops stay too.

## Revisit when

`RunState` replaces `PlayerManager` ([0025](0025-runstate-replaces-playermanager.md)),
more girls get first dates (Smokey shows up then), or the music needs more
than one track per screen (e.g. layers that change during a date).
