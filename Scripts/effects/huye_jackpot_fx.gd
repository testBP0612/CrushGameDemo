class_name HuyeJackpotFx
extends Node2D

var _fx_config: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func setup(huye_config: Dictionary) -> bool:
	_fx_config = huye_config.get("jackpot_fx", {})
	if _fx_config.is_empty() or not bool(_fx_config.get("enabled", false)):
		return false
	z_index = int(_fx_config.get("z_index", 0))
	_rng.randomize()
	return true


func play_anticipation(center: Vector2) -> void:
	var config: Dictionary = _fx_config.get("anticipation", {})
	var count := maxi(int(config.get("count", 0)), 0)
	var duration := maxf(float(config.get("duration", 0.0)), 0.0)
	if count <= 0 or duration <= 0.0:
		return
	for index in range(count):
		var start := center + Vector2(
			_rng.randf_range(-float(config.get("radius_x", 0.0)), float(config.get("radius_x", 0.0))),
			_rng.randf_range(-float(config.get("radius_y", 0.0)), float(config.get("radius_y", 0.0)))
		)
		var end := start + Vector2(
			_rng.randf_range(-float(config.get("drift_x", 0.0)), float(config.get("drift_x", 0.0))),
			-float(config.get("rise_distance", 0.0))
		)
		_spawn_linear_fleck(
			start,
			end,
			duration,
			float(config.get("stagger", 0.0)) * float(index),
			_random_size(config),
			_random_color(_fx_config.get("gold_colors", [])),
			_rng.randf_range(-float(config.get("rotation_turns", 0.0)), float(config.get("rotation_turns", 0.0)))
		)


func play_descent_trail(from: Vector2, to: Vector2) -> void:
	var config: Dictionary = _fx_config.get("descent_trail", {})
	var count := maxi(int(config.get("count", 0)), 0)
	var duration := maxf(float(config.get("duration", 0.0)), 0.0)
	if count <= 0 or duration <= 0.0:
		return
	for index in range(count):
		var progress := float(index) / maxf(float(count - 1), 1.0)
		var start := from.lerp(to, progress) + Vector2(
			_rng.randf_range(-float(config.get("spread_x", 0.0)), float(config.get("spread_x", 0.0))),
			_rng.randf_range(-float(config.get("spread_y", 0.0)), float(config.get("spread_y", 0.0)))
		)
		var end := start + Vector2(
			_rng.randf_range(-float(config.get("drift_x", 0.0)), float(config.get("drift_x", 0.0))),
			float(config.get("fall_distance", 0.0))
		)
		_spawn_linear_fleck(
			start,
			end,
			duration,
			float(config.get("stagger", 0.0)) * float(index),
			_random_size(config),
			_random_color(_fx_config.get("gold_colors", [])),
			_rng.randf_range(-float(config.get("rotation_turns", 0.0)), float(config.get("rotation_turns", 0.0)))
		)


func play_divine_reveal(center: Vector2) -> void:
	var config: Dictionary = _fx_config.get("divine_reveal", {})
	var count := maxi(int(config.get("count", 0)), 0)
	var duration := maxf(float(config.get("duration", 0.0)), 0.0)
	if count > 0 and duration > 0.0:
		for index in range(count):
			var start := center + Vector2(
				_rng.randf_range(-float(config.get("radius_x", 0.0)), float(config.get("radius_x", 0.0))),
				_rng.randf_range(-float(config.get("radius_y", 0.0)), float(config.get("radius_y", 0.0)))
			)
			var end := start + Vector2(
				_rng.randf_range(-float(config.get("drift_x", 0.0)), float(config.get("drift_x", 0.0))),
				-float(config.get("rise_distance", 0.0))
			)
			_spawn_linear_fleck(
				start,
				end,
				duration,
				float(config.get("stagger", 0.0)) * float(index),
				_random_size(config),
				_random_color(_fx_config.get("gold_colors", [])),
				_rng.randf_range(-float(config.get("rotation_turns", 0.0)), float(config.get("rotation_turns", 0.0)))
			)
	_play_reveal_halo(center, config)


func play_impact(center: Vector2) -> void:
	_play_impact_flash()
	_play_shockwave(center)
	_play_ballistic_group(center, _fx_config.get("impact_sparks", {}), _fx_config.get("gold_colors", []))
	_play_ballistic_group(center, _fx_config.get("impact_dust", {}), _fx_config.get("dust_colors", []))


