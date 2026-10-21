class_name Attr
extends RefCounted
## The player's four attributes. Use Attr.Id instead of strings like "Culture".
## Their scale (1-9) is data/attribute_rules.tres: Attr.rules().

enum Id { CULTURE, INTELLECT, SEDUCTION, HEART }

const NAMES := {
	Id.CULTURE: "Culture",
	Id.INTELLECT: "Intellect",
	Id.SEDUCTION: "Seduction",
	Id.HEART: "Heart",
}
const RULES_PATH := "res://data/attribute_rules.tres"

static var _rules: AttributeRules


static func display_name(attr: Id) -> String:
	return NAMES[attr]


## The attributes' scale: Lowest, Highest, Default Value (data/attribute_rules.tres).
static func rules() -> AttributeRules:
	if not _rules:
		_rules = load(RULES_PATH) if ResourceLoader.exists(RULES_PATH) else AttributeRules.new()
	return _rules


## Parses an attribute name as written in dialogue tags ("culture", "Culture").
## Returns -1 if the name isn't an attribute.
static func from_string(text: String) -> int:
	for attr in NAMES:
		if NAMES[attr].to_lower() == text.strip_edges().to_lower():
			return attr
	return -1
