extends Control

signal compatibility_updated(value: float)  # Signal for updating compatibility UI

var compatibility_score: float = 0.0

func update_compatibility(value: float):
	compatibility_score = value
	emit_signal("compatibility_updated", value)  # Emit the signal