func play_banner_confetti(viewport_size: Vector2) -> void:
	var config: Dictionary = _fx_config.get("banner_confetti", {})
	var count := maxi(int(config.get("count", 0)), 0)
	var duration := maxf(float(config.get("duration", 0.0)), 0.0)
	if count <= 0 or duration <= 0.0:
		return
	var center := Vector2(
		viewport_size.x * float(config.get("origin_x_ratio", 0.0)),
		viewport_size.y * float(config.get("origin_y_ratio", 0.0))
	)
	var spread_x := viewport_size.x * float(config.get("spread_x_ratio", 0.0))
	for index in range(count):
		var start := center + Vector2(_rng.randf_range(-spread_x, spread_x), 0.0)
		var velocity := Vector2(
			_rng.randf_range(-float(config.get("speed_x", 0.0)), float(config.get("speed_x", 0.0))),
			_rng.randf_range(float(config.get("speed_y_min", 0.0)), float(config.get("speed_y_max", 0.0)))
		)
		_spawn_ballistic_fleck(
			start,
			velocity,
			float(config.get("gravity", 0.0)),
			duration,
			float(config.get("stagger", 0.0)) * float(index),
			_random_size(config),
			_random_color(_fx_config.get("confetti_colors", [])),
			_rng.randf_range(float(config.get("rotation_turns_min", 0.0)), float(config.get("rotation_turns_max", 0.0)))
		)


func _play_impact_flash() -> void:
	var config: Dictionary = _fx_config.get("impact_flash", {})
	var duration := maxf(float(config.get("duration", 0.0)), 0.0)
	if duration <= 0.0:
		return
	var size := get_viewport_rect().size
	var flash := Polygon2D.new()
	flash.name = "ImpactFlash"
	flash.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0.0),
		size,
		Vector2(0.0, size.y)
	])
	var color := Color.from_string(str(config.get("color", "")), Color.WHITE)
	color.a = clampf(float(config.get("alpha", 0.0)), 0.0, 1.0)
	flash.color = color
	add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.0, duration)
	tween.tween_callback(flash.queue_free)


func _play_shockwave(center: Vector2) -> void:
	var config: Dictionary = _fx_config.get("shockwave", {})
	var duration := maxf(float(config.get("duration", 0.0)), 0.0)
	var point_count := maxi(int(config.get("point_count", 0)), 0)
	if duration <= 0.0 or point_count < 3:
		return
	var line := Line2D.new()
	line.name = "ImpactShockwave"
	line.position = center
	line.width = float(config.get("width_start", 0.0))
	line.default_color = Color.from_string(str(config.get("color", "")), Color.WHITE)
	line.antialiased = true
	_set_shockwave_radius(float(config.get("radius_start", 0.0)), line, point_count)
	add_child(line)
	var tween := create_tween()
	tween.tween_method(
		_set_shockwave_radius.bind(line, point_count),
		float(config.get("radius_start", 0.0)),
		float(config.get("radius_end", 0.0)),
		duration
	)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(line, "width", float(config.get("width_end", 0.0)), duration)
	tween.parallel().tween_property(line, "modulate:a", 0.0, duration)
	tween.tween_callback(line.queue_free)


