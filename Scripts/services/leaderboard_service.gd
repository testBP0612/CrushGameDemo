class_name LeaderboardService
extends RefCounted

signal top_loaded(rows: Array)
signal rank_loaded(rank: int, beaten_percent: int)


func request_top(_n: int) -> void:
	push_error("LeaderboardService.request_top must be implemented by a concrete service.")


func request_rank_for(_payout: int) -> void:
	push_error("LeaderboardService.request_rank_for must be implemented by a concrete service.")


func submit_best(_payout: int) -> void:
	push_error("LeaderboardService.submit_best must be implemented by a concrete service.")
