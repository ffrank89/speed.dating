class_name StatHub
extends PanelContainer
## The player's stats hub: every stat that's on (data/stats.tres), each as its picture and
## its number (1-9), in a panel beside the phone. It's a scene of its own
## (scenes/Stats/StatHub.tscn), so it can go on any screen; the calendar has one.
##
## When training raises a stat, show_changes() plays it: the stat's picture flies from the
## phone (the choice you picked) to the hub, the hub's picture of that stat swallows it,
## and the number next to it goes up. A stat that goes down just changes its number.
## Rest the mouse on a stat and its name shows above it.
##
## Its look (panel colour, font, text colours) is the player's style
## (data/player_style.tres); its layout and the animation's timing are the settings
## below. Full guide: docs/guides/stats.md

## A heading above the stats. Empty = none.
@export var heading_text: String = "Stats"
## Only these stats (drag stat files from data/stats/ here), in this order. Empty = every
## stat that's on. Stats that are off are left out either way.
@export var only_these: Array[PlayerStat] = []
## The player's look: the panel's colour and corners, the font and the text colours.
@export var player_style: PlayerStyle
## The phone's look, for its font when the player's style has none.
@export var phone_style: PhoneStyle

@export_group("Layout")
## How many stats side by side.
@export_range(1, 12) var columns: int = 2
## Size of each stat's picture, in pixels.
@export_range(16, 300) var icon_size: int = 90
## Size of the numbers.
@export_range(8, 200) var font_size: int = 60
## Size of the heading.
@export_range(8, 200) var heading_size: int = 44
## Space between the stats, in pixels.
@export_range(0, 200) var gap: int = 28
## Space inside the panel's edge, in pixels.
@export_range(0, 200) var padding: int = 32

@export_group("Names")
## Rest the mouse on a stat and its name shows above it, in a little tag.
@export var name_on_hover: bool = true
## Size of the name.
@export_range(8, 200) var name_size: int = 44

@export_group("Boost Animation")
## Seconds the stat's picture takes to fly from the phone to the hub.
@export_range(0.05, 3.0, 0.05) var fly_seconds: float = 0.7
## How high its path arcs up on the way, in pixels. 0 = a straight line.
@export_range(0.0, 1000.0, 10.0) var arc_height: float = 260.0
## Seconds the hub's picture takes to swallow it (a gulp, then it settles).
@export_range(0.05, 2.0, 0.05) var swallow_seconds: float = 0.45
## How big the hub's picture gets as it swallows: 1.4 = 40% bigger.
@export_range(1.0, 3.0, 0.05) var swallow_scale: float = 1.4
## How big the number pops as it changes.
@export_range(1.0, 3.0, 0.05) var number_pop_scale: float = 1.6
## The number flashes this colour as it goes up, then fades back.
@export var boost_color: Color = Color("#7cff6b")
## The number flashes this colour as it goes down.
@export var drop_color: Color = Color("#ff6b6b")
## Seconds between stats when one choice changes several.
@export_range(0.0, 2.0, 0.05) var between_seconds: float = 0.25
## Played as the hub swallows it.
@export var swallow_sound: AudioStream
@export_range(-40.0, 12.0, 0.5) var volume_db: float = -4.0

# Stat id → {"icon": TextureRect, "number": Label}.
var _rows := {}
var _grid := GridContainer.new()
var _heading := Label.new()
var _sound := AudioStreamPlayer.new()
# The name of the stat under the mouse, in a little tag above it.
var _name_tag := PanelContainer.new()
var _name_label := Label.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", gap)
	add_child(column)
	_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_heading)
	_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_grid)
	add_child(_sound)
	_name_tag.top_level = true
	_name_tag.z_index = 110
	_name_tag.visible = false
	_name_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_tag.add_child(_name_label)
	add_child(_name_tag)
	refresh()


## Shows the stats as they are now. Hides itself when there's nothing to show.
func refresh() -> void:
	var look := player_style if player_style else PlayerStyle.new()
	var font := look.font_or(phone_style.ui_font if phone_style else null)
	add_theme_stylebox_override("panel", look.make_panel(padding))
	_heading.text = heading_text
	_heading.visible = not heading_text.is_empty()
	look.style_label(_heading, font, heading_size, look.faint_text_color)
	_name_tag.add_theme_stylebox_override("panel", look.make_panel(maxi(padding / 3, 6), true))
	look.style_label(_name_label, font, name_size)
	_name_tag.visible = false
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	_rows.clear()
	_grid.columns = columns
	_grid.add_theme_constant_override("h_separation", gap * 2)
	_grid.add_theme_constant_override("v_separation", gap)
	var player := PlayerManager.ensure_player()
	for stat in _stats():
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_theme_constant_override("separation", gap)
		var icon := TextureRect.new()
		icon.texture = stat.icon
		icon.custom_minimum_size = Vector2.ONE * icon_size
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
		var number := Label.new()
		number.text = str(player.get_stat(stat))
		number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		number.custom_minimum_size.x = font_size
		look.style_label(number, font, font_size)
		row.add_child(number)
		_grid.add_child(row)
		_rows[stat.id] = {"icon": icon, "number": number}
		row.mouse_entered.connect(_show_name.bind(stat, icon))
		row.mouse_exited.connect(func() -> void: _name_tag.visible = false)
	visible = not _rows.is_empty()


