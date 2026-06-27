class_name PayoutCountUp
extends RefCounted


static func play(label: Label, from_value: int, to_value: int, duration: float, formatter: Callable = Callable()) -> void:
	if label == null or not is_instance_valid(label):
		push_warning("PayoutCountUp skipped: invalid label.")
		return
	if duration <= 0.0:
		push_error("PayoutCountUp missing positive duration.")
		return

	var holder := Node.new()
	holder.set_meta("value", from_value)
	label.add_child(holder)

	var update_text := func(value: float) -> void:
		if label != null and is_instance_valid(label):
			var rounded_value := int(round(value))
			label.text = str(rounded_value) if formatter.is_null() else str(formatter.call(rounded_value))

	var tween := label.create_tween()
	tween.tween_method(update_text, float(from_value), float(to_value), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "scale", Vector2(1.08, 1.08), duration * 0.45)
	tween.tween_property(label, "scale", Vector2.ONE, duration * 0.55)
	tween.tween_callback(func() -> void:
		if holder != null and is_instance_valid(holder):
			holder.queue_free()
	)
