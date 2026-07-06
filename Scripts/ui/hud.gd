class_name Hud
extends Control

const PayoutCountUp := preload("res://Scripts/effects/payout_count_up.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

@onready var board_rect: TextureRect = $BoardRect
@onready var stage_caption: Label = $StageCaption
@onready var stage_value: Label = $StageValue
@onready var multiplier_caption: Label = $MultiplierCaption
@onready var multiplier_value: Label = $MultiplierValue
@onready var payout_caption: Label = $PayoutCaption
@onready var payout_value: Label = $PayoutValue
@onready var balance_label: Label = $BalanceLabel
@onready var balance_icon: TextureRect = $BalanceIcon

var _displayed_payout := 0
var _has_snapshot := false


func _ready() -> void:
	var board_ok := UiSkin.apply_art_texture(board_rect, "board")
	UiSkin.apply_hud_card_text(stage_caption, "board_caption")
	UiSkin.apply_hud_card_text(stage_value, "board_value")
	UiSkin.apply_hud_card_text(multiplier_caption, "board_caption")
	UiSkin.apply_hud_card_text(multiplier_value, "board_value_pink")
	UiSkin.apply_hud_card_text(payout_caption, "board_tab")
	UiSkin.apply_hud_card_text(payout_value, "board_value_pink")
	UiSkin.apply_resource_label(balance_label)
	UiSkin.apply_icon(balance_icon, "coin")
	if not board_ok:
		# 缺看板圖時給數值標籤補底板，維持可讀（缺檔不崩原則）
		for label: Label in [stage_value, multiplier_value, payout_value]:
			label.add_theme_stylebox_override("normal", UiSkin.fallback_value_box())


func update_snapshot(snapshot: Dictionary) -> void:
	var next_payout := int(snapshot.get("current_payout", 0))
	_set_caption_value(stage_caption, stage_value, Data.text("hud_stage", {
		"stage": int(snapshot.get("stage", 0)),
		"max": int(snapshot.get("max_stage", 0))
	}))
	_set_caption_value(multiplier_caption, multiplier_value, Data.text("hud_multiplier", {
		"multiplier": snapshot.get("current_multiplier", 1.0)
	}))
	payout_caption.text = _caption_from_text(Data.text("hud_current_payout", {"payout": next_payout}))
	_update_payout_label(next_payout)
	balance_label.text = Data.text("hud_balance", {
		"balance": int(snapshot.get("balance", 0))
	})


func _update_payout_label(next_payout: int) -> void:
	if not _has_snapshot:
		_displayed_payout = next_payout
		_has_snapshot = true
		payout_value.text = _format_payout_text(next_payout)
		return

	if next_payout == _displayed_payout:
		payout_value.text = _format_payout_text(next_payout)
		return

	var duration := float(Data.animation_timing_config().get("ui", {}).get("payout_count_up", 0.0))
	PayoutCountUp.play(payout_value, _displayed_payout, next_payout, duration, _format_payout_text)
	_displayed_payout = next_payout


func _format_payout_text(value: int) -> String:
	return str(value)


func _set_caption_value(caption_label: Label, value_label: Label, text: String) -> void:
	var split_at := text.find(" ")
	if split_at <= 0:
		caption_label.text = text
		value_label.text = ""
		return
	caption_label.text = text.substr(0, split_at)
	value_label.text = text.substr(split_at + 1)


func _caption_from_text(text: String) -> String:
	var split_at := text.find(" ")
	if split_at <= 0:
		return text
	return text.substr(0, split_at)


func entrance_targets() -> Array[Control]:
	return [stage_value, multiplier_value, payout_value]
