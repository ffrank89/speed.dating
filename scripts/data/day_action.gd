class_name DayAction
extends Resource
## One thing you can spend a day on. The calendar offers a few of these each day
## (data/calendar_rules.tres → Actions); pick one and it uses up its days.
##
## An action is made of parts, all optional, so a new one needs no code. When it's
## picked, in this order:
##   1. Attributes: it changes the player's attributes (e.g. Culture +5).
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
## The line under its title on today's choices. Empty = what it changes (e.g. "+5 Culture").
@export_multiline var description: String = ""
## Its picture on the calendar.
@export var icon: Texture2D
## How many days it uses up (a date: 2, training: 1).
@export_range(1, 7) var days: int = 1
## How often the calendar offers it, compared to the other actions. 0 = never.
@export_range(0.0, 10.0, 0.1) var weight: float = 1.0

@export_group("Attributes")
## How much it changes each of the player's attributes. 0 = no change; below 0 lowers it.
@export_range(-100, 100) var culture: int = 0
@export_range(-100, 100) var intellect: int = 0
@export_range(-100, 100) var seduction: int = 0
@export_range(-100, 100) var heart: int = 0

@export_group("Message")
## The title in dialogue/calendar.dialogue that plays when you pick it (e.g. "train").
## Empty = no message. The lines can use {{action}} (its title), {{changes}}
## ("Culture +5"), and {{attribute}} / {{amount}} (the first thing it changes).
@export var dialogue_title: String = ""

@export_group("Chapter")
## The boss day's action: instead of using up days, it ends the chapter and the next one
## starts. Put it in Calendar Rules → Boss, not in Actions.
@export var ends_chapter: bool = false

@export_group("Opens")
## A screen it opens afterwards, like an app (the date opens the dating app).
## Empty = it stays on the calendar.
@export_file("*.tscn") var scene: String = ""
## Which app it opens like (a file name in data/apps/: its icon and launch screen).
@export var app_name: String = ""


## What it changes, as {Attr.Id: amount}, leaving out the zeros.
func attribute_changes() -> Dictionary:
	var changes := {}
	var amounts := {
		Attr.Id.CULTURE: culture,
		Attr.Id.INTELLECT: intellect,
		Attr.Id.SEDUCTION: seduction,
		Attr.Id.HEART: heart,
	}
	for attr in amounts:
		if amounts[attr] != 0:
			changes[attr] = amounts[attr]
	return changes


## What it changes, in words: "Culture +5, Heart -2". Empty = nothing.
func changes_text() -> String:
	var parts: PackedStringArray = []
	var changes := attribute_changes()
	for attr in changes:
		parts.append("%s %+d" % [Attr.display_name(attr), changes[attr]])
	return ", ".join(parts)
