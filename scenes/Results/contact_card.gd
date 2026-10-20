class_name ContactCard
extends CanvasLayer
## The end-of-date result: an iPhone "New Contact" screen.
## If the date went well, she types her name (in her font), her number and her address,
## adds a heart emoji after her name on a really good date, and taps Done. If not, she
## types her name, deletes it, and taps Cancel.
##
## The boxes, her font and text colour come from her dialogue style; everything else is
## Style (data/contact_card_style.tres). Her name, number and address come from her girl
## file (Contact Card); how many hearts each ending takes is data/date_rules.tres → Result.
## Move or resize the rows in this scene. Press F6 to watch it with the Testing settings.
##
## From code: show_card(girl), then var got_number: bool = await play(hearts, rules)
## Full guide: docs/guides/result-screen.md

## Sent when she's done (true = she gave you her number).
signal finished(got_number: bool)

const DEFAULT_BOX_STYLE := "res://data/dialogue_styles/default.tres"

## How the card looks, types and sounds (data/contact_card_style.tres).
@export var style: ContactCardStyle

@export_group("Testing (F6)")
## The girl shown when you play this scene on its own.
@export var test_girl: GirlData
## The hearts (0-3) the pretend date ended on. 3 = number and heart emoji, 0 = no number.
@export_range(0, 3) var test_hearts: int = 3

var _girl: GirlData
var _box: DialogueBoxStyle
var _typing: Label
var _typed := {}
var _hints := {}
var _time := 0.0

@onready var dim: ColorRect = %Dim
@onready var sheet: Panel = %Sheet
@onready var cancel: Label = %Cancel
@onready var title: Label = %Title
@onready var done: Label = %Done
@onready var circle: Panel = %Circle
@onready var initials: Label = %Initials
@onready var photo: TextureRect = %Photo
@onready var add_photo: Label = %AddPhoto
@onready var name_group: PanelContainer = %NameGroup
@onready var phone_group: PanelContainer = %PhoneGroup
@onready var address_group: PanelContainer = %AddressGroup
@onready var first_name: Label = %FirstName
@onready var heart: TextureRect = %Heart
@onready var heart_text: Label = %HeartText
@onready var last_name: Label = %LastName
@onready var company: Label = %Company
@onready var phone_kind: Label = %PhoneKind
@onready var phone: Label = %Phone
@onready var address_kind: Label = %AddressKind
@onready var address: Label = %Address
@onready var result: Label = %Result
@onready var caret: ColorRect = %Caret
@onready var sound: AudioStreamPlayer = %Sound


func _ready() -> void:
	if not style:
		style = ContactCardStyle.new()
	sound.max_polyphony = 4
	caret.visible = false
	# Her box style can keep its outline over a picture box, like her dialogue box does.
	for group: PanelContainer in [name_group, phone_group, address_group]:
		group.draw.connect(_draw_outline.bind(group))
	if get_parent() == get_tree().root:
		_play_alone.call_deferred()
	else:
		visible = false


## Sets the card up, blank, for `girl` and shows it.
func show_card(girl: GirlData) -> void:
	_girl = girl
	_box = girl.dialogue_style if girl.dialogue_style else load(DEFAULT_BOX_STYLE)
	_apply_style()
	for label: Label in [first_name, last_name, company, phone, address]:
		_set_typed(label, "")
	heart.visible = false
	heart_text.visible = false
	result.visible = false
	caret.visible = false
	visible = true


## She fills it in, or doesn't. Returns true if she gave you her number. Use with await.
func play(hearts: int, rules: DateRules = null) -> bool:
	if not rules:
		rules = DateRules.new()
	var gives_number := hearts >= rules.number_at_hearts
	if gives_number:
		await _type_into(first_name, _girl.display_name)
		if hearts >= rules.heart_emoji_at_hearts:
			await _add_heart()
		await _next_field()
		await _type_into(phone, _girl.phone_number)
		await _next_field()
		await _type_into(address, _girl.address)
		caret.visible = false
		await _tap(done, style.done_sound)
		result.text = style.got_number_text
	else:
		if style.type_then_delete_when_no:
			await _type_into(first_name, _girl.display_name)
			await _wait(0.7)
			await _delete_all(first_name)
		caret.visible = false
		await _tap(cancel, style.cancel_sound)
		result.text = style.no_number_text
	result.visible = true
	await _wait(style.end_hold_seconds)
	finished.emit(gives_number)
	return gives_number


