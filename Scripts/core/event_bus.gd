class_name EventBus
extends Node

signal data_loaded
signal bet_confirmed(bet: int)
signal attack_finished
signal result_resolved(is_win: bool)
signal huye_triggered(stage: int, bonus: int)
signal stage_advanced(stage: int, multiplier: float, payout: int)
signal cashout_requested
signal advance_requested
signal settled(result: String)
signal state_changed(state_name: String)
signal balance_changed(balance: int)
signal bet_changed(bet: int)
