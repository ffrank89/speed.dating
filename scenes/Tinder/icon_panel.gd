extends Panel
## Her picture on her dating profile: her animated sprite (her date character's icon_path,
## a SpriteFrames file), in the middle, scaled to fit. The dating app sets its look
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


## Shows the SpriteFrames file at `frames_path`, playing.
func update_display(frames_path: String) -> void:
	if ResourceLoader.exists(frames_path):
		animated_sprite.sprite_frames = load(frames_path)
		animated_sprite.play()
	else:
		animated_sprite.sprite_frames = null
		push_error("Dating app: no picture at \"%s\"." % frames_path)


func _process(_delta: float) -> void:
	# Stays in the middle and fits as the box changes size.
	animated_sprite.position = size / 2.0
	if not animated_sprite.sprite_frames:
		return
	var texture := animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, 0)
	if texture:
		var fit := minf(size.x * fill / texture.get_width(), size.y * fill / texture.get_height())
		animated_sprite.scale = Vector2(fit, fit)
