class_name PayoutCalculator
extends RefCounted


func current_payout(bet: int, stage: int) -> int:
	var raw_payout := float(bet) * Data.multiplier_at(stage)
	var rounding := str(Data.payout_config().get("rounding", "floor"))

	match rounding:
		"floor":
			return int(floor(raw_payout))
		_:
			push_error("PayoutCalculator unsupported rounding mode: %s" % rounding)
			return int(floor(raw_payout))
