class_name AttributeRules
extends Resource
## The scale of the player's four attributes (Culture, Intellect, Seduction, Heart).
## One file: data/attribute_rules.tres. Everything that shows or checks an attribute
## uses it: the intro's sliders, training, Profile's bars, the date test bench, and the
## option checks writers put in dialogue ([#check=culture:4]).
## Full guide: docs/guides/options-and-scoring.md

## The lowest an attribute can be.
@export_range(0, 100) var lowest: int = 1
## The highest an attribute can be (a full bar in Profile).
@export_range(1, 100) var highest: int = 9
## Every attribute when there's no player yet (a screen played on its own with F6), and
## where the date test bench's sliders start.
@export_range(0, 100) var default_value: int = 5


## `value` kept between Lowest and Highest.
func clamp_value(value: int) -> int:
	return clampi(value, lowest, highest)
