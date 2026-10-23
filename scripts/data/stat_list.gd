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

@export_group("Starting Values")
## Where the stats start a run (and where the intro's sliders start): each stat's own
## Starting Value (in its file), or all the same: Lowest, Highest, or Starting Number.
@export_enum("Each Stat's Own", "Lowest", "Highest", "Starting Number") var start_at: int = 0
## With Start At = Starting Number: what every stat starts at (kept between Lowest and
## Highest).
@export_range(0, 100) var starting_number: int = 5


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


## Where `stat` starts a run (Start At), kept between Lowest and Highest.
func starting_value_of(stat: PlayerStat) -> int:
	match start_at:
		1:
			return lowest
		2:
			return highest
		3:
			return clamp_value(starting_number)
	return clamp_value(stat.starting_value)


## `value` kept between Lowest and Highest.
func clamp_value(value: int) -> int:
	return clampi(value, lowest, highest)
