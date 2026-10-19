class_name GirlPose
extends Resource
## One of a girl's full-art poses, and how big and where to show it.
## Poses are scaled from her feet (bottom-centre), so she stays standing on the
## same spot whatever the size. Full guide: docs/guides/dialogue-box.md

## The full-art picture for this pose.
@export var image: Texture2D
## Size of this pose. 1.0 = normal, 1.2 = 20% bigger, 0.8 = 20% smaller.
## Use it when this picture was drawn bigger or smaller than her other poses.
@export_range(0.25, 3.0, 0.01) var scale: float = 1.0
## Nudge this pose, in pixels. X: positive moves right. Y: positive moves down.
## Use it when the drawing sits off-centre in its picture.
@export var offset: Vector2 = Vector2.ZERO
## Mirror this pose left-to-right.
@export var flip: bool = false
