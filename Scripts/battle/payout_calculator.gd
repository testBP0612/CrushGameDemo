class_name PayoutCalculator
extends RefCounted


# D-019：倍率由呼叫端傳入（可能是本局隨機盤的值），本類只負責金額換算；
# 顯示倍率與計算倍率必須同源，由呼叫端保證。
func current_payout(bet: int, multiplier: float) -> int:
	var raw_payout := float(bet) * multiplier
	var rounding := str(Data.payout_config().get("rounding", "floor"))

	match rounding:
		"floor":
			return int(floor(raw_payout))
		_:
			push_error("PayoutCalculator unsupported rounding mode: %s" % rounding)
			return int(floor(raw_payout))
