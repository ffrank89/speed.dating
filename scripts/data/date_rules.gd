class_name DateRules
extends Resource
## The numbers that decide how dates run and score. One file: data/date_rules.tres.
## Change them to make dates longer, shorter, easier, harder, swingier or safer.
## Full guides: docs/guides/the-full-date.md (Flow), docs/guides/options-and-scoring.md

@export_group("Flow")
## Exchanges per date, between the opener and the closer.
@export_range(1, 20) var exchanges: int = 5
## How many of those are microgame exchanges (their titles start with Microgame Prefix).
@export_range(0, 20) var microgame_exchanges: int = 2
## The title names in her first-date dialogue file.
@export var opener_title: String = "opener"
## Regular exchanges: ~ exchange_boat, ~ exchange_band...
@export var exchange_prefix: String = "exchange_"
## Exchanges with a microgame option: ~ microgame_light_it...
@export var microgame_prefix: String = "microgame_"
## The closer when the date failed (below her Number Threshold).
@export var closer_failed_title: String = "closer_failed"
## The closer when she gives her number but you earned no hearts.
@export var closer_no_hearts_title: String = "closer_no_hearts"
## The closer at 1 heart or more.
@export var closer_hearts_title: String = "closer_hearts"

@export_group("Odds")
## Lowest chance a risky option can show, in percent. Even a hopeless option gets this.
@export_range(0, 100) var min_chance: int = 5
## Highest chance an option below its requirement can show, in percent.
## (At or above the requirement there's no roll: it always lands.)
@export_range(0, 100) var max_chance: int = 95

@export_group("Microgames")
## How hard an option's microgame is (0 = easiest, 1 = hardest) when the player meets
## its requirement. Below the requirement it gets harder, up to Max Difficulty.
@export_range(0.0, 1.0, 0.05) var min_difficulty: float = 0.2
## How hard it is when the player has none of the attribute.
@export_range(0.0, 1.0, 0.05) var max_difficulty: float = 1.0
## How hard it is for an option with a microgame but no #check.
@export_range(0.0, 1.0, 0.05) var unchecked_difficulty: float = 0.5

@export_group("Result")
## On her end-of-date contact card: which kinds of trait show, and how many hearts each
## needs. Hearts (0-3) come from the score and her Affection Thresholds (her girl file);
## a date below her Number Threshold failed and shows nothing.
## Below a kind's hearts its field says "you dont know me like that!".
## Kinds not listed (e.g. ability, for now) don't show at all.
@export var trait_hearts: Dictionary[String, int] = {"type": 0, "tag": 1}
## She types a heart emoji next to her name at this many hearts or more. 4 = never.
@export_range(0, 4) var heart_emoji_at_hearts: int = 3

@export_group("Points")
## How much her likes boost an option's points. An option is worth
## value × (1 + her like for that attribute × Likes Weight).
## 0 = her likes don't matter. 1 = an attribute she likes at 1.0 doubles the points.
@export_range(0.0, 3.0, 0.05) var likes_weight: float = 1.0
## How much a missed risky option costs, as a share of what it would have earned.
## 0.5 = a +3 option that misses costs half as much (-1.5). 1.0 = it costs the full 3.
@export_range(0.0, 2.0, 0.05) var miss_penalty: float = 0.5
## A missed option always costs at least this many points.
@export_range(0.0, 5.0, 0.5) var min_miss_cost: float = 1.0
