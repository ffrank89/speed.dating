class_name DialogueOption
extends Resource

@export var hint_text: String
@export var next_dialogue_id: String
@export var skill_type: String = ""  # "Culture", "Intellect", etc.
@export var req: int = 0  # Required skill level
@export var skill_check: Dictionary  # For backward compatibility
@export var responses: Dictionary = {
	"great": "",
	"good": ""
}
@export var selected_response: String = ""

# Combined effects
@export var success_effect: Dictionary = {
	"compatibility": 0.0,  # Score impact
	"Skill": "",          # Skill to improve
	"Effect": 0           # Amount to improve
}

@export var failure_effect: Dictionary = {}

# Availability flag (set during runtime)
var is_available: bool = true
var locked_reason: String = ""
