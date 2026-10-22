class_name SynergyStreams
extends Node2D
## The synergy streams on the Contacts list: for each two girls who share tags, a stream of
## sprites flows between their photos, bowing out to the right, stronger (more, bigger,
## faster, more solid sprites) the more tags they share. The look and the score are a
## SynergyStyle (data/synergy.tres). The Contacts app puts one of these over its list.

## One stream between two girls' photos.
class Stream:
	var from: Control
	var to: Control
	var points := 0
	# How far apart they are on the list (1 = next to each other).
	var apart := 1
	var sprites: Array[AnimatedSprite2D] = []
	# Each sprite's place along the stream (0-1) and which way it flows.
	var places: Array[float] = []
	var backwards: Array[bool] = []


var style: SynergyStyle
var _streams: Array[Stream] = []
var _time := 0.0


## Makes a stream for each two of `photos` (one per girl, in list order) whose `girls`
## share tags. Clears any old ones.
func setup(synergy: SynergyStyle, photos: Array[Control], girls: Array[GirlData]) -> void:
	style = synergy
	for old in get_children():
		old.queue_free()
	_streams.clear()
	if not style:
		return
	for i in girls.size():
		for j in range(i + 1, girls.size()):
			var points := style.score(girls[i], girls[j])
			if points > 0:
				_add_stream(photos[i], photos[j], points, j - i)


func _add_stream(from: Control, to: Control, points: int, apart: int) -> void:
	var stream := Stream.new()
	stream.from = from
	stream.to = to
	stream.points = mini(points, style.max_points)
	stream.apart = apart
	var count := style.sprites_per_point * stream.points
	var animation := style.animation_name
	if style.sprite_frames and (animation.is_empty() or not style.sprite_frames.has_animation(animation)):
		animation = style.sprite_frames.get_animation_names()[0]
	for i in count:
		var sprite := AnimatedSprite2D.new()
		if style.sprite_frames:
			sprite.sprite_frames = style.sprite_frames
			sprite.play(animation)
			sprite.frame = i % maxi(style.sprite_frames.get_frame_count(animation), 1)
		add_child(sprite)
		stream.sprites.append(sprite)
		stream.places.append(float(i) / count)
		stream.backwards.append(style.both_ways and i % 2 == 1)
	_streams.append(stream)


func _process(delta: float) -> void:
	_time += delta
	for stream in _streams:
		if not is_instance_valid(stream.from) or not is_instance_valid(stream.to):
			continue
		var start := to_local(stream.from.get_global_rect().get_center())
		var end := to_local(stream.to.get_global_rect().get_center())
		var middle := (start + end) / 2.0 + Vector2(style.arc_bulge * (1.0 + 0.5 * (stream.apart - 1)), 0.0)
		var length := start.distance_to(middle) + middle.distance_to(end)
		var extra := stream.points - 1
		var flow := (style.speed + style.speed_per_point * extra) / maxf(length, 1.0)
		var size := style.sprite_size + style.size_per_point * extra
		var opacity := minf(style.opacity + style.opacity_per_point * extra, 1.0)
		for i in stream.sprites.size():
			stream.places[i] = fposmod(stream.places[i] + flow * delta, 1.0)
			var t := stream.places[i]
			if stream.backwards[i]:
				t = 1.0 - t
			# Along a curve through the bow (a quadratic Bézier), wiggling off it a little.
			var point := start.lerp(middle, t).lerp(middle.lerp(end, t), t)
			var across := (middle.lerp(end, t) - start.lerp(middle, t)).orthogonal().normalized()
			point += across * sin(t * TAU * 2.0 + _time * 3.0 + i) * style.wobble
			var sprite := stream.sprites[i]
			sprite.position = point
			var frame_size := Vector2.ONE * 64.0
			if sprite.sprite_frames:
				var picture := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
				if picture:
					frame_size = picture.get_size()
			sprite.scale = Vector2.ONE * size / maxf(frame_size.x, frame_size.y)
			# They fade in leaving one photo and out reaching the other.
			sprite.modulate.a = opacity * sin(PI * stream.places[i])
