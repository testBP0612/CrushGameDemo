class_name RiskResolver
extends RefCounted


func resolve(stage_to_challenge: int) -> bool:
	var success_rate := Data.success_rate_at(stage_to_challenge)
	return randf() < success_rate


func sample_win_rate(stage_to_challenge: int, trials: int) -> float:
	if trials <= 0:
		return 0.0

	var wins := 0
	for _i in range(trials):
		if resolve(stage_to_challenge):
			wins += 1

	return float(wins) / float(trials)
