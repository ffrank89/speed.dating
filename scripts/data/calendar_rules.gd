class_name CalendarRules
extends Resource
## How the run's calendar is laid out and what it offers. One file:
## data/calendar_rules.tres. Change these to make chapters longer or shorter, or to
## change what turns up on which days.
## Full guide: docs/guides/the-calendar.md

@export_group("Chapter")
## Days in a chapter. The last one is always the boss.
@export_range(2, 30) var days_per_chapter: int = 7
## The boss day's action (data/day_actions/boss.tres).
@export var boss: DayAction

@export_group("What's Offered")
## Everything a day can offer. Each day draws from these at random, more often the
## higher an action's Weight. Add one: Add Element, then drag in a file from
## data/day_actions/.
@export var actions: Array[DayAction] = []
## How many choices each day offers (no repeats in a day).
@export_range(1, 4) var options_per_day: int = 3

@export_group("The Whole Calendar")
## How many days the whole calendar shows when you open it up (28 = four weeks).
@export_range(7, 120) var calendar_days: int = 28
## How many days past this chapter you can see into. 0 = every day after this
## chapter shows an X. Something like a "see the future" ability can raise this later.
@export_range(0, 120) var foresight_days: int = 0
