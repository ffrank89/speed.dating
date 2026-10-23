class_name PlayerCharacter
extends RefCounted
## The player: their name and their stats (data/stats.tres: Culture, Heart, Strength,
## Luck...), each on the list's scale (1-9). Made by the intro (or
## PlayerManager.ensure_player()).

signal stats_changed

var name: String
## Stat id (&"culture") → value. Every stat in data/stats.tres, on or off, so turning one
## on mid-run just works.
var stats: Dictionary


func _init(char_name: String) -> void:
	name = char_name
	stats = {}
	for stat in StatList.get_default().stats:
		if stat:
			stats[stat.id] = StatList.get_default().starting_value_of(stat)


## A stat's value. One the player hasn't got yet is at its Starting Value.
func get_stat(stat: PlayerStat) -> int:
	return stats.get(stat.id, StatList.get_default().starting_value_of(stat))


# Training raises it (or lowers it), never past the list's Lowest or Highest.
func raise_stat(stat: PlayerStat, amount: int) -> void:
	stats[stat.id] = StatList.get_default().clamp_value(get_stat(stat) + amount)
	stats_changed.emit()
