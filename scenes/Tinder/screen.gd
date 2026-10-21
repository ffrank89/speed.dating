extends Control
## The dating app, on your phone: one girl's profile at a time (her picture, name, age,
## bio and interests, from her girl file). Pass ("Ewwwwwww....") swipes her away for the
## next one; Start Dating! puts the phone down and the date with her begins (phone down:
## real life). Girls in your Contacts, girls whose first date failed, and girls with no
## First Date Dialogue yet aren't shown. When there's no one left, Start goes back to the
## calendar, and the days the Date choice took are given back (Give Days Back).
##
## The phone (screen, font, your room behind it) is data/phone_style.tres; the app's
## look, words and sounds are Style (data/dating_app_style.tres); move or resize the
## parts in this scene (PhoneScreen → Phone → Body → Screen → Margin).
## Who's in it: Girls below. Full guide: docs/guides/dating-app.md

## The app's look, words and sounds (data/dating_app_style.tres).
@export var style: DatingAppStyle
## Everyone on the app, in order: drag girl files (data/girls/) here.
@export var girls: Array[GirlData] = []
## The date that starts when you press Start Dating! (with the girl on screen).
@export_file("*.tscn") var date_scene: String = "res://scenes/Dates/Date/Date.tscn"
## No one left to date: going back to the calendar gives back the days the Date choice
## took (2), so the player hasn't lost them. Off = they stay spent.
@export var give_days_back: bool = true

# The girls you can swipe on now.
var _profiles: Array[GirlData] = []
var _index := 0
var _busy := false

@onready var phone_screen: PhoneScreen = %PhoneScreen
@onready var title: Label = %Title
@onready var card: PanelContainer = %Card
@onready var photo: Panel = %Photo
@onready var name_label: Label = %NameLabel
@onready var bio: Label = %Bio
@onready var interests_title: Label = %InterestsTitle
@onready var interests: Label = %Interests
@onready var empty: Label = %Empty
@onready var pass_button: Button = %Pass
@onready var start_button: Button = %Start
@onready var sound: AudioStreamPlayer = %Sound


func _ready():
	if not style:
		style = DatingAppStyle.new()
	_load_profiles()
	update_display()
	start_button.pressed.connect(_on_start_pressed)
	pass_button.pressed.connect(_on_next_pressed)
	for button: Button in [start_button, pass_button]:
		button.mouse_entered.connect(_play.bind(style.hover_sound))
	card.resized.connect(func() -> void: card.pivot_offset = card.size / 2.0)


func _load_profiles() -> void:
	for girl in girls:
		# No first date yet = nothing to play. In your contacts = taken. A failed first
		# date = gone for the run.
		if girl and girl.first_date_dialogue and not PlayerManager.is_in_party(girl) and not PlayerManager.is_gone(girl):
			_profiles.append(girl)


func update_display():
	_apply_style()
	if _profiles.is_empty():
		# Everyone's taken or gone: Start goes back to the calendar instead.
		card.visible = false
		empty.visible = true
		pass_button.visible = false
		start_button.text = style.back_text
		return
	var girl := _profiles[_index]
	_apply_card_style(girl)
	photo.update_display(girl.profile_picture)
	name_label.text = girl.display_name + style.age_text.format({"age": girl.age})
	bio.text = girl.bio
	bio.visible = not girl.bio.is_empty()
	interests_title.text = style.interests_title
	interests_title.visible = not girl.interests.is_empty()
	interests.text = "\n".join(girl.interests.map(func(interest: String) -> String: return style.bullet + interest))
	interests.visible = not girl.interests.is_empty()
	pass_button.disabled = _profiles.size() < 2


