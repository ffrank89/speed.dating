class_name SynergyStyle
extends Resource
## Synergy between the girls in your party, and how the Contacts app shows it: for each
## two girls who share tags, a stream of little sprites flows between their photos on the
## list, stronger the more they share. Each tag flows its own sprites (Smoker: cigarette
## packs), so the stream shows what kind of synergy it is.
## data/synergy.tres; full guide: docs/guides/contacts.md

@export_group("Score")
## What counts: traits of these kinds (her girl file → Contact Card → Traits → Kind) with
## the same title on both girls ("Smoker" and "smoker" match). One point per match.
@export var counted_kinds: Array[String] = ["tag"]

@export_group("Each Tag's Sprites")
## Each tag's own sprites: Add Key/Value Pair, type the tag's title on the left
## ("Smoker"; capitals don't matter) and drop its SpriteFrames on the right. Two girls
## sharing that tag get a stream of these. A tag not listed here uses its trait's Icon
## (her girl file → Traits), or else Sprite Frames below.
@export var tag_sprites: Dictionary[String, SpriteFrames] = {}

@export_group("Stream")
## The sprites for a tag with none of its own (the Godot logo for now).
@export var sprite_frames: SpriteFrames
## Which animation plays, in any tag's sprites that have one by this name. Empty (or not
## there) = the first one.
@export var animation_name: StringName = &""
## How many sprites flow for each point of synergy (each shared tag's own sprites).
@export_range(1, 20) var sprites_per_point: int = 6
## At most this many points count towards how strong it looks.
@export_range(1, 20) var max_points: int = 4
## How big each sprite is at 1 point, in pixels...
@export_range(4.0, 300.0, 1.0) var sprite_size: float = 56.0
## ...and how much bigger for each point after that.
@export_range(0.0, 100.0, 1.0) var size_per_point: float = 18.0
## How fast they flow at 1 point, in pixels per second...
@export_range(10.0, 2000.0, 10.0) var speed: float = 180.0
## ...and how much faster for each point after that.
@export_range(0.0, 1000.0, 10.0) var speed_per_point: float = 80.0
## How see-through they are at 1 point (1 = solid)...
@export_range(0.05, 1.0, 0.05) var opacity: float = 0.75
## ...and how much more solid for each point after that.
@export_range(0.0, 1.0, 0.05) var opacity_per_point: float = 0.1
## How far the stream bows out to the right of the photos, in pixels (more for girls
## further apart on the list).
@export_range(0.0, 800.0, 10.0) var arc_bulge: float = 280.0
## How much the sprites wiggle off the stream's line, in pixels.
@export_range(0.0, 100.0, 1.0) var wobble: float = 16.0
## On: half the sprites flow each way. Off: from the girl higher on the list to the other.
@export var both_ways: bool = true


## How much synergy two girls have: the tags they share (Counted Kinds).
func score(a: GirlData, b: GirlData) -> int:
	return shared(a, b).size()


## The titles of the tags (Counted Kinds) both girls have.
func shared(a: GirlData, b: GirlData) -> Array[String]:
	var mine := _titles(a)
	var both: Array[String] = []
	for title in _titles(b):
		if mine.has(title) and not both.has(title):
			both.append(title)
	return both


## The sprites for a shared tag (a title from shared()): its own in Tag Sprites, else the
## Icon on either girl's trait, else Sprite Frames.
func frames_for(tag: String, a: GirlData, b: GirlData) -> SpriteFrames:
	for key in tag_sprites:
		if key.strip_edges().to_lower() == tag and tag_sprites[key]:
			return tag_sprites[key]
	for girl in [a, b]:
		for item: GirlTrait in girl.traits if girl else []:
			if item and item.icon and item.title.strip_edges().to_lower() == tag:
				var frames := SpriteFrames.new()
				frames.add_frame(&"default", item.icon)
				return frames
	return sprite_frames


func _titles(girl: GirlData) -> Array[String]:
	var titles: Array[String] = []
	if not girl:
		return titles
	var kinds := counted_kinds.map(func(kind: String) -> String: return kind.strip_edges().to_lower())
	for item in girl.traits:
		if item and kinds.has(item.kind.strip_edges().to_lower()) and not item.title.strip_edges().is_empty():
			titles.append(item.title.strip_edges().to_lower())
	return titles
