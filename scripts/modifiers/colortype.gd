extends Node
class_name ColorType

enum Colors {
	RED,
	BLUE,
	GREEN,
	BLACK
}

var color: Colors
var intensity: float

func _init(init_color: Colors, init_intensity: float):
	color = init_color
	intensity = init_intensity
