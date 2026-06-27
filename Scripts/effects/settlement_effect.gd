class_name SettlementEffect
extends RefCounted


static func play(panel: Control, result: String, duration: float) -> void:
	if panel == null or not is_instance_valid(panel):
		push_warning("SettlementEffect skipped: invalid panel.")
		return
	if duration <= 0.0:
		push_error("SettlementEffect missing positive duration.")
		return

	panel.pivot_offset = panel.size * 0.5
	panel.modulate = _start_color(result)
	panel.scale = Vector2(0.92, 0.92)

	var tween := panel.create_tween()
	tween.tween_property(panel, "scale", Vector2(1.04, 1.04), duration * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(panel, "modulate", Color.WHITE, duration * 0.65)
	tween.tween_property(panel, "scale", Vector2.ONE, duration * 0.55)


static func _start_color(result: String) -> Color:
	match result:
		"cash_out", "clear":
			return Color(1.0, 0.9, 0.45, 1.0)
		"defeat":
			return Color(1.0, 0.35, 0.35, 1.0)
		_:
			return Color.WHITE

