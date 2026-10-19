class_name DialogueBox
extends Control
## The box her lines appear in. Text types out letter by letter in the speaker's
## voice, and the box restyles itself for whoever is speaking.
##
## Click, Space or Enter: the first press finishes the line, the next one continues.
##
## How it picks the look: each line's speaker name ("Split Ends: …") is matched to
## a girl in the cast; her GirlData's Dialogue Style and Voice are used. Anyone
## else (including the player) gets Default Style and no voice.
##
## From code: start(dialogue_file, "start", [girl]). Full guide: docs/guides/dialogue-box.md

signal line_started(line: DialogueLine)
## A line asked for a pose with a tag like [#pose=cig].
signal pose_requested(speaker: GirlData, pose_name: String)
## A line asked for a reaction with a tag like [#react=heart].
signal reaction_requested(speaker: GirlData, reaction_name: String)
## A line ended in choices. Call choose(response) to continue.
signal responses_ready(responses: Array)
## The dialogue reached its end.
signal finished

## The look for anyone without a style of their own, including the player.
@export var default_style: DialogueBoxStyle
## Keyboard action that finishes or continues a line (Space and Enter by default).
@export var advance_action: StringName = &"ui_accept"

var _resource: DialogueResource
var _game_states: Array = []
var _line: DialogueLine
var _cast := {}  # display name -> GirlData
var _style: DialogueBoxStyle
var _arrow_tween: Tween
var _arrow_rest_y := 0.0

@onready var box: PanelContainer = $Box
@onready var outline: Panel = $Outline
@onready var label: DialogueLabel = %Text
@onready var name_plate: PanelContainer = $NamePlate
@onready var name_label: Label = %NameLabel
@onready var next_arrow: Control = $NextArrow
@onready var arrow_label: Label = %ArrowLabel
@onready var arrow_image: TextureRect = %ArrowImage
@onready var voice_player: VoicePlayer = $VoicePlayer


func _ready() -> void:
	if not default_style:
		default_style = DialogueBoxStyle.new()
	label.spoke.connect(voice_player.speak)
	label.finished_typing.connect(_on_finished_typing)
	_arrow_rest_y = next_arrow.position.y
	apply_style(default_style)
	hide()


## Starts a dialogue file at a title (the "~ start" line). The cast is the girls in
## this scene; their names must match the speaker names in the file. Game states are
## objects whose properties the file can check, e.g. a DateState for "if hit".
func start(resource: DialogueResource, title: String = "start", cast: Array[GirlData] = [], game_states: Array = []) -> void:
	_resource = resource
	_game_states = game_states
	_cast.clear()
	for girl in cast:
		_cast[girl.display_name] = girl
	show()
	_show_line(await resource.get_next_dialogue_line(title, _game_states))


## Finishes the current line, or moves to the next one if it's already finished.
func advance() -> void:
	if not _line:
		return
	if label.is_typing:
		label.skip_typing()
		return
	if not _line.responses.is_empty():
		return
	_show_line(await _resource.get_next_dialogue_line(_line.next_id, _game_states))


## Continues the dialogue down the chosen response.
func choose(response: DialogueResponse) -> void:
	_show_line(await _resource.get_next_dialogue_line(response.next_id, _game_states))


## Restyles the box. Called automatically for each line's speaker.
func apply_style(style: DialogueBoxStyle) -> void:
	if style == _style:
		return
	_style = style
	box.add_theme_stylebox_override("panel", style.make_box())
	var line := style.make_outline()
	outline.visible = line != null
	if line:
		outline.add_theme_stylebox_override("panel", line)
	name_plate.add_theme_stylebox_override("panel", style.make_name_plate())

	var font := _font_or_default(style.font)
	label.add_theme_font_override("normal_font", font)
	label.add_theme_font_override("bold_font", _bold(font))
	label.add_theme_font_override("italics_font", _italic(font))
	for size_name in ["normal_font_size", "bold_font_size", "italics_font_size"]:
		label.add_theme_font_size_override(size_name, style.font_size)
	label.add_theme_color_override("default_color", style.text_color)
	label.add_theme_constant_override("outline_size", style.text_outline_width)
	label.add_theme_color_override("font_outline_color", style.text_outline_color)

	name_label.add_theme_font_override("font", style.name_font if style.name_font else font)
	name_label.add_theme_font_size_override("font_size", style.name_font_size)
	name_label.add_theme_color_override("font_color", style.name_color)

	arrow_image.texture = style.next_arrow_image
	arrow_image.visible = style.next_arrow_image != null
	arrow_label.visible = style.next_arrow_image == null
	arrow_label.add_theme_color_override("font_color", style.next_arrow_color)
	arrow_label.add_theme_font_size_override("font_size", style.font_size)


func _show_line(line: DialogueLine) -> void:
	_line = line
	_set_arrow(false)
	if not line:
		hide()
		finished.emit()
		return

	var speaker: GirlData = _cast.get(line.character)
	apply_style(speaker.dialogue_style if speaker and speaker.dialogue_style else default_style)
	var voice: GirlVoice = speaker.voice if speaker else null
	voice_player.set_voice(voice)
	voice_player.reset()
	label.seconds_per_step = voice.seconds_per_letter if voice else 0.03

	name_label.text = line.character
	name_plate.visible = _style.show_name_plate and not line.character.is_empty()

	var pose := line.get_tag_value("pose")
	if speaker and not pose.is_empty():
		pose_requested.emit(speaker, pose)
	var reaction := line.get_tag_value("react")
	if speaker and not reaction.is_empty():
		reaction_requested.emit(speaker, reaction)
	line_started.emit(line)

	label.dialogue_line = line
	label.type_out()


func _on_finished_typing() -> void:
	if _line and not _line.responses.is_empty():
		responses_ready.emit(_line.responses)
	else:
		_set_arrow(true)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		advance()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(advance_action):
		get_viewport().set_input_as_handled()
		advance()


func _set_arrow(on: bool) -> void:
	next_arrow.visible = on
	if _arrow_tween:
		_arrow_tween.kill()
	next_arrow.position.y = _arrow_rest_y
	if on:
		_arrow_tween = create_tween().set_loops()
		_arrow_tween.tween_property(next_arrow, "position:y", _arrow_rest_y + 10, 0.4).set_trans(Tween.TRANS_SINE)
		_arrow_tween.tween_property(next_arrow, "position:y", _arrow_rest_y, 0.4).set_trans(Tween.TRANS_SINE)


func _font_or_default(font: Font) -> Font:
	if font:
		return font
	if default_style and default_style.font:
		return default_style.font
	return ThemeDB.fallback_font


# [b]bold[/b] in a line uses a thickened copy of her font, so it matches.
static func _bold(font: Font) -> Font:
	var bold := FontVariation.new()
	bold.base_font = font
	bold.variation_embolden = 0.7
	return bold


# [i]italics[/i] in a line uses a slanted copy of her font.
static func _italic(font: Font) -> Font:
	var italic := FontVariation.new()
	italic.base_font = font
	italic.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)
	return italic