func _process(delta: float) -> void:
	_time += delta
	if not caret.visible or not _typing:
		return
	# The caret sits after the last letter, and blinks.
	var font := _typing.get_theme_font("font")
	var font_size := _typing.get_theme_font_size("font_size")
	var lines: PackedStringArray = String(_typed[_typing]).split("\n")
	var line_height := font.get_height(font_size)
	var width := font.get_string_size(lines[-1], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x if _typed[_typing] != "" else 0.0
	var top := (_typing.size.y - line_height * lines.size()) / 2.0
	caret.size = Vector2(5, line_height * 0.85)
	caret.position = _typing.global_position + Vector2(width + 4.0, top + (lines.size() - 1) * line_height + line_height * 0.075)
	caret.modulate.a = 1.0 if fmod(_time, 1.0) < 0.6 else 0.0


func _type_into(label: Label, words: String) -> void:
	_typing = label
	caret.visible = true
	for character in words:
		_set_typed(label, _typed[label] + character)
		_play(style.space_sound if character == " " else style.key_sound)
		_time = 0.0
		await _wait(randf_range(style.min_seconds_per_key, style.max_seconds_per_key))


func _delete_all(label: Label) -> void:
	_typing = label
	while not String(_typed[label]).is_empty():
		_set_typed(label, String(_typed[label]).left(-1))
		_play(style.delete_sound)
		_time = 0.0
		await _wait(style.min_seconds_per_key)


func _add_heart() -> void:
	_play(style.space_sound)
	await _wait(style.max_seconds_per_key * 2.0)
	_play(style.key_sound)
	if style.heart_image:
		heart.texture = style.heart_image
		heart.visible = true
	else:
		heart_text.text = style.heart_text
		heart_text.visible = true
	await _wait(style.max_seconds_per_key)


func _next_field() -> void:
	caret.visible = false
	await _wait(style.pause_between_fields)
	_play(style.next_field_sound)


# A little press on Done or Cancel, the way a tap looks.
func _tap(label: Label, tap_sound: AudioStream) -> void:
	await _wait(style.pause_between_fields)
	_play(tap_sound)
	label.pivot_offset = label.size / 2.0
	var press := create_tween()
	press.tween_property(label, "scale", Vector2(1.25, 1.25), 0.08)
	press.tween_property(label, "scale", Vector2.ONE, 0.15)
	await press.finished


# Shows what's been typed, or the grey hint when nothing has.
func _set_typed(label: Label, words: String) -> void:
	_typed[label] = words
	var empty := words.is_empty()
	label.text = String(_hints.get(label, "")) if empty else words
	var color := _box.text_color if _box else Color.BLACK
	label.add_theme_color_override("font_color", Color(color, color.a * style.hint_alpha) if empty else color)


func _apply_style() -> void:
	var accent := _box.name_plate_color
	var her_font: Font = _box.font if _box.font else (load(DEFAULT_BOX_STYLE) as DialogueBoxStyle).font

	dim.color = style.behind_dim
	var sheet_box := StyleBoxFlat.new()
	sheet_box.bg_color = style.sheet_color
	sheet_box.set_corner_radius_all(style.sheet_corner)
	sheet_box.anti_aliasing = true
	sheet.add_theme_stylebox_override("panel", sheet_box)

	for group: PanelContainer in [name_group, phone_group, address_group]:
		group.add_theme_stylebox_override("panel", _box.make_box())
		group.queue_redraw()
	for line: ColorRect in [%Line1, %Line2]:
		line.color = Color(_box.text_color, 0.18)

	_hints = {first_name: style.first_name_hint, last_name: style.last_name_hint, company: style.company_hint,
		phone: "", address: ""}
	for label: Label in [first_name, last_name, company, phone, address]:
		_font(label, her_font, style.field_font_size, _box.text_color)
		label.add_theme_constant_override("outline_size", _box.text_outline_width)
		label.add_theme_color_override("font_outline_color", _box.text_outline_color)

	_font(title, style.ui_font, style.ui_font_size, style.ui_text_color)
	_font(result, style.ui_font, style.ui_font_size, style.ui_text_color)
	for label: Label in [cancel, done, add_photo, phone_kind, address_kind]:
		_font(label, style.ui_font, style.ui_font_size, accent)
	title.text = style.title
	cancel.text = style.cancel_text
	done.text = style.done_text
	add_photo.text = style.add_photo_text
	phone_kind.text = style.phone_kind
	address_kind.text = style.address_kind
	caret.color = accent
	_font(heart_text, style.emoji_font if style.emoji_font else _emoji_font(), style.field_font_size, Color.WHITE)

	var round_box := StyleBoxFlat.new()
	round_box.bg_color = accent
	round_box.set_corner_radius_all(1000)
	round_box.anti_aliasing = true
	circle.add_theme_stylebox_override("panel", round_box)
	_font(initials, her_font, 120, _box.name_color)
	initials.text = _initials(_girl.display_name)
	photo.texture = _girl.contact_photo
	photo.visible = _girl.contact_photo != null
	initials.visible = _girl.contact_photo == null


func _draw_outline(group: PanelContainer) -> void:
	var outline := _box.make_outline() if _box else null
	if outline:
		group.draw_style_box(outline, Rect2(Vector2.ZERO, group.size))


func _font(label: Label, font: Font, font_size: int, color: Color) -> void:
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)


# The computer's colour emoji font.
func _emoji_font() -> Font:
	var emoji := SystemFont.new()
	emoji.font_names = PackedStringArray(["Apple Color Emoji", "Noto Color Emoji", "Segoe UI Emoji"])
	return emoji


func _initials(full_name: String) -> String:
	var letters := ""
	for word in full_name.split(" ", false):
		letters += word.left(1).to_upper()
	return letters.left(2)


func _play(stream: AudioStream) -> void:
	if stream:
		sound.stream = stream
		sound.volume_db = style.volume_db
		sound.play()


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout


func _play_alone() -> void:
	if not test_girl:
		push_warning("ContactCard: set Testing → Test Girl to play it on its own.")
		return
	show_card(test_girl)
	var got_number := await play(test_hearts, DateRules.new())
	print("ContactCard: %d hearts -> %s" % [test_hearts, "got her number" if got_number else "no number"])
