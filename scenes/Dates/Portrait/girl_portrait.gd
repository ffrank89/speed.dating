class_name GirlPortrait
extends Control
## Shows one of a girl's poses, sized and placed by that pose's Scale, Offset and Flip.
## Place and size this node where she should stand: at Scale 1.0 a pose fits inside
## it with her feet on its bottom edge, and Scale grows or shrinks her from there.
## Full guide: docs/guides/dialogue-box.md

var _image: TextureRect
var _pose: GirlPose
# Pose pictures read back for is_point_on_her(), so each is only read once.
var _pixels := {}


func _ready() -> void:
	_image = TextureRect.new()
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_image)
	resized.connect(_apply)
	_apply()


## True if `point` (in screen space) is on a drawn part of her current pose, not on
## the see-through space around her. Used to drop option bubbles onto her.
func is_point_on_her(point: Vector2) -> bool:
	if not _image or not _image.texture:
		return false
	var local := _image.get_global_transform().affine_inverse() * point
	if not Rect2(Vector2.ZERO, _image.size).has_point(local):
		return false
	var texture := _image.texture
	if not _pixels.has(texture):
		var read := texture.get_image()
		if read and read.is_compressed():
			read.decompress()
		_pixels[texture] = read
	var picture: Image = _pixels[texture]
	if not picture:
		return true  # Can't read the picture: count the whole pose's box.
	# Undo the "keep aspect, centred" fit to find the pixel under the point.
	var picture_size := Vector2(picture.get_size())
	var fit := minf(_image.size.x / picture_size.x, _image.size.y / picture_size.y)
	var pixel := (local - (_image.size - picture_size * fit) / 2.0) / fit
	if _image.flip_h:
		pixel.x = picture_size.x - 1.0 - pixel.x
	if not Rect2(Vector2.ZERO, picture_size).has_point(pixel):
		return false
	return picture.get_pixelv(Vector2i(pixel)).a > 0.3


## Shows a pose. Pass null to show nothing.
func show_pose(pose: GirlPose) -> void:
	_pose = pose
	_apply()


func _apply() -> void:
	if not _image:
		return
	var pose_scale := _pose.scale if _pose else 1.0
	_image.texture = _pose.image if _pose else null
	_image.flip_h = _pose.flip if _pose else false
	_image.size = size
	_image.position = _pose.offset if _pose else Vector2.ZERO
	# Grow and shrink from her feet, so she stays standing on the same spot.
	_image.pivot_offset = Vector2(size.x / 2.0, size.y)
	_image.scale = Vector2(pose_scale, pose_scale)