## Plays stat changes (stat → amount, e.g. from DayAction.stat_changes()) after the
## player's stats have changed: each raised stat's picture flies from `from` (a rect on
## screen, e.g. the choice you picked) into the hub and its number goes up; a lowered
## stat's number goes down. Use with await to wait for all of them.
func show_changes(changes: Dictionary, from: Rect2) -> void:
	var first := true
	for stat: PlayerStat in changes:
		if not _rows.has(stat.id):
			continue
		if not first and between_seconds > 0.0:
			await get_tree().create_timer(between_seconds).timeout
		first = false
		if changes[stat] > 0:
			_fly_in(stat, from)
		else:
			_show_number(stat, drop_color)
	if not first:
		await get_tree().create_timer(fly_seconds + swallow_seconds).timeout


# The stat's picture flies from `from` to its row along an arc, shrinking to the row's
# picture size; then the row's picture swallows it and the number goes up.
func _fly_in(stat: PlayerStat, from: Rect2) -> void:
	var target: TextureRect = _rows[stat.id].icon
	var flier := TextureRect.new()
	flier.texture = stat.icon
	flier.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flier.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	flier.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Above everything on this screen, placed in screen pixels.
	flier.top_level = true
	flier.z_index = 100
	add_child(flier)
	var start := from.get_center()
	var start_size := Vector2.ONE * minf(from.size.x, from.size.y)
	var travel := func(p: float) -> void:
		var end := target.get_global_rect().get_center()
		var top := (start + end) / 2.0 - Vector2(0.0, arc_height)
		# A curve through the top of the arc (a quadratic Bézier).
		var point := start.lerp(top, p).lerp(top.lerp(end, p), p)
		flier.size = start_size.lerp(target.size, p)
		flier.position = point - flier.size / 2.0
	travel.call(0.0)
	var fly := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fly.tween_method(travel, 0.0, 1.0, fly_seconds)
	await fly.finished
	_swallow(target, flier)
	_show_number(stat, boost_color)


# The hub's picture gulps (grows, squashes, settles) as the flying one shrinks into it.
func _swallow(target: TextureRect, flier: TextureRect) -> void:
	if swallow_sound:
		_sound.stream = swallow_sound
		_sound.volume_db = volume_db
		_sound.play()
	flier.pivot_offset = flier.size / 2.0
	var gone := create_tween()
	gone.tween_property(flier, "scale", Vector2.ZERO, swallow_seconds * 0.25)
	gone.tween_callback(flier.queue_free)
	target.pivot_offset = target.size / 2.0
	var big := swallow_scale
	var gulp := create_tween()
	gulp.tween_property(target, "scale", Vector2(big, big), swallow_seconds * 0.2)
	gulp.tween_property(target, "scale", Vector2(big * 1.1, 1.0 / big), swallow_seconds * 0.2)
	gulp.tween_property(target, "scale", Vector2.ONE, swallow_seconds * 0.6) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


# The number shows the stat's value now: it pops and flashes `flash`, then fades back.
func _show_number(stat: PlayerStat, flash: Color) -> void:
	var number: Label = _rows[stat.id].number
	var look := player_style if player_style else PlayerStyle.new()
	number.text = str(PlayerManager.ensure_player().get_stat(stat))
	number.pivot_offset = number.size / 2.0
	number.scale = Vector2.ONE * number_pop_scale
	number.add_theme_color_override("font_color", flash)
	var pop := create_tween().set_parallel()
	pop.tween_property(number, "scale", Vector2.ONE, swallow_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_method(func(c: Color) -> void: number.add_theme_color_override("font_color", c),
		flash, look.text_color, swallow_seconds * 2.0)


# The stat's name in a tag, centred above its picture.
func _show_name(stat: PlayerStat, icon: TextureRect) -> void:
	if not name_on_hover:
		return
	_name_label.text = stat.display_name
	_name_tag.reset_size()
	var spot := icon.get_global_rect()
	_name_tag.position = Vector2(spot.get_center().x - _name_tag.size.x / 2.0, spot.position.y - _name_tag.size.y - 12.0)
	_name_tag.visible = true


# The stats to show: Only These, or every stat in data/stats.tres; only the ones that are on.
func _stats() -> Array[PlayerStat]:
	var list: Array[PlayerStat] = []
	var all := StatList.get_default()
	for stat in only_these if not only_these.is_empty() else all.stats:
		if stat and all.is_active(stat):
			list.append(stat)
	return list
