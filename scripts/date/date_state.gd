class_name DateState
extends RefCounted
## What dialogue files can check while a date is running, e.g.
##   if hit
##       Split Ends: HOW did you know?!
##   else
##       Split Ends: ...no.

## Whether the last option the player picked landed.
var hit := true
## Opposite of hit, for lines that read better as "if missed".
var missed: bool:
	get:
		return not hit
## Points the last option earned (negative on a miss).
var last_points := 0.0
## The date's running score.
var score := 0.0
