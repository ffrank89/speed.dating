class_name ContactCard
extends CanvasLayer
## The end-of-date result: an iPhone "New Contact" screen.
##   Failed date: she types "not a chance!" as her name and taps Cancel. Nothing else.
##   Otherwise: she types her name (in her font); her traits pop into their fields under
##   it (boop, boop, boop); she types her number and address and taps Done. Which traits
##   show, and how many hearts each kind needs (type at 0, tags at 1), is
##   data/date_rules.tres → Result; below that a field says "you dont know me like that!".
##   A heart after her name at Heart Emoji At Hearts (3).
## The middle scrolls to follow her, so there's room for any number of traits.
##
## The boxes, her font and text colour come from her dialogue style; everything else is
## Style (data/contact_card_style.tres). Her name, number, address and traits come from
## her girl file (Contact Card); her Number Threshold (Dating) decides a failed date.
## Move or resize the rows in this scene. Press F6 to watch it with the Testing settings.
##
## From code: show_card(girl, rules), then var got_number: bool = await play(hearts)
## (hearts = -1 for a failed date).
## Her saved contact in the Contacts app: show_saved(girl, hearts, rules) fills it in at
## once, with "‹ Contacts" to go back (back_pressed).
## Full guides: docs/guides/result-screen.md, docs/guides/contacts.md

## Sent when she's done (true = she gave you her number).
signal finished(got_number: bool)
## Her saved contact's "‹ Contacts" was clicked (or Escape pressed).
signal back_pressed

const DEFAULT_BOX_STYLE := "res://data/dialogue_styles/default.tres"

## How the card looks, types and sounds (data/contact_card_style.tres).
@export var style: ContactCardStyle

@export_group("Testing (F6)")
## The girl shown when you play this scene on its own.
@export var test_girl: GirlData
## The hearts the pretend date ended on. -1 = a failed date (no number), 0 = number and
## type, 1 = number, type and tags, 3 = all that and the heart emoji.
@export_range(-1, 3) var test_hearts: int = 1

var _girl: GirlData
var _rules: DateRules
var _box: DialogueBoxStyle
var _typing: Label
var _typed := {}
var _hints := {}
var _time := 0.0
var _saved := false
# Trait pops get their own player, so their rising pitch doesn't bend the key clicks.
var _boop := AudioStreamPlayer.new()

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
@onready var heart_icon: Control = %HeartIcon
@onready var heart_sprite: AnimatedSprite2D = %HeartSprite
@onready var scroll: ScrollContainer = %Scroll
@onready var traits_group: PanelContainer = %TraitsGroup
@onready var trait_rows: VBoxContainer = %TraitRows
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
	add_child(_boop)
	caret.visible = false
	# Her box style can keep its outline over a picture box, like her dialogue box does.
	for group: PanelContainer in [name_group, phone_group, address_group, traits_group]:
		group.draw.connect(_draw_outline.bind(group))
	cancel.gui_input.connect(_on_cancel_input)
	if get_parent() == get_tree().root:
		_play_alone.call_deferred()
	else:
		visible = false


## Sets the card up, blank, for `girl` and shows it. `rules` = the date's DateRules.
func show_card(girl: GirlData, rules: DateRules = null) -> void:
	_girl = girl
	_rules = rules if rules else DateRules.new()
	_box = box_style_of(girl)
	_set_saved(false)
	_apply_style()
	for label: Label in [first_name, last_name, company, phone, address]:
		_set_typed(label, "")
	heart.visible = false
	heart_text.visible = false
	heart_icon.visible = false
	heart_sprite.stop()
	# The result line keeps its space from the start, so the card doesn't jump when it appears.
	result.text = ""
	caret.visible = false
	_build_traits()
	scroll.scroll_vertical = 0
	visible = true


## Her saved contact, filled in at once: what `hearts` unlocked on her date (her type,
## her tags or "you dont know me like that!", the heart), her number and address.
## "‹ Contacts" (top left) sends back_pressed.
func show_saved(girl: GirlData, hearts: int, rules: DateRules = null) -> void:
	show_card(girl, rules)
	_set_saved(true)
	_set_typed(first_name, girl.display_name)
	_set_typed(phone, girl.phone_number)
	_set_typed(address, girl.address)
	if hearts >= _rules.heart_emoji_at_hearts:
		_place_heart()
	for child in trait_rows.get_children():
		if child.has_meta("trait"):
			_fill_trait(child, hearts)
			child.get_meta("words").modulate.a = 1.0


