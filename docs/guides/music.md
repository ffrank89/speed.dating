# Music

For anyone choosing or swapping music. **No code needed.**

Music plays all through the game and fades from one track to the next as you
move between screens:

| Screen | Track (now) |
|---|---|
| The intro, the calendar (and Contacts, Profile over it) | `calendar` |
| The dating app | `dating_app` |
| A date | `date` |
| A microgame | whatever was playing, quieter |

`calendar` and `date` are the same file now, so going from the calendar to a
date doesn't restart it. One more track, `first_loop` (`real first loop
poop.ogg`), is in the library with no screen playing it yet: type its name
in a Music Cue to use it. The tracks are **placeholders**: their source and
licence aren't recorded yet ([replacing-placeholders.md](replacing-placeholders.md)).

## How it fits together

Three parts, so each kind of change has one home:

| Part | What it decides |
|---|---|
| `data/music.tres` | **Every track by name**, how they fade, how loud the music is |
| A **Music Cue** in a scene | **Which track plays there** (by name) |
| The **Music** autoload (`scenes/Music/Music.tscn`) | Plays it: fades, loops, gets quieter. Nothing to change here |

A scene without a Music Cue keeps whatever is playing (that's why Contacts and
Profile don't change the music).

## Change the music: `data/music.tres`

| Section | What's in it |
|---|---|
| **Tracks** | Every track by name. Click one to change it: **Stream** (the sound file: .ogg, .mp3 or .wav), **Volume dB** (louder or quieter than the others), **Loop** (on), **Loop Early Seconds** (starts again this many seconds before the end, for files with silence at the end; now 1.1), **Start At** (where it starts and loops back to) |
| **Changing Tracks** | **Fade Seconds** (1.5: how long one track takes to fade into the next), **Fade Out First** (off = they overlap; on = the old one fades out, then the new one fades in) |
| **Volume** | **Volume dB** (−8: all the music), **Bus** (`Music`: the Audio panel at the bottom of Godot, where it has a little reverb), **Microgame Quieter dB** (−12: how much quieter it gets during a microgame), **Quieter Seconds** |

| I want to... | Do this |
|---|---|
| Swap the date's music | `data/music.tres` → **Tracks** → `date` → drag the new file onto **Stream**. |
| A new track | **Tracks** → **Add Key/Value Pair**: type a name, then **New MusicTrack** and drag the file onto its **Stream**. |
| Music on another screen | Drag `scenes/Music/MusicCue.tscn` into that scene, and type the track's name in its **Track**. |
| Silence on a screen | A Music Cue with an empty **Track**. |
| A quicker or slower fade | **Fade Seconds** (all fades), or one cue's own **Fade Seconds** (−1 = the library's). |
| No quieter music during microgames | **Microgame Quieter dB** 0. |

## Where the cues are

| Scene | Its Music Cue's Track |
|---|---|
| `scenes/Intro/IntroQuestions.tscn` | `calendar` |
| `scenes/Calendar/calendar.tscn` | `calendar` |
| `scenes/Tinder/Screen.tscn` | `dating_app` |
| `scenes/Dates/Date/Date.tscn` | `date` (the test bench, F6 on `FirstDateTest.tscn`, plays it too) |

## Something's wrong

| Problem | Fix |
|---|---|
| No music at all | Godot prints which track is missing ("no track named …"). Check the cue's **Track** matches a name in **Tracks** exactly. Also check the **Music** bus isn't muted in the Audio panel. |
| A gap or a silent bit before it loops | Raise that track's **Loop Early Seconds**. |
| It restarts when it shouldn't | The two tracks use different files. Point both names at the same file. |

## For programmers

- `Music` (autoload, `scenes/Music/music.gd`): `play(name, fade := -1)`,
  `stop(fade := -1)`, `quieter(on)`, `current_track()`; signal
  `track_changed(name)`. Two `AudioStreamPlayer`s crossfade (the fade is a 0–1
  mix turned into dB). Looping uses the file's own loop flag, or
  `_process` with **Loop Early Seconds**. It keeps playing while the game is
  paused.
- `MusicLibrary` (`scripts/data/music_library.gd`): `tracks:
  Dictionary[String, MusicTrack]`, `track(name)`. `MusicTrack`
  (`scripts/data/music_track.gd`).
- `MusicCue` (`scenes/Music/music_cue.gd`): `track`, `fade_seconds`,
  `play_on_start`, `play()`.
- `MicrogameHost.play()` calls `Music.quieter(true)` / `(false)`.
