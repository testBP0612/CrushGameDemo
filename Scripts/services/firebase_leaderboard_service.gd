class_name FirebaseLeaderboardService
extends "res://Scripts/services/leaderboard_service.gd"

## D-016 Phase 2 / Codex 17：Firestore `leaderboard/{uid}` 為資料來源。
## 同介面（signal 非同步）；未登入 / 橋接缺失 / 網路失敗一律靜默回空值，不阻塞。

const PlayerProfileServiceScript := preload("res://Scripts/services/player_profile_service.gd")

var _bridge: JavaScriptObject = null
var _score_service
var _profile_service: PlayerProfileService
# 每次呼叫建立的一次性 JS callback 需保留參照，避免在非同步結果回來前被 GC。
var _pending_callbacks: Array = []


func setup(score_service, profile_service: PlayerProfileService = null) -> void:
	_score_service = score_service
	_profile_service = profile_service if profile_service != null else PlayerProfileServiceScript.new()
	if OS.has_feature("web"):
		_bridge = JavaScriptBridge.get_interface("CrushOnline")


func request_top(n: int) -> void:
	var result_limit := maxi(0, n)
	if _bridge == null or not _is_signed_in():
		top_loaded.emit([])
		return
	_bridge.fetchLeaderboard(result_limit, _make_callback(_on_top_response.bind(result_limit)))


func request_rank_for(payout: int) -> void:
	var candidate := maxi(0, payout)
	if _bridge == null or not _is_signed_in():
		rank_loaded.emit(0, 0)
		return
	_bridge.fetchRankFor(candidate, _make_callback(_on_rank_response))


func submit_best(payout: int) -> void:
	if _bridge == null or _score_service == null:
		return
	var safe_payout := maxi(0, payout)
	if safe_payout <= int(_score_service.get_best_payout()):
		return
	_bridge.submitLeaderboard(safe_payout, _player_display_name())


func _on_top_response(args: Array, result_limit: int) -> void:
	var payload := _parse_json_arg(args)
	if payload.is_empty() or bool(payload.get("error", false)):
		top_loaded.emit([])
		return

	var raw_rows: Array = payload.get("rows", [])
	var rows: Array = []
	var my_uid := _my_uid()
	var found_me := false
	for entry: Variant in raw_rows:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var is_me := my_uid != "" and str(entry.get("uid", "")) == my_uid
		found_me = found_me or is_me
		rows.append({
			"rank": int(entry.get("rank", 0)),
			"display_name": str(entry.get("display_name", "")),
			"best_payout": int(entry.get("best_payout", 0)),
			"is_me": is_me
		})

	if found_me or my_uid == "":
		top_loaded.emit(rows)
		return

	# 本人不在 top N 內：另查一次精確排名，補到最後一格（同 Mock 語意）。
	var own_payout := int(_score_service.get_best_payout())
	_bridge.fetchRankFor(own_payout, _make_callback(_on_own_rank_for_top.bind(rows, result_limit, own_payout)))


func _on_own_rank_for_top(args: Array, rows: Array, result_limit: int, own_payout: int) -> void:
	var payload := _parse_json_arg(args)
	var own_row := {
		"rank": int(payload.get("rank", rows.size() + 1)),
		"display_name": _player_display_name(),
		"best_payout": own_payout,
		"is_me": true
	}
	var result: Array = rows.duplicate()
	if result_limit > 0 and result.size() >= result_limit:
		result[result_limit - 1] = own_row
	else:
		result.append(own_row)
	result.sort_custom(func(a, b): return int(a.get("rank", 0)) < int(b.get("rank", 0)))
	top_loaded.emit(result)


func _on_rank_response(args: Array) -> void:
	var payload := _parse_json_arg(args)
	if payload.is_empty() or bool(payload.get("error", false)):
		rank_loaded.emit(0, 0)
		return
	rank_loaded.emit(int(payload.get("rank", 0)), int(payload.get("beaten_percent", 0)))


func _make_callback(callable: Callable) -> JavaScriptObject:
	var cb := JavaScriptBridge.create_callback(callable)
	_pending_callbacks.append(cb)
	return cb


func _is_signed_in() -> bool:
	return _score_service != null and _score_service.has_method("is_signed_in") and bool(_score_service.call("is_signed_in"))


func _my_uid() -> String:
	if _score_service != null and _score_service.has_method("online_uid"):
		return str(_score_service.call("online_uid"))
	return ""


func _player_display_name() -> String:
	if _score_service != null and _score_service.has_method("online_display_name"):
		var online_name := str(_score_service.call("online_display_name"))
		if not online_name.is_empty():
			return online_name
	if _profile_service == null:
		_profile_service = PlayerProfileServiceScript.new()
	return str(_profile_service.get_profile().get("display_name", Data.text("profile_mock_display_name")))


func _parse_json_arg(args: Array) -> Dictionary:
	if args.is_empty() or typeof(args[0]) != TYPE_STRING:
		return {}
	var parsed: Variant = JSON.parse_string(args[0])
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("FirebaseLeaderboardService: malformed bridge payload ignored.")
		return {}
	return parsed
