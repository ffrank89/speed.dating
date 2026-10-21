extends Control
## Test bench for a date: the real date scene (the Date node, scenes/Dates/Date/Date.tscn)
## plus a debug panel. Press F6 here.
## The sliders stand in for the player's attributes. The date stays here when it's over
## instead of going to the calendar; press Restart to play another.

@export var girl: GirlData
## The dialogue to play. Empty = the girl's First Date Dialogue.
@export var dialogue: DialogueResource
## Empty = the whole date (opener, 5 exchanges, closer, contact card).
## A title (e.g. "opener") = play just that one, then the card.
@export var start_title: String = ""
## The scoring and flow numbers (data/date_rules.tres).
@export var rules: DateRules

# Static so the sliders keep their values when the date restarts.
static var attributes := {
	Attr.Id.CULTURE: 50,
	Attr.Id.INTELLECT: 50,
	Attr.Id.SEDUCTION: 50,
	Attr.Id.HEART: 50,
}

@onready var date: DateScene = $Date
@onready var girl_label: Label = %GirlLabel
@onready var status_label: Label = %StatusLabel
@onready var score_label: Label = %ScoreLabel
@onready var sliders: VBoxContainer = %Sliders
@onready var pose_button: Button = %PoseButton
@onready var restart_button: Button = %RestartButton
@onready var hazard_button: Button = %HazardButton
@onready var end_date_button: Button = %EndDateButton


func _ready() -> void:
	_build_sliders()
	restart_button.pressed.connect(get_tree().reload_current_scene)
	date.status_changed.connect(func(text: String) -> void: status_label.text = text)
	date.score_changed.connect(func(text: String) -> void: score_label.text = text)

	if girl:
		date.girl = girl
	if dialogue:
		date.dialogue = dialogue
	if rules:
		date.rules = rules
	date.only_title = start_title
	date.attributes = attributes
	date.begin()
	if not date.girl:
		pose_button.disabled = true
		return

	girl_label.text = "%s, %d" % [date.girl.display_name, date.girl.age]
	pose_button.text = "Pose: %s  (next)" % date.girl.default_pose
	pose_button.pressed.connect(func() -> void: pose_button.text = "Pose: %s  (next)" % date.next_pose())
	hazard_button.pressed.connect(date.stage_hazards.appear_all)
	end_date_button.pressed.connect(date.end_now)


func _build_sliders() -> void:
	for attr in Attr.Id.values():
		var row := HBoxContainer.new()
		var label := Label.new()
		label.custom_minimum_size.x = 260
		label.text = _slider_text(attr)

		var slider := HSlider.new()
		slider.max_value = 100
		slider.value = attributes[attr]
		slider.custom_minimum_size.x = 400
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.focus_mode = Control.FOCUS_NONE
		slider.value_changed.connect(func(value: float) -> void:
			attributes[attr] = int(value)
			label.text = _slider_text(attr)
		)

		row.add_child(label)
		row.add_child(slider)
		sliders.add_child(row)


func _slider_text(attr: Attr.Id) -> String:
	return "%s  %d" % [Attr.display_name(attr), attributes[attr]]
