class_name MicrogameLibrary
extends Resource
## Every microgame, by the name writers use in dialogue: [#microgame=light_cigarette].
## One file: data/microgames.tres.
##
## To add one: click data/microgames.tres → Games → Add Key/Value Pair → type its name
## on the left (lowercase, no spaces) → drag its .tscn onto the right.
## Full guide: docs/guides/making-a-microgame.md

## Name → microgame scene.
@export var games: Dictionary[String, PackedScene] = {}


func has_game(game_name: String) -> bool:
	return games.get(game_name) != null
