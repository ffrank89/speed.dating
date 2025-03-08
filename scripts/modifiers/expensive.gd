extends Node
class_name Expensive

enum Expensives {
	CHEAP,
	MEH,
	NICE,
	LUXURY
}

var expensive: Expensives
var intensity: float

func _init(init_expensive: Expensives, init_intensity: float):
	expensive = init_expensive
	intensity = init_intensity
