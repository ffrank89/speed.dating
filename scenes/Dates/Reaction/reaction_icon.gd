class_name ReactionIcon
extends Control
## Pops up a little animated reaction (!, ?, anger, heart…) where this node sits,
## then hides itself. Dialogue lines trigger one with a tag, e.g. [#react=heart].
##
## The reactions are the animations in Reactions (data/reactions.tres, a SpriteFrames
## file). To add one: open that file, add an animation, drop its frames in, and use
## its name in a [#react=…] tag. Move this node in the scene to change where they appear.

## The reaction animations. Each animation's name is what [#react=…] uses.
@export var reactions: SpriteFrames
## How big the reaction is drawn. 1.0 = the pictures' own size.
@export_range(0.25, 6.0, 0.05) var icon_scale: float = 2.0
## How long a reaction stays up, in seconds.
@export_range(0.2, 6.0, 0.1) var seconds_shown: float = 2.5

var _sprite: AnimatedSprite2D
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = reactions
	_sprite.visible = false
	add_child(_sprite)


## Shows a reaction by name. Returns false (and shows nothing) if there's no such reaction.
func show_reaction(reaction_name: String) -> bool:
	if not reactions or not reactions.has_animation(reaction_name):
		push_warning("ReactionIcon: no reaction called \"%s\" in %s" % [reaction_name, reactions.resource_path if reactions else "(none)"])
		return false
	_sprite.position = size / 2.0
	_sprite.play(reaction_name)
	_sprite.visible = true
	if _tween:
		_tween.kill()
	_sprite.scale = Vector2.ZERO
	_tween = create_tween()
	_tween.tween_property(_sprite, "scale", Vector2.ONE * icon_scale * 1.25, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_sprite, "scale", Vector2.ONE * icon_scale, 0.1)
	_tween.tween_interval(seconds_shown)
	_tween.tween_property(_sprite, "scale", Vector2.ZERO, 0.12)
	_tween.tween_callback(func() -> void: _sprite.visible = false)
	return true
