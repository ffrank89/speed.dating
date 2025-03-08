extends Node

var player: Character

func set_player(new_player: Character):
	player = new_player
	
func get_player() -> Character:
	return player
