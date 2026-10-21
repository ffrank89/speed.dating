class_name DebugNote
extends PanelContainer
## A small note on screen for testers, outside the phone: e.g. which keys open which
## apps. It only shows while the game runs from Godot (or in a debug export); a finished
## (release) build hides it. Drop DebugNote.tscn into any scene, move it, and type its Text.

## What the note says. Each line on its own row.
@export_multiline var text: String = "Debug"
## Off = it shows in a finished (release) build too.
@export var only_while_testing: bool = true
@export_range(8, 120) var font_size: int = 34
@export var text_color: Color = Color(1, 1, 1, 0.9)
@export var background_color: Color = Color(0, 0, 0, 0.55)

@onready var label: Label = %Text


func _ready() -> void:
	visible = not only_while_testing or OS.is_debug_build()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	var box := StyleBoxFlat.new()
	box.bg_color = background_color
	box.set_corner_radius_all(16)
	box.set_content_margin_all(22)
	add_theme_stylebox_override("panel", box)
