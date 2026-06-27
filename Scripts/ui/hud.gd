class_name Hud
extends Control

@onready var stage_label: Label = $Columns/StageCard/StageLabel
@onready var multiplier_label: Label = $Columns/MultiplierCard/MultiplierLabel
@onready var payout_label: Label = $Columns/PayoutCard/PayoutLabel
@onready var balance_label: Label = $BalanceLabel


func update_snapshot(snapshot: Dictionary) -> void:
	stage_label.text = Data.text("hud_stage", {
		"stage": int(snapshot.get("stage", 0)),
		"max": int(snapshot.get("max_stage", 0))
	})
	multiplier_label.text = Data.text("hud_multiplier", {
		"multiplier": snapshot.get("current_multiplier", 1.0)
	})
	payout_label.text = Data.text("hud_current_payout", {
		"payout": int(snapshot.get("current_payout", 0))
	})
	balance_label.text = Data.text("hud_balance", {
		"balance": int(snapshot.get("balance", 0))
	})
