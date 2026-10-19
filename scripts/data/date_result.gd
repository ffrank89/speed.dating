class_name DateResult
extends RefCounted
## What a finished date hands back to the run.

var girl: GirlData
var score: float = 0.0
## 0-3 hearts. 0 on a first date means she's gone for the run.
var affection: int = 0
## Attr.Id -> points gained on this date.
var attribute_gains: Dictionary = {}
## Perks earned on this date (PerkData once perks are rebuilt).
var perks_earned: Array = []
