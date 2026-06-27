class_name LocalScoreService
extends "res://Scripts/services/score_service.gd"

const SAVE_PATH := "user://save.json"

var _balance := 0
var _best_payout := 0


func load_save() -> void:
	var defaults := _default_save_data()
	_balance = int(defaults.get("balance", 0))
	_best_payout = int(defaults.get("best_payout", 0))

	if not FileAccess.file_exists(SAVE_PATH):
		_save()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("LocalScoreService failed to open save: %s" % error_string(FileAccess.get_open_error()))
		_save()
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("LocalScoreService save parse failed; using defaults.")
		_save()
		return

	_balance = _safe_int(parsed, "balance", _balance)
	_best_payout = _safe_int(parsed, "best_payout", _best_payout)
	_save()


func get_balance() -> int:
	return _balance


func set_balance(value: int) -> void:
	_balance = max(0, value)
	_save()


func get_best_payout() -> int:
	return _best_payout


func submit_payout(payout: int) -> void:
	if payout > _best_payout:
		_best_payout = payout
		_save()


func reset_balance() -> int:
	_balance = _starting_balance()
	_save()
	return _balance


func save_path() -> String:
	return SAVE_PATH


func _default_save_data() -> Dictionary:
	return {
		"balance": _starting_balance(),
		"best_payout": 0
	}


func _starting_balance() -> int:
	return int(Data.balance_config().get("starting_balance", 0))


func _safe_int(source: Dictionary, key: String, fallback: int) -> int:
	if not source.has(key):
		return fallback
	var value: Variant = source[key]
	if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
		return int(value)
	return fallback


func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("LocalScoreService failed to write save: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify({
		"schema_version": "1.0",
		"balance": _balance,
		"best_payout": _best_payout
	}, "\t"))
