class_name DateOption
extends RefCounted
## One choice the player can pick, read from a dialogue response's tags:
##   - Guess "The Unsinkable II". [#check=culture:4, #value=2]
## A check names a stat that's on by its id (data/stats/: culture, heart, strength,
## luck...) and a number on the stats' scale, 1-9 (data/stats.tres). No #check = no roll.
## No #value = worth 0.

var response: DialogueResponse
var text: String
## The stat it checks (a file in data/stats/), or null when it has no check.
var stat: PlayerStat
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
		option.requirement = int(parts[1]) if parts.size() > 1 else 0
		var list := StatList.get_default()
		var found := list.find(parts[0])
		if list.is_active(found):
			option.stat = found
		elif found:
			push_warning("Option \"%s\": [#check=%s] checks %s, which is off (data/stats/), so it has no roll." % [r.text, check, found.display_name])
		else:
			push_warning("Option \"%s\": no stat called \"%s\" in [#check=%s]. Use a stat's id from data/stats/ (e.g. culture, strength)." % [r.text, parts[0], check])
		if option.has_check() and option.requirement > list.highest:
			push_warning("Option \"%s\": [#check=%s] needs more than the highest a stat goes (%d), so it can never be met. Stats are %d-%d." % [r.text, check, list.highest, list.lowest, list.highest])
	return option


func has_check() -> bool:
	return stat != null


## What it checks, by name ("Culture", "Strength"). Empty = no check.
func check_name() -> String:
	return stat.display_name if stat else ""


## What it checks, as the key in the date's stats (the stat's id).
func check_key() -> StringName:
	return stat.id if stat else &""


## The little picture for what it checks (the stat's Icon), or null.
func check_icon() -> Texture2D:
	return stat.icon if stat else null
