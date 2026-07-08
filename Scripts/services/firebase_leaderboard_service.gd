class_name FirebaseLeaderboardService
extends "res://Scripts/services/leaderboard_service.gd"

## D-016 Phase 2 / Codex 17：Firestore `leaderboard/{uid}` 為資料來源。
## 同介面（signal 非同步）；未登入 / 橋接缺失 / 網路失敗一律靜默回空值，不阻塞。
## D-020：`leaderboard_mock.json > keep_in_production` 開啟時，NPC 保底名單於
## client 端併入雲端資料（榜面與排名皆重算）；未登入/失敗時整份退回 Mock 語意
## ——比賽 demo 期間排行榜永不空。關閉 flag 即回到純雲端行為。

const PlayerProfileServiceScript := preload("res://Scripts/services/player_profile_service.gd")
const MockLeaderboardServiceScript := preload("res://Scripts/services/mock_leaderboard_service.gd")

var _bridge: JavaScriptObject = null
var _score_service
var _profile_service: PlayerProfileService
# D-020：NPC 保底的離線/未登入退路（訊號轉發）；flag 關閉時為 null
var _fallback_mock
# 每次呼叫建立的一次性 JS callback 需保留參照，避免在非同步結果回來前被 GC。
var _pending_callbacks: Array = []


func setup(score_service, profile_service: PlayerProfileService = null) -> void:
	_score_service = score_service
	_profile_service = profile_service if profile_service != null else PlayerProfileServiceScript.new()
	if OS.has_feature("web"):
		_bridge = JavaScriptBridge.get_interface("CrushOnline")
	if _npc_keep_enabled():
		_fallback_mock = MockLeaderboardServiceScript.new()
		_fallback_mock.setup(_score_service, _profile_service)
		_fallback_mock.top_loaded.connect(func(rows: Array) -> void: top_loaded.emit(rows))
		_fallback_mock.rank_loaded.connect(func(rank: int, percent: int) -> void: rank_loaded.emit(rank, percent))


func request_top(n: int) -> void:
	var result_limit := maxi(0, n)
	if _bridge == null or not _is_signed_in():
		if _fallback_mock != null:
			_fallback_mock.request_top(result_limit)
		else:
			top_loaded.emit([])
		return
	_bridge.fetchLeaderboard(result_limit, _make_callback(_on_top_response.bind(result_limit)))


