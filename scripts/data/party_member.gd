class_name PartyMember
extends Resource
## A girl in your party for this run: she gave you her number, so she's a contact in
## your phone (the Contacts app). Made by PlayerManager.add_party_member() when a date
## goes well.

## Her girl file: her name, card, traits and look.
var girl: GirlData
## 0-3 hearts. Her contact shows what these hearts unlocked on her card
## (data/date_rules.tres → Result).
var affection: int = 0
## Her dating-app profile (the old DateCharacter), so the dating app knows she's taken.
var profile: DateCharacter


func _init(her_girl: GirlData = null, her_affection: int = 0, her_profile: DateCharacter = null) -> void:
	girl = her_girl
	affection = her_affection
	profile = her_profile


## Her name, as saved in your phone.
func display_name() -> String:
	return girl.display_name if girl else (String(profile.name) if profile else "")
