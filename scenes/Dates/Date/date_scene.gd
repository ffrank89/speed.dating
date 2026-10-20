class_name DateScene
extends Control
## A whole date: her room and her, the dialogue, the player's option bubbles, microgames,
## stage hazards, and her contact card at the end.
##
## How a date plays, from her first-date .dialogue file (title names and numbers are in
## data/date_rules.tres → Flow):
##   ~ opener
##   5 exchanges drawn at random, no repeats: 2 from the ~ microgame_... titles and the
##     rest from the ~ exchange_... titles, in a random order
##   one closer, picked by how it went: ~ closer_failed (below her Number Threshold),
##     ~ closer_no_hearts, or ~ closer_hearts (1 heart or more)
##   her contact card
## Then she's saved in your contacts (your party) if she gave you her number, or gone
## for the run if the date failed, and the game goes back to the calendar.
##
## The game opens this scene from the dating app, with the girl picked there. To test,
## press F5: scenes/Dates/FirstDate/FirstDateTest.tscn wraps this with a debug panel.
## Full guide: docs/guides/the-full-date.md

## Something to tell the tester (shown in the test bench's debug panel).
signal status_changed(text: String)
## The score changed (shown in the test bench's debug panel).
signal score_changed(text: String)
## The date is over and her contact card has closed.
signal date_finished(result: DateResult)

## Who the date is with. Empty = the girl picked in the dating app (her date character's
## Girl Data Path), or Fallback Girl if she has no girl file yet.
@export var girl: GirlData
## Used when the picked girl has no girl file yet.
@export var fallback_girl: GirlData
## The dialogue to play. Empty = the girl's First Date Dialogue.
@export var dialogue: DialogueResource
## Testing: play just this one title (e.g. "start") instead of the whole date.
@export var only_title: String = ""
## The scoring and flow numbers (data/date_rules.tres).
@export var rules: DateRules
## Start as soon as the scene opens. Off = something else calls begin() (the test bench).
@export var auto_start: bool = true
## Go back to the calendar after her contact card (off in the test bench).
@export var go_to_calendar: bool = true

## The player's attributes (Attr.Id → 0-100). Set before begin(); empty = the player's own.
var attributes: Dictionary = {}
var scorer: DateScorer
## The pose names she has, in her girl file's order.
var pose_names: Array[String] = []
var _pose_index := 0
var _state := DateState.new()
var _lines: DialogueResource
var _titles: Array[String] = []
var _closer_done := false
var _started := false
var _ended := false

@onready var background: TextureRect = $Background
@onready var portrait: GirlPortrait = $Portrait
@onready var reaction_icon: ReactionIcon = $ReactionIcon
@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var option_list: OptionList = $OptionList
@onready var stage_hazards: StageHazards = $StageHazards
@onready var contact_card: ContactCard = $ContactCard


func _ready() -> void:
	dialogue_box.pose_requested.connect(_on_pose_requested)
	dialogue_box.reaction_requested.connect(_on_reaction_requested)
	dialogue_box.responses_ready.connect(func(responses: Array) -> void:
		option_list.show_options(responses, scorer, girl.option_style))
	option_list.option_resolved.connect(_on_option_resolved)
	dialogue_box.finished.connect(_next_title)
	stage_hazards.hazard_cleared.connect(_on_hazard_cleared)
	if auto_start:
		begin.call_deferred()


## Starts the date. Called by itself when Auto Start is on.
func begin() -> void:
	if _started:
		return
	_started = true
	if not rules:
		rules = DateRules.new()
	if not girl:
		girl = _picked_girl()
	if not girl:
		status_changed.emit("No girl: set Girl or Fallback Girl on the Date node")
		return
	background.texture = girl.date_background
	pose_names.assign(girl.poses.keys())
	show_pose(girl.default_pose)
	if attributes.is_empty():
		attributes = _player_attributes()
	scorer = DateScorer.new(rules, girl, attributes)

	_lines = dialogue if dialogue else girl.first_date_dialogue
	if not _lines:
		status_changed.emit("No dialogue: set her First Date Dialogue (girl file → Dialogue)")
		return
	if only_title.is_empty():
		_titles = _plan_titles()
	else:
		_titles = [only_title]
		_closer_done = true
	status_changed.emit("Click the box or press Space. Pick with 1-4.")
	_next_title()


## Ends the date now and shows her contact card (the test bench's End Date button).
func end_now() -> void:
	_end_date()


## Shows one of her poses by name (her default pose if she doesn't have it).
func show_pose(pose_name: String) -> void:
	portrait.show_pose(girl.get_pose(pose_name))
	_pose_index = maxi(pose_names.find(pose_name), 0)


## Shows her next pose (the test bench's pose button). Returns its name.
func next_pose() -> String:
	var pose_name := pose_names[(_pose_index + 1) % pose_names.size()]
	show_pose(pose_name)
	return pose_name


