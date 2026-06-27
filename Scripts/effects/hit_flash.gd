class_name HitFlash
extends RefCounted


static func play(target: CanvasItem, duration: float) -> void:
	if target == null or not is_instance_valid(target):
		push_warning("HitFlash skipped: invalid target.")
		return
	if duration <= 0.0:
		push_error("HitFlash missing positive duration.")
		return

	var original_modulate := target.modulate
	var tween := target.create_tween()
	tween.tween_property(target, "modulate", Color.WHITE, duration * 0.35)
	tween.tween_property(target, "modulate", original_modulate, duration * 0.65)

