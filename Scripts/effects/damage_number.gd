class_name DamageNumber
extends Label


func play(value: int, delay: float, origin: Vector2) -> void:
	position = origin
	text = str(value)
	modulate = Color(1.0, 0.95, 0.35, 1.0)

	var config: Dictionary = Data.battle_sequence_config().get("damage_number", {})
	var rise_distance := float(config.get("rise_distance", 0.0))
	var rise_duration := float(config.get("rise_duration", 0.0))
	var fade_duration := float(config.get("fade_duration", 0.0))

	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(self, "position:y", origin.y - rise_distance, rise_duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(queue_free)
