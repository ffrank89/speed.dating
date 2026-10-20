# Game data: start here

Everything in this folder is **data you can change without code**. Click a
file in the FileSystem panel and edit it in the Inspector on the right.
Hover over any setting to see what it does.

| Folder | What's in it |
|---|---|
| `girls/` | One file per girl: name, bio, poses (each with its own size, nudge and flip), background, dialogue style, option style (optional), voice and lines. |
| `dialogue_styles/` | How each girl's dialogue box looks: colours, outline, font, name plate. `default.tres` is for anyone without their own. |
| `option_styles/` | How the player's choice bubbles look, float and sound, including the roll and the drag trail. `default.tres` is shared; a girl can have her own. |
| `date_rules.tres` | The scoring numbers: odds limits, how much her likes matter, what a miss costs, and how hard microgames get. |
| `microgames.tres` | Every microgame by the name writers use: `[#microgame=light_cigarette]`. Add one like a pose: Add Key/Value Pair. |
| `microgame_style.tres` | How the frame around every microgame looks and sounds: dim, banner, timer bar, NICE/OOPS stamp. |
| `reactions.tres` | The reaction animations (`[#react=heart]`). Double-click to edit. |

**Try your change:** open `scenes/Dates/FirstDate/FirstDateTest.tscn` and press **F6**.

**Step-by-step guides** in the project folder (or on GitHub):
- `docs/guides/dialogue-box.md`: box colours, picture boxes, fonts, voices,
  letter sounds, poses, writing lines
- `docs/guides/options-and-scoring.md`: writing options, odds, scoring,
  tuning, option buttons, reactions
- `docs/guides/replacing-placeholders.md`: every placeholder picture (the
  Godot logo) and sound, and how to swap in the real ones
