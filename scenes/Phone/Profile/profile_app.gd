class_name ProfileApp
extends PhoneOverlayApp
## Your Profile, an app on your phone: your stats (every one that's on in
## data/stats.tres), each 1-9 with a bar. Press P (the open_profile action) on the
## calendar and the phone switches to it, like moving between open apps on an iPhone (W
## flips through all your apps); P again, Escape or the phone's home bar goes back to
## the app you were on before.
##
## The list is Stat Bars (scenes/Stats/StatBars.tscn): click StatBars in this scene
## (PhoneScreen → Phone → Body → Screen → Margin → Column → Scroll → Stats) to change its
## sizes or heading, or to show only some stats. Drop in another to split them into
## groups. The list scrolls when it's taller than the phone. The phone (screen, font,
## accent colour) is data/phone_style.tres; the words are the settings below. Press F6
## to try it.

## The big title.
@export var title_text: String = "Profile"
## Under the title.
@export var subtitle_text: String = "Your stats"

@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var scroll: ScrollContainer = %Scroll


func _ready() -> void:
	phone_screen.home_pressed.connect(close)
	visible = false
	if get_parent() == get_tree().root:
		phone_screen.behind = PhoneScreen.Behind.ROOM
		phone_screen.apply_style()
		open.call_deferred()


func _show_now() -> void:
	show_profile()


## Shows it at once, with your stats as they are now.
func show_profile() -> void:
	var ui := phone_screen.style
	ui.style_label(title, ui.ui_text_color, ui.title_font_size)
	title.text = title_text
	ui.style_label(subtitle, Color(ui.ui_text_color, 0.5))
	subtitle.text = subtitle_text
	# Every list of stats on it, as they are now.
	for node in find_children("*", "StatBars", true, false):
		(node as StatBars).refresh()
	scroll.scroll_vertical = 0
	phone_screen.show_up()
	visible = true
