extends Node
class_name Style

enum Styles {
	GRUNGE,
	PREP,
	NERD,
	INSTAGRAM
}

var style: Styles
var intensity: float

func _init(init_style: Styles, init_intensity: float):
	style = init_style
	intensity = init_intensity
