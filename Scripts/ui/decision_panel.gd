class_name DecisionPanel
extends Control

const ButtonFeedback := preload("res://Scripts/effects/button_feedback.gd")

signal cashout_requested
signal advance_requested

@onready var cashout_button: Button = $Buttons/CashoutButton
@onready var advance_button: Button = $Buttons/AdvanceButton


func _ready() -> void:
	advance_button.text = Data.text("decision_advance")
	_apply_button_style(cashout_button, Color(0.87, 0.43, 0.18, 1.0))
	_apply_button_style(advance_button, Color(0.18, 0.58, 0.27, 1.0))
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


func _apply_button_style(button: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.12)
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.14)
	button.add_theme_stylebox_override("pressed", pressed)


func _install_button_feedback(button: Button) -> void:
	var duration := float(Data.animation_timing_config().get("ui", {}).get("button_feedback", 0.0))
	ButtonFeedback.install(button, duration)
