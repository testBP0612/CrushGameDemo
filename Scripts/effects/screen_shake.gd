class_name ScreenShake
extends RefCounted


static func play(target: Node2D, duration: float, strength: float) -> void:
	if target == null or not is_instance_valid(target):
		push_warning("ScreenShake skipped: invalid target.")
		return
	if duration <= 0.0:
		push_error("ScreenShake missing positive duration.")
		return

	var original_position := target.position
	var tween := target.create_tween()
	tween.tween_property(target, "position", original_position + Vector2(strength, 0.0), duration * 0.25)
	tween.tween_property(target, "position", original_position + Vector2(-strength, 0.0), duration * 0.25)
	tween.tween_property(target, "position", original_position + Vector2(strength * 0.5, 0.0), duration * 0.25)
	tween.tween_property(target, "position", original_position, duration * 0.25)

