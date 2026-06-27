class_name HeroActor
extends Node2D

@onready var body: ColorRect = $Body

var _home_position := Vector2.ZERO
var _idle_tween: Tween


func _ready() -> void:
	_home_position = position
	play_idle()


func play_idle() -> void:
	_kill_idle()
	var duration := _hero_duration("idle_loop")
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(self, "position:y", _home_position.y - 12.0, duration * 0.5)
	_idle_tween.tween_property(self, "position:y", _home_position.y, duration * 0.5)


func play_attack(target_position: Vector2) -> Signal:
	_kill_idle()
	var duration := _hero_duration("attack")
	var tween := create_tween()
	var strike_position := _home_position.lerp(target_position, 0.42)
	tween.tween_property(self, "position", strike_position, duration * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", _home_position, duration * 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(play_idle)
	return tween.finished


func play_hurt() -> Signal:
	_kill_idle()
	var duration := _hero_duration("hurt")
	var original_color := body.color
	var tween := create_tween()
	tween.tween_property(body, "color", Color(1.0, 0.35, 0.35, 1.0), duration * 0.25)
	tween.parallel().tween_property(self, "position:x", _home_position.x - 40.0, duration * 0.5)
	tween.tween_property(body, "color", original_color, duration * 0.25)
	tween.parallel().tween_property(self, "position", _home_position, duration * 0.5)
	tween.tween_callback(play_idle)
	return tween.finished


func play_defeat() -> Signal:
	_kill_idle()
	var duration := _hero_duration("defeat")
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", -18.0, duration)
	tween.parallel().tween_property(self, "modulate", Color(0.55, 0.55, 0.55, 1.0), duration)
	return tween.finished


func play_walk() -> Signal:
	_kill_idle()
	var duration := _advance_duration("hero_walk_duration")
	var tween := create_tween()
	tween.tween_property(self, "position:x", _home_position.x + 90.0, duration * 0.5)
	tween.tween_property(self, "position:x", _home_position.x, duration * 0.5)
	tween.tween_callback(play_idle)
	return tween.finished


func reset_pose() -> void:
	_kill_idle()
	position = _home_position
	rotation = 0.0
	modulate = Color.WHITE
	play_idle()


func _kill_idle() -> void:
	if _idle_tween != null:
		_idle_tween.kill()
		_idle_tween = null


func _hero_duration(key: String) -> float:
	var duration := float(Data.animation_timing_config().get("hero", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("HeroActor missing animation duration: hero.%s" % key)
	return duration


func _advance_duration(key: String) -> float:
	var duration := float(Data.battle_sequence_config().get("advance_sequence", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("HeroActor missing advance duration: %s" % key)
	return duration
