class_name SettlementPanel
extends Control

const ButtonFeedback := preload("res://Scripts/effects/button_feedback.gd")
const SettlementEffect := preload("res://Scripts/effects/settlement_effect.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

signal acknowledge_requested

@onready var title_label: Label = $Panel/Margin/Layout/TitleLabel
@onready var body_label: Label = $Panel/Margin/Layout/BodyLabel
@onready var play_again_button: Button = $Panel/Margin/Layout/PlayAgainButton
@onready var panel: PanelContainer = $Panel
@onready var reward_icon: TextureRect = $Panel/Margin/Layout/RewardIcon

var _last_settle_state := ""


func _ready() -> void:
	UiSkin.apply_panel(panel, "large")
	UiSkin.apply_button(play_again_button, "primary_plain")
	UiSkin.apply_modal_title(title_label)
	UiSkin.apply_light_panel_label(body_label)
	UiSkin.apply_icon(reward_icon, "cat_can")
	play_again_button.text = Data.text("settle_play_again")
	_install_button_feedback(play_again_button)
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

	if bool(snapshot.get("is_settle", false)) and state_name != _last_settle_state:
		_last_settle_state = state_name
		_play_settlement_effect(state_name)
	elif not bool(snapshot.get("is_settle", false)):
		_last_settle_state = ""


func _play_settlement_effect(state_name: String) -> void:
	var duration := float(Data.animation_timing_config().get("ui", {}).get("settlement_appear", 0.0))
	var result := "cash_out"
	if state_name == "DEFEAT_SETTLE":
		result = "defeat"
	elif state_name == "CLEAR_SETTLE":
		result = "clear"
	SettlementEffect.play(panel, result, duration)


func _install_button_feedback(button: Button) -> void:
	var duration := float(Data.animation_timing_config().get("ui", {}).get("button_feedback", 0.0))
	ButtonFeedback.install(button, duration)


func entrance_targets() -> Array[Control]:
	return [reward_icon, title_label, body_label, play_again_button]
