class_name GirlData
extends Resource
## Everything about a girl that's the same in every run.
## One .tres per girl (data/girls/), edited in the Inspector, so a new girl needs no code.
## Per-run state (Affection, HP) will live in PartyMember, not here.

@export_group("Identity")
@export var id: StringName
@export var display_name: String
@export var age: int = 0
@export_multiline var bio: String
@export var interests: Array[String] = []

@export_group("Art")
## Pose name -> full-art image. Her dialogue picks one with [#pose=name].
@export var poses: Dictionary[String, Texture2D] = {}
## Shown when a line names no pose, or a pose she doesn't have.
@export var default_pose: String
@export var date_background: Texture2D

@export_group("Dating")
@export var voice: GirlVoice
@export var first_date_dialogue: DialogueResource
@export var microgames: Array[PackedScene] = []
## Date score needed for 1, 2 and 3 hearts. Placeholder until scoring is tuned.
@export var affection_thresholds: Array[int] = [3, 6, 9]

@export_subgroup("Likes")
## How much she cares about each attribute (0-1). Weights date scoring and synergy.
@export_range(0.0, 1.0, 0.05) var likes_culture: float = 0.25
@export_range(0.0, 1.0, 0.05) var likes_intellect: float = 0.25
@export_range(0.0, 1.0, 0.05) var likes_seduction: float = 0.25
@export_range(0.0, 1.0, 0.05) var likes_heart: float = 0.25


func get_pose(pose_name: String) -> Texture2D:
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
