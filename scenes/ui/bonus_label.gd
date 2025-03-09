extends RichTextLabel

signal bonus_updated(bonuses: Dictionary)
		
func _ready():
	custom_minimum_size = Vector2(200, 100)
	position = Vector2(20, 60)  # Below compatibility meter
	animate_idle()

func update_bonuses(bonuses: Dictionary):
	if not bonuses.is_empty():
		animate_success()
		var bonus_text = "BONUSES: "
		for bonus_name in bonuses:
			bonus_text += "%s +%.1f\n" % [bonus_name, bonuses[bonus_name] * 100]
		text = bonus_text
		emit_signal("bonus_updated", bonuses)
	else:
		animate_failure()
		emit_signal("bonus_updated", bonuses)
		text = "OUTFIT CHECK FAILED"

func clear_bonuses():
	var clear_tween = create_tween()
	# Shake and fade out current text
	clear_tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5)
	clear_tween.parallel().tween_property(self, "position", position + Vector2(5,0), 0.1)
	clear_tween.tween_property(self, "position", position - Vector2(5,0), 0.1)
	clear_tween.tween_property(self, "position", position, 0.1)
	# Reset text and fade back in
	clear_tween.tween_callback(func(): text = "")
	clear_tween.tween_property(self, "modulate", Color(1,1,1,1), 0.5)


func animate_idle():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", position.y + 5, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y - 5, 1.0).set_trans(Tween.TRANS_SINE)

func animate_success():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.GREEN, 0.2)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
	tween.tween_callback(animate_idle)

func animate_failure():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.2)
	tween.tween_property(self, "rotation_degrees", -5, 0.1)
	tween.tween_property(self, "rotation_degrees", 5, 0.1)
	tween.tween_property(self, "rotation_degrees", 0, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	tween.tween_callback(animate_idle)
