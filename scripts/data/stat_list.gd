class_name StatList
extends Resource
## The player's stats: which ones the game has, in what order, and their scale
## (data/stats.tres). Each stat is its own file in data/stats/; turn one off with its
## Enabled. Everything that shows or checks a stat uses this list: the intro, Profile,
## training, dialogue checks, her Likes, the date test bench.
## Full guide: docs/guides/stats.md

const PATH := "res://data/stats.tres"

static var _default: StatList

## The lowest a stat can be.
@export_range(0, 100) var lowest: int = 1
## The highest a stat can be (a full bar in Profile).
@export_range(1, 100) var highest: int = 9
## Every stat, in the order they're listed. Drag stat files from data/stats/ here; drag
## them up or down to reorder.
@export var stats: Array[PlayerStat] = []


## The game's stats (data/stats.tres).
static func get_default() -> StatList:
	if not _default:
		_default = load(PATH) if ResourceLoader.exists(PATH) else StatList.new()
	return _default


## The stats that are on now, in order.
func active() -> Array[PlayerStat]:
	var list: Array[PlayerStat] = []
	for stat in stats:
		if stat and stat.enabled:
			list.append(stat)
	return list


## The stat with this id ("strength", "Strength"), on or off. Null = there isn't one.
func find(stat_id: String) -> PlayerStat:
	var wanted := stat_id.strip_edges().to_lower()
	for stat in stats:
		if stat and String(stat.id).to_lower() == wanted:
			return stat
	return null


## True if this stat is in the game now (in the list, and Enabled).
func is_active(stat: PlayerStat) -> bool:
	return stat != null and stat.enabled and stat in stats


## `value` kept between Lowest and Highest.
func clamp_value(value: int) -> int:
	return clampi(value, lowest, highest)