## She fills it in, or doesn't. `hearts` = how the date went: -1 = failed (no number),
## 0-3 = hearts earned. Returns true if she gave you her number. Use with await.
func play(hearts: int) -> bool:
	var gives_number := hearts >= 0
	if gives_number:
		await _type_into(first_name, _girl.display_name)
		if hearts >= _rules.heart_emoji_at_hearts:
			await _add_heart()
		caret.visible = false
		await _show_traits(hearts)
		await _next_field()
		await _type_into(phone, _girl.phone_number)
		await _next_field()
		await _type_into(address, _girl.address)
		caret.visible = false
		await _scroll_to_end()
		await _tap(done, style.done_sound)
		result.text = style.got_number_text
	else:
		# A failed date: "not a chance!" where her name would go, and that's it.
		await _type_into(first_name, style.failed_name_text)
		caret.visible = false
		await _tap(cancel, style.cancel_sound)
		result.text = style.no_number_text
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
	# Blink, and stay hidden while the field is scrolled out of view (the caret isn't clipped).
	var in_view := scroll.get_global_rect().has_point(caret.position + caret.size / 2.0)
	caret.modulate.a = 1.0 if in_view and fmod(_time, 1.0) < 0.6 else 0.0


func _type_into(label: Label, words: String) -> void:
	_typing = label
	caret.visible = true
	_follow(label)
	for character in words:
		_set_typed(label, _typed[label] + character)
		_play(style.space_sound if character == " " else style.key_sound)
		_time = 0.0
		await _wait(randf_range(style.min_seconds_per_key, style.max_seconds_per_key))


func _add_heart() -> void:
	_play(style.space_sound)
	await _wait(style.max_seconds_per_key * 2.0)
	_play(style.key_sound)
	_place_heart()
	if heart.visible:
		_pop(heart)
	await _wait(style.max_seconds_per_key)


# The heart after her name: her animation, picture, or emoji (the first that's set).
func _place_heart() -> void:
	if style.heart_animation:
		_show_animated_heart()
	elif style.heart_image:
		heart.custom_minimum_size = Vector2(style.heart_size, style.heart_size)
		heart.texture = style.heart_image
		heart.visible = true
	else:
		heart_text.text = style.heart_text
		heart_text.visible = true


func _show_animated_heart() -> void:
	var frames := style.heart_animation
	var animation := StringName(style.heart_animation_name)
	if animation.is_empty() or not frames.has_animation(animation):
		animation = frames.get_animation_names()[0]
	heart_icon.custom_minimum_size = Vector2(style.heart_size, style.heart_size)
	heart_icon.visible = true
	heart_sprite.sprite_frames = frames
	heart_sprite.play(animation)
	heart_sprite.position = heart_icon.custom_minimum_size / 2.0
	var picture := frames.get_frame_texture(animation, 0)
	var fit := style.heart_size / maxf(picture.get_width(), picture.get_height()) if picture else 1.0
	heart_sprite.scale = Vector2.ZERO
	create_tween().tween_property(heart_sprite, "scale", Vector2(fit, fit), 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# One row per trait in her girl file, hidden until she gets to them.
func _build_traits() -> void:
	for child in trait_rows.get_children():
		trait_rows.remove_child(child)
		child.queue_free()
	var accent := _box.name_plate_color
	var her_font := _her_font()
	for i in _girl.traits.size():
		var info: GirlTrait = _girl.traits[i]
		# Only kinds listed in the rules' Trait Hearts show (abilities aren't, yet).
		if not info or not _rules.trait_hearts.has(info.kind):
			continue
		if trait_rows.get_child_count() > 0:
			var line := ColorRect.new()
			line.custom_minimum_size.y = 3
			line.color = Color(_box.text_color, 0.18)
			line.mouse_filter = Control.MOUSE_FILTER_IGNORE
			trait_rows.add_child(line)
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 30)
		if info.icon:
			var picture := TextureRect.new()
			picture.texture = info.icon
			picture.custom_minimum_size = Vector2(style.trait_icon_size, style.trait_icon_size)
			picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			picture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			picture.modulate.a = 0.0
			row.add_child(picture)
			row.set_meta("icon", picture)
		var kind := Label.new()
		kind.text = info.kind
		kind.custom_minimum_size = Vector2(170, 0)
		_font(kind, style.ui_font, style.ui_font_size, accent)
		row.add_child(kind)
		var words := VBoxContainer.new()
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		words.add_theme_constant_override("separation", 2)
		row.add_child(words)
		var title_label := Label.new()
		_font(title_label, her_font, style.field_font_size, _box.text_color)
		title_label.text = "" if style.type_traits else info.title
		words.add_child(title_label)
		if not info.description.is_empty():
			var description := Label.new()
			description.text = info.description
			description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			_font(description, her_font, style.trait_description_size, Color(_box.text_color, 0.7))
			words.add_child(description)
			row.set_meta("description", description)
		row.set_meta("trait", info)
		row.set_meta("title_label", title_label)
		row.set_meta("words", words)
		# The fields and their labels ("type", "tag"...) are there from the start, empty,
		# like "mobile" and "home"; what's in them pops in once her name is written.
		words.modulate.a = 0.0
		trait_rows.add_child(row)
	traits_group.visible = style.show_traits and trait_rows.get_child_count() > 0


