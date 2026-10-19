# Game data: start here

Everything in this folder is **data you can change without code**. Click a
file in the FileSystem panel and edit it in the Inspector on the right.
Hover over any setting to see what it does.

| Folder | What's in it |
|---|---|
| `girls/` | One file per girl: name, bio, poses (each with its own size, nudge and flip), background, dialogue style, voice and lines. |
| `dialogue_styles/` | How each girl's dialogue box looks: colours, outline, font, name plate. `default.tres` is for anyone without their own. |
| `option_styles/` | How the player's choice buttons look and sound, including the roll. |
| `date_rules.tres` | The scoring numbers: odds limits, how much her likes matter, what a miss costs. |
| `reactions.tres` | The reaction animations (`[#react=heart]`). Double-click to edit. |

**Try your change:** open `scenes/Dates/FirstDate/FirstDateTest.tscn` and press **F6**.

**Step-by-step guides** in the project folder (or on GitHub):
- `docs/guides/dialogue-box.md`: box colours, picture boxes, fonts, voices,
  letter sounds, poses, writing lines
- `docs/guides/options-and-scoring.md`: writing options, odds, scoring,
  tuning, option buttons, reactions
