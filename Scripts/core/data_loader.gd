class_name DataLoader
extends Node

const DATA_PATHS := {
	"game_balance": "res://Data/game_balance.json",
	"monsters": "res://Data/monsters.json",
	"battle_sequences": "res://Data/battle_sequences.json",
	"animation_timing": "res://Data/animation_timing.json",
	"ui_text": "res://Data/ui_text.json"
}

var _data: Dictionary = {}
var _loaded := false


func _ready() -> void:
	if not load_all():
		push_error("DataLoader autoload failed to load Data/*.json.")


func load_all() -> bool:
	_data.clear()
	_loaded = false

	for key: String in DATA_PATHS:
		var path: String = DATA_PATHS[key]
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			push_error("DataLoader failed to open %s: %s" % [path, error_string(FileAccess.get_open_error())])
			return false

		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if typeof(parsed) != TYPE_DICTIONARY:
			push_error("DataLoader failed to parse %s as a JSON object." % path)
			return false

		_data[key] = parsed

	_loaded = true
	return true


func is_loaded() -> bool:
	return _loaded


func text(key: String, vars: Dictionary = {}) -> String:
	var text_root: Dictionary = _data.get("ui_text", {}).get("text", {})
	if not text_root.has(key):
		push_error("DataLoader missing ui_text key: %s" % key)
		return "[%s]" % key

	var value: String = str(text_root[key])
	for var_key: Variant in vars.keys():
		value = value.replace("{%s}" % str(var_key), str(vars[var_key]))
	return value


func balance_config() -> Dictionary:
	return _data.get("game_balance", {}).get("currency", {})


func payout_config() -> Dictionary:
	return _data.get("game_balance", {}).get("payout", {})


func stage_progression_config() -> Dictionary:
	return _data.get("game_balance", {}).get("stage_progression", {})


func battle_sequence_config() -> Dictionary:
	return _data.get("battle_sequences", {})


func animation_timing_config() -> Dictionary:
	return _data.get("animation_timing", {})


func multiplier_at(stage: int) -> float:
	var balance_data: Dictionary = _data.get("game_balance", {})
	if stage == 0:
		return float(balance_data.get("payout", {}).get("base_multiplier_at_stage_0", 1.0))

	for entry: Dictionary in balance_data.get("multiplier_curve", []):
		if int(entry.get("stage", -1)) == stage:
			return float(entry.get("multiplier", 0.0))

	push_error("DataLoader missing multiplier for stage %d." % stage)
	return 0.0


func success_rate_at(stage: int) -> float:
	var balance_data: Dictionary = _data.get("game_balance", {})
	for entry: Dictionary in balance_data.get("success_rate_curve", []):
		if int(entry.get("stage", -1)) == stage:
			return float(entry.get("success_rate", 0.0))

	push_error("DataLoader missing success rate for stage %d." % stage)
	return 0.0


func monster_for_stage(stage: int) -> Dictionary:
	var monsters: Array = _data.get("monsters", {}).get("monsters", [])
	for monster: Dictionary in monsters:
		if int(monster.get("stage", -1)) == stage:
			return monster

	push_error("DataLoader missing monster for stage %d." % stage)
	return {}


func loaded_keys() -> Array:
	return _data.keys()