# Her traits pop into their fields one after another, each boop a little higher than
# the last (or she types them), the card scrolling to follow. A kind that needs more
# hearts than the date earned (Trait Hearts) shows Secret Text instead.
func _show_traits(hearts: int) -> void:
	if not traits_group.visible:
		return
	await _wait(style.trait_reveal_seconds)
	var pitch := 1.0
	for child in trait_rows.get_children():
		if not child.has_meta("trait"):
			continue
		_follow(child)
		var words: Control = child.get_meta("words")
		var shown_title := _fill_trait(child, hearts)
		var title_label: Label = child.get_meta("title_label")
		if style.type_traits:
			words.modulate.a = 1.0
			_hints[title_label] = ""
			_typed[title_label] = ""
			await _type_into(title_label, shown_title)
			caret.visible = false
			await _wait(style.pause_between_fields * 0.5)
		else:
			_boop_at(pitch)
			pitch += style.trait_pitch_step
			words.pivot_offset = Vector2(0.0, words.size.y / 2.0)
			words.scale = Vector2(0.4, 0.4)
			words.modulate.a = 1.0
			create_tween().tween_property(words, "scale", Vector2.ONE, 0.18) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			await _wait(style.trait_reveal_seconds)


# Fills a trait's row for a date that earned `hearts`: its title, or Secret Text when
# its kind needs more hearts (Trait Hearts). Returns what the field says.
func _fill_trait(row: Control, hearts: int) -> String:
	var info: GirlTrait = row.get_meta("trait")
	var secret := hearts < int(_rules.trait_hearts.get(info.kind, 0))
	var shown_title := style.secret_text if secret else info.title
	row.get_meta("title_label").text = shown_title
	if row.has_meta("description"):
		row.get_meta("description").visible = not secret
	if row.has_meta("icon") and not secret:
		row.get_meta("icon").modulate.a = 1.0
	return shown_title


func _boop_at(pitch: float) -> void:
	if style.trait_sound:
		_boop.stream = style.trait_sound
		_boop.volume_db = style.volume_db
		_boop.pitch_scale = pitch
		_boop.play()


# Scrolls all the way down, so the whole card is in view when she's done.
func _scroll_to_end() -> void:
	# Wrapped descriptions settle a few frames after they appear.
	for i in 3:
		await get_tree().process_frame
	var end := int(scroll.get_v_scroll_bar().max_value - scroll.size.y)
	if end > scroll.scroll_vertical:
		var slide := create_tween()
		slide.tween_property(scroll, "scroll_vertical", end, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await slide.finished
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value - scroll.size.y)


