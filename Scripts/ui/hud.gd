class_name Hud
extends Control

const PayoutCountUp := preload("res://Scripts/effects/payout_count_up.gd")

@onready var stage_label: Label = $Columns/StageCard/StageLabel
@onready var multiplier_label: Label = $Columns/MultiplierCard/MultiplierLabel
@onready var payout_label: Label = $Columns/PayoutCard/PayoutLabel
@onready var balance_label: Label = $BalanceLabel

var _displayed_payout := 0
var _has_snapshot := false


func update_snapshot(snapshot: Dictionary) -> void:
	var next_payout := int(snapshot.get("current_payout", 0))
	stage_label.text = Data.text("hud_stage", {
		"stage": int(snapshot.get("stage", 0)),
		"max": int(snapshot.get("max_stage", 0))
	})
	multiplier_label.text = Data.text("hud_multiplier", {
		"multiplier": snapshot.get("current_multiplier", 1.0)
	})
	_update_payout_label(next_payout)
	balance_label.text = Data.text("hud_balance", {
		"balance": int(snapshot.get("balance", 0))
	})


func _update_payout_label(next_payout: int) -> void:
	if not _has_snapshot:
		_displayed_payout = next_payout
		_has_snapshot = true
		payout_label.text = Data.text("hud_current_payout", {"payout": next_payout})
		return

	if next_payout == _displayed_payout:
		payout_label.text = Data.text("hud_current_payout", {"payout": next_payout})
		return

	var duration := float(Data.animation_timing_config().get("ui", {}).get("payout_count_up", 0.0))
	PayoutCountUp.play(payout_label, _displayed_payout, next_payout, duration, _format_payout_text)
	_displayed_payout = next_payout


func _format_payout_text(value: int) -> String:
	return Data.text("hud_current_payout", {"payout": value})
