class_name MockLeaderboardService
extends "res://Scripts/services/leaderboard_service.gd"

const PlayerProfileServiceScript := preload("res://Scripts/services/player_profile_service.gd")

var _score_service
var _profile_service: PlayerProfileService


func setup(score_service, profile_service: PlayerProfileService = null) -> void:
	_score_service = score_service
	_profile_service = profile_service if profile_service != null else PlayerProfileServiceScript.new()


func request_top(n: int) -> void:
	var limit := maxi(0, n)
	var rows := _rows_for_score(_current_player_best())
	var result := rows.slice(0, mini(limit, rows.size()))

	if limit > 0 and not _contains_player(result):
		var player_row := _player_row(rows)
		if not player_row.is_empty():
			if result.size() >= limit:
				result[limit - 1] = player_row
			else:
				result.append(player_row)
			result.sort_custom(_sort_rows_by_rank)

	top_loaded.emit(result)


func request_rank_for(payout: int) -> void:
	var candidate_score := maxi(0, payout)
	var entries := _entries_with_player_score(candidate_score)
	var total := entries.size()
	var higher_count := 0
	var lower_count := 0

	for entry: Dictionary in entries:
		var entry_score := int(entry.get("best_payout", 0))
		if entry_score > candidate_score:
			higher_count += 1
		elif entry_score < candidate_score:
			lower_count += 1

	var rank := higher_count + 1
	var beaten_percent := 0
	if total > 0:
		beaten_percent = int(floor(float(lower_count) * 100.0 / float(total)))

	rank_loaded.emit(rank, beaten_percent)


func submit_best(payout: int) -> void:
	if _score_service == null:
		return
	var safe_payout := maxi(0, payout)
	if safe_payout > int(_score_service.get_best_payout()):
		_score_service.submit_payout(safe_payout)


func _rows_for_score(player_score: int) -> Array:
	var entries := _entries_with_player_score(player_score)
	entries.sort_custom(_sort_entries)

	var rows: Array = []
	for entry: Dictionary in entries:
		var score := int(entry.get("best_payout", 0))
		rows.append({
			"rank": _rank_for_score(score, entries),
			"display_name": str(entry.get("display_name", "")),
			"best_payout": score,
			"is_me": bool(entry.get("is_me", false))
		})
	return rows


func _entries_with_player_score(player_score: int) -> Array:
	var entries: Array = []
	for entry: Dictionary in Data.leaderboard_mock_config().get("entries", []):
		entries.append({
			"display_name": str(entry.get("display_name", "")),
			"best_payout": maxi(0, int(entry.get("best_payout", 0))),
			"is_me": false
		})

	entries.append({
		"display_name": _player_display_name(),
		"best_payout": maxi(0, player_score),
		"is_me": true
	})
	return entries


func _rank_for_score(score: int, entries: Array) -> int:
	var higher_count := 0
	for entry: Dictionary in entries:
		if int(entry.get("best_payout", 0)) > score:
			higher_count += 1
	return higher_count + 1


func _current_player_best() -> int:
	if _score_service == null:
		return 0
	return maxi(0, int(_score_service.get_best_payout()))


func _player_display_name() -> String:
	if _score_service != null and _score_service.has_method("is_signed_in") and bool(_score_service.call("is_signed_in")):
		var online_name := str(_score_service.call("online_display_name"))
		if not online_name.is_empty():
			return online_name

	if _profile_service == null:
		_profile_service = PlayerProfileServiceScript.new()
	return str(_profile_service.get_profile().get("display_name", Data.text("profile_mock_display_name")))


func _contains_player(rows: Array) -> bool:
	for row: Dictionary in rows:
		if bool(row.get("is_me", false)):
			return true
	return false


func _player_row(rows: Array) -> Dictionary:
	for row: Dictionary in rows:
		if bool(row.get("is_me", false)):
			return row
	return {}


func _sort_entries(a: Dictionary, b: Dictionary) -> bool:
	var a_score := int(a.get("best_payout", 0))
	var b_score := int(b.get("best_payout", 0))
	if a_score != b_score:
		return a_score > b_score
	if bool(a.get("is_me", false)) != bool(b.get("is_me", false)):
		return bool(a.get("is_me", false))
	return str(a.get("display_name", "")) < str(b.get("display_name", ""))


func _sort_rows_by_rank(a: Dictionary, b: Dictionary) -> bool:
	var a_rank := int(a.get("rank", 0))
	var b_rank := int(b.get("rank", 0))
	if a_rank != b_rank:
		return a_rank < b_rank
	return _sort_entries(a, b)
