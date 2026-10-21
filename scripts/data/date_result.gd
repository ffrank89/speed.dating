class_name DateResult
extends RefCounted
## What a finished date hands back to the run.

var girl: GirlData
var score: float = 0.0
## 0-3 hearts.
var affection: int = 0
## She gave you her number, so she's in your party. False = the date failed and she's
## gone for the run.
var got_number: bool = false
## Stat id -> how much it went up on this date (not used yet).
var stat_gains: Dictionary = {}
## Perks earned on this date (PerkData once perks are rebuilt).
var perks_earned: Array = []
