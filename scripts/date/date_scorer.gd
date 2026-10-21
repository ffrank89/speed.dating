class_name DateScorer
extends RefCounted
## The one score for a date. Works out each option's odds, rolls risky ones,
## and adds up the points. The numbers it uses live in DateRules.
##
##   points if it lands = value × (1 + her like for the attribute × likes_weight)
##   chance             = 100% at or above the requirement, else
##                        attribute ÷ requirement, clamped to min/max chance
##   points if it misses = −max(points × miss_penalty, min_miss_cost)
##   microgame difficulty = min_difficulty at or above the requirement, rising to
##                          max_difficulty at the lowest attribute (1)
## Attributes and requirements are on the 1-9 scale (data/attribute_rules.tres).

## What happened when an option was picked.
class Result:
	var option: DateOption
	## True when the option needed a roll (player was below the requirement).
	var rolled := false
	## 0-100. The chance it had of landing.
	var chance := 100
	## 1-100. What was rolled; the option lands if roll <= chance.
	var roll := 0
	var hit := true
	## True when a microgame decided it instead of a roll (then hit = passed).
	var played := false
	var points := 0.0

var rules: DateRules
var girl: GirlData
## The player's stats: Attr.Id -> attribute value, skill id -> skill value (1-9).
var attributes: Dictionary = {}
var score := 0.0
var rng := RandomNumberGenerator.new()


func _init(p_rules: DateRules, p_girl: GirlData, p_attributes: Dictionary) -> void:
	rules = p_rules
	girl = p_girl
	attributes = p_attributes
	rng.randomize()


## 0-100: the chance this option lands, as shown on its button.
func chance_of(option: DateOption) -> int:
	if not option.has_check() or option.requirement <= 0:
		return 100
	var have: int = attributes.get(option.check_key(), 0)
	if have >= option.requirement:
		return 100
	var percent := int(floor(100.0 * have / option.requirement))
	return clampi(percent, rules.min_chance, rules.max_chance)


## What the option earns if it lands, after her likes.
func points_if_hit(option: DateOption) -> float:
	# She has likes for the four attributes; skills don't have any (yet).
	var like := girl.likes(option.attribute) if option.attribute != -1 else 0.0
	return option.value * (1.0 + like * rules.likes_weight)


## 0-1: how hard this option's microgame should be. 0 = easiest, 1 = hardest.
func difficulty_of(option: DateOption) -> float:
	if not option.has_check() or option.requirement <= 0:
		return rules.unchecked_difficulty
	var have: int = attributes.get(option.check_key(), 0)
	# How far below the requirement, from 0 (meets it) to 1 (the lowest attribute).
	var lowest := Attr.rules().lowest
	var gap := float(option.requirement - lowest)
	var short_by := clampf((option.requirement - have) / gap, 0.0, 1.0) if gap > 0.0 else 0.0
	return lerpf(rules.min_difficulty, rules.max_difficulty, short_by)


## Picks the option: rolls if needed, adds the points to the score, and says what happened.
func resolve(option: DateOption) -> Result:
	var result := Result.new()
	result.option = option
	result.chance = chance_of(option)
	result.rolled = result.chance < 100
	if result.rolled:
		result.roll = rng.randi_range(1, 100)
		result.hit = result.roll <= result.chance
	_add_points(result)
	return result


## Picks an option whose microgame was played: passing is a hit, failing a miss.
func resolve_microgame(option: DateOption, passed: bool) -> Result:
	var result := Result.new()
	result.option = option
	result.chance = chance_of(option)
	result.played = true
	result.hit = passed
	_add_points(result)
	return result


## True if the score reached her Number Threshold (she gives you her number).
func gives_number() -> bool:
	return score >= girl.number_threshold


## 0-3 hearts: how many of her Affection Thresholds the score has reached.
func hearts() -> int:
	var count := 0
	for threshold in girl.affection_thresholds:
		if score >= threshold:
			count += 1
	return count


## Adds points from outside the options (e.g. shooing a stage hazard away). Returns them.
func add_bonus(points: float) -> float:
	score += points
	return points


func _add_points(result: Result) -> void:
	var earned := points_if_hit(result.option)
	result.points = earned if result.hit else -maxf(absf(earned) * rules.miss_penalty, rules.min_miss_cost)
	score += result.points
