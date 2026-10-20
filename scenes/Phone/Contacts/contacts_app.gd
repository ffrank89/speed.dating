class_name ContactsApp
extends CanvasLayer
## Your party, as the Contacts on your phone: every girl who gave you her number is
## saved here. Press C (the open_contacts action) and the list slides up over the screen.
## Click a girl to open her contact (her card as she filled it in on the date: what your
## hearts unlocked, her number and address); "‹ Contacts" goes back. C again, Escape or
## the bar at the bottom slides it away.
##
## C works on any screen that has this scene in it. For now that's only the calendar.
##
## The look, words and sounds are data/contact_card_style.tres → Contacts App; each row
## and her card use her dialogue style. Move or resize the list in this scene.
## Press F6 to try it with the Testing settings.
## Full guide: docs/guides/contacts.md

## A girl's contact was opened.
signal contact_opened(member: PartyMember)
## The list slid away.
signal closed

## The key that opens and closes Contacts: an action in Project Settings → Input Map
## (open_contacts = C).
@export var open_action: StringName = &"open_contacts"
## How the list and the cards look and sound (data/contact_card_style.tres).
@export var style: ContactCardStyle
## Which hearts unlock what on her card (data/date_rules.tres → Result).
@export var rules: DateRules

@export_group("Testing (F6)")
## Played on its own, the list shows these girls instead of your party.
@export var test_contacts: Array[GirlData] = []
## The hearts each test contact got on her date (0-3).
@export_range(0, 3) var test_hearts: int = 1

var _members: Array[PartyMember] = []
# Played on its own (F6): the test contacts, shown instead of your party.
var _test_members: Array[PartyMember] = []
var _busy := false

@onready var dim: ColorRect = %Dim
@onready var sheet: Panel = %Sheet
@onready var title: Label = %Title
@onready var scroll: ScrollContainer = %Scroll
@onready var list: VBoxContainer = %List
@onready var empty: Label = %Empty
@onready var count: Label = %Count
@onready var home_bar: Control = %HomeBar
@onready var home_pill: Panel = %HomePill
@onready var card: ContactCard = %ContactCard
@onready var sound: AudioStreamPlayer = %Sound


func _ready() -> void:
	if not style:
		style = ContactCardStyle.new()
	if not rules:
		rules = DateRules.new()
	card.style = style
	# The list is already dimming what's behind; her card sits on the list.
	card.dim.visible = false
	card.back_pressed.connect(_back_to_list)
	home_bar.gui_input.connect(_on_home_bar_input)
	if not InputMap.has_action(open_action):
		push_warning("ContactsApp: no input action \"%s\" (Project Settings → Input Map)." % open_action)
	if get_parent() == get_tree().root:
		_play_alone.call_deferred()
	else:
		visible = false


## Slides the list up from the bottom of the screen. Use with await to wait for it.
func open() -> void:
	if visible or _busy or AppLauncher.is_busy():
		return
	show_list()
	await _slide_sheet(true)


## Slides the list (and her card, if it's open) back down.
func close() -> void:
	if not visible or _busy:
		return
	await _slide_sheet(false)
	hide_list()
	closed.emit()


## Shows the list at once, without the open animation. `members` = who's in it;
## empty = your party (PlayerManager.party).
func show_list(members: Array[PartyMember] = []) -> void:
	_members = members
	if _members.is_empty():
		_members = _test_members if not _test_members.is_empty() else PlayerManager.get_party()
	_apply_style()
	_build_rows()
	card.visible = false
	sheet.position = Vector2(_sheet_x(), _sheet_y())
	sheet.modulate = Color.WHITE
	dim.modulate.a = 1.0
	scroll.scroll_vertical = 0
	visible = true


## Hides the list (and her card) at once, without sliding.
func hide_list() -> void:
	card.visible = false
	visible = false


func _apply_style() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = style.sheet_color
	box.set_corner_radius_all(style.sheet_corner)
	box.anti_aliasing = true
	sheet.add_theme_stylebox_override("panel", box)
	dim.color = style.behind_dim
	_font(title, style.ui_font, int(style.ui_font_size * 1.9), style.ui_text_color)
	title.text = style.list_title
	var faint := Color(style.ui_text_color, 0.45)
	_font(empty, style.ui_font, style.ui_font_size, faint)
	empty.text = style.no_contacts_text
	_font(count, style.ui_font, style.ui_font_size, faint)
	var pill := StyleBoxFlat.new()
	pill.bg_color = Color(style.ui_text_color, 0.85)
	pill.set_corner_radius_all(100)
	pill.anti_aliasing = true
	home_pill.add_theme_stylebox_override("panel", pill)


# One row per girl, A to Z, each in her own box style and font, under letter headers.
func _build_rows() -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	var sorted := _members.duplicate()
	sorted.sort_custom(func(a: PartyMember, b: PartyMember) -> bool:
		return a.display_name().naturalnocasecmp_to(b.display_name()) < 0)
	var letter := ""
	for member: PartyMember in sorted:
		var first := member.display_name().left(1).to_upper()
		if style.section_letters and first != letter:
			letter = first
			var header := Label.new()
			_font(header, style.ui_font, style.ui_font_size, Color(style.ui_text_color, 0.45))
			header.text = letter
			list.add_child(header)
		list.add_child(_make_row(member))
	empty.visible = _members.is_empty()
	scroll.visible = not _members.is_empty()
	count.visible = not _members.is_empty()
	count.text = style.one_contact_text if _members.size() == 1 else style.many_contacts_text % _members.size()


