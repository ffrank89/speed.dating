class_name StageHazards
extends Control
## Runs a date's stage hazards: things that turn up mid-date (a fly...) that the player
## can deal with for a bonus. List them in Hazards. Each hazard's own scene says when it
## turns up (after how many answers) and what dealing with it earns.
## Full guide: docs/guides/stage-hazards.md

## Sent when the player deals with a hazard. The date adds its points and shows her reaction.
signal hazard_cleared(hazard: StageHazard)

## The hazards this date can have (scenes from scenes/Hazards/).
@export var hazards: Array[PackedScene] = []
## Counts the player's answers (the date's OptionList).
@export var option_list: OptionList
## Hazards freeze while a microgame plays (the date's MicrogameHost).
@export var microgame_host: MicrogameHost

## How many questions the player has answered on this date.
var answers := 0
var _hazards: Array[StageHazard] = []
var _sound := AudioStreamPlayer.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sound)
	for scene in hazards:
		var hazard: StageHazard = scene.instantiate() as StageHazard if scene else null
		if not hazard:
			push_warning("StageHazards: a scene in Hazards doesn't use a StageHazard script.")
			continue
		add_child(hazard)
		hazard.cleared.connect(_on_cleared)
		_hazards.append(hazard)
	if option_list:
		option_list.option_resolved.connect(_on_answered)


## Brings on every hazard now, whatever the answer count (the test scene's debug button).
func appear_all() -> void:
	for hazard in _hazards:
		hazard.appear()


func _process(_delta: float) -> void:
	var frozen := microgame_host != null and microgame_host.is_active()
	for hazard in _hazards:
		if hazard.is_active:
			hazard.process_mode = Node.PROCESS_MODE_DISABLED if frozen else Node.PROCESS_MODE_INHERIT


func _on_answered(_response: DialogueResponse, _result: DateScorer.Result) -> void:
	answers += 1
	for hazard in _hazards:
		if hazard.is_due(answers):
			_bring_on(hazard)


func _bring_on(hazard: StageHazard) -> void:
	if hazard.delay_seconds > 0.0:
		await get_tree().create_timer(hazard.delay_seconds, false).timeout
	hazard.appear()


func _on_cleared(hazard: StageHazard) -> void:
	if hazard.cleared_sound:
		_sound.stream = hazard.cleared_sound
		_sound.play()
	hazard_cleared.emit(hazard)