# Opener, then the exchanges for this date (2 microgame ones), shuffled. No repeats.
func _plan_titles() -> Array[String]:
	var all_titles := _lines.get_titles()
	var regular: Array[String] = []
	var games: Array[String] = []
	for title in all_titles:
		if title.begins_with(rules.microgame_prefix):
			games.append(title)
		elif title.begins_with(rules.exchange_prefix):
			regular.append(title)
	games.shuffle()
	regular.shuffle()
	var picks: Array[String] = []
	picks.append_array(games.slice(0, rules.microgame_exchanges))
	picks.append_array(regular.slice(0, rules.exchanges - picks.size()))
	# Not enough regular ones: top up with more microgame exchanges.
	picks.append_array(games.slice(rules.microgame_exchanges, rules.microgame_exchanges + rules.exchanges - picks.size()))
	if picks.size() < rules.exchanges:
		push_warning("Date: only %d exchanges in %s (wanted %d)." % [picks.size(), _lines.resource_path, rules.exchanges])
	picks.shuffle()
	if all_titles.has(rules.opener_title):
		picks.push_front(rules.opener_title)
	else:
		push_warning("Date: no ~ %s in %s." % [rules.opener_title, _lines.resource_path])
	return picks


# Plays the next title in the plan, then the closer, then ends the date.
func _next_title() -> void:
	if _ended:
		return
	if not _titles.is_empty():
		dialogue_box.start(_lines, _titles.pop_front(), [girl], [_state])
		return
	if not _closer_done:
		_closer_done = true
		var closer := _closer_title()
		if _lines.get_titles().has(closer):
			dialogue_box.start(_lines, closer, [girl], [_state])
			return
		push_warning("Date: no ~ %s in %s." % [closer, _lines.resource_path])
	_end_date()


func _closer_title() -> String:
	if not scorer.gives_number():
		return rules.closer_failed_title
	if scorer.hearts() == 0:
		return rules.closer_no_hearts_title
	return rules.closer_hearts_title


# The date's over: open Contacts like an app, and she types in her number (or doesn't).
# Then she joins the party or is gone for the run, and it's back to the calendar.
func _end_date() -> void:
	if _ended or not scorer:
		return
	_ended = true
	dialogue_box.hide()
	option_list.hide()
	# -1 = a failed date (below her Number Threshold); otherwise the hearts earned.
	var hearts := scorer.hearts() if scorer.gives_number() else -1
	var how := "failed" if hearts < 0 else "%d of 3 hearts" % hearts
	status_changed.emit("Date over: %s" % how)
	await AppLauncher.open("contacts", contact_card.show_card.bind(girl, rules))
	await contact_card.play(hearts)

	var result := DateResult.new()
	result.girl = girl
	result.score = scorer.score
	result.affection = maxi(hearts, 0)
	result.got_number = hearts >= 0
	_apply_to_run(result)
	await AppLauncher.close("contacts", func() -> void: contact_card.visible = false)
	status_changed.emit("Date over: %s, %s." % [how, "she's in" if result.got_number else "she's gone for the run"])
	date_finished.emit(result)
	if go_to_calendar:
		AppLauncher.open_scene("calendar", PlayerManager.CALENDAR)


# She gave you her number: she's saved in your contacts (your party), with her hearts.
# A failed date means she's gone for the run.
func _apply_to_run(result: DateResult) -> void:
	var picked: DateCharacter = PlayerManager.current_date
	if not picked:
		return
	if result.got_number:
		PlayerManager.add_party_member(girl, result.affection, picked)
	else:
		PlayerManager.mark_gone(picked)


# The girl picked in the dating app, by her date character's Girl Data Path.
func _picked_girl() -> GirlData:
	var picked: DateCharacter = PlayerManager.current_date
	if picked and not picked.girl_data_path.is_empty():
		return load(picked.girl_data_path)
	if picked:
		push_warning("Date: %s has no girl file yet; using Fallback Girl." % picked.name)
	return fallback_girl


# The player's attributes from their character, or 50 each if there isn't one yet.
func _player_attributes() -> Dictionary:
	var values := {}
	var player: PlayerCharacter = PlayerManager.player
	for attr in Attr.Id.values():
		values[attr] = 50
		if player:
			values[attr] = int(player.skills.get(Attr.display_name(attr), 50))
	return values


func _on_option_resolved(response: DialogueResponse, result: DateScorer.Result) -> void:
	_state.hit = result.hit
	_state.last_points = result.points
	_state.score = scorer.score
	var how := "rolled %d vs %d%%, %s" % [result.roll, result.chance, "hit" if result.hit else "miss"] if result.rolled else "no roll"
	if result.played:
		how = "microgame %s" % ("passed" if result.hit else "failed")
	score_changed.emit("Date score: %.1f   (last: %+.1f, %s)" % [scorer.score, result.points, how])
	dialogue_box.choose(response)


# The player dealt with a stage hazard (e.g. shooed the fly away): points and her reaction.
func _on_hazard_cleared(hazard: StageHazard) -> void:
	if not scorer:
		return
	scorer.add_bonus(hazard.points)
	_state.score = scorer.score
	if not hazard.reaction.is_empty():
		reaction_icon.show_reaction(hazard.reaction)
	if not hazard.pose.is_empty():
		show_pose(hazard.pose)
	score_changed.emit("Date score: %.1f   (last: %+.1f, %s cleared)" % [scorer.score, hazard.points, hazard.name])


func _on_pose_requested(speaker: GirlData, pose_name: String) -> void:
	if speaker == girl:
		show_pose(pose_name)


func _on_reaction_requested(speaker: GirlData, reaction_name: String) -> void:
	if speaker == girl:
		reaction_icon.show_reaction(reaction_name)
