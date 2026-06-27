class_name ButtonFeedback
extends RefCounted


static func install(button: Button, duration: float, audio_service = null) -> void:
	if button == null or not is_instance_valid(button):
		push_warning("ButtonFeedback skipped: invalid button.")
		return
	if duration <= 0.0:
		push_error("ButtonFeedback missing positive duration.")
		return
	if button.has_meta("button_feedback_installed"):
		return

	button.set_meta("button_feedback_installed", true)
	button.pressed.connect(func() -> void:
		play(button, duration)
		if audio_service != null and audio_service.has_method("play_sfx"):
			audio_service.play_sfx("button_click")
	)


static func play(button: Button, duration: float) -> void:
	if button == null or not is_instance_valid(button):
		push_warning("ButtonFeedback play skipped: invalid button.")
		return
	if duration <= 0.0:
		push_error("ButtonFeedback play missing positive duration.")
		return

	var base_scale := button.scale
	button.pivot_offset = button.size * 0.5
	var tween := button.create_tween()
	tween.tween_property(button, "scale", base_scale * 0.94, duration * 0.45)
	tween.tween_property(button, "scale", base_scale, duration * 0.55)

