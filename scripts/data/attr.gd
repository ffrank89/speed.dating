class_name Attr
extends RefCounted
## The player's four attributes. Use Attr.Id instead of strings like "Culture".

enum Id { CULTURE, INTELLECT, SEDUCTION, HEART }

const NAMES := {
	Id.CULTURE: "Culture",
	Id.INTELLECT: "Intellect",
	Id.SEDUCTION: "Seduction",
	Id.HEART: "Heart",
}


static func display_name(attr: Id) -> String:
	return NAMES[attr]


## Parses an attribute name as written in dialogue tags ("culture", "Culture").
## Returns -1 if the name isn't an attribute.
static func from_string(text: String) -> int:
	for attr in NAMES:
		if NAMES[attr].to_lower() == text.strip_edges().to_lower():
			return attr
	return -1
