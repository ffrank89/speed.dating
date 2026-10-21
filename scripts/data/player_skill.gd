class_name PlayerSkill
extends Resource
## One of the player's skills (Fallout: New Vegas's set: Barter, Speech, Sneak...), next
## to their four attributes. One file each in data/skills/; which ones the game has, and
## in what order, is data/skills.tres.
##
## A skill is just data, so it can go anywhere a stat can: Profile shows it, the intro
## sets it, a calendar action can raise it (its Skills), and a dialogue option can check
## it ([#check=speech:5]). Skills use the attributes' scale, 1-9
## (data/attribute_rules.tres). Full guide: docs/guides/skills.md

## Short name with no spaces, used in dialogue checks: [#check=speech:5].
@export var id: StringName
## Its name as players see it.
@export var display_name: String
## Off = the game acts as if it doesn't exist: not in Profile or the intro, not raised by
## actions, and dialogue checks on it warn and don't roll.
@export var enabled: bool = true
## What it's for. Shown when the mouse rests on it in Profile.
@export_multiline var description: String
## Its picture (Profile, the intro, option bubbles that check it).
@export var icon: Texture2D
## What it is at the start of a run (and when a screen is played on its own).
@export_range(0, 100) var starting_value: int = 1
