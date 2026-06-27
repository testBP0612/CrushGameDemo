class_name BattleMessage
extends Control

@onready var message_label: Label = $MessageLabel


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

	visible = key != ""
	if visible:
		message_label.text = Data.text(key, {"monster": monster_name})


func _monster_name(stage: int) -> String:
	var monster := Data.monster_for_stage(stage)
	if monster.is_empty():
		return ""
	return Data.text(str(monster.get("name_key", "")))
