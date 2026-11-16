class_name GirlSpin
extends Control
## Shows a girl spinning on the spot, with buttons for how fast and which way.
## Her frames are on the Girl node (Sprite Frames). The buttons are drawn in her style
## (Style: a file from data/dialogue_styles/): her box, outline, font and colours.
## The chosen buttons use her name plate's colours.
## Press F6 to try it. The buttons appear when it runs.

## Her style. The buttons use its box, outline, font and colours.
@export var style: DialogueBoxStyle

@export_group("Speed")
## One button for each: its words, and how many frames a second. 0 = stopped.
## With 4 frames, 4 = one full turn a second.
@export var speeds: Dictionary[String, float] = {"Stop": 0.0, "Slow": 2.0, "Medium": 4.0, "Fast": 8.0}
## Which speed button is chosen when it starts (one of the words above).
@export var start_speed: String = "Medium"

@export_group("Direction")
## The words on the two direction buttons. Right = the frames in order
## (front, then facing right, back, facing left). Left = the other way.
@export var left_text: String = "Left"
@export var right_text: String = "Right"
## Start turning right. Off = start turning left.
@export var start_right: bool = true

var _frames_a_second := 0.0
var _direction := 1.0

@onready var girl: AnimatedSprite2D = $Girl
@onready var speed_row: Container = $Buttons/Speed
@onready var direction_row: Container = $Buttons/Direction


func _ready() -> void:
	# One button per speed, and only one of them chosen at a time (a ButtonGroup).
	var speed_group := ButtonGroup.new()
	for words in speeds:
		_add_button(speed_row, speed_group, words, words == start_speed, _set_speed.bind(speeds[words]))
	var direction_group := ButtonGroup.new()
	_add_button(direction_row, direction_group, left_text, not start_right, _set_direction.bind(-1.0))
	_add_button(direction_row, direction_group, right_text, start_right, _set_direction.bind(1.0))

	_frames_a_second = speeds.get(start_speed, 0.0)
	_direction = 1.0 if start_right else -1.0
	girl.play()
	_update()


func _set_speed(frames_a_second: float) -> void:
	_frames_a_second = frames_a_second
	_update()


func _set_direction(direction: float) -> void:
	_direction = direction
	_update()


# The frames file plays at its own speed; Speed Scale makes that the speed you picked.
# A negative Speed Scale plays the frames backwards, so she turns the other way.
func _update() -> void:
	var file_speed := girl.sprite_frames.get_animation_speed(girl.animation)
	if file_speed <= 0.0:
		return
	girl.speed_scale = _direction * _frames_a_second / file_speed


func _add_button(row: Container, group: ButtonGroup, words: String, chosen: bool, on_press: Callable) -> void:
	var button := Button.new()
	button.text = words
	button.toggle_mode = true
	button.button_group = group
	button.button_pressed = chosen
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(on_press)
	_use_her_style(button)
	row.add_child(button)


# Her box for a button; a thicker outline when the mouse is over it; her name plate's
# colours when it's the chosen one.
func _use_her_style(button: Button) -> void:
	if style == null:
		return
	var box := style.make_box()
	var hover := style.make_box()
	var chosen := style.make_box()
	if hover is StyleBoxFlat:
		hover.set_border_width_all(style.outline_width * 2)
	if chosen is StyleBoxFlat:
		chosen.bg_color = style.name_plate_color
		chosen.border_color = style.name_plate_outline_color
	elif chosen is StyleBoxTexture:
		chosen.modulate_color = style.name_plate_color
	button.add_theme_stylebox_override("normal", box)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", chosen)
	button.add_theme_stylebox_override("hover_pressed", chosen)

	button.add_theme_font_override("font", style.text_font())
	button.add_theme_font_size_override("font_size", style.font_size)
	button.add_theme_color_override("font_color", style.text_color)
	button.add_theme_color_override("font_hover_color", style.text_color)
	button.add_theme_color_override("font_pressed_color", style.name_color)
	button.add_theme_color_override("font_hover_pressed_color", style.name_color)
	button.add_theme_color_override("font_outline_color", style.text_outline_color)
	button.add_theme_constant_override("outline_size", style.text_outline_width)
