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

var _displayed_payout := 0
var _has_snapshot := false
var _payout_hold_active := false
var _payout_hold_generation := 0
var _held_payout_pending := false
var _held_payout_value := 0


func _ready() -> void:
	var board_ok := UiSkin.apply_art_texture(board_rect, "board")
	# 正式看板已內含三個欄位標題；缺圖 fallback 時才顯示程式文字。
	stage_caption.visible = not board_ok
	multiplier_caption.visible = not board_ok
	payout_caption.visible = not board_ok
	UiSkin.apply_hud_card_text(stage_caption, "board_caption")
	UiSkin.apply_hud_card_text(stage_value, "board_value")
	UiSkin.apply_hud_card_text(multiplier_caption, "board_caption")
	UiSkin.apply_hud_card_text(multiplier_value, "board_value_pink")
	UiSkin.apply_hud_card_text(payout_caption, "board_tab")
	UiSkin.apply_hud_card_text(payout_value, "board_value_pink")
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
		"multiplier": _format_multiplier(float(snapshot.get("current_multiplier", 1.0)))
	}))
	payout_caption.text = _caption_from_text(Data.text("hud_current_payout", {"payout": next_payout}))
	_update_payout_label(next_payout)


func _update_payout_label(next_payout: int) -> void:
	if _payout_hold_active and _has_snapshot and next_payout != _displayed_payout:
		_held_payout_pending = true
		_held_payout_value = next_payout
		return

	_apply_payout_label(next_payout)


func hold_payout_count_up(max_hold: float) -> void:
	_payout_hold_generation += 1
	_payout_hold_active = true
	_held_payout_pending = false

	if max_hold <= 0.0:
		push_error("Hud payout hold missing positive max_hold.")
		release_payout_count_up()
		return

	var generation := _payout_hold_generation
	get_tree().create_timer(max_hold).timeout.connect(func() -> void:
		if _payout_hold_active and generation == _payout_hold_generation:
			release_payout_count_up()
	)


func release_payout_count_up() -> void:
	if not _payout_hold_active:
		return

	_payout_hold_active = false
	_payout_hold_generation += 1
	if _held_payout_pending:
		var pending_value := _held_payout_value
		_held_payout_pending = false
		_apply_payout_label(pending_value)


func payout_anchor_canvas_position() -> Vector2:
	if payout_value == null or not is_instance_valid(payout_value):
		return Vector2.ZERO
	return payout_value.get_global_transform_with_canvas().origin + payout_value.size * 0.5


func _apply_payout_label(next_payout: int) -> void:
	if not _has_snapshot:
		_displayed_payout = next_payout
		_has_snapshot = true
		payout_value.text = _format_payout_text(next_payout)
		return

	if next_payout == _displayed_payout:
		payout_value.text = _format_payout_text(next_payout)
		return

	var duration := float(Data.animation_timing_config().get("ui", {}).get("payout_count_up", 0.0))
	if duration <= 0.0:
		push_error("Hud missing positive ui.payout_count_up duration.")
		_displayed_payout = next_payout
		payout_value.text = _format_payout_text(next_payout)
		return
	PayoutCountUp.play(payout_value, _displayed_payout, next_payout, duration, _format_payout_text)
	_displayed_payout = next_payout


func _format_payout_text(value: int) -> String:
	return str(value)


## 倍率顯示：最多兩位小數、去尾零（1.0 → 1、1.30 → 1.3），避免「1賠1.0」。
func _format_multiplier(value: float) -> String:
	var text := String.num(value, 2)
	if text.contains("."):
		text = text.rstrip("0").rstrip(".")
	return text


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
