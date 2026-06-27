class_name SettlementPanel
extends Control

signal acknowledge_requested

@onready var title_label: Label = $Panel/Margin/Layout/TitleLabel
@onready var body_label: Label = $Panel/Margin/Layout/BodyLabel
@onready var play_again_button: Button = $Panel/Margin/Layout/PlayAgainButton


func _ready() -> void:
	play_again_button.text = Data.text("settle_play_again")
	play_again_button.pressed.connect(func() -> void: acknowledge_requested.emit())


func update_snapshot(snapshot: Dictionary) -> void:
	var state_name := str(snapshot.get("state_name", ""))
	play_again_button.disabled = not bool(snapshot.get("is_settle", false))

	match state_name:
		"CASH_OUT_SETTLE":
			title_label.text = Data.text("settle_cashout_title")
			body_label.text = Data.text("settle_cashout_body", {
				"payout": int(snapshot.get("current_payout", 0))
			})
		"DEFEAT_SETTLE":
			title_label.text = Data.text("settle_defeat_title")
			body_label.text = Data.text("settle_defeat_body", {
				"bet": int(snapshot.get("bet", 0))
			})
		"CLEAR_SETTLE":
			title_label.text = Data.text("settle_clear_title")
			body_label.text = Data.text("settle_clear_body", {
				"payout": int(snapshot.get("current_payout", 0))
			})
