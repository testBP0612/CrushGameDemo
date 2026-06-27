class_name MonsterActor
extends Node2D

@onready var body: ColorRect = $Body

var _home_position := Vector2.ZERO
var _idle_tween: Tween
var _base_color := Color.WHITE


func _ready() -> void:
	_home_position = position
	play_idle()


func apply_monster(monster: Dictionary) -> void:
	_kill_idle()
	_base_color = Color.html(str(monster.get("placeholder_color", "#ffffff")))
	body.color = _base_color
	modulate = Color.WHITE
	scale = Vector2.ONE
	rotation = 0.0
	position = _home_position
	visible = true
	play_idle()


func play_idle() -> void:
	_kill_idle()
	var duration := _monster_duration("idle_loop")
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(self, "scale", Vector2(1.04, 0.96), duration * 0.5)
	_idle_tween.tween_property(self, "scale", Vector2.ONE, duration * 0.5)


func play_hurt() -> Signal:
	_kill_idle()
	var duration := _monster_duration("hurt")
	var tween := create_tween()
	tween.tween_property(body, "color", Color.WHITE, duration * 0.25)
	tween.parallel().tween_property(self, "position:x", _home_position.x + 24.0, duration * 0.5)
	tween.tween_property(body, "color", _base_color, duration * 0.25)
	tween.parallel().tween_property(self, "position", _home_position, duration * 0.5)
	tween.tween_callback(play_idle)
	return tween.finished


func play_death() -> Signal:
	_kill_idle()
	var duration := _monster_duration("death")
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.2, 0.2), duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(func() -> void: visible = false)
	return tween.finished


func play_counter(target_position: Vector2) -> Signal:
	_kill_idle()
	var duration := _lose_branch_duration("monster_counter_duration")
	var tween := create_tween()
	var strike_position := _home_position.lerp(target_position, 0.35)
	tween.tween_property(self, "position", strike_position, duration * 0.45)
	tween.tween_property(self, "position", _home_position, duration * 0.55)
	tween.tween_callback(play_idle)
	return tween.finished


func play_enter() -> Signal:
	_kill_idle()
	var duration := _advance_duration("next_monster_enter_duration")
	position = _home_position + Vector2(260.0, 0.0)
	scale = Vector2.ONE
	modulate = Color.WHITE
	visible = true
	var tween := create_tween()
	tween.tween_property(self, "position", _home_position, duration)
	tween.tween_callback(play_idle)
	return tween.finished


func _kill_idle() -> void:
	if _idle_tween != null:
		_idle_tween.kill()
		_idle_tween = null


func _monster_duration(key: String) -> float:
	var duration := float(Data.animation_timing_config().get("monster", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("MonsterActor missing animation duration: monster.%s" % key)
	return duration


func _lose_branch_duration(key: String) -> float:
	var duration := float(Data.battle_sequence_config().get("result_resolution", {}).get("lose_branch", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("MonsterActor missing lose branch duration: %s" % key)
	return duration


func _advance_duration(key: String) -> float:
	var duration := float(Data.battle_sequence_config().get("advance_sequence", {}).get(key, 0.0))
	if duration <= 0.0:
		push_error("MonsterActor missing advance duration: %s" % key)
	return duration
