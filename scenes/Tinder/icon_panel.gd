extends Panel
## Her picture on her dating profile: her animated sprite (her girl file's Profile
## Picture), in the middle, scaled to fit. The dating app sets its look
## (data/dating_app_style.tres → Profile Card).

## How much of the box her picture fills (1 = touches the edges).
var fill := 0.9

var animated_sprite: AnimatedSprite2D


func _ready() -> void:
	if has_node("AnimatedSprite2D"):
		animated_sprite = $AnimatedSprite2D
	else:
		animated_sprite = AnimatedSprite2D.new()
		animated_sprite.name = "AnimatedSprite2D"
		add_child(animated_sprite)


## Shows these frames, playing. Null = an empty box.
func update_display(frames: SpriteFrames) -> void:
	animated_sprite.sprite_frames = frames
	if frames:
		animated_sprite.play()


func _process(_delta: float) -> void:
	# Stays in the middle and fits as the box changes size.
	animated_sprite.position = size / 2.0
	if not animated_sprite.sprite_frames:
		return
	var texture := animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, 0)
	if texture:
		var fit := minf(size.x * fill / texture.get_width(), size.y * fill / texture.get_height())
		animated_sprite.scale = Vector2(fit, fit)
