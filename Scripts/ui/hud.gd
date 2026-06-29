class_name Hud
extends Control

const PayoutCountUp := preload("res://Scripts/effects/payout_count_up.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

@onready var stage_card: PanelContainer = $Columns/StageCard
@onready var multiplier_card: PanelContainer = $Columns/MultiplierCard
@onready var payout_card: PanelContainer = $Columns/PayoutCard
@onready var stage_icon: TextureRect = $Columns/StageCard/StageContent/StageHeader/StageIcon
@onready var stage_caption: Label = $Columns/StageCard/StageContent/StageHeader/StageCaption
@onready var stage_value: Label = $Columns/StageCard/StageContent/StageValue
@onready var multiplier_icon: TextureRect = $Columns/MultiplierCard/MultiplierContent/MultiplierHeader/MultiplierIcon
@onready var multiplier_caption: Label = $Columns/MultiplierCard/MultiplierContent/MultiplierHeader/MultiplierCaption
@onready var multiplier_value: Label = $Columns/MultiplierCard/MultiplierContent/MultiplierValue
@onready var payout_icon: TextureRect = $Columns/PayoutCard/PayoutContent/PayoutHeader/PayoutIcon
@onready var payout_caption: Label = $Columns/PayoutCard/PayoutContent/PayoutHeader/PayoutCaption
@onready var payout_value: Label = $Columns/PayoutCard/PayoutContent/PayoutValue
@onready var balance_label: Label = $BalanceLabel
@onready var balance_icon: TextureRect = $BalanceIcon

var _displayed_payout := 0
var _has_snapshot := false


func _ready() -> void:
	UiSkin.apply_panel(stage_card, "card")
	UiSkin.apply_panel(multiplier_card, "card")
	UiSkin.apply_panel(payout_card, "card")
	UiSkin.apply_icon(stage_icon, "stage")
	UiSkin.apply_hud_card_text(stage_caption, "label")
	UiSkin.apply_hud_card_text(stage_value, "value")
	UiSkin.apply_icon(multiplier_icon, "multiplier")
	UiSkin.apply_hud_card_text(multiplier_caption, "label")
	UiSkin.apply_hud_card_text(multiplier_value, "value")
	UiSkin.apply_icon(payout_icon, "payout")
	UiSkin.apply_hud_card_text(payout_caption, "label")
	UiSkin.apply_hud_card_text(payout_value, "value")
	UiSkin.apply_resource_label(balance_label)
	UiSkin.apply_icon(balance_icon, "coin")


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
	return [stage_card, multiplier_card, payout_card]
