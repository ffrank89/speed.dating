@tool
class_name MicrogameStyle
extends Resource
## How the frame around every microgame looks and sounds: the dimmed date behind it,
## the instruction banner, the timer bar, the pass/fail stamp and the keyboard pointer.
## One shared file: data/microgame_style.tres. Hover any setting to see what it does.
##
## Where each part sits on screen is set in the scene scenes/Microgames/MicrogameHost.tscn
## (click Banner, TimerBar or Stamp there and move it). Each microgame sets its own banner
## words and length. Full guide: docs/guides/making-a-microgame.md

@export_group("Opening")
## Open microgames like an iPhone app: the picked option grows into the microgame, and
## it shrinks back afterwards (the same animation as the calendar and the dating app;
## its feel is in data/app_transition_style.tres, its icon in the microgame's App).
## Off = a plain fade.
@export var open_as_app: bool = true
## Only used with Open As App off: seconds the dim and the microgame take to fade in and out.
@export_range(0.0, 2.0, 0.05) var fade_seconds: float = 0.2

@export_group("Dim")
## Colour laid over the date while a microgame plays. Lower the A (alpha) to see more of the date.
@export var dim_color: Color = Color(0.03, 0.02, 0.06, 0.72)

@export_group("Banner")
## How long the instruction (e.g. "LIGHT IT!") shows before play starts, in seconds.
## The microgame is visible but frozen meanwhile, and the timer doesn't run.
@export_range(0.0, 3.0, 0.05) var banner_seconds: float = 0.8
## Leave empty to use Godot's default font.
@export var banner_font: Font
@export_range(8, 400) var banner_font_size: int = 150
@export var banner_text_color: Color = Color.WHITE
## Outline around each letter. 0 = none.
@export_range(0, 60) var banner_outline_width: int = 28
@export var banner_outline_color: Color = Color("#d8352b")
## Optional: a picture behind the words. It stretches like a picture frame.
@export var banner_image: Texture2D
## Only used with Banner Image: how many pixels in from each edge never stretch.
@export_range(0, 512) var banner_image_corner_size: int = 32
## Space between the edge of the banner picture and the words, in pixels.
@export_range(0, 200) var banner_padding: int = 40

@export_group("Timer Bar")
## Colour of the empty part of the bar.
@export var timer_back_color: Color = Color(0, 0, 0, 0.55)
## Colour of the part that shrinks as time runs out.
@export var timer_fill_color: Color = Color("#4cd47a")
## Fill colour in the last few seconds (see Low Seconds).
@export var timer_low_color: Color = Color("#ff5a5a")
## The fill turns Low Color when this many seconds are left. Tick Sound plays each second from then.
@export_range(0.0, 10.0, 0.5) var timer_low_seconds: float = 2.0
@export var timer_outline_color: Color = Color.WHITE
## Thickness of the line around the bar, in pixels. 0 = none.
@export_range(0, 20) var timer_outline_width: int = 4
## How rounded the bar's ends are, in pixels.
@export_range(0, 100) var timer_corner_radius: int = 20
## Optional: pictures for the bar's back and fill. They stretch like picture frames.
@export var timer_back_image: Texture2D
@export var timer_fill_image: Texture2D
## Only used with the timer pictures: how many pixels in from each edge never stretch.
@export_range(0, 512) var timer_image_corner_size: int = 16

@export_group("Stamp")
## Words stamped on screen when the player passes or fails.
@export var pass_text: String = "NICE!"
@export var fail_text: String = "OOPS!"
@export var pass_color: Color = Color("#4cd47a")
@export var fail_color: Color = Color("#ff5a5a")
## Leave empty to use the banner font.
@export var stamp_font: Font
@export_range(8, 600) var stamp_font_size: int = 240
@export_range(0, 60) var stamp_outline_width: int = 32
@export var stamp_outline_color: Color = Color.WHITE
## Optional: pictures to show instead of the words.
@export var pass_image: Texture2D
@export var fail_image: Texture2D
## Tilt of the stamp, in degrees.
@export_range(-45.0, 45.0, 0.5) var stamp_tilt: float = -8.0
## How long the stamp stays before the date comes back, in seconds.
@export_range(0.2, 4.0, 0.05) var stamp_seconds: float = 1.0

@export_group("Keyboard Pointer")
## Players can aim with the arrow keys or WASD instead of the mouse. This marks where
## they're aiming while they do. Optional picture; empty = a ring in Pointer Color.
@export var pointer_image: Texture2D
@export var pointer_color: Color = Color.WHITE
@export_range(8, 300) var pointer_size: int = 56
## How fast the arrow keys / WASD move the pointer, in pixels per second.
@export_range(100.0, 4000.0, 50.0) var pointer_speed: float = 1100.0

@export_group("Sounds")
## Played with the banner.
@export var start_sound: AudioStream
## Played once a second when time is low (see Timer Bar → Low Seconds).
@export var tick_sound: AudioStream
@export var pass_sound: AudioStream
@export var fail_sound: AudioStream
@export_range(-30.0, 6.0, 0.5) var volume_db: float = -4.0


## A flat box, or `image` stretched like a picture frame when one is set.
func make_box(fill: Color, line: Color, line_width: int, radius: int, image: Texture2D, corner: int) -> StyleBox:
	if image:
		var picture := StyleBoxTexture.new()
		picture.texture = image
		picture.set_texture_margin_all(corner)
		return picture
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.draw_center = fill.a > 0.0
	box.border_color = line
	box.set_border_width_all(line_width)
	box.set_corner_radius_all(radius)
	box.anti_aliasing = true
	return box
