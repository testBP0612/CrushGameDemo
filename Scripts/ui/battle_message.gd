class_name BattleMessage
extends Control

@onready var message_label: Label = $MessageLabel

var _current_message_id := ""
var _queued_message_id := ""
var _queued_message_text := ""
var _last_message_started_at := -9999.0
var _message_tween: Tween


func update_snapshot(snapshot: Dictionary) -> void:
	var state_name := str(snapshot.get("state_name", ""))
	var monster_name := _monster_name(int(snapshot.get("active_monster_stage", 1)))
	var key := ""

	match state_name:
		"CHALLENGE_START", "BATTLE_ATTACK":
			key = "battle_msg_challenging"
		"MONSTER_HURT", "MONSTER_DEATH":
			key = "battle_msg_victory"
		"MONSTER_COUNTER", "PLAYER_HURT", "DEFEAT_SETTLE":
			key = "battle_msg_defeat"
		"CLEAR_SETTLE":
			key = "battle_msg_max_clear"

	if key == "":
		_hide_message()
		return

	var next_text := Data.text(key, {"monster": monster_name})
	if key == _current_message_id:
		message_label.text = next_text
		return

	_request_message(key, next_text)


func _monster_name(stage: int) -> String:
	var monster := Data.monster_for_stage(stage)
	if monster.is_empty():
		return ""
	return Data.text(str(monster.get("name_key", "")))


func _request_message(message_id: String, message_text: String) -> void:
	var ui_config: Dictionary = Data.animation_timing_config().get("ui", {})
	var hold := float(ui_config.get("message_hold", 0.0))
	var elapsed := _now_seconds() - _last_message_started_at

	if visible and elapsed < hold:
		_queued_message_id = message_id
		_queued_message_text = message_text
		_wait_then_show(hold - elapsed)
		return

	_show_message(message_id, message_text)


func _show_message(message_id: String, message_text: String) -> void:
	var ui_config: Dictionary = Data.animation_timing_config().get("ui", {})
	var appear := float(ui_config.get("message_appear", 0.0))
	_kill_message_tween()

	visible = true
	_current_message_id = message_id
	_queued_message_id = ""
	_queued_message_text = ""
	_last_message_started_at = _now_seconds()
	message_label.text = message_text

	if appear <= 0.0:
		push_error("BattleMessage missing positive message_appear.")
		modulate = Color.WHITE
		return

	modulate = Color(1.0, 1.0, 1.0, 0.0)
	_message_tween = create_tween()
	_message_tween.tween_property(self, "modulate:a", 1.0, appear).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_message_tween.tween_callback(func() -> void:
		_message_tween = null
	)


func _wait_then_show(delay: float) -> void:
	_kill_message_tween()
	_message_tween = create_tween()
	_message_tween.tween_interval(maxf(0.0, delay))
	_message_tween.tween_callback(func() -> void:
		if _queued_message_id != "":
			_show_message(_queued_message_id, _queued_message_text)
	)


func _hide_message() -> void:
	_kill_message_tween()
	visible = false
	modulate = Color.WHITE
	_current_message_id = ""
	_queued_message_id = ""
	_queued_message_text = ""


func _kill_message_tween() -> void:
	if _message_tween != null and is_instance_valid(_message_tween):
		_message_tween.kill()
	_message_tween = null


func _now_seconds() -> float:
	return float(Time.get_ticks_msec()) / 1000.0
