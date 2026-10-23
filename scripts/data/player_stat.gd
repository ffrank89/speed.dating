class_name PlayerStat
extends Resource
## One of the player's stats, e.g. Culture, Heart, or Fallout's S.P.E.C.I.A.L. (Strength,
## Perception, Endurance, Charisma, Intelligence, Agility, Luck). One file each in
## data/stats/; which stats the game has, in what order, and their scale (1-9) is
## data/stats.tres.
##
## A stat is just data, so it goes everywhere stats go: Profile and the intro list it,
## a calendar action can raise it (its Stats), a dialogue option can check it
## ([#check=strength:5]), and a girl can like it (her Likes). Turn it off to try the game
## without it. Full guide: docs/guides/stats.md

## Short name with no spaces, used in dialogue checks: [#check=strength:5].
@export var id: StringName
## Its name as players see it.
@export var display_name: String
## Off = the game acts as if it doesn't exist: not in Profile, the intro or the test
## bench, not raised by actions, and dialogue checks on it warn and don't roll.
@export var enabled: bool = true
## What it's for. Shown when the mouse rests on it in Profile.
@export_multiline var description: String
## Its picture: in Profile, and on option bubbles that check it.
@export var icon: Texture2D
## What it is at the start of a run (the intro's sliders start here too), when
## data/stats.tres → Start At is Each Stat's Own. Otherwise that setting decides.
@export_range(0, 100) var starting_value: int = 5