func request_rank_for(payout: int) -> void:
	var candidate := maxi(0, payout)
	if _bridge == null or not _is_signed_in():
		if _fallback_mock != null:
			_fallback_mock.request_rank_for(candidate)
		else:
			rank_loaded.emit(0, 0)
		return
	_bridge.fetchRankFor(candidate, _make_callback(_on_rank_response.bind(candidate)))


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
		if _fallback_mock != null:
			_fallback_mock.request_top(result_limit)
		else:
			top_loaded.emit([])
		return

	# D-020：雲端列 + NPC 保底列合併後重排名（competition ranking：1 + 嚴格較高者數）
	var my_uid := _my_uid()
	var merged: Array = []
	for entry: Variant in payload.get("rows", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		merged.append({
			"display_name": str(entry.get("display_name", "")),
			"best_payout": int(entry.get("best_payout", 0)),
			"is_me": my_uid != "" and str(entry.get("uid", "")) == my_uid
		})
	merged.append_array(_npc_entries())
	merged.sort_custom(_sort_by_payout_desc)

	var rows: Array = []
	for entry: Dictionary in merged:
		rows.append({
			"rank": _rank_within(int(entry.get("best_payout", 0)), merged),
			"display_name": str(entry.get("display_name", "")),
			"best_payout": int(entry.get("best_payout", 0)),
			"is_me": bool(entry.get("is_me", false))
		})
	if result_limit > 0:
		rows = rows.slice(0, mini(result_limit, rows.size()))

	var found_me := false
	for row: Dictionary in rows:
		found_me = found_me or bool(row.get("is_me", false))
	if found_me or my_uid == "":
		top_loaded.emit(rows)
		return

	# 本人不在合併後 top N 內：另查雲端精確計數，併 NPC 算出正確名次補到最後一格。
	var own_payout := int(_score_service.get_best_payout())
	_bridge.fetchRankFor(own_payout, _make_callback(_on_own_rank_for_top.bind(rows, result_limit, own_payout)))


func _on_own_rank_for_top(args: Array, rows: Array, result_limit: int, own_payout: int) -> void:
	var payload := _parse_json_arg(args)
	var cloud_higher := int(payload.get("higher", maxi(0, int(payload.get("rank", rows.size() + 1)) - 1)))
	var own_row := {
		"rank": cloud_higher + _npc_higher_than(own_payout) + 1,
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


func _on_rank_response(args: Array, candidate: int) -> void:
	var payload := _parse_json_arg(args)
	if payload.is_empty() or bool(payload.get("error", false)):
		if _fallback_mock != null:
			_fallback_mock.request_rank_for(candidate)
		else:
			rank_loaded.emit(0, 0)
		return
	if _fallback_mock == null:
		rank_loaded.emit(int(payload.get("rank", 0)), int(payload.get("beaten_percent", 0)))
		return

	# D-020：雲端計數 + NPC 計數合併。lower/total 為新版 bridge 欄位；
	# 若打到舊版 bridge（未部署），percent 退回雲端原值、rank 仍可由 rank-1 併算。
	var cloud_higher := int(payload.get("higher", maxi(0, int(payload.get("rank", 1)) - 1)))
	var merged_rank := cloud_higher + _npc_higher_than(candidate) + 1
	var cloud_lower := int(payload.get("lower", -1))
	var cloud_total := int(payload.get("total", -1))
	var merged_percent := int(payload.get("beaten_percent", 0))
	if cloud_lower >= 0 and cloud_total >= 0:
		var merged_lower := cloud_lower + _npc_lower_than(candidate)
		var merged_total := cloud_total + _npc_entries().size()
		if merged_total > 0:
			merged_percent = int(floor(float(merged_lower) * 100.0 / float(merged_total)))
	rank_loaded.emit(merged_rank, merged_percent)


# --- D-020 NPC 保底名單 helpers ---

func _npc_keep_enabled() -> bool:
	var config := Data.leaderboard_mock_config()
	var entries: Array = config.get("entries", [])
	return bool(config.get("keep_in_production", false)) and not entries.is_empty()


func _npc_entries() -> Array:
	if _fallback_mock == null:
		return []
	var entries: Array = []
	for entry: Variant in Data.leaderboard_mock_config().get("entries", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		entries.append({
			"display_name": str(entry.get("display_name", "")),
			"best_payout": maxi(0, int(entry.get("best_payout", 0))),
			"is_me": false
		})
	return entries


func _npc_higher_than(payout: int) -> int:
	var count := 0
	for entry: Dictionary in _npc_entries():
		if int(entry.get("best_payout", 0)) > payout:
			count += 1
	return count


func _npc_lower_than(payout: int) -> int:
	var count := 0
	for entry: Dictionary in _npc_entries():
		if int(entry.get("best_payout", 0)) < payout:
			count += 1
	return count


func _rank_within(score: int, entries: Array) -> int:
	var higher_count := 0
	for entry: Dictionary in entries:
		if int(entry.get("best_payout", 0)) > score:
			higher_count += 1
	return higher_count + 1


func _sort_by_payout_desc(a: Dictionary, b: Dictionary) -> bool:
	var a_score := int(a.get("best_payout", 0))
	var b_score := int(b.get("best_payout", 0))
	if a_score != b_score:
		return a_score > b_score
	if bool(a.get("is_me", false)) != bool(b.get("is_me", false)):
		return bool(a.get("is_me", false))
	return str(a.get("display_name", "")) < str(b.get("display_name", ""))


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
