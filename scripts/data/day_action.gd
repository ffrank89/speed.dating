class_name DayAction
extends Resource
## One thing you can spend a day on: a date, training, a rest day, the boss... The
## calendar offers a few of these each day (data/calendar_rules.tres → Actions); pick
## one and it uses up its days.
##
## One file per action in data/day_actions/. Hover any setting to see what it does.
## Full guide: docs/guides/the-calendar.md

enum Kind {
	## Opens the dating app: swipe, then go on a date.
	DATE,
	## Raises one of your attributes.
	TRAIN,
	## Nothing happens (perks, items and events come later).
	REST,
	## The chapter's last day. For now: a message, then the next chapter.
	BOSS,
}

## What it's called on the calendar, e.g. "Date" or "Study".
@export var title: String = ""
## What it does, shown under its title on Today's choices. Optional.
@export_multiline var description: String = ""
## Its picture on the calendar.
@export var icon: Texture2D
## What happens when you pick it.
@export var kind: Kind = Kind.REST
## How many days it uses up (a date: 2, training: 1).
@export_range(1, 7) var days: int = 1
## How often the calendar offers it, compared to the other actions. 0 = never.
@export_range(0.0, 10.0, 0.1) var weight: float = 1.0

@export_group("Date")
## The app it opens like (a file name in data/apps/).
@export var app_name: String = "dating_app"
## The screen it opens.
@export_file("*.tscn") var scene: String = "res://scenes/Tinder/Screen.tscn"

@export_group("Train")
## Which attribute it raises.
@export var attribute: Attr.Id = Attr.Id.CULTURE
## By how much.
@export_range(0, 100) var amount: int = 5

@export_group("Message")
## The title in dialogue/calendar.dialogue that plays when you pick it (e.g. "train").
## The lines can use {{action}}, {{attribute}} and {{amount}}. Empty = no message.
@export var dialogue_title: String = ""