# Scrolls the card so `node` is in view, the way a phone follows what you're typing.
func _follow(node: Control) -> void:
	# Wrapped descriptions settle a few frames after they appear.
	for i in 3:
		await get_tree().process_frame
	var view := scroll.get_global_rect()
	var bottom := node.get_global_rect().end.y + 40.0
	var top := node.get_global_rect().position.y - 40.0
	var target := scroll.scroll_vertical
	if bottom > view.end.y:
		target += int(bottom - view.end.y)
	elif top < view.position.y:
		target -= int(view.position.y - top)
	if target != scroll.scroll_vertical:
		create_tween().tween_property(scroll, "scroll_vertical", target, 0.3) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _pop(node: Control) -> void:
	node.pivot_offset = node.custom_minimum_size / 2.0
	node.scale = Vector2.ZERO
	create_tween().tween_property(node, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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


# A saved contact (in the Contacts app) or a new one (the end of a date): the header,
# and the empty rows a saved contact doesn't show.
func _set_saved(saved: bool) -> void:
	_saved = saved
	cancel.text = style.back_text if saved else style.cancel_text
	title.visible = not saved
	done.visible = not saved
	add_photo.visible = not saved
	result.visible = not saved
	for node: Control in [%Line1, last_name, %Line2, company]:
		node.visible = not saved
	cancel.mouse_filter = Control.MOUSE_FILTER_STOP if saved else Control.MOUSE_FILTER_IGNORE
	cancel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if saved else Control.CURSOR_ARROW


func _on_cancel_input(event: InputEvent) -> void:
	if _saved and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_go_back()


func _unhandled_input(event: InputEvent) -> void:
	if _saved and visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back()


func _go_back() -> void:
	_play(style.back_sound)
	cancel.pivot_offset = cancel.size / 2.0
	var press := create_tween()
	press.tween_property(cancel, "scale", Vector2(1.15, 1.15), 0.06)
	press.tween_property(cancel, "scale", Vector2.ONE, 0.1)
	back_pressed.emit()


# Shows what's been typed, or the grey hint when nothing has.
func _set_typed(label: Label, words: String) -> void:
	_typed[label] = words
	var empty := words.is_empty()
	label.text = String(_hints.get(label, "")) if empty else words
	var color := _box.text_color if _box else Color.BLACK
	label.add_theme_color_override("font_color", Color(color, color.a * style.hint_alpha) if empty else color)


func _apply_style() -> void:
	var accent := _box.name_plate_color
	var her_font := _her_font()

	dim.color = style.behind_dim
	var sheet_box := StyleBoxFlat.new()
	sheet_box.bg_color = style.sheet_color
	sheet_box.set_corner_radius_all(style.sheet_corner)
	sheet_box.anti_aliasing = true
	sheet.add_theme_stylebox_override("panel", sheet_box)

	for group: PanelContainer in [name_group, phone_group, address_group, traits_group]:
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
	result.custom_minimum_size.y = style.ui_font_size * 1.6
	for label: Label in [cancel, done, add_photo, phone_kind, address_kind]:
		_font(label, style.ui_font, style.ui_font_size, accent)
	title.text = style.title
	cancel.text = style.cancel_text
	done.text = style.done_text
	add_photo.text = style.add_photo_text
	phone_kind.text = style.phone_kind
	address_kind.text = style.address_kind
	caret.color = accent
	_font(heart_text, style.emoji_font if style.emoji_font else emoji_font(), style.field_font_size, Color.WHITE)

	var round_box := StyleBoxFlat.new()
	round_box.bg_color = accent
	round_box.set_corner_radius_all(1000)
	round_box.anti_aliasing = true
	circle.add_theme_stylebox_override("panel", round_box)
	_font(initials, her_font, 120, _box.name_color)
	initials.text = initials_of(_girl.display_name)
	photo.texture = _girl.contact_photo
	photo.visible = _girl.contact_photo != null
	initials.visible = _girl.contact_photo == null


func _her_font() -> Font:
	return font_of(_box)


## Her dialogue box style (the default one if she has none): her card's boxes and font.
static func box_style_of(girl: GirlData) -> DialogueBoxStyle:
	return girl.dialogue_style if girl and girl.dialogue_style else load(DEFAULT_BOX_STYLE)


## The font for a box style (the default style's font if it has none).
static func font_of(box: DialogueBoxStyle) -> Font:
	return box.font if box.font else (load(DEFAULT_BOX_STYLE) as DialogueBoxStyle).font


func _draw_outline(group: PanelContainer) -> void:
	var outline := _box.make_outline() if _box else null
	if outline:
		group.draw_style_box(outline, Rect2(Vector2.ZERO, group.size))


func _font(label: Label, font: Font, font_size: int, color: Color) -> void:
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)


## The computer's colour emoji font.
static func emoji_font() -> Font:
	var emoji := SystemFont.new()
	emoji.font_names = PackedStringArray(["Apple Color Emoji", "Noto Color Emoji", "Segoe UI Emoji"])
	return emoji


## "Split Ends" → "SE": shown in the circle when she has no contact photo.
static func initials_of(full_name: String) -> String:
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
	show_card(test_girl, DateRules.new())
	var got_number := await play(test_hearts)
	print("ContactCard: %s -> %s" % ["failed date" if test_hearts < 0 else "%d hearts" % test_hearts, "got her number" if got_number else "no number"])
