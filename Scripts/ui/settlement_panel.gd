class_name SettlementPanel
extends Control

const ButtonFeedback := preload("res://Scripts/effects/button_feedback.gd")
const SettlementEffect := preload("res://Scripts/effects/settlement_effect.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

const ACCENT_PINK := "#e8447a"
const ACCENT_TEAL := "#1f9e94"
const STAT_TEXT := Color(0.29, 0.23, 0.26, 1.0)
const STAT_MUTED := Color(0.5, 0.42, 0.45, 1.0)

signal acknowledge_requested
signal leaderboard_requested

@onready var panel: PanelContainer = $Panel
@onready var title_row: HBoxContainer = $Panel/Margin/Layout/TitleRow
@onready var title_label: Label = $Panel/Margin/Layout/TitleRow/TitleLabel
@onready var paw_left: TextureRect = $Panel/Margin/Layout/TitleRow/PawLeft
@onready var paw_right: TextureRect = $Panel/Margin/Layout/TitleRow/PawRight
@onready var body_label: RichTextLabel = $Panel/Margin/Layout/BodyLabel
# 戰敗版統計：三張並排小卡（target: ui_target_lb_defeat）
@onready var stats_cards: HBoxContainer = $Panel/Margin/Layout/StatsCards
@onready var depth_card: PanelContainer = $Panel/Margin/Layout/StatsCards/DepthCard
@onready var depth_icon: TextureRect = $Panel/Margin/Layout/StatsCards/DepthCard/DepthRow/DepthIcon
@onready var depth_caption: Label = $Panel/Margin/Layout/StatsCards/DepthCard/DepthRow/DepthBox/DepthCaption
@onready var depth_value: RichTextLabel = $Panel/Margin/Layout/StatsCards/DepthCard/DepthRow/DepthBox/DepthValue
@onready var beaten_card: PanelContainer = $Panel/Margin/Layout/StatsCards/BeatenCard
@onready var beaten_icon: TextureRect = $Panel/Margin/Layout/StatsCards/BeatenCard/BeatenRow/BeatenIcon
@onready var beaten_caption: Label = $Panel/Margin/Layout/StatsCards/BeatenCard/BeatenRow/BeatenBox/BeatenCaption
@onready var beaten_value: RichTextLabel = $Panel/Margin/Layout/StatsCards/BeatenCard/BeatenRow/BeatenBox/BeatenValue
@onready var best_card: PanelContainer = $Panel/Margin/Layout/StatsCards/BestCard
@onready var best_icon: TextureRect = $Panel/Margin/Layout/StatsCards/BestCard/BestRow/BestIcon
@onready var best_caption: Label = $Panel/Margin/Layout/StatsCards/BestCard/BestRow/BestBox/BestCaption
@onready var best_value: RichTextLabel = $Panel/Margin/Layout/StatsCards/BestCard/BestRow/BestBox/BestValue
# 撤退/通關版統計：雙欄框（target: ui_target_lb_cashout）
@onready var stats_duo: PanelContainer = $Panel/Margin/Layout/StatsDuo
@onready var rank_icon: TextureRect = $Panel/Margin/Layout/StatsDuo/DuoRow/RankIcon
@onready var rank_line: RichTextLabel = $Panel/Margin/Layout/StatsDuo/DuoRow/RankBox/RankLine
@onready var rank_sub: RichTextLabel = $Panel/Margin/Layout/StatsDuo/DuoRow/RankBox/RankSub
@onready var record_icon: TextureRect = $Panel/Margin/Layout/StatsDuo/DuoRow/RecordIcon
@onready var record_line: RichTextLabel = $Panel/Margin/Layout/StatsDuo/DuoRow/RecordBox/RecordLine
@onready var record_sub: RichTextLabel = $Panel/Margin/Layout/StatsDuo/DuoRow/RecordBox/RecordSub
@onready var play_again_button: Button = $Panel/Margin/Layout/PlayAgainButton
@onready var leaderboard_button: Button = $Panel/Margin/Layout/LeaderboardButton

var _last_settle_state := ""
var _leaderboard_service
var _last_snapshot := {}
var _rank_step := ""
var _lb_button_style := ""
# D-019 FOMO 事後揭示行（撤退：若再過一關可得…／戰敗：上一關落袋…）。程式生成，不動 .tscn。
var _fomo_label: RichTextLabel
var _outcome_label: Label


func _ready() -> void:
	_build_fomo_label()
	_build_outcome_label()
	# D-019 微調（2026-07-08 人類指示）：FOMO 行加入後內容變高，看板上緣上移擴容、
	# 下緣抬高留邊（原 tscn 60/588 → 12/566，免貼底）；統計 icon 放大 1.2 倍。
	# ActionArea 的全域起點是 y=1300；負 offset 把結果卡移到 result.jpg 的中央區。
	panel.offset_left = 120.0
	panel.offset_right = 864.0
	panel.offset_top = -720.0
	panel.offset_bottom = 18.0
	for stat_icon: TextureRect in [depth_icon, beaten_icon, best_icon, rank_icon, record_icon]:
		stat_icon.custom_minimum_size = Vector2(65, 65)
	UiSkin.apply_panel(panel, "settle")
	# 文字必須先設好再套樣式：icon 對齊方式依「當下有無文字」決定（空字=置中會疊字）
	play_again_button.text = Data.text("settle_play_again")
	leaderboard_button.text = Data.text("lb_view_entry")
	UiSkin.apply_button(play_again_button, "settle_primary")
	title_label.text = Data.text("settle_result_title")
	UiSkin.apply_ribbon_label(title_label)
	body_label.add_theme_color_override("default_color", Color(0.24, 0.19, 0.23, 1.0))
	for paw: TextureRect in [paw_left, paw_right]:
		UiSkin.apply_icon(paw, "paw")
		paw.modulate = Color(0.96, 0.25, 0.42, 1.0)
	# 統計卡外框與文字（icon 以現有貼紙近似，人類 2026-07-07 裁示）
	for card: PanelContainer in [depth_card, beaten_card, best_card, stats_duo]:
		UiSkin.apply_panel(card, "stat_card")
	UiSkin.apply_icon(depth_icon, "stage")
	UiSkin.apply_icon(beaten_icon, "paw")
	UiSkin.apply_icon(best_icon, "trophy")
	UiSkin.apply_icon(rank_icon, "trophy")
	UiSkin.apply_icon(record_icon, "coin")
	for caption: Label in [depth_caption, beaten_caption, best_caption]:
		caption.add_theme_color_override("font_color", STAT_MUTED)
	for rich: RichTextLabel in [depth_value, beaten_value, best_value, rank_line, record_line]:
		rich.add_theme_color_override("default_color", STAT_TEXT)
	for rich: RichTextLabel in [rank_sub, record_sub]:
		rich.add_theme_color_override("default_color", STAT_MUTED)
	depth_caption.text = Data.text("lb_stat_depth_caption")
	beaten_caption.text = Data.text("lb_stat_beaten_caption")
	best_caption.text = Data.text("lb_stat_best_caption")
	_install_button_feedback(play_again_button)
	_install_button_feedback(leaderboard_button)
	play_again_button.pressed.connect(func() -> void: acknowledge_requested.emit())
	leaderboard_button.pressed.connect(func() -> void: leaderboard_requested.emit())


func update_snapshot(snapshot: Dictionary) -> void:
	var state_name := str(snapshot.get("state_name", ""))
	_last_snapshot = snapshot
	var is_settle := bool(snapshot.get("is_settle", false))
	var is_defeat := state_name == "DEFEAT_SETTLE"
	play_again_button.disabled = not is_settle
	stats_cards.visible = is_settle and is_defeat
	stats_duo.visible = is_settle and not is_defeat
	leaderboard_button.visible = is_settle
	# target：戰敗版「查看排行榜」是文字連結，撤退版是膠囊
	_apply_lb_button_style("settle_link" if is_defeat else "settle_pill")
	_bind_leaderboard_service(snapshot.get("leaderboard_service", null))

	match state_name:
		"CASH_OUT_SETTLE":
			_outcome_label.text = Data.text("settle_cashout_title")
			_set_body(Data.text("settle_cashout_body", {
				"payout": _accent(int(snapshot.get("current_payout", 0)))
			}))
		"DEFEAT_SETTLE":
			_outcome_label.text = Data.text("settle_defeat_title")
			_set_body(Data.text("settle_defeat_body", {
				"bet": _accent(int(snapshot.get("bet", 0)))
			}))
		"CLEAR_SETTLE":
			_outcome_label.text = Data.text("settle_clear_title")
			_set_body(Data.text("settle_clear_body", {
				"payout": _accent(int(snapshot.get("current_payout", 0)))
			}))
	_update_fomo_line(state_name, snapshot)
	_update_leaderboard_stats(state_name, snapshot)

	if is_settle and state_name != _last_settle_state:
		_last_settle_state = state_name
		_play_settlement_effect(state_name)
	elif not is_settle:
		_last_settle_state = ""


func _build_fomo_label() -> void:
	_fomo_label = RichTextLabel.new()
	_fomo_label.name = "FomoLabel"
	_fomo_label.bbcode_enabled = true
	_fomo_label.fit_content = true
	_fomo_label.scroll_active = false
	# HBox/VBox 內 RichTextLabel 不給水平 expand 會塌成一字一行（見 2026-07-07 教訓）
	_fomo_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fomo_label.add_theme_color_override("default_color", STAT_MUTED)
	_fomo_label.add_theme_font_size_override("normal_font_size", 30)
	_fomo_label.visible = false
	var layout := body_label.get_parent()
	layout.add_child(_fomo_label)
	layout.move_child(_fomo_label, body_label.get_index() + 1)


func _build_outcome_label() -> void:
	_outcome_label = Label.new()
	_outcome_label.name = "OutcomeLabel"
	_outcome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outcome_label.add_theme_font_size_override("font_size", 46)
	UiSkin.apply_hud_card_text(_outcome_label, "board_value_pink")
	var layout := body_label.get_parent()
	layout.add_child(_outcome_label)
	layout.move_child(_outcome_label, body_label.get_index())


## D-019 FOMO 行：撤退＝下一關若過可得多少；戰敗＝上一關收手可帶走多少。
## 邊界（通關、無下一關、第 1 關即戰死）整行隱藏，不出現空佔位。
func _update_fomo_line(state_name: String, snapshot: Dictionary) -> void:
	if _fomo_label == null or not is_instance_valid(_fomo_label):
		return
	var fomo_text := ""
	match state_name:
		"CASH_OUT_SETTLE":
			var next_payout := int(snapshot.get("next_stage_payout", 0))
			if bool(snapshot.get("has_next_stage", false)) and next_payout > 0:
				fomo_text = Data.text("settle_cashout_fomo", {
					"next_payout": _accent(next_payout)
				})
		"DEFEAT_SETTLE":
			# stage = 已清關數；0 表示第 1 關就戰死，沒有「上一關落袋」可言
			var lost_payout := int(snapshot.get("defeat_payout_before_loss", 0))
			if int(snapshot.get("stage", 0)) > 0 and lost_payout > 0:
				fomo_text = Data.text("settle_defeat_fomo", {
					"payout": _accent(lost_payout)
				})
	_fomo_label.visible = not fomo_text.is_empty()
	if _fomo_label.visible:
		_fomo_label.text = "[center]%s[/center]" % fomo_text


## 內文金額：粉紅高亮（同字級）
func _accent(value: int) -> String:
	return "[color=%s]%d[/color]" % [ACCENT_PINK, value]


## 統計數字：放大 + 上色（target：數字為視覺主角）
func _big(value: String, color: String = ACCENT_PINK, size: int = 40) -> String:
	return "[font_size=%d][color=%s]%s[/color][/font_size]" % [size, color, value]


func _set_body(text: String) -> void:
	body_label.text = "[center]%s[/center]" % text


func _center(rich: RichTextLabel, text: String) -> void:
	rich.text = "[center]%s[/center]" % text


func _apply_lb_button_style(style: String) -> void:
	if style == _lb_button_style:
		return
	_lb_button_style = style
	UiSkin.apply_button(leaderboard_button, style)


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
	return [title_row, body_label, _fomo_label, stats_cards, stats_duo, play_again_button, leaderboard_button]


func _bind_leaderboard_service(service) -> void:
	if service == _leaderboard_service:
		return
	if _leaderboard_service != null and _leaderboard_service.rank_loaded.is_connected(_on_rank_loaded):
		_leaderboard_service.rank_loaded.disconnect(_on_rank_loaded)
	_leaderboard_service = service
	if _leaderboard_service != null and not _leaderboard_service.rank_loaded.is_connected(_on_rank_loaded):
		_leaderboard_service.rank_loaded.connect(_on_rank_loaded)


func _update_leaderboard_stats(state_name: String, snapshot: Dictionary) -> void:
	if not bool(snapshot.get("is_settle", false)):
		return
	var loading := Data.text("lb_loading")
	if state_name == "DEFEAT_SETTLE":
		_center(depth_value, Data.text("lb_stat_depth_value", {
			"stage": _big(str(int(snapshot.get("run_deepest_stage", 0)))),
			"max": int(snapshot.get("max_stage", 0))
		}))
		_center(beaten_value, loading)
		_center(best_value, loading)
	else:
		rank_line.text = loading
		rank_sub.text = ""
		record_line.text = Data.text("lb_stat_record_line", {
			"payout": _big(str(int(snapshot.get("best_payout", 0))), ACCENT_PINK, 34)
		})
		record_sub.text = Data.text("lb_stat_record_sub")
	if _leaderboard_service == null:
		return
	_rank_step = "result"
	var compare_payout := int(snapshot.get("defeat_payout_before_loss", 0)) if state_name == "DEFEAT_SETTLE" else int(snapshot.get("settlement_payout", snapshot.get("current_payout", 0)))
	_leaderboard_service.request_rank_for(compare_payout)


func _on_rank_loaded(rank: int, beaten_percent: int) -> void:
	if not bool(_last_snapshot.get("is_settle", false)):
		return
	var is_defeat := str(_last_snapshot.get("state_name", "")) == "DEFEAT_SETTLE"
	if _rank_step == "result":
		if is_defeat:
			_center(beaten_value, Data.text("lb_stat_beaten_value", {
				"percent": _big("%d%%" % beaten_percent, ACCENT_TEAL)
			}))
		else:
			rank_line.text = Data.text("lb_stat_rank_line", {
				"rank": _big(str(rank), ACCENT_PINK, 34)
			})
			rank_sub.text = Data.text("lb_stat_rank_sub", {
				"percent": "[color=%s]%d%%[/color]" % [ACCENT_PINK, beaten_percent]
			})
		_rank_step = "best"
		if _leaderboard_service != null:
			_leaderboard_service.request_rank_for(int(_last_snapshot.get("best_payout", 0)))
	elif _rank_step == "best":
		if is_defeat:
			_center(best_value, Data.text("lb_stat_best_value", {
				"rank": _big(str(rank))
			}))
		_rank_step = ""
