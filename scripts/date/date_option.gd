class_name DateOption
extends RefCounted
## One choice the player can pick, read from a dialogue response's tags:
##   - Guess "The Unsinkable II". [#check=culture:4, #value=2]
## The check's number is on the attributes' scale, 1-9 (data/attribute_rules.tres).
## No #check = no roll. No #value = worth 0.

var response: DialogueResponse
var text: String
## Attr.Id, or -1 when the option has no check.
var attribute: int = -1
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
			push_warning("Option \"%s\": unknown attribute in [#check=%s]. Use culture, intellect, seduction or heart." % [r.text, check])
		elif option.requirement > Attr.rules().highest:
			push_warning("Option \"%s\": [#check=%s] needs more than the highest attribute (%d), so it can never be met. Attributes are %d-%d." % [r.text, check, Attr.rules().highest, Attr.rules().lowest, Attr.rules().highest])
	return option


func has_check() -> bool:
	return attribute != -1
