class_name DecisionPanel
extends Control

const ButtonFeedback := preload("res://Scripts/effects/button_feedback.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

signal cashout_requested
signal advance_requested

@onready var cashout_button: Button = $Buttons/CashoutButton
@onready var advance_button: Button = $Buttons/AdvanceButton
@onready var hint_panel: PanelContainer = $RankHint
@onready var hint_label: Label = $RankHint/Margin/HintLabel

var _leaderboard_service


func _ready() -> void:
	advance_button.text = Data.text("decision_advance")
	UiSkin.apply_button(cashout_button, "secondary")
	UiSkin.apply_button(advance_button, "primary")
	UiSkin.apply_leaderboard_hint(hint_panel)
	UiSkin.apply_light_panel_label(hint_label)
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
	hint_panel.visible = is_reward_decision
	_bind_leaderboard_service(snapshot.get("leaderboard_service", null))
	if is_reward_decision and _leaderboard_service != null:
		hint_label.text = Data.text("lb_loading")
		_leaderboard_service.request_rank_for(int(snapshot.get("current_payout", 0)))


func _bind_leaderboard_service(service) -> void:
	if service == _leaderboard_service:
		return
	if _leaderboard_service != null and _leaderboard_service.rank_loaded.is_connected(_on_rank_loaded):
		_leaderboard_service.rank_loaded.disconnect(_on_rank_loaded)
	_leaderboard_service = service
	if _leaderboard_service != null and not _leaderboard_service.rank_loaded.is_connected(_on_rank_loaded):
		_leaderboard_service.rank_loaded.connect(_on_rank_loaded)


func _on_rank_loaded(rank: int, _beaten_percent: int) -> void:
	hint_label.text = Data.text("lb_cashout_rank_hint", {"rank": rank})


func _install_button_feedback(button: Button) -> void:
	var duration := float(Data.animation_timing_config().get("ui", {}).get("button_feedback", 0.0))
	ButtonFeedback.install(button, duration)
