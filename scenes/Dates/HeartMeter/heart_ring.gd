class_name HeartRing
extends Control
## One ring of the heart meter: it fills clockwise from the top, and the heart in its
## middle is grey until it's full; then it turns to colour (and plays Heart Animation). The meter builds these from HeartRing.tscn; move or
## resize the Heart there. Its look is data/heart_meter_style.tres, its colour her
## dialogue style's Meter Color.

## Sent when the ring fills and the heart turns to colour.
signal heart_won

# A heart shown in grey (a picture's colours turned to shades of grey).
const GREY := "shader_type canvas_item;\nvoid fragment() {\n\tfloat g = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));\n\tCOLOR.rgb = vec3(g);\n}\n"

## How full the ring looks now, 0-1.
var fill := 0.0:
	set(value):
		fill = value
		queue_redraw()
## Whether its heart has been won.
var won := false

var _style: HeartMeterStyle
var _color := Color.WHITE
var _tween: Tween
var _grey := ShaderMaterial.new()

@onready var heart: TextureRect = %Heart
## The animated heart, shown instead of Heart once the ring is full (Heart Animation).
@onready var heart_sprite: AnimatedSprite2D = %HeartSprite


func _ready() -> void:
	_grey.shader = Shader.new()
	_grey.shader.code = GREY
	resized.connect(_center_heart)


## Sets the ring's look. `color` = what it fills with.
func setup(style: HeartMeterStyle, color: Color) -> void:
	_style = style
	_color = color
	custom_minimum_size = Vector2.ONE * style.ring_size
	heart.custom_minimum_size = Vector2.ONE * style.heart_size
	heart.size = heart.custom_minimum_size
	_center_heart()
	_show_heart(false)
	queue_redraw()


## Fills (or empties) the ring to `amount` (0-1). `animate` = slide there over Fill
## Seconds; a ring that becomes full wins its heart (and plays the sound).
func fill_to(amount: float, animate := true) -> void:
	amount = clampf(amount, 0.0, 1.0)
	if _tween:
		_tween.kill()
	if not animate or _style.fill_seconds <= 0.0:
		fill = amount
		_update_heart(false)
		return
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "fill", amount, _style.fill_seconds)
	_tween.tween_callback(_update_heart.bind(true))


func _update_heart(celebrate: bool) -> void:
	var full := fill >= 0.999
	if full == won:
		return
	won = full
	_show_heart(full)
	if full and celebrate:
		# Pop whichever heart is showing.
		if heart_sprite.visible:
			var rest := heart_sprite.scale
			heart_sprite.scale = rest * _style.heart_pop
			create_tween().tween_property(heart_sprite, "scale", rest, 0.35) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			heart.pivot_offset = heart.size / 2.0
			heart.scale = Vector2.ONE * _style.heart_pop
			create_tween().tween_property(heart, "scale", Vector2.ONE, 0.35) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		heart_won.emit()


func _show_heart(full: bool) -> void:
	if full or not _style.empty_heart_image:
		heart.texture = _style.heart_image
	else:
		heart.texture = _style.empty_heart_image
	# No separate empty picture: the heart in grey, a little see-through.
	var greyed := not full and not _style.empty_heart_image
	heart.material = _grey if greyed else null
	heart.modulate.a = _style.empty_heart_alpha if not full else 1.0
	# Won, with an animated heart: it plays instead of the still picture.
	var animated := full and _style.heart_animation != null
	heart.visible = not animated
	heart_sprite.visible = animated
	if animated:
		_play_heart_animation()
	else:
		heart_sprite.stop()


func _play_heart_animation() -> void:
	var frames := _style.heart_animation
	var animation := StringName(_style.heart_animation_name)
	if animation.is_empty() or not frames.has_animation(animation):
		animation = frames.get_animation_names()[0]
	heart_sprite.sprite_frames = frames
	var picture := frames.get_frame_texture(animation, 0)
	var side := maxf(picture.get_width(), picture.get_height()) if picture else float(_style.heart_size)
	heart_sprite.scale = Vector2.ONE * (_style.heart_size / side)
	heart_sprite.position = size / 2.0
	heart_sprite.play(animation)


func _center_heart() -> void:
	if heart:
		heart.position = (size - heart.size) / 2.0
	if heart_sprite:
		heart_sprite.position = size / 2.0


func _draw() -> void:
	if not _style:
		return
	var center := size / 2.0
	var radius := minf(size.x, size.y) / 2.0 - _style.ring_width / 2.0
	if _style.ring_outline_color.a > 0.0:
		draw_arc(center, radius, 0.0, TAU, 96, _style.ring_outline_color, _style.ring_width + 6.0, true)
	draw_arc(center, radius, 0.0, TAU, 96, _style.track_color, _style.ring_width, true)
	if fill > 0.0:
		# Clockwise from the top.
		draw_arc(center, radius, -PI / 2.0, -PI / 2.0 + TAU * fill, maxi(8, int(96 * fill)), _color, _style.ring_width, true)
