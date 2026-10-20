extends Control
## Test bench for the calendar over picture backgrounds. Open CalendarTest.tscn and press
## F6. The bar at the top:
##   ◀ ▶        flip through Backgrounds (and "Pattern": the animated one)
##   New        a new calendar (new random choices)
##   Skip day   uses up today without doing anything
##   Boss day   jumps to the boss day
##   Foresight  how many days past this chapter you can see (open the whole month)
## F1 hides the bar. Nothing here is saved: the files keep their settings.

## The pictures to try behind the calendar. Add more with Add Element.
@export var backgrounds: Array[Texture2D] = []
## Which one to start on. -1 = the animated pattern.
@export var start_background: int = 0

# Static, so the picked background stays when New restarts the scene.
static var _background := -2

@onready var calendar: CalendarScene = $Calendar
@onready var bar: Control = %Bar
@onready var background_label: Label = %BackgroundLabel
@onready var foresight_label: Label = %ForesightLabel
@onready var foresight: HSlider = %Foresight


func _ready() -> void:
	if _background == -2:
		_background = start_background
	%Previous.pressed.connect(_flip.bind(-1))
	%Next.pressed.connect(_flip.bind(1))
	%Pattern.pressed.connect(_show_background.bind(-1))
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
	_show_background(_background)


func _flip(step: int) -> void:
	if backgrounds.is_empty():
		return
	# -1 (the pattern) is part of the loop, before the first picture.
	_show_background(posmod(_background + 1 + step, backgrounds.size() + 1) - 1)


func _show_background(index: int) -> void:
	_background = clampi(index, -1, backgrounds.size() - 1)
	var picture: Texture2D = backgrounds[_background] if _background >= 0 else null
	calendar.style.background_image = picture
	background_label.text = picture.resource_path.get_file() if picture else "Pattern"
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
		bar.visible = not bar.visible
