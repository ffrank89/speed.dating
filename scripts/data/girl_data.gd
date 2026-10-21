class_name GirlData
extends Resource
## Everything about a girl that's the same in every run.
## One .tres per girl (data/girls/), edited in the Inspector, so a new girl needs no code.
## Hover any setting in the Inspector to see what it does.
## Per-run state (Affection, HP) will live in PartyMember, not here.

@export_group("Identity")
## Short internal name with no spaces, e.g. split_ends. Never shown to players.
@export var id: StringName
## Her name as players see it, on her profile and her name plate.
## Dialogue lines must use exactly this name, e.g. "Split Ends: Hi!".
@export var display_name: String
## Shown after her name on her dating profile ("Split Ends, 24").
@export var age: int = 0
## Her dating-profile bio.
@export_multiline var bio: String
## Shown on her dating profile.
@export var interests: Array[String] = []
## Her picture on her dating profile: an animated sprite. Click it to edit its frames in
## the SpriteFrames panel at the bottom of Godot.
@export var profile_picture: SpriteFrames

@export_group("Contact Card")
## What she types as her phone number when she gives it to you at the end of a date.
@export var phone_number: String
## What she types as her address. Press Enter in the box for a second line.
@export_multiline var address: String
## Optional: the round photo on her contact card. Empty = her initials in a circle.
@export var contact_photo: Texture2D
## Her type, tags, abilities... listed on her contact card under her name.
## Each is a kind ("type", "tag", "ability"), a title, an optional description and icon.
@export var traits: Array[GirlTrait] = []

@export_group("Art")
## Her full-art poses. Each entry is a name and a pose (picture, size, nudge, flip).
## A dialogue line switches pose with a tag, e.g. "Split Ends: [#pose=cig] Got a light?"
@export var poses: Dictionary[String, GirlPose] = {}
## The pose shown when a line names no pose, or a pose she doesn't have.
@export var default_pose: String
## The picture behind her on dates.
@export var date_background: Texture2D

@export_group("Dialogue")
## How her dialogue box looks: colours, outline, font, name plate.
## Drag a file from data/dialogue_styles/ here. Empty = the default style.
@export var dialogue_style: DialogueBoxStyle
## Optional: how the player's choice bubbles look on her dates.
## Drag a file from data/option_styles/ here. Empty = the shared default.
@export var option_style: OptionListStyle
## How she sounds while her text types out: pitch, speed, which letter sounds.
@export var voice: GirlVoice
## Her first-date script (a .dialogue file).
@export var first_date_dialogue: DialogueResource

@export_group("Dating")
## Microgame scenes that can happen on her dates.
@export var microgames: Array[PackedScene] = []
## Date score she needs to give you her number at all. Below it the date failed: she
## types "not a chance!" on the contact card and that's it.
@export var number_threshold: int = 0
## Date score needed for 1, 2 and 3 hearts. Placeholder until scoring is tuned.
@export var affection_thresholds: Array[int] = [3, 6, 9]

@export_subgroup("Likes")
## How much she cares about each attribute (0-1). Weights date scoring and synergy.
@export_range(0.0, 1.0, 0.05) var likes_culture: float = 0.25
@export_range(0.0, 1.0, 0.05) var likes_intellect: float = 0.25
@export_range(0.0, 1.0, 0.05) var likes_seduction: float = 0.25
@export_range(0.0, 1.0, 0.05) var likes_heart: float = 0.25


## The named pose, or her default pose if she doesn't have one by that name.
func get_pose(pose_name: String) -> GirlPose:
	if poses.has(pose_name):
		return poses[pose_name]
	return poses.get(default_pose)


func likes(attr: Attr.Id) -> float:
	match attr:
		Attr.Id.CULTURE:
			return likes_culture
		Attr.Id.INTELLECT:
			return likes_intellect
		Attr.Id.SEDUCTION:
			return likes_seduction
		Attr.Id.HEART:
			return likes_heart
	return 0.0