# The phone's font for the title and the empty message; the buttons from Style.
func _apply_style() -> void:
	var ui := phone_screen.style
	ui.style_label(title, ui.ui_text_color, ui.title_font_size)
	title.text = style.title
	ui.style_label(empty, Color(ui.ui_text_color, 0.5))
	empty.text = style.no_one_text
	pass_button.text = style.pass_text
	start_button.text = style.start_text
	for pair in [[pass_button, style.pass_color], [start_button, style.start_color]]:
		var button: Button = pair[0]
		var color: Color = pair[1]
		button.custom_minimum_size.y = style.button_height
		button.add_theme_stylebox_override("normal", style.make_button_box(color))
		button.add_theme_stylebox_override("hover", style.make_button_box(color.lightened(0.15)))
		button.add_theme_stylebox_override("pressed", style.make_button_box(color.darkened(0.15)))
		button.add_theme_stylebox_override("disabled", style.make_button_box(Color(color, 0.4)))
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		if ui.ui_font:
			button.add_theme_font_override("font", ui.ui_font)
		button.add_theme_font_size_override("font_size", style.button_font_size)
		for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			button.add_theme_color_override(state, style.button_text_color)
		button.add_theme_color_override("font_disabled_color", Color(style.button_text_color, 0.6))


# Her card in her own dialogue style (Use Her Style), or the plain card.
func _apply_card_style(girl: GirlData) -> void:
	var box_style: DialogueBoxStyle = ContactCard.box_style_of(girl) if style.use_her_style else null
	var ui := phone_screen.style
	var font: Font = box_style.text_font() if box_style else ui.ui_font
	var ink: Color = box_style.text_color if box_style else style.card_text_color
	var box: StyleBox
	if box_style:
		box = box_style.make_box()
	else:
		var flat := StyleBoxFlat.new()
		flat.bg_color = style.card_color
		flat.set_corner_radius_all(style.card_corner)
		flat.set_content_margin_all(28)
		flat.anti_aliasing = true
		box = flat
	card.add_theme_stylebox_override("panel", box)

	var photo_box := StyleBoxFlat.new()
	photo_box.bg_color = style.photo_background
	photo_box.set_corner_radius_all(int(style.card_corner * 0.6))
	photo_box.anti_aliasing = true
	photo.add_theme_stylebox_override("panel", photo_box)
	photo.custom_minimum_size.y = style.photo_height
	photo.fill = style.photo_fill

	# Her "next" arrow colour is made to show up on her box.
	var accent: Color = box_style.next_arrow_color if box_style else ui.accent_color
	_font(name_label, box_style.name_font if box_style and box_style.name_font else font, style.name_font_size, ink)
	_font(bio, font, style.bio_font_size, ink)
	_font(interests_title, font, style.interests_font_size, accent)
	_font(interests, font, style.interests_font_size, Color(ink, 0.8))


func _font(label: Label, font: Font, font_size: int, color: Color) -> void:
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)


# Pass: her card swipes off to the left, turning, and the next one comes in.
func _on_next_pressed():
	if _busy or _profiles.size() < 2:
		return
	_busy = true
	_play(style.pass_sound)
	var away := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	away.tween_property(card, "position:x", card.position.x - card.size.x * 1.3, style.swipe_seconds)
	away.tween_property(card, "rotation_degrees", -style.swipe_tilt, style.swipe_seconds)
	away.tween_property(card, "modulate:a", 0.0, style.swipe_seconds)
	await away.finished
	_index = (_index + 1) % _profiles.size()
	update_display()
	# Wait a frame so the column has put the card back in place.
	(card.get_parent() as Container).queue_sort()
	await get_tree().process_frame
	card.rotation_degrees = 0.0
	card.scale = Vector2(0.9, 0.9)
	var come_in := create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	come_in.tween_property(card, "scale", Vector2.ONE, style.swipe_seconds)
	come_in.tween_property(card, "modulate:a", 1.0, style.swipe_seconds)
	await come_in.finished
	_busy = false


func _on_start_pressed():
	if _busy or AppLauncher.is_busy():
		return
	if _profiles.is_empty():
		# No date, so the date's days come back.
		if give_days_back and PlayerManager.calendar:
			PlayerManager.calendar.give_back()
		AppLauncher.open_scene("calendar", PlayerManager.CALENDAR, start_button.get_global_rect())
		return
	_busy = true
	_play(style.start_sound)
	PlayerManager.select_girl(_profiles[_index])
	# Phone down: real life, the date with her.
	AppLauncher.phone_down(date_scene)


func _play(stream: AudioStream) -> void:
	if stream:
		sound.stream = stream
		sound.volume_db = style.volume_db
		sound.play()
