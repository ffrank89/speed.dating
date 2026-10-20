class_name CalendarStyle
extends Resource
## How the calendar looks and sounds. Its boxes, font and name tabs come from Box Style,
## a dialogue-box style like a girl's (data/dialogue_styles/calendar.tres), so the
## calendar matches the dialogue boxes. This file sets the rest: words, sizes, which
## parts show, and sounds. Where the parts sit is in the scenes: scenes/Calendar/
## calendar.tscn, DayBox.tscn (one day) and DayChoice.tscn (one of today's choices).
## One file: data/calendar_style.tres. Full guide: docs/guides/the-calendar.md

## The boxes, font, colours and name tabs (a dialogue-box style).
@export var box_style: DialogueBoxStyle

@export_group("Words")
## The words can fill in blanks: {chapter}, {days} (days left, or days a choice takes),
## {weekday} and {day} (the day's number in the run).
## On the tab above the days (What Shows → Show Chapter).
@export var chapter_text: String = "CHAPTER {chapter}"
## Next to it.
@export var days_left_text: String = "{days} days to the boss"
@export var boss_today_text: String = "Boss day"
## On the tab above today's choices.
@export var today_text: String = "TODAY · {weekday}"
## Opens the whole calendar, and closes it again.
@export var expand_text: String = "See the whole month ▾"
@export var collapse_text: String = "Just this week ▴"
## Under each choice: how many days it uses.
@export var one_day_text: String = "1 day"
@export var many_days_text: String = "{days} days"
## On a choice that doesn't fit before the boss.
@export var not_enough_days_text: String = "Not enough days left"
## Under the boss day's picture (What Shows → Show Boss Text).
@export var boss_text: String = "BOSS"
## The weekdays, starting with day 1.
@export var weekdays: PackedStringArray = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

@export_group("Background")
## A picture behind the calendar, filling the screen. Empty = the animated pattern.
@export var background_image: Texture2D
## Laid over Background Image, to help the calendar stand out. A = how strong.
@export var background_dim: Color = Color(0, 0, 0, 0.2)

@export_group("What Shows")
## The "CHAPTER 1" tab above the days.
@export var show_chapter: bool = false
## Each day's number on its box (off = just the weekday).
@export var show_day_numbers: bool = false
## The "BOSS" caption under the boss day's picture.
@export var show_boss_text: bool = false
## Each day's weekday on its tab.
@export var show_weekdays: bool = true
## The little pictures of what each day offers.
@export var show_offers: bool = true
## The text that pops up when the mouse rests on a day (what it offers).
@export var show_tooltips: bool = true
## "6 days to the boss" above the days.
@export var show_days_left: bool = true
## The "See the whole month" button.
@export var show_expand_button: bool = true
## The line under each choice's title (its description and how many days).
@export var show_details: bool = true

@export_group("Days")
## Size of each day's box, in pixels.
@export var day_size: Vector2 = Vector2(330, 300)
## Size of each day's box when the whole month is open (smaller, so it all fits).
@export var month_day_size: Vector2 = Vector2(300, 250)
## Space between the days, in pixels.
@export_range(0, 100) var day_gap: int = 26
## Space inside each day's box, between its edge and what's in it (the dialogue boxes'
## Padding is too roomy for a box this small).
@export_range(0, 100) var day_padding: int = 16
## Size of the day's number.
@export_range(8, 200) var day_number_size: int = 64
## Size of the weekday on each day's tab.
@export_range(8, 120) var weekday_size: int = 30
## Size of the pictures of what a day offers.
@export_range(16, 200) var offer_icon_size: int = 84
## Size of the picture on a day that's been spent, the boss day, and the X.
@export_range(16, 300) var spent_icon_size: int = 150
## Days already gone fade to this (1 = not faded).
@export_range(0.0, 1.0, 0.05) var past_alpha: float = 0.45
## Today's box grows by this much, and gets this outline.
@export_range(1.0, 1.5, 0.01) var today_scale: float = 1.1
@export var today_outline_color: Color = Color(1.0, 0.84, 0.25)
@export_range(0, 30) var today_outline_width: int = 8
## Drawn on days you can't see yet (past this chapter). Empty = a ✕ in the text colour.
@export var hidden_mark: Texture2D
## Seconds between each week popping in when the whole calendar opens.
@export_range(0.0, 1.0, 0.01) var row_pop_seconds: float = 0.06

@export_group("Today's Choices")
## Size of each choice's picture.
@export_range(16, 300) var choice_icon_size: int = 130
## Size of each choice's title.
@export_range(8, 200) var choice_title_size: int = 56
## Size of the line under it (what it does, how many days).
@export_range(8, 200) var choice_detail_size: int = 34
## Show the 1, 2, 3 key next to each choice.
@export var show_keys: bool = true

@export_group("Sounds")
## The mouse moving onto a choice.
@export var hover_sound: AudioStream
## Picking a choice.
@export var pick_sound: AudioStream
## A choice that doesn't fit.
@export var blocked_sound: AudioStream
## Opening and closing the whole calendar.
@export var expand_sound: AudioStream
## A day being crossed off.
@export var day_done_sound: AudioStream
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -6.0


## The weekday of a calendar day (1 = the first of Weekdays).
func weekday(day_number: int) -> String:
	return weekdays[(day_number - 1) % weekdays.size()] if not weekdays.is_empty() else ""


## Fills in the blanks in one of the words above, e.g. words(chapter_text, {"chapter": 2}).
func words(text: String, blanks: Dictionary) -> String:
	return text.format(blanks)
