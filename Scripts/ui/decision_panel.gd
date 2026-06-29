class_name DecisionPanel
extends Control

const ButtonFeedback := preload("res://Scripts/effects/button_feedback.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

signal cashout_requested
signal advance_requested

@onready var cashout_button: Button = $Buttons/CashoutButton
@onready var advance_button: Button = $Buttons/AdvanceButton


func _ready() -> void:
	advance_button.text = Data.text("decision_advance")
	UiSkin.apply_button(cashout_button, "secondary")
	UiSkin.apply_button(advance_button, "primary")
	_install_button_feedback(cashout_button)
	_install_button_feedback(advance_button)
	cashout_button.pressed.connect(func() -> void: cashout_requested.emit())
	advance_button.pressed.connect(func() -> void: advance_requested.emit())


func update_snapshot(snapshot: Dictionary) -> void:
	var is_reward_decision := bool(snapshot.get("is_reward_decision", false))
	cashout_button.text = Data.text("decision_cashout", {
		"payout": int(snapshot.get("current_payout", 0))
	})
	cashout_button.disabled = not is_reward_decision
	advance_button.visible = bool(snapshot.get("can_advance", false))
	advance_button.disabled = not is_reward_decision


func _install_button_feedback(button: Button) -> void:
	var duration := float(Data.animation_timing_config().get("ui", {}).get("button_feedback", 0.0))
	ButtonFeedback.install(button, duration)
