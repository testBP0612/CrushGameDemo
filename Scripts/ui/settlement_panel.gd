class_name SettlementPanel
extends Control

const ButtonFeedback := preload("res://Scripts/effects/button_feedback.gd")
const SettlementEffect := preload("res://Scripts/effects/settlement_effect.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

signal acknowledge_requested
signal leaderboard_requested

@onready var title_row: HBoxContainer = $Panel/Margin/Layout/TitleRow
@onready var title_label: Label = $Panel/Margin/Layout/TitleRow/TitleLabel
@onready var paw_left: TextureRect = $Panel/Margin/Layout/TitleRow/PawLeft
@onready var paw_right: TextureRect = $Panel/Margin/Layout/TitleRow/PawRight
@onready var body_label: RichTextLabel = $Panel/Margin/Layout/BodyLabel
@onready var play_again_button: Button = $Panel/Margin/Layout/PlayAgainButton
@onready var panel: PanelContainer = $Panel
@onready var stats_box: VBoxContainer = $Panel/Margin/Layout/StatsBox
@onready var rank_label: Label = $Panel/Margin/Layout/StatsBox/RankLabel
@onready var beaten_label: Label = $Panel/Margin/Layout/StatsBox/BeatenLabel
@onready var best_label: Label = $Panel/Margin/Layout/StatsBox/BestLabel
@onready var leaderboard_button: Button = $Panel/Margin/Layout/LeaderboardButton

var _last_settle_state := ""
var _leaderboard_service
var _last_snapshot := {}
var _rank_step := ""
var _pending_beaten_percent := 0
var _pending_result_rank := 0


func _ready() -> void:
	UiSkin.apply_panel(panel, "settle")
	UiSkin.apply_button(play_again_button, "settle_primary")
	UiSkin.apply_settle_title(title_label)
	# 內文深炭色字，數字用 bbcode 粉紅高亮（見 _accent）
	body_label.add_theme_color_override("default_color", Color(0.24, 0.19, 0.23, 1.0))
	# 排行統計為配角：小字、柔和棕灰
	for stat_label: Label in [rank_label, beaten_label, best_label]:
		stat_label.add_theme_color_override("font_color", Color(0.5, 0.42, 0.45, 1.0))
	# 目標圖：標題左右各一顆粉紅掌印
	for paw: TextureRect in [paw_left, paw_right]:
		UiSkin.apply_icon(paw, "paw")
		paw.modulate = Color(0.96, 0.25, 0.42, 1.0)
	play_again_button.text = Data.text("settle_play_again")
	leaderboard_button.text = Data.text("lb_view_entry")
	UiSkin.apply_button(leaderboard_button, "small")
	_install_button_feedback(play_again_button)
	_install_button_feedback(leaderboard_button)
	play_again_button.pressed.connect(func() -> void: acknowledge_requested.emit())
	leaderboard_button.pressed.connect(func() -> void: leaderboard_requested.emit())


func update_snapshot(snapshot: Dictionary) -> void:
	var state_name := str(snapshot.get("state_name", ""))
	_last_snapshot = snapshot
	play_again_button.disabled = not bool(snapshot.get("is_settle", false))
	stats_box.visible = bool(snapshot.get("is_settle", false))
	leaderboard_button.visible = bool(snapshot.get("is_settle", false))
	_bind_leaderboard_service(snapshot.get("leaderboard_service", null))

	match state_name:
		"CASH_OUT_SETTLE":
			title_label.text = Data.text("settle_cashout_title")
			_set_body(Data.text("settle_cashout_body", {
				"payout": _accent(int(snapshot.get("current_payout", 0)))
			}))
		"DEFEAT_SETTLE":
			title_label.text = Data.text("settle_defeat_title")
			_set_body(Data.text("settle_defeat_body", {
				"bet": _accent(int(snapshot.get("bet", 0)))
			}))
		"CLEAR_SETTLE":
			title_label.text = Data.text("settle_clear_title")
			_set_body(Data.text("settle_clear_body", {
				"payout": _accent(int(snapshot.get("current_payout", 0)))
			}))
	_update_leaderboard_stats(state_name, snapshot)

	if bool(snapshot.get("is_settle", false)) and state_name != _last_settle_state:
		_last_settle_state = state_name
		_play_settlement_effect(state_name)
	elif not bool(snapshot.get("is_settle", false)):
		_last_settle_state = ""


## 數字粉紅高亮（文案模板仍在 ui_text.json，僅代入值加 bbcode 色標）
func _accent(value: int) -> String:
	return "[color=#e8447a]%d[/color]" % value


func _set_body(text: String) -> void:
	body_label.text = "[center]%s[/center]" % text


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
	return [title_row, body_label, stats_box, leaderboard_button, play_again_button]


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
	if state_name == "DEFEAT_SETTLE":
		rank_label.text = Data.text("lb_defeat_depth", {
			"stage": int(snapshot.get("run_deepest_stage", 0)),
			"max": int(snapshot.get("max_stage", 0))
		})
	else:
		rank_label.text = Data.text("lb_loading")
	beaten_label.text = Data.text("lb_loading")
	best_label.text = Data.text("lb_result_personal_best", {
		"payout": int(snapshot.get("best_payout", 0))
	})
	if _leaderboard_service == null:
		return
	_rank_step = "result"
	var compare_payout := int(snapshot.get("defeat_payout_before_loss", 0)) if state_name == "DEFEAT_SETTLE" else int(snapshot.get("settlement_payout", snapshot.get("current_payout", 0)))
	_leaderboard_service.request_rank_for(compare_payout)


func _on_rank_loaded(rank: int, beaten_percent: int) -> void:
	if not bool(_last_snapshot.get("is_settle", false)):
		return
	if _rank_step == "result":
		_pending_result_rank = rank
		_pending_beaten_percent = beaten_percent
		if str(_last_snapshot.get("state_name", "")) != "DEFEAT_SETTLE":
			rank_label.text = Data.text("lb_result_rank", {"rank": rank})
		beaten_label.text = Data.text("lb_result_beaten", {"percent": beaten_percent})
		_rank_step = "best"
		if _leaderboard_service != null:
			_leaderboard_service.request_rank_for(int(_last_snapshot.get("best_payout", 0)))
	elif _rank_step == "best":
		if str(_last_snapshot.get("state_name", "")) == "DEFEAT_SETTLE":
			best_label.text = Data.text("lb_current_best_rank", {"rank": rank})
		else:
			best_label.text = Data.text("lb_result_personal_best", {
				"payout": int(_last_snapshot.get("best_payout", 0))
			})
		_rank_step = ""
