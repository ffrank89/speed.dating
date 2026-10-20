class_name RunCalendar
extends RefCounted
## The run's calendar: which chapter it is, which day, and what every day offers.
## Made from data/calendar_rules.tres and kept on PlayerManager for the whole run
## (PlayerManager.get_calendar()).
##
## Days are counted two ways: a chapter's days (1 to Days Per Chapter, "today" is one
## of these) and calendar days (1 = the run's first day), used by the whole-calendar view.

## One day of the calendar.
class Day:
	extends RefCounted
	## What's offered that day (the boss day offers only the boss).
	var options: Array[DayAction] = []
	## What the player spent it on. Null = not spent (yet).
	var spent_on: DayAction
	## True when the day before used it up (the second day of a two-day date).
	var continued := false


var rules: CalendarRules
var chapter := 1
## Today, counting from 1 at the start of the chapter.
var today := 1
var _rng := RandomNumberGenerator.new()
# Chapter number -> its days, planned when first needed (this chapter, or foresight).
var _plans := {}


func _init(calendar_rules: CalendarRules) -> void:
	rules = calendar_rules
	_rng.randomize()


## This chapter's days, first to last (the boss).
func days() -> Array[Day]:
	return _plan(chapter)


func today_day() -> Day:
	return days()[today - 1]


func is_boss_day() -> bool:
	return today == rules.days_per_chapter


## Days left before the boss day (0 on the boss day).
func days_until_boss() -> int:
	return rules.days_per_chapter - today


## Whether `action` fits: everything but the boss has to be done before the boss day.
func fits(action: DayAction) -> bool:
	if action.kind == DayAction.Kind.BOSS:
		return true
	return today + action.days - 1 < rules.days_per_chapter


## Spends today (and the days after it, for a longer action) on `action`.
func spend(action: DayAction) -> void:
	var chapter_days := days()
	for i in action.days:
		var index := today - 1 + i
		if index < chapter_days.size():
			chapter_days[index].spent_on = action
			chapter_days[index].continued = i > 0
	today += action.days


## Moves on to the next chapter's first day.
func next_chapter() -> void:
	chapter += 1
	today = 1


## The calendar-day number of a day in this chapter.
func calendar_day(chapter_day: int) -> int:
	return (chapter - 1) * rules.days_per_chapter + chapter_day


## The calendar-day number of today.
func calendar_today() -> int:
	return calendar_day(today)


## How many days the whole-calendar view shows.
func calendar_length() -> int:
	return maxi(rules.calendar_days, chapter * rules.days_per_chapter)


## Any day of the calendar, by its calendar-day number (plans its chapter if needed).
func day_at(number: int) -> Day:
	var its_chapter := (number - 1) / rules.days_per_chapter + 1
	return _plan(its_chapter)[(number - 1) % rules.days_per_chapter]


## Whether the day shows what's on it: days up to the end of this chapter, plus
## Foresight Days past it. Later days show an X.
func is_revealed(number: int) -> bool:
	return number <= chapter * rules.days_per_chapter + rules.foresight_days


## Whether the day is a boss day (the last of its chapter).
func is_boss(number: int) -> bool:
	return number % rules.days_per_chapter == 0


func _plan(chapter_number: int) -> Array[Day]:
	if not _plans.has(chapter_number):
		var planned: Array[Day] = []
		for i in rules.days_per_chapter:
			var day := Day.new()
			if i == rules.days_per_chapter - 1 and rules.boss:
				day.options = [rules.boss]
			else:
				day.options = _draw_options()
			planned.append(day)
		_plans[chapter_number] = planned
	return _plans[chapter_number]


# Options Per Day different actions, picked at random by their Weight.
func _draw_options() -> Array[DayAction]:
	var pool: Array[DayAction] = []
	for action in rules.actions:
		if action and action.weight > 0.0 and not action in pool:
			pool.append(action)
	var picked: Array[DayAction] = []
	while picked.size() < rules.options_per_day and not pool.is_empty():
		var total := 0.0
		for action in pool:
			total += action.weight
		var roll := _rng.randf() * total
		for action in pool:
			roll -= action.weight
			if roll <= 0.0 or action == pool.back():
				picked.append(action)
				pool.erase(action)
				break
	return picked
