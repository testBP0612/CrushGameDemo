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
var _cashout_is_art := false
var _advance_is_art := false
# D-019 決策資訊板：過關可得（主）＋ 1賠N（副）＋ 危險度（質化）。程式生成，不動 .tscn。
var _info_panel: PanelContainer
var _next_win_label: Label
var _odds_label: Label
var _danger_caption: Label
var _danger_icons: HBoxContainer


func _ready() -> void:
	_build_next_info()
	# 撤退/續戰改用 mockup 大圖按鈕（retreat.png / next.png 含烤字）；缺檔退回文字按鈕
	_cashout_is_art = UiSkin.apply_art_button(cashout_button, "btn_retreat")
	if not _cashout_is_art:
		# icon 對齊依套樣式當下有無文字決定：先給文字再套樣式
		cashout_button.text = Data.text("decision_cashout", {"payout": 0})
		UiSkin.apply_button(cashout_button, "secondary")
	_advance_is_art = UiSkin.apply_art_button(advance_button, "btn_next")
	if _advance_is_art:
		advance_button.text = ""
	else:
		advance_button.text = Data.text("decision_advance")
		UiSkin.apply_button(advance_button, "primary")
	UiSkin.apply_leaderboard_hint(hint_panel)
	UiSkin.apply_light_panel_label(hint_label)
	_install_button_feedback(cashout_button)
	_install_button_feedback(advance_button)
	cashout_button.pressed.connect(func() -> void: cashout_requested.emit())
	advance_button.pressed.connect(func() -> void: advance_requested.emit())


func _build_next_info() -> void:
	_info_panel = PanelContainer.new()
	_info_panel.name = "NextInfoPanel"
	_info_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_info_panel.offset_left = 60.0
	_info_panel.offset_right = -60.0
	_info_panel.offset_top = 20.0
	_info_panel.offset_bottom = 250.0
	UiSkin.apply_leaderboard_hint(_info_panel)
	add_child(_info_panel)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 6)
	_info_panel.add_child(layout)

	_next_win_label = Label.new()
	_next_win_label.name = "NextWinLabel"
	_next_win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_next_win_label.add_theme_font_size_override("font_size", 58)
	UiSkin.apply_hud_card_text(_next_win_label, "board_value_pink")
	layout.add_child(_next_win_label)

	var odds_row := HBoxContainer.new()
	odds_row.alignment = BoxContainer.ALIGNMENT_CENTER
	odds_row.add_theme_constant_override("separation", 24)
	layout.add_child(odds_row)

	_odds_label = Label.new()
	_odds_label.name = "OddsLabel"
	_odds_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_odds_label.add_theme_font_size_override("font_size", 34)
	UiSkin.apply_hud_card_text(_odds_label, "board_value")
	odds_row.add_child(_odds_label)

	_danger_caption = Label.new()
	_danger_caption.name = "DangerCaption"
	_danger_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_danger_caption.add_theme_font_size_override("font_size", 34)
	UiSkin.apply_hud_card_text(_danger_caption, "board_caption")
	odds_row.add_child(_danger_caption)

	_danger_icons = HBoxContainer.new()
	_danger_icons.name = "DangerIcons"
	_danger_icons.alignment = BoxContainer.ALIGNMENT_CENTER
	_danger_icons.add_theme_constant_override("separation", 4)
	odds_row.add_child(_danger_icons)


func _update_next_info(snapshot: Dictionary, is_reward_decision: bool) -> void:
	if _info_panel == null or not is_instance_valid(_info_panel):
		return
	var has_next := bool(snapshot.get("has_next_stage", false))
	_info_panel.visible = is_reward_decision and has_next
	if not _info_panel.visible:
		return

	_next_win_label.text = Data.text("decision_next_win", {
		"payout": int(snapshot.get("next_stage_payout", 0))
	})
	_odds_label.text = Data.text("decision_next_odds", {
		"multiplier": _format_multiplier(float(snapshot.get("next_stage_multiplier", 0.0)))
	})
	var next_stage := int(snapshot.get("stage_to_challenge", 1))
	var max_level := Data.danger_max_level()
	var level := Data.danger_level_at(next_stage)
	var icons_ok := max_level > 0 and UiSkin.fill_danger_icons(_danger_icons, level, max_level, 36.0)
	_danger_icons.visible = icons_ok
	if icons_ok:
		_danger_caption.text = Data.text("monster_danger_caption")
	elif max_level > 0:
		_danger_caption.text = Data.text("monster_danger_fallback", {
			"stars": "★".repeat(level) + "☆".repeat(maxi(0, max_level - level))
		})
	else:
		_danger_caption.text = ""


func update_snapshot(snapshot: Dictionary) -> void:
	var is_reward_decision := bool(snapshot.get("is_reward_decision", false))
	_update_next_info(snapshot, is_reward_decision)
	if not _cashout_is_art:
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


## 倍率顯示：最多兩位小數、去尾零（同 hud.gd 慣例）。
func _format_multiplier(value: float) -> String:
	var text := String.num(value, 2)
	if text.contains("."):
		text = text.rstrip("0").rstrip(".")
	return text


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
