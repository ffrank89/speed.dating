extends Node
## PlayerManager (autoload): this run's state. The player and their attributes, the
## run's calendar, the girl picked in the dating app, your party (the girls saved in your
## contacts) and the girls who are gone for the run.

## A girl joined your party (her contact was saved), or her hearts changed.
signal party_changed

const CALENDAR := "res://scenes/Calendar/calendar.tscn"
const CALENDAR_RULES := "res://data/calendar_rules.tres"

var player: PlayerCharacter
## The girl picked in the dating app: the next date is with her.
var current_girl: GirlData

## Your party: the girls who gave you their number, saved as contacts in your phone
## (the Contacts app, scenes/Phone/Contacts/). One PartyMember each.
var party: Array[PartyMember] = []
## Girls whose first date failed: they're gone for the rest of the run.
var gone_for_run: Array[GirlData] = []

## The run's calendar: chapter, today, and what each day offers. Use get_calendar().
var calendar: RunCalendar


# She gave you her number: she's saved in your contacts with the hearts she gave you.
# Already there = her hearts go up if this date went better.
func add_party_member(girl: GirlData, affection: int) -> PartyMember:
	for member in party:
		if member.girl == girl:
			member.affection = maxi(member.affection, affection)
			party_changed.emit()
			return member
	var member := PartyMember.new(girl, affection)
	party.append(member)
	party_changed.emit()
	return member


func get_party() -> Array[PartyMember]:
	return party


# True if she's in your party (saved in your contacts).
func is_in_party(girl: GirlData) -> bool:
	return party.any(func(member: PartyMember) -> bool: return member.girl == girl)


# A failed first date: she's gone for the rest of the run (the dating app skips her).
func mark_gone(girl: GirlData) -> void:
	if girl and not girl in gone_for_run:
		gone_for_run.append(girl)


func is_gone(girl: GirlData) -> bool:
	return girl in gone_for_run


# The dating app picked her: the next date is with her.
func select_girl(girl: GirlData) -> void:
	current_girl = girl


# The player, made with every attribute at the Default Value (data/attribute_rules.tres)
# if there isn't one yet (e.g. when a screen is played on its own with F6, without the
# intro).
func ensure_player() -> PlayerCharacter:
	if not player:
		player = PlayerCharacter.new("Me!")
		for skill in player.skills:
			player.skills[skill] = Attr.rules().default_value
	return player


# The run's calendar, planned the first time it's needed from `rules` (empty =
# data/calendar_rules.tres). After that the run keeps the same one.
func get_calendar(rules: CalendarRules = null) -> RunCalendar:
	if not calendar:
		calendar = RunCalendar.new(rules if rules else load(CALENDAR_RULES))
	return calendar