func _play_reveal_halo(center: Vector2, config: Dictionary) -> void:
	var duration := maxf(float(config.get("halo_duration", 0.0)), 0.0)
	var point_count := maxi(int(config.get("halo_point_count", 0)), 0)
	if duration <= 0.0 or point_count < 3:
		return
	var halo := Line2D.new()
	halo.name = "DivineRevealHalo"
	halo.position = center
	halo.width = float(config.get("halo_width_start", 0.0))
	var color := Color.from_string(str(config.get("halo_color", "")), Color.WHITE)
	color.a = clampf(float(config.get("halo_alpha", 0.0)), 0.0, 1.0)
	halo.default_color = color
	halo.antialiased = true
	_set_shockwave_radius(float(config.get("halo_radius_start", 0.0)), halo, point_count)
	add_child(halo)
	var tween := create_tween()
	tween.tween_method(
		_set_shockwave_radius.bind(halo, point_count),
		float(config.get("halo_radius_start", 0.0)),
		float(config.get("halo_radius_end", 0.0)),
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(halo, "width", float(config.get("halo_width_end", 0.0)), duration)
	tween.parallel().tween_property(halo, "modulate:a", 0.0, duration)
	tween.tween_callback(halo.queue_free)


func _set_shockwave_radius(radius: float, line: Line2D, point_count: int) -> void:
	if line == null or not is_instance_valid(line):
		return
	var points := PackedVector2Array()
	for index in range(point_count + 1):
		var angle := TAU * float(index) / float(point_count)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	line.points = points


func _play_ballistic_group(center: Vector2, config: Dictionary, colors: Array) -> void:
	var count := maxi(int(config.get("count", 0)), 0)
	var duration := maxf(float(config.get("duration", 0.0)), 0.0)
	if count <= 0 or duration <= 0.0:
		return
	var base_angle := deg_to_rad(float(config.get("base_angle_degrees", 0.0)))
	var spread := deg_to_rad(float(config.get("spread_degrees", 0.0)))
	for index in range(count):
		var angle := base_angle + _rng.randf_range(-spread * 0.5, spread * 0.5)
		var speed := _rng.randf_range(float(config.get("speed_min", 0.0)), float(config.get("speed_max", 0.0)))
		var velocity := Vector2.RIGHT.rotated(angle) * speed
		_spawn_ballistic_fleck(
			center,
			velocity,
			float(config.get("gravity", 0.0)),
			duration,
			float(config.get("stagger", 0.0)) * float(index),
			_random_size(config),
			_random_color(colors),
			_rng.randf_range(-float(config.get("rotation_turns", 0.0)), float(config.get("rotation_turns", 0.0)))
		)


func _spawn_linear_fleck(start: Vector2, end: Vector2, duration: float, delay: float, size: float, color: Color, rotation_turns: float) -> void:
	var fleck := _make_fleck(size, color)
	fleck.position = start
	add_child(fleck)
	var tween := create_tween()
	if delay > 0.0:
		fleck.visible = false
		tween.tween_interval(delay)
		tween.tween_callback(func() -> void:
			if fleck != null and is_instance_valid(fleck):
				fleck.visible = true
		)
	tween.tween_property(fleck, "position", end, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fleck, "rotation", TAU * rotation_turns, duration)
	tween.parallel().tween_property(fleck, "modulate:a", 0.0, duration)
	tween.tween_callback(fleck.queue_free)


func _spawn_ballistic_fleck(start: Vector2, velocity: Vector2, gravity: float, duration: float, delay: float, size: float, color: Color, rotation_turns: float) -> void:
	var fleck := _make_fleck(size, color)
	fleck.position = start
	add_child(fleck)
	var tween := create_tween()
	if delay > 0.0:
		fleck.visible = false
		tween.tween_interval(delay)
		tween.tween_callback(func() -> void:
			if fleck != null and is_instance_valid(fleck):
				fleck.visible = true
		)
	tween.tween_method(_update_ballistic.bind(fleck, start, velocity, gravity), 0.0, duration, duration)\
		.set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(fleck, "rotation", TAU * rotation_turns, duration)
	tween.parallel().tween_property(fleck, "modulate:a", 0.0, duration)
	tween.tween_callback(fleck.queue_free)


func _update_ballistic(elapsed: float, fleck: Polygon2D, start: Vector2, velocity: Vector2, gravity: float) -> void:
	if fleck != null and is_instance_valid(fleck):
		fleck.position = start + velocity * elapsed + Vector2.DOWN * gravity * 0.5 * elapsed * elapsed


func _make_fleck(size: float, color: Color) -> Polygon2D:
	var fleck := Polygon2D.new()
	fleck.polygon = PackedVector2Array([
		Vector2(0.0, -size),
		Vector2(size * 0.55, 0.0),
		Vector2(0.0, size),
		Vector2(-size * 0.55, 0.0)
	])
	fleck.color = color
	return fleck


func _random_size(config: Dictionary) -> float:
	return _rng.randf_range(float(config.get("size_min", 0.0)), float(config.get("size_max", 0.0)))


func _random_color(colors: Array) -> Color:
	if colors.is_empty():
		return Color.WHITE
	return Color.from_string(str(colors[_rng.randi_range(0, colors.size() - 1)]), Color.WHITE)
