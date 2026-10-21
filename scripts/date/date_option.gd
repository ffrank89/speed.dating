class_name DateOption
extends RefCounted
## One choice the player can pick, read from a dialogue response's tags:
##   - Guess "The Unsinkable II". [#check=culture:4, #value=2]
## A check can name an attribute (culture, intellect, seduction, heart) or a skill that's
## on (its id in data/skills/, e.g. [#check=speech:5]). Its number is on the 1-9 scale
## (data/attribute_rules.tres). No #check = no roll. No #value = worth 0.

var response: DialogueResponse
var text: String
## Attr.Id, or -1 when the option has no check (or checks a skill).
var attribute: int = -1
## The skill it checks (a file in data/skills/), or null.
var skill: PlayerSkill
var requirement: int = 0
var value: int = 0
## Microgame to play when picked (milestone M3), or "".
var microgame: String = ""


static func from_response(r: DialogueResponse) -> DateOption:
	var option := DateOption.new()
	option.response = r
	option.text = r.text
	option.value = int(r.get_tag_value("value")) if r.get_tag_value("value").is_valid_int() else 0
	option.microgame = r.get_tag_value("microgame")

	var check := r.get_tag_value("check")
	if not check.is_empty():
		var parts := check.split(":")
		option.attribute = Attr.from_string(parts[0])
		option.requirement = int(parts[1]) if parts.size() > 1 else 0
		if option.attribute == -1:
			var skills := SkillList.get_default()
			var found := skills.find(parts[0])
			if skills.is_active(found):
				option.skill = found
			elif found:
				push_warning("Option \"%s\": [#check=%s] checks %s, which is off (data/skills.tres), so it has no roll." % [r.text, check, found.display_name])
			else:
				push_warning("Option \"%s\": unknown attribute or skill in [#check=%s]. Use culture, intellect, seduction, heart, or a skill's id (data/skills/)." % [r.text, check])
		if option.has_check() and option.requirement > Attr.rules().highest:
			push_warning("Option \"%s\": [#check=%s] needs more than the highest attribute (%d), so it can never be met. Attributes are %d-%d." % [r.text, check, Attr.rules().highest, Attr.rules().lowest, Attr.rules().highest])
	return option


func has_check() -> bool:
	return attribute != -1 or skill != null


## What it checks, by name ("Culture", "Speech"). Empty = no check.
func check_name() -> String:
	if skill:
		return skill.display_name
	return Attr.display_name(attribute) if attribute != -1 else ""


## What it checks, as the key in the date's attributes: an Attr.Id or the skill's id.
func check_key() -> Variant:
	return skill.id if skill else attribute


## The little picture for what it checks: the skill's icon, or the attribute's from `style`.
func check_icon(style: OptionListStyle) -> Texture2D:
	if skill:
		return skill.icon
	return style.icon_for(attribute)
