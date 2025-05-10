extends Label

var value: float = 0.0
@export var decimal_places: int = 2

func update_value(new_value: float):
	value = new_value
	text = "%.{0}f".format([decimal_places]) % value
