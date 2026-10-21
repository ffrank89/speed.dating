class_name CalendarStyle
extends Resource
## How the calendar app looks and sounds. It's an app on your phone: the phone, its
## screen, its font (the title, "TODAY") and your room behind it are the phone's style
## (data/phone_style.tres). The calendar's boxes, font and name tabs come from Box Style,
## a dialogue-box style like a girl's (data/dialogue_styles/calendar.tres), so it
## matches the dialogue boxes. This file sets the rest: words, sizes, which parts show,
## and sounds. Where the parts sit is in the scenes: scenes/Calendar/calendar.tscn,
## DayRow.tscn (a day in the week list), DayBox.tscn (a day in the whole month) and
## DayChoice.tscn (one of today's choices).
## One file: data/calendar_style.tres. Full guide: docs/guides/the-calendar.md

## The boxes, font, colours and name tabs (a dialogue-box style).
@export var box_style: DialogueBoxStyle

@export_group("Words")
## The words can fill in blanks: {chapter}, {days} (days left, or days a choice takes),
## {weekday} and {day} (the day's number in the run).
## The app's big title at the top.
@export var title_text: String = "Calendar"
## On the tab above the days (What Shows → Show Chapter).
@export var chapter_text: String = "CHAPTER {chapter}"
## Next to it.
@export var days_left_text: String = "{days} days to the boss"
@export var boss_today_text: String = "Boss day"
## Above today's choices.
@export var today_text: String = "TODAY · {weekday}"
## On today's row in the week (What Shows → Show Day Words).
@export var today_word: String = "Today"
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

@export_group("Calendar Art")
## A picture for the calendar itself: the page the days sit on (e.g. a paper calendar).
## Empty = the calendar's box style. Drop finished calendar art in here, like the
## iPhone frame. Try pictures in scenes/Calendar/CalendarTest.tscn.
@export var page_image: Texture2D
## How many pixels in from each edge of Page Image are frame that never stretches
## (e.g. a spiral binding along the top). 0 = the whole picture stretches to fit.
@export_range(0, 2048) var page_image_margin: int = 0
## Space between the page's edges and what's on it, in pixels (with Page Image).
@export_subgroup("Page Padding")
@export_range(0, 1000) var page_padding_left: int = 40
@export_range(0, 1000) var page_padding_top: int = 40
@export_range(0, 1000) var page_padding_right: int = 40
@export_range(0, 1000) var page_padding_bottom: int = 40
@export_subgroup("")
## Colour of the words on the page with Page Image.
@export var page_text_color: Color = Color(0.1, 0.1, 0.12)
## A picture for each day's box. Empty = the calendar's box style.
@export var day_image: Texture2D
## How many pixels in from each edge of Day Image never stretch. 0 = it all stretches.
@export_range(0, 1024) var day_image_margin: int = 0
## Colour of the words on a day (its number, BOSS, the ✕) with Day Image.
@export var day_text_color: Color = Color(0.1, 0.1, 0.12)

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
## Words on each day in the week list: what a past day was spent on, "Today", the boss.
@export var show_day_words: bool = true
## "6 days to the boss" above the days.
@export var show_days_left: bool = true
## The "See the whole month" button.
@export var show_expand_button: bool = true
## The line under each choice's title (its description and how many days).
@export var show_details: bool = true

@export_group("Week")
## The week list: one row per day of this chapter (scenes/Calendar/DayRow.tscn).
## Height of each day's row, in pixels.
@export_range(30, 300) var week_row_height: int = 74
## Space between the rows, in pixels.
@export_range(0, 60) var week_gap: int = 10
## Width of the weekday tab at the left of each row, in pixels.
@export_range(40, 300) var week_tab_width: int = 120
## Size of the pictures of what a day offers.
@export_range(16, 200) var week_offer_icon_size: int = 54
## Size of the picture on a day that's been spent, the boss day, and the X.
@export_range(16, 200) var week_spent_icon_size: int = 58
## Size of the words on a row (What Shows → Show Day Words).
@export_range(8, 120) var week_words_size: int = 34
## Today's row grows by this much.
@export_range(1.0, 1.3, 0.01) var week_today_scale: float = 1.0

@export_group("Month")
## The whole month, when "See the whole month" is open (scenes/Calendar/DayBox.tscn).
## Size of each day's box, in pixels.
@export var month_day_size: Vector2 = Vector2(98, 92)
## Space between the days, in pixels.
@export_range(0, 60) var month_gap: int = 8
## Size of the weekday on each day's tab.
@export_range(8, 120) var month_weekday_size: int = 22
## Size of the pictures of what a day offers.
@export_range(8, 200) var month_offer_icon_size: int = 26
## Size of the picture on a day that's been spent, the boss day, and the X.
@export_range(16, 200) var month_spent_icon_size: int = 62
## Today's box grows by this much.
@export_range(1.0, 1.5, 0.01) var month_today_scale: float = 1.08
## Seconds between each week popping in when the whole month opens.
@export_range(0.0, 1.0, 0.01) var row_pop_seconds: float = 0.06

@export_group("Days")
## For both the week list and the month.
## Space inside the box the days sit on (with no Page Image), in pixels.
@export_range(0, 200) var page_box_padding: int = 18
## Space inside each day's box, between its edge and what's in it (the dialogue boxes'
## Padding is too roomy for a box this small).
@export_range(0, 100) var day_padding: int = 8
## Size of the day's number (What Shows → Show Day Numbers).
@export_range(8, 200) var day_number_size: int = 40
## Size of the weekday on each day's tab in the week list.
@export_range(8, 120) var weekday_size: int = 30
## Days already gone fade to this (1 = not faded).
@export_range(0.0, 1.0, 0.05) var past_alpha: float = 0.45
## Today's outline.
@export var today_outline_color: Color = Color(1.0, 0.84, 0.25)
@export_range(0, 30) var today_outline_width: int = 6
## Drawn on days you can't see yet (past this chapter). Empty = a ✕ in the text colour.
@export var hidden_mark: Texture2D

@export_group("Today's Choices")
## Size of each choice's picture.
@export_range(16, 300) var choice_icon_size: int = 80
## Size of each choice's title.
@export_range(8, 200) var choice_title_size: int = 44
## Size of the line under it (what it does, how many days).
@export_range(8, 200) var choice_detail_size: int = 28
## Space inside each choice's box, in pixels (the dialogue boxes' Padding is roomier).
@export_range(0, 100) var choice_padding: int = 20
## Space between the choices, in pixels.
@export_range(0, 100) var choice_gap: int = 14
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


## The calendar's page drawn with Page Image, or null when there isn't one.
func make_page_box() -> StyleBox:
	if not page_image:
		return null
	var page := _picture_box(page_image, page_image_margin)
	page.content_margin_left = page_padding_left
	page.content_margin_top = page_padding_top
	page.content_margin_right = page_padding_right
	page.content_margin_bottom = page_padding_bottom
	return page


## A day's box drawn with Day Image, or null when there isn't one.
func make_day_box() -> StyleBox:
	if not day_image:
		return null
	var day := _picture_box(day_image, day_image_margin)
	day.set_content_margin_all(day_padding)
	return day


# A picture stretched like a frame: `margin` pixels at each edge stay sharp.
func _picture_box(texture: Texture2D, margin: int) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = texture
	box.set_texture_margin_all(margin)
	return box
