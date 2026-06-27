class_name ScoreService
extends RefCounted


func load_save() -> void:
	push_error("ScoreService.load_save must be implemented by a concrete service.")


func get_balance() -> int:
	push_error("ScoreService.get_balance must be implemented by a concrete service.")
	return 0


func set_balance(_value: int) -> void:
	push_error("ScoreService.set_balance must be implemented by a concrete service.")


func get_best_payout() -> int:
	push_error("ScoreService.get_best_payout must be implemented by a concrete service.")
	return 0


func submit_payout(_payout: int) -> void:
	push_error("ScoreService.submit_payout must be implemented by a concrete service.")


func reset_balance() -> int:
	push_error("ScoreService.reset_balance must be implemented by a concrete service.")
	return get_balance()
