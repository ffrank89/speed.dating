class_name DayAction
extends Resource
## One thing you can spend a day on. The calendar offers a few of these each day
## (data/calendar_rules.tres → Actions); pick one and it uses up its days.
##
## An action is made of parts, all optional, so a new one needs no code. When it's
## picked, in this order:
##   1. Stats: it changes the player's stats (e.g. Culture +1, Strength +1).
##   2. Message: a line from dialogue/calendar.dialogue plays in the calendar's box.
##   3. Its days are used up, or, with Ends Chapter, the next chapter starts.
##   4. Opens: it opens a screen like an app (e.g. the dating app).
## The date, the trainings, the rest day and the boss in data/day_actions/ are just
## different mixes of these.
##
## One file per action in data/day_actions/. Hover any setting to see what it does.
## Full guide: docs/guides/the-calendar.md

## What it's called on the calendar, e.g. "Date" or "Train Culture".
@export var title: String = ""
## The line under its title on today's choices. Empty = what it changes (e.g. "Culture +1").
@export_multiline var description: String = ""
## Its picture on the calendar.
@export var icon: Texture2D
## How many days it uses up (a date: 2, training: 1).
@export_range(1, 7) var days: int = 1
## How often the calendar offers it, compared to the other actions. 0 = never.
@export_range(0.0, 10.0, 0.1) var weight: float = 1.0

@export_group("Stats")
## How much it changes the player's stats: Add Key/Value Pair, drag a stat file from
## data/stats/ on the left and type the amount on the right (e.g. Culture 1; below 0
## lowers it). A stat never goes past the list's Lowest or Highest (data/stats.tres), and
## stats that are off are left alone.
@export var stats: Dictionary[PlayerStat, int] = {}

@export_group("Message")
## The title in dialogue/calendar.dialogue that plays when you pick it (e.g. "train").
## Empty = no message. The lines can use {{action}} (its title), {{changes}}
## ("Culture +1"), and {{stat}} / {{amount}} (the first thing it changes).
@export var dialogue_title: String = ""

@export_group("Chapter")
## The boss day's action: instead of using up days, it ends the chapter and the next one
## starts. Put it in Calendar Rules → Boss, not in Actions.
@export var ends_chapter: bool = false

@export_group("Opens")
## A screen it opens afterwards, like an app on the phone (the date opens the dating
## app). Empty = it stays on the calendar.
@export_file("*.tscn") var scene: String = ""
## Which app it opens like (a file name in data/apps/: its icon and launch screen).
@export var app_name: String = ""
## On = Scene is real life (e.g. a boss fight): the phone goes down into it instead of
## the screen opening as an app (data/phone_style.tres → Phone Up / Down).
@export var real_life: bool = false


## What it changes in the stats that are on, as {PlayerStat: amount}, leaving out the
## zeros.
func stat_changes() -> Dictionary:
	var changes := {}
	var list := StatList.get_default()
	for stat in stats:
		if list.is_active(stat) and stats[stat] != 0:
			changes[stat] = stats[stat]
	return changes


## Everything it changes, in the stat list's order: [{"name": "Culture", "amount": 1}, ...].
func change_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var changes := stat_changes()
	for stat in StatList.get_default().stats:
		if changes.has(stat):
			list.append({"name": stat.display_name, "amount": changes[stat]})
	return list


## What it changes, in words: "Culture +1, Strength +1". Empty = nothing.
func changes_text() -> String:
	var parts: PackedStringArray = []
	for change in change_list():
		parts.append("%s %+d" % [change.name, change.amount])
	return ", ".join(parts)
