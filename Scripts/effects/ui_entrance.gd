class_name UiEntrance
extends RefCounted

const META_BASE_POSITION := "ui_entrance_base_position"
const META_TWEEN := "ui_entrance_tween"


static func play(control: Control, fade_duration: float, slide_duration: float, slide_offset: float, delay: float = 0.0) -> void:
	if control == null or not is_instance_valid(control):
		push_warning("UiEntrance skipped: invalid control.")
		return
	if fade_duration <= 0.0:
		push_error("UiEntrance missing positive panel_fade.")
		return
	if slide_duration <= 0.0:
		push_error("UiEntrance missing positive panel_slide.")
		return

	_store_base_position(control)
	_kill_existing_tween(control)

	var base_position := control.get_meta(META_BASE_POSITION) as Vector2
	control.modulate = Color(1.0, 1.0, 1.0, 0.0)
	control.position = base_position + Vector2(0.0, slide_offset)

	var tween := control.create_tween()
	control.set_meta(META_TWEEN, tween)
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_property(control, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(control, "position", base_position, slide_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void:
		if control != null and is_instance_valid(control):
			control.position = base_position
			control.modulate = Color.WHITE
			control.remove_meta(META_TWEEN)
	)


static func play_group(controls: Array[Control], fade_duration: float, slide_duration: float, slide_offset: float, stagger: float) -> void:
	for index in range(controls.size()):
		play(controls[index], fade_duration, slide_duration, slide_offset, maxf(0.0, stagger) * float(index))


static func play_fade_group(controls: Array[Control], fade_duration: float, stagger: float) -> void:
	if fade_duration <= 0.0:
		push_error("UiEntrance missing positive panel_fade.")
		return
	for index in range(controls.size()):
		_play_fade(controls[index], fade_duration, maxf(0.0, stagger) * float(index))


static func reset(control: Control) -> void:
	if control == null or not is_instance_valid(control):
		return
	_store_base_position(control)
	_kill_existing_tween(control)
	control.position = control.get_meta(META_BASE_POSITION) as Vector2
	control.modulate = Color.WHITE


static func reset_fade(control: Control) -> void:
	if control == null or not is_instance_valid(control):
		return
	_kill_existing_tween(control)
	control.modulate = Color.WHITE


static func _store_base_position(control: Control) -> void:
	if not control.has_meta(META_BASE_POSITION):
		control.set_meta(META_BASE_POSITION, control.position)


static func _kill_existing_tween(control: Control) -> void:
	if not control.has_meta(META_TWEEN):
		return
	var existing = control.get_meta(META_TWEEN)
	if existing != null and is_instance_valid(existing):
		existing.kill()
	control.remove_meta(META_TWEEN)


static func _play_fade(control: Control, fade_duration: float, delay: float) -> void:
	if control == null or not is_instance_valid(control):
		push_warning("UiEntrance fade skipped: invalid control.")
		return
	_kill_existing_tween(control)
	control.modulate = Color(1.0, 1.0, 1.0, 0.0)

	var tween := control.create_tween()
	control.set_meta(META_TWEEN, tween)
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_property(control, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void:
		if control != null and is_instance_valid(control):
			control.modulate = Color.WHITE
			control.remove_meta(META_TWEEN)
	)
