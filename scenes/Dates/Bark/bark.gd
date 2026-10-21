class_name Bark
extends Control
## A quick line she says in a little bubble by her head, outside her dialogue box: in her
## own box style (her dialogue style) and voice, typed out, then it fades. The date uses
## it when a stage hazard annoys her (e.g. ".....ew" when the fly sits on her).
##
## Move or resize this node in the date scene (scenes/Dates/Date/Date.tscn → Bark) to
## change where the bubble appears: it sits at the bottom of this node, centred.

## How fast her line types out, in seconds per letter.
@export_range(0.01, 0.5, 0.01) var seconds_per_letter: float = 0.07
## How long the bubble stays up once her line is typed, in seconds.
@export_range(0.2, 10.0, 0.1) var seconds_shown: float = 1.4
## Size of her words. 0 = her dialogue style's size.
@export_range(0, 200) var font_size: int = 0
## How long the bubble takes to pop in and fade out, in seconds.
@export_range(0.0, 1.0, 0.05) var pop_seconds: float = 0.15

var _bubble: PanelContainer
var _label: Label
var _voice: VoicePlayer
var _shown := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble = PanelContainer.new()
	_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.visible = false
	add_child(_bubble)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.add_child(_label)
	_voice = VoicePlayer.new()
	add_child(_voice)


## She says `text` in the bubble, in her style and voice. Use with await: it returns once
## the line is typed (the bubble then stays up for Seconds Shown and fades by itself).
func say(text: String, girl: GirlData) -> void:
	var style := ContactCard.box_style_of(girl)
	_shown += 1
	var this_time := _shown
	_bubble.add_theme_stylebox_override("panel", style.make_box())
	_label.add_theme_font_override("font", style.text_font())
	_label.add_theme_font_size_override("font_size", font_size if font_size > 0 else style.font_size)
	_label.add_theme_color_override("font_color", style.text_color)
	_label.add_theme_constant_override("outline_size", style.text_outline_width)
	_label.add_theme_color_override("font_outline_color", style.text_outline_color)
	_label.text = text
	_label.visible_characters = 0
	_voice.set_voice(girl.voice if girl else null)
	_voice.reset()

	# Sits at the bottom of this node, centred, and pops in.
	_bubble.reset_size()
	_bubble.position = Vector2((size.x - _bubble.size.x) / 2.0, size.y - _bubble.size.y)
	_bubble.pivot_offset = Vector2(_bubble.size.x / 2.0, _bubble.size.y)
	_bubble.modulate.a = 1.0
	_bubble.scale = Vector2.ZERO
	_bubble.visible = true
	create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) \
		.tween_property(_bubble, "scale", Vector2.ONE, pop_seconds)

	for i in text.length():
		_label.visible_characters = i + 1
		_voice.speak(text[i])
		await get_tree().create_timer(seconds_per_letter).timeout
	_hide_later(this_time)


func _hide_later(this_time: int) -> void:
	await get_tree().create_timer(seconds_shown).timeout
	if this_time != _shown:
		return
	var fade := create_tween()
	fade.tween_property(_bubble, "modulate:a", 0.0, pop_seconds)
	await fade.finished
	if this_time == _shown:
		_bubble.visible = false
