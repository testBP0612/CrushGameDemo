class_name HitFlash
extends RefCounted

const FLASH_COLOR := Color(1.85, 1.85, 1.85, 1.0)


static func play(target: CanvasItem, duration: float) -> void:
	if target == null or not is_instance_valid(target):
		push_warning("HitFlash skipped: invalid target.")
		return
	if duration <= 0.0:
		push_error("HitFlash missing positive duration.")
		return

	var original_modulate := target.modulate
	var tween := target.create_tween()
	# 過曝白（>1.0）才看得到閃光——sprite 平常 modulate 就是純白，補到 WHITE 等於沒閃
	tween.tween_property(target, "modulate", FLASH_COLOR, duration * 0.35)
	tween.tween_property(target, "modulate", original_modulate, duration * 0.65)

