class_name GirlPortrait
extends Control
## Shows one of a girl's poses, sized and placed by that pose's Scale, Offset and Flip.
## Place and size this node where she should stand: at Scale 1.0 a pose fits inside
## it with her feet on its bottom edge, and Scale grows or shrinks her from there.
## Full guide: docs/guides/dialogue-box.md

var _image: TextureRect
var _pose: GirlPose


func _ready() -> void:
	_image = TextureRect.new()
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_image)
	resized.connect(_apply)
	_apply()


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