func _make_row(member: PartyMember) -> Control:
	var box := ContactCard.box_style_of(member.girl)
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", box.make_box())
	row.draw.connect(func() -> void:
		var outline := box.make_outline()
		if outline:
			row.draw_style_box(outline, Rect2(Vector2.ZERO, row.size)))
	# Pass, so the mouse wheel still scrolls the list over a row.
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.mouse_entered.connect(func() -> void: row.modulate = Color(1.08, 1.08, 1.08))
	row.mouse_exited.connect(func() -> void: row.modulate = Color.WHITE)
	row.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_open_contact(member))

	var line := HBoxContainer.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_theme_constant_override("separation", 30)
	row.add_child(line)

	# Her photo, or her initials in a circle in her name-plate colour (like her card).
	var circle := Panel.new()
	circle.custom_minimum_size = Vector2(style.row_photo_size, style.row_photo_size)
	circle.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	circle.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var round_box := StyleBoxFlat.new()
	round_box.bg_color = box.name_plate_color
	round_box.set_corner_radius_all(1000)
	round_box.anti_aliasing = true
	circle.add_theme_stylebox_override("panel", round_box)
	line.add_child(circle)
	if member.girl.contact_photo:
		var photo := TextureRect.new()
		photo.texture = member.girl.contact_photo
		photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		photo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		circle.add_child(photo)
	else:
		var initials := Label.new()
		initials.text = ContactCard.initials_of(member.display_name())
		initials.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		initials.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		initials.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_font(initials, ContactCard.font_of(box), int(style.row_photo_size * 0.42), box.name_color)
		circle.add_child(initials)

	var name_label := Label.new()
	name_label.text = member.display_name()
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_font(name_label, ContactCard.font_of(box), style.row_font_size, box.text_color)
	name_label.add_theme_constant_override("outline_size", box.text_outline_width)
	name_label.add_theme_color_override("font_outline_color", box.text_outline_color)
	line.add_child(name_label)

	# The heart after her name, if she gave you one on her card.
	if member.affection >= rules.heart_emoji_at_hearts:
		line.add_child(_make_heart())
	return row


func _make_heart() -> Control:
	var picture: Texture2D = style.heart_image
	if style.heart_animation:
		var frames := style.heart_animation
		var animation := StringName(style.heart_animation_name)
		if animation.is_empty() or not frames.has_animation(animation):
			animation = frames.get_animation_names()[0]
		picture = frames.get_frame_texture(animation, 0)
	if picture:
		var heart := TextureRect.new()
		heart.texture = picture
		heart.custom_minimum_size = Vector2.ONE * style.row_font_size
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return heart
	var heart_text := Label.new()
	heart_text.text = style.heart_text
	heart_text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_font(heart_text, style.emoji_font if style.emoji_font else ContactCard.emoji_font(), style.row_font_size, Color.WHITE)
	return heart_text


# Her saved card slides in over the list, the way a phone opens a contact.
func _open_contact(member: PartyMember) -> void:
	if card.visible or _busy:
		return
	_play(style.open_contact_sound)
	card.show_saved(member.girl, member.affection, rules)
	contact_opened.emit(member)
	_slide(true)


func _back_to_list() -> void:
	if not card.visible or _busy:
		return
	await _slide(false)
	card.visible = false


func _slide(opening: bool) -> void:
	_busy = true
	var push := sheet.size.x * 0.25
	if opening:
		card.offset.x = push
		card.sheet.modulate.a = 0.0
	var slide := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	slide.tween_property(card, "offset:x", 0.0 if opening else push, style.slide_seconds)
	slide.tween_property(card.sheet, "modulate:a", 1.0 if opening else 0.0, style.slide_seconds)
	slide.tween_property(sheet, "position:x", _sheet_x() - (push * 0.4 if opening else 0.0), style.slide_seconds)
	slide.tween_property(sheet, "modulate", Color(0.85, 0.85, 0.85) if opening else Color.WHITE, style.slide_seconds)
	await slide.finished
	_busy = false


# Up from below the screen (opening) or back down (closing), with the dim fading.
func _slide_sheet(opening: bool) -> void:
	_busy = true
	var rest := _sheet_y()
	var away := sheet.get_parent_area_size().y + 40.0
	if opening:
		sheet.position.y = away
		dim.modulate.a = 0.0
	var slide := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT if opening else Tween.EASE_IN)
	slide.tween_property(sheet, "position:y", rest if opening else away, style.open_seconds)
	slide.tween_property(dim, "modulate:a", 1.0 if opening else 0.0, style.open_seconds)
	if card.visible and not opening:
		slide.tween_property(card, "offset:y", away - rest, style.open_seconds)
	await slide.finished
	card.offset.y = 0.0
	_busy = false


# Where the sheet sits when nothing has pushed it aside.
func _sheet_x() -> float:
	return sheet.get_parent_area_size().x * sheet.anchor_left + sheet.offset_left


func _sheet_y() -> float:
	return sheet.get_parent_area_size().y * sheet.anchor_top + sheet.offset_top


func _on_home_bar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		close()


func _unhandled_input(event: InputEvent) -> void:
	if InputMap.has_action(open_action) and event.is_action_pressed(open_action):
		get_viewport().set_input_as_handled()
		if visible:
			close()
		else:
			open()
	# Escape on her card goes back (the card handles it); on the list it slides it away.
	elif visible and not card.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _font(label: Label, font: Font, font_size: int, color: Color) -> void:
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _play(stream: AudioStream) -> void:
	if stream:
		sound.stream = stream
		sound.volume_db = style.volume_db
		sound.play()


# F6: the test contacts slide up; press C to put them away and bring them back.
func _play_alone() -> void:
	for girl in test_contacts:
		if girl:
			_test_members.append(PartyMember.new(girl, test_hearts))
	if _test_members.is_empty():
		push_warning("ContactsApp: no Testing → Test Contacts, so the list shows your (empty) party.")
	open()
