extends Control
## Test bench for the first date: pick a girl in the Inspector, press F6.
## The sliders stand in for the player's attributes until RunState exists.

@export var girl: GirlData

# Static so the sliders keep their values when the date restarts.
static var attributes := {
	Attr.Id.CULTURE: 50,
	Attr.Id.INTELLECT: 50,
	Attr.Id.SEDUCTION: 50,
	Attr.Id.HEART: 50,
}

var _pose_names: Array[String] = []
var _pose_index := 0

@onready var background: TextureRect = $Background
@onready var portrait: TextureRect = $Portrait
@onready var girl_label: Label = %GirlLabel
@onready var sliders: VBoxContainer = %Sliders
@onready var pose_button: Button = %PoseButton
@onready var restart_button: Button = %RestartButton


func _ready() -> void:
	_build_sliders()
	pose_button.pressed.connect(_next_pose)
	restart_button.pressed.connect(get_tree().reload_current_scene)

	if not girl:
		girl_label.text = "No girl: drop a GirlData into the 'girl' slot"
		pose_button.disabled = true
		return

	girl_label.text = "%s, %d" % [girl.display_name, girl.age]
	background.texture = girl.date_background
	_pose_names.assign(girl.poses.keys())
	_pose_index = maxi(_pose_names.find(girl.default_pose), 0)
	_show_pose(girl.default_pose)


func _build_sliders() -> void:
	for attr in Attr.Id.values():
		var row := HBoxContainer.new()
		var label := Label.new()
		label.custom_minimum_size.x = 260
		label.text = _slider_text(attr)

		var slider := HSlider.new()
		slider.max_value = 100
		slider.value = attributes[attr]
		slider.custom_minimum_size.x = 400
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.value_changed.connect(func(value: float) -> void:
			attributes[attr] = int(value)
			label.text = _slider_text(attr)
		)

		row.add_child(label)
		row.add_child(slider)
		sliders.add_child(row)


func _slider_text(attr: Attr.Id) -> String:
	return "%s  %d" % [Attr.display_name(attr), attributes[attr]]


func _next_pose() -> void:
	_pose_index = (_pose_index + 1) % _pose_names.size()
	_show_pose(_pose_names[_pose_index])


func _show_pose(pose_name: String) -> void:
	portrait.texture = girl.get_pose(pose_name)
	pose_button.text = "Pose: %s  (next)" % pose_name
