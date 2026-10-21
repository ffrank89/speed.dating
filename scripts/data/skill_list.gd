class_name SkillList
extends Resource
## The player's skills: which ones the game has and in what order (data/skills.tres).
## Each skill is its own file in data/skills/. Turn one off with its Enabled; turn them
## all off with Skills On. Full guide: docs/guides/skills.md

const PATH := "res://data/skills.tres"

static var _default: SkillList

## Off = no skills anywhere in the game (each skill's own Enabled is kept for later).
@export var skills_on: bool = true
## Every skill, in the order they're listed (Profile, the intro). Drag skill files from
## data/skills/ here; drag them up or down to reorder.
@export var skills: Array[PlayerSkill] = []


## The game's skill list (data/skills.tres).
static func get_default() -> SkillList:
	if not _default:
		_default = load(PATH) if ResourceLoader.exists(PATH) else SkillList.new()
	return _default


## The skills that are on now, in order (none when Skills On is off).
func active() -> Array[PlayerSkill]:
	var list: Array[PlayerSkill] = []
	if skills_on:
		for skill in skills:
			if skill and skill.enabled:
				list.append(skill)
	return list


## The skill with this id ("speech", "Speech"), on or off. Null = there isn't one.
func find(skill_id: String) -> PlayerSkill:
	var wanted := skill_id.strip_edges().to_lower()
	for skill in skills:
		if skill and String(skill.id).to_lower() == wanted:
			return skill
	return null


## True if this skill is in the game now (Skills On, and its own Enabled).
func is_active(skill: PlayerSkill) -> bool:
	return skills_on and skill != null and skill.enabled
