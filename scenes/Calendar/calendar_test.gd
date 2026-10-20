extends Control
## Test bench for the calendar's art. Open CalendarTest.tscn and press F6.
##
## Top row, the calendar itself (try art the way the iPhone frame will be tried):
##   Page ◀ ▶   pictures for the calendar's page (Page Images; "None" = the box style)
##   Days ◀ ▶   pictures for each day's box (Day Images; "None" = the box style)
##   Scene ◀ ▶  pictures behind the whole screen (Scene Backgrounds; "None" = the pattern)
## Second row, the run:
##   New calendar, Skip day, Boss day, Foresight (open the whole month to see it)
## F1 hides the bars. Nothing here is saved: the files keep their settings. To keep a
## picture, put it in data/calendar_style.tres → Calendar Art (or Background).

## Pictures to try as the calendar's page. Add more with Add Element.
@export var page_images: Array[Texture2D] = []
## Pictures to try as each day's box.
@export var day_images: Array[Texture2D] = []
## Pictures to try behind the whole screen.
@export var scene_backgrounds: Array[Texture2D] = []

# Which picture each flipper is on (-1 = none). Static, so New calendar keeps them.
static var _picks := {"page": 0, "day": -1, "scene": -1}

@onready var calendar: CalendarScene = $Calendar
@onready var bars: Control = %Bars
@onready var foresight_label: Label = %ForesightLabel
@onready var foresight: HSlider = %Foresight


func _ready() -> void:
	_hook_flipper("page", %PagePrevious, %PageNext, %PageLabel)
	_hook_flipper("day", %DayPrevious, %DayNext, %DayLabel)
	_hook_flipper("scene", %ScenePrevious, %SceneNext, %SceneLabel)
	%NewCalendar.pressed.connect(func() -> void:
		PlayerManager.calendar = null
		get_tree().reload_current_scene())
	%SkipDay.pressed.connect(_skip_day)
	%BossDay.pressed.connect(func() -> void:
		var run := PlayerManager.get_calendar()
		run.today = run.rules.days_per_chapter
		calendar.refresh_look())
	foresight.value = PlayerManager.get_calendar().rules.foresight_days
	foresight.value_changed.connect(_on_foresight)
	_on_foresight(foresight.value)
	_apply_art()


func _hook_flipper(slot: String, previous: Button, next: Button, label: Label) -> void:
	previous.pressed.connect(_flip.bind(slot, -1))
	next.pressed.connect(_flip.bind(slot, 1))
	label.set_meta("slot", slot)


func _pictures(slot: String) -> Array[Texture2D]:
	match slot:
		"page":
			return page_images
		"day":
			return day_images
	return scene_backgrounds


# Steps through the pictures, with "None" (-1) before the first one.
func _flip(slot: String, step: int) -> void:
	var count := _pictures(slot).size()
	_picks[slot] = posmod(_picks[slot] + 1 + step, count + 1) - 1
	_apply_art()


func _picked(slot: String) -> Texture2D:
	var pictures := _pictures(slot)
	var index: int = _picks[slot]
	return pictures[index] if index >= 0 and index < pictures.size() else null


func _apply_art() -> void:
	calendar.style.page_image = _picked("page")
	calendar.style.day_image = _picked("day")
	calendar.style.background_image = _picked("scene")
	for label: Label in [%PageLabel, %DayLabel, %SceneLabel]:
		var picture := _picked(label.get_meta("slot"))
		label.text = picture.resource_path.get_file() if picture else "None"
	calendar.refresh_look()


func _skip_day() -> void:
	var run := PlayerManager.get_calendar()
	if run.is_boss_day():
		run.next_chapter()
	else:
		var nothing := DayAction.new()
		nothing.title = "Skipped"
		run.spend(nothing)
	calendar.refresh_look()


func _on_foresight(value: float) -> void:
	PlayerManager.get_calendar().rules.foresight_days = int(value)
	foresight_label.text = "Foresight: %d days" % int(value)
	calendar.refresh_look()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		bars.visible = not bars.visible
