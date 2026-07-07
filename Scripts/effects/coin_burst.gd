class_name CoinBurst
extends CanvasLayer

const COIN_TEXTURE_PATH := "res://Assets/final/ui/icon_coin.png"

var _remaining_coins := 0
var _first_arrival_sent := false
var _on_first_arrival: Callable
var _rng := RandomNumberGenerator.new()


## multiplier：擊殺後的目前倍率——倍率越高噴越多（D-019 微調，取代原 stage 線性）。
func play(origin_canvas_pos: Vector2, target_canvas_pos: Vector2, multiplier: float, on_first_arrival: Callable) -> bool:
	_on_first_arrival = on_first_arrival
	_rng.randomize()

	var config := _coin_config()
	if config.is_empty():
		push_warning("CoinBurst skipped: missing animation_timing.effects.coin_burst config.")
		return false

	if not ResourceLoader.exists(COIN_TEXTURE_PATH, "Texture2D"):
		push_warning("CoinBurst skipped: missing coin texture %s." % COIN_TEXTURE_PATH)
		return false

	var texture := load(COIN_TEXTURE_PATH) as Texture2D
	if texture == null:
		push_warning("CoinBurst skipped: failed to load coin texture %s." % COIN_TEXTURE_PATH)
		return false

	layer = int(config.get("canvas_layer", 0))
	var count: int = int(config.get("count_base", 0)) + int(round(float(config.get("count_per_multiplier", 0.0)) * maxf(multiplier, 0.0)))
	var count_max := int(config.get("count_max", 0))
	if count_max > 0:
		count = mini(count, count_max)
	if count <= 0:
		_notify_first_arrival()
		return false

	_remaining_coins = count
	for index in range(count):
		_spawn_coin(texture, origin_canvas_pos, target_canvas_pos, index, config)

	return true


func _spawn_coin(texture: Texture2D, origin: Vector2, target: Vector2, index: int, config: Dictionary) -> void:
	var coin := Sprite2D.new()
	coin.texture = texture
	coin.centered = true
	coin.position = origin
	coin.visible = false
	coin.modulate = Color.WHITE
	add_child(coin)

	var scale_min := float(config.get("scale_min", 0.0))
	var scale_max := float(config.get("scale_max", 0.0))
	var coin_scale := _rng.randf_range(min(scale_min, scale_max), max(scale_min, scale_max))
	coin.scale = Vector2.ONE * coin_scale

	var launch_speed := float(config.get("launch_speed", 0.0))
	var spread_radians := deg_to_rad(float(config.get("spread_degrees", 0.0)))
	var launch_angle := _rng.randf_range(-spread_radians * 0.5, spread_radians * 0.5)
	var velocity := Vector2.UP.rotated(launch_angle) * launch_speed
	var gravity := float(config.get("gravity", 0.0))
	var burst_duration := float(config.get("burst_duration", 0.0))
	var spawn_stagger := float(config.get("spawn_stagger", 0.0))
	var hover_time := float(config.get("hover_time", 0.0))
	var fly_duration := float(config.get("fly_duration", 0.0))
	var fly_stagger := float(config.get("fly_stagger", 0.0))
	var arrive_fade := float(config.get("arrive_fade", 0.0))

	var tween := create_tween()
	tween.tween_interval(spawn_stagger * float(index))
	tween.tween_callback(_show_coin.bind(coin))
	tween.tween_method(_update_coin_burst.bind(coin, origin, velocity, gravity), 0.0, burst_duration, burst_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(hover_time + fly_stagger * float(index))
	tween.tween_property(coin, "position", target, fly_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(_handle_arrival.bind(index))
	tween.tween_property(coin, "scale", Vector2.ZERO, arrive_fade).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(coin, "modulate:a", 0.0, arrive_fade)
	tween.tween_callback(_finish_coin.bind(coin))


func _show_coin(coin: Sprite2D) -> void:
	if coin != null and is_instance_valid(coin):
		coin.visible = true


func _update_coin_burst(elapsed: float, coin: Sprite2D, origin: Vector2, velocity: Vector2, gravity: float) -> void:
	if coin != null and is_instance_valid(coin):
		coin.position = origin + velocity * elapsed + Vector2.DOWN * gravity * 0.5 * elapsed * elapsed


func _handle_arrival(index: int) -> void:
	if index == 0:
		_notify_first_arrival()


func _finish_coin(coin: Sprite2D) -> void:
	if coin != null and is_instance_valid(coin):
		coin.queue_free()

	_remaining_coins -= 1
	if _remaining_coins <= 0:
		queue_free()


func _notify_first_arrival() -> void:
	if _first_arrival_sent:
		return
	_first_arrival_sent = true
	if not _on_first_arrival.is_null():
		_on_first_arrival.call()


func max_hold() -> float:
	return float(_coin_config().get("max_hold", 0.0))


func _coin_config() -> Dictionary:
	return Data.animation_timing_config().get("effects", {}).get("coin_burst", {})
