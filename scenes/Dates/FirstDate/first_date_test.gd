extends Control
## Test bench for the first date: pick a girl in the Inspector, press F6.
## The sliders stand in for the player's attributes until RunState exists.

@export var girl: GirlData
## The dialogue to play. Empty = the girl's First Date Dialogue.
@export var dialogue: DialogueResource
## Where in the dialogue file to start (the name after "~").
@export var start_title: String = "start"
## The scoring numbers (data/date_rules.tres).
@export var rules: DateRules

# Static so the sliders keep their values when the date restarts.
static var attributes := {
	Attr.Id.CULTURE: 50,
	Attr.Id.INTELLECT: 50,
	Attr.Id.SEDUCTION: 50,
	Attr.Id.HEART: 50,
}

var _pose_names: Array[String] = []
var _pose_index := 0
var _scorer: DateScorer
var _state := DateState.new()

@onready var background: TextureRect = $Background
@onready var portrait: GirlPortrait = $Portrait
@onready var reaction_icon: ReactionIcon = $ReactionIcon
@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var option_list: OptionList = $OptionList
@onready var girl_label: Label = %GirlLabel
@onready var status_label: Label = %StatusLabel
@onready var score_label: Label = %ScoreLabel
@onready var sliders: VBoxContainer = %Sliders
@onready var pose_button: Button = %PoseButton
@onready var restart_button: Button = %RestartButton
@onready var hazard_button: Button = %HazardButton
@onready var stage_hazards: StageHazards = $StageHazards


func _ready() -> void:
	_build_sliders()
	pose_button.pressed.connect(_next_pose)
	restart_button.pressed.connect(get_tree().reload_current_scene)
	hazard_button.pressed.connect(stage_hazards.appear_all)
	stage_hazards.hazard_cleared.connect(_on_hazard_cleared)
	dialogue_box.pose_requested.connect(_on_pose_requested)
	dialogue_box.reaction_requested.connect(_on_reaction_requested)
	dialogue_box.responses_ready.connect(func(responses: Array) -> void: option_list.show_options(responses, _scorer, girl.option_style))
	option_list.option_resolved.connect(_on_option_resolved)
	dialogue_box.finished.connect(func() -> void: status_label.text = "Dialogue finished. Press Restart.")

	if not girl:
		girl_label.text = "No girl: drop a GirlData into the 'girl' slot"
		pose_button.disabled = true
		return

	girl_label.text = "%s, %d" % [girl.display_name, girl.age]
	background.texture = girl.date_background
	_pose_names.assign(girl.poses.keys())
	_show_pose(girl.default_pose)
	_scorer = DateScorer.new(rules if rules else DateRules.new(), girl, attributes)

	var lines := dialogue if dialogue else girl.first_date_dialogue
	if lines:
		status_label.text = "Click the box or press Space. Pick with 1-4."
		dialogue_box.start(lines, start_title, [girl], [_state])
	else:
		status_label.text = "No dialogue: set 'dialogue' here or her First Date Dialogue"


func _on_option_resolved(response: DialogueResponse, result: DateScorer.Result) -> void:
	_state.hit = result.hit
	_state.last_points = result.points
	_state.score = _scorer.score
	var roll := "rolled %d vs %d%%, %s" % [result.roll, result.chance, "hit" if result.hit else "miss"] if result.rolled else "no roll"
	if result.played:
		roll = "microgame %s" % ("passed" if result.hit else "failed")
	score_label.text = "Date score: %.1f   (last: %+.1f, %s)" % [_scorer.score, result.points, roll]
	dialogue_box.choose(response)


# The player dealt with a stage hazard (e.g. shooed the fly away): points and her reaction.
func _on_hazard_cleared(hazard: StageHazard) -> void:
	if not _scorer:
		return
	_scorer.add_bonus(hazard.points)
	_state.score = _scorer.score
	if not hazard.reaction.is_empty():
		reaction_icon.show_reaction(hazard.reaction)
	if not hazard.pose.is_empty():
		_show_pose(hazard.pose)
	score_label.text = "Date score: %.1f   (last: %+.1f, %s cleared)" % [_scorer.score, hazard.points, hazard.name]


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


func _next_pose() -> void:
	_show_pose(_pose_names[(_pose_index + 1) % _pose_names.size()])


func _show_pose(pose_name: String) -> void:
	portrait.show_pose(girl.get_pose(pose_name))
	_pose_index = maxi(_pose_names.find(pose_name), 0)
	pose_button.text = "Pose: %s  (next)" % pose_name


func _on_pose_requested(speaker: GirlData, pose_name: String) -> void:
	if speaker == girl:
		_show_pose(pose_name)


func _on_reaction_requested(speaker: GirlData, reaction_name: String) -> void:
	if speaker == girl:
		reaction_icon.show_reaction(reaction_name)
