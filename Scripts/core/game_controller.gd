extends Node2D

const EventBusScript := preload("res://Scripts/core/event_bus.gd")
const GameStateMachineScript := preload("res://Scripts/core/game_state_machine.gd")
const OnlineScoreServiceScript := preload("res://Scripts/services/online_score_service.gd")
const MockLeaderboardServiceScript := preload("res://Scripts/services/mock_leaderboard_service.gd")
const FirebaseLeaderboardServiceScript := preload("res://Scripts/services/firebase_leaderboard_service.gd")
const AudioServiceScript := preload("res://Scripts/services/audio_service.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")
const CoinBurstScript := preload("res://Scripts/effects/coin_burst.gd")
const WinBannerScript := preload("res://Scripts/effects/win_banner.gd")

@onready var title_screen: Control = $UILayer/TitleScreen
@onready var battle_presenter = $BattleScene
@onready var title_label: Label = $UILayer/TitleScreen/TitleLayout/TitleLabel
@onready var best_record_label: Label = $UILayer/TitleScreen/TitleLayout/BestRecordLabel
@onready var start_button: Button = $UILayer/TitleScreen/TitleLayout/StartButton
@onready var login_button: Button = $UILayer/TitleScreen/TitleLayout/LoginButton
@onready var vertical_ui: VerticalUi = $UILayer/VerticalUi

var event_bus := EventBusScript.new()
var state_machine := GameStateMachineScript.new()
# D-015：OnlineScoreService 繼承 LocalScoreService——非 Web/未登入/橋接缺失時
# 行為與純本機完全相同（fallback 契約見 Docs/08 §五）。
var score_service := OnlineScoreServiceScript.new()
# D-016 §4 / Codex 17：Web 且橋接可用才用 Firebase 實作，否則 Mock（同一介面，UI 零修改）。
var leaderboard_service
var audio_service := AudioServiceScript.new()
var _run_deepest_stage := 0
var _defeat_payout_before_loss := 0
var _last_settlement_payout := 0
var _active_win_banner: WinBanner


func _ready() -> void:
	add_child(event_bus)
	add_child(audio_service)
	score_service.setup_bridge()
	score_service.auth_changed.connect(_on_auth_changed)
	score_service.cloud_merged.connect(_on_cloud_merged)
	leaderboard_service = FirebaseLeaderboardServiceScript.new() if score_service.is_online_available() else MockLeaderboardServiceScript.new()
	leaderboard_service.setup(score_service)
	state_machine.setup(event_bus, score_service)
	_connect_events()
	_connect_buttons()
	_connect_battle_presenter()
	_apply_static_text()

	if not state_machine.start():
		return

	_update_view()


func _connect_events() -> void:
	event_bus.state_changed.connect(_on_state_changed)
	event_bus.balance_changed.connect(_on_balance_changed)
	event_bus.bet_changed.connect(_on_bet_changed)
	event_bus.stage_advanced.connect(_on_stage_advanced)
	event_bus.result_resolved.connect(_on_result_resolved)
	event_bus.settled.connect(_on_settled)


func _connect_buttons() -> void:
	start_button.pressed.connect(_on_start_pressed)
	login_button.pressed.connect(_on_login_pressed)
	vertical_ui.bet_decrease_requested.connect(_on_decrease_pressed)
	vertical_ui.bet_increase_requested.connect(_on_increase_pressed)
	vertical_ui.bet_confirm_requested.connect(_on_confirm_bet_pressed)
	vertical_ui.quick_bet_requested.connect(_on_quick_bet_requested)
	vertical_ui.cashout_requested.connect(_on_cashout_pressed)
	vertical_ui.advance_requested.connect(_on_advance_pressed)
	vertical_ui.settle_acknowledged.connect(_on_settle_pressed)
	vertical_ui.balance_reset_requested.connect(_on_balance_reset_pressed)


func _connect_battle_presenter() -> void:
	battle_presenter.attack_sequence_finished.connect(_on_attack_sequence_finished)
	battle_presenter.monster_hurt_finished.connect(_on_monster_hurt_finished)
	battle_presenter.monster_death_finished.connect(_on_monster_death_finished)
	battle_presenter.advance_walk_finished.connect(_on_advance_walk_finished)
	battle_presenter.transition_finished.connect(_on_transition_finished)
	battle_presenter.monster_counter_finished.connect(_on_monster_counter_finished)
	battle_presenter.player_hurt_finished.connect(_on_player_hurt_finished)
	battle_presenter.hit_landed.connect(_on_hit_landed)


func _apply_static_text() -> void:
	title_label.text = Data.text("title_game_name")
	_update_best_record_text()
	start_button.text = Data.text("title_tap_to_start")
	_update_auth_ui()
	UiSkin.apply_button(login_button, "login")
	_style_title_screen()


## 標題畫面美術化（夜間 UI 輪 2026-07-08）：戰鬥背景＋暗角、Logo 取代文字標題、
## 緞帶紀錄、樣式化開始鈕。全程式生成不動 .tscn；素材缺檔逐項退回原樣（D-004）。
func _style_title_screen() -> void:
	var background := _title_background_texture()
	if background != null:
		var backdrop: Control = title_screen.get_node("TitleBackground")
		var bg_rect := TextureRect.new()
		bg_rect.name = "TitleArtBackground"
		bg_rect.texture = background
		bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		backdrop.add_child(bg_rect)
		# 暗角壓一層，讓中央文字/按鈕在花背景上仍可讀
		var vignette := ColorRect.new()
		vignette.name = "TitleVignette"
		vignette.color = Color(0.05, 0.08, 0.16, 0.30)
		vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
		vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
		backdrop.add_child(vignette)

	var layout := title_label.get_parent() as VBoxContainer
	if layout != null:
		layout.alignment = BoxContainer.ALIGNMENT_CENTER
		layout.add_theme_constant_override("separation", 30)
		layout.offset_top = -380.0
		layout.offset_bottom = 380.0

	var logo_texture: Texture2D = UiSkin.art_texture("logo")
	if logo_texture != null and layout != null:
		var logo_rect := TextureRect.new()
		logo_rect.name = "TitleLogo"
		logo_rect.texture = logo_texture
		logo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo_rect.custom_minimum_size = Vector2(0.0, 380.0)
		layout.add_child(logo_rect)
		layout.move_child(logo_rect, 0)
		title_label.visible = false
	else:
		UiSkin.apply_title_label(title_label)

	best_record_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	UiSkin.apply_ribbon_label(best_record_label)
	for entry_button: Button in [start_button, login_button]:
		entry_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		entry_button.custom_minimum_size = Vector2(560.0, entry_button.custom_minimum_size.y)
	UiSkin.apply_button(start_button, "settle_primary")


func _title_background_texture() -> Texture2D:
	var background_config := Data.background_zones_config()
	var background_id := str(background_config.get("default_background_id", ""))
	if background_id.is_empty():
		return null
	for extension: String in [".jpg", ".jpeg", ".png"]:
		var path := "res://Assets/final/%s%s" % [background_id, extension]
		if ResourceLoader.exists(path, "Texture2D"):
			return load(path) as Texture2D
	return null


func _on_start_pressed() -> void:
	audio_service.play_sfx("button_click")
	state_machine.start_from_title()
	_update_view()


func _on_login_pressed() -> void:
	if score_service.is_signed_in():
		score_service.sign_out()
	else:
		score_service.sign_in()
	audio_service.play_sfx("button_click")
	_update_auth_ui()


func _on_decrease_pressed() -> void:
	audio_service.play_sfx("button_click")
	state_machine.change_bet_steps(-1)
	_update_view()


func _on_increase_pressed() -> void:
	audio_service.play_sfx("button_click")
	state_machine.change_bet_steps(1)
	_update_view()


func _on_quick_bet_requested(amount: int) -> void:
	audio_service.play_sfx("button_click")
	state_machine.set_bet(amount)
	_update_view()


func _on_confirm_bet_pressed() -> void:
	audio_service.play_sfx("bet_confirm")
	state_machine.confirm_bet()
	_update_view()


func _on_cashout_pressed() -> void:
	audio_service.play_sfx("button_click")
	state_machine.cash_out()
	_update_view()


func _on_advance_pressed() -> void:
	audio_service.play_sfx("advance")
	state_machine.advance()
	_update_view()


func _on_settle_pressed() -> void:
	audio_service.play_sfx("button_click")
	state_machine.acknowledge_settle()
	_update_view()


func _on_balance_reset_pressed() -> void:
	audio_service.play_sfx("balance_reset")
	state_machine.reset_balance_to_starting()
	_update_view()


func _on_state_changed(state_name: String) -> void:
	if state_name == "BETTING":
		_reset_run_stats()
		_clear_active_win_banner()
	elif state_name == "BATTLE_ATTACK":
		_run_deepest_stage = maxi(_run_deepest_stage, state_machine.active_monster_stage)
	_try_apply_cloud_balance()
	_update_view()
	_play_presentation_for_state(state_name)


func _on_balance_changed(_balance: int) -> void:
	_update_view()


func _on_bet_changed(_bet: int) -> void:
	_update_view()


func _on_stage_advanced(stage: int, multiplier: float, payout: int) -> void:
	print("Stage advanced: stage=%d multiplier=%s payout=%d" % [stage, multiplier, payout])
	_run_deepest_stage = maxi(_run_deepest_stage, stage)
	_update_view()


func _on_result_resolved(is_win: bool) -> void:
	print("Result resolved: is_win=%s" % is_win)
	if not is_win:
		_run_deepest_stage = maxi(_run_deepest_stage, state_machine.active_monster_stage)
		_defeat_payout_before_loss = state_machine.current_payout
	_update_view()


func _on_settled(result: String) -> void:
	print("Settled: %s balance=%d" % [result, state_machine.balance])
	_last_settlement_payout = _defeat_payout_before_loss if result == "defeat" else state_machine.current_payout
	if result == "cash_out":
		leaderboard_service.submit_best(state_machine.current_payout)
	_play_settlement_sfx(result)
	_update_best_record_text()
	_update_view()
	_show_win_banner_if_needed(result)


func _on_attack_sequence_finished(hit_count: int) -> void:
	print("Attack sequence finished: hit_count=%d" % hit_count)
	state_machine.finish_attack()


func _on_hit_landed() -> void:
	audio_service.play_sfx("attack_hit")


func _on_monster_hurt_finished() -> void:
	state_machine.finish_monster_hurt()


func _on_monster_death_finished() -> void:
	audio_service.play_sfx("monster_death")
	state_machine.finish_monster_death()


func _on_advance_walk_finished() -> void:
	state_machine.finish_advance_walk()


func _on_transition_finished() -> void:
	state_machine.finish_transition()


func _on_monster_counter_finished() -> void:
	state_machine.finish_monster_counter()


func _on_player_hurt_finished() -> void:
	state_machine.finish_player_hurt()


func _play_presentation_for_state(state_name: String) -> void:
	match state_name:
		"BETTING":
			battle_presenter.reset_for_betting()
		"BATTLE_ATTACK":
			battle_presenter.play_attack_sequence(state_machine.stage_to_challenge())
		"MONSTER_HURT":
			battle_presenter.play_monster_hurt()
		"MONSTER_DEATH":
			_play_monster_death_with_coin_burst()
		"ADVANCE_WALK":
			battle_presenter.play_advance_walk()
		"TRANSITION":
			battle_presenter.play_transition(state_machine.stage_to_challenge())
		"MONSTER_COUNTER":
			battle_presenter.play_monster_counter()
		"PLAYER_HURT":
			battle_presenter.play_player_hurt()


func _play_settlement_sfx(result: String) -> void:
	match result:
		"cash_out":
			audio_service.play_sfx("cashout")
		"defeat":
			audio_service.play_sfx("defeat")
		"clear":
			audio_service.play_sfx("clear")


func _play_monster_death_with_coin_burst() -> void:
	var burst := CoinBurstScript.new()
	add_child(burst)
	vertical_ui.hold_payout_count_up(burst.max_hold())
	battle_presenter.play_monster_death()

	var started: bool = burst.play(
		battle_presenter.monster_canvas_position(),
		vertical_ui.payout_anchor_canvas_position(),
		state_machine.current_multiplier,
		func() -> void:
			if vertical_ui != null and is_instance_valid(vertical_ui):
				vertical_ui.release_payout_count_up()
	)
	if not started:
		vertical_ui.release_payout_count_up()
		if burst != null and is_instance_valid(burst):
			burst.queue_free()


func _show_win_banner_if_needed(result: String) -> void:
	if result not in ["cash_out", "clear"]:
		return
	if _last_settlement_payout <= 0:
		return
	_clear_active_win_banner()
	var banner := WinBannerScript.new()
	_active_win_banner = banner
	add_child(banner)
	banner.dismissed.connect(func() -> void:
		if _active_win_banner == banner:
			_active_win_banner = null
	)
	if not banner.play(_last_settlement_payout):
		_active_win_banner = null


func _clear_active_win_banner() -> void:
	if _active_win_banner == null:
		return
	if is_instance_valid(_active_win_banner):
		_active_win_banner.queue_free()
	_active_win_banner = null


func _update_view() -> void:
	if not is_node_ready():
		return

	var state_name := state_machine.state_name()
	title_screen.visible = state_machine.is_title()
	vertical_ui.visible = not state_machine.is_title()
	_update_auth_ui()
	vertical_ui.update_snapshot(_ui_snapshot(state_name))
	_update_best_record_text()


func _update_best_record_text() -> void:
	if not is_node_ready():
		return
	best_record_label.text = Data.text("best_record", {
		"payout": score_service.get_best_payout()
	})


func _ui_snapshot(state_name: String) -> Dictionary:
	var balance_config := Data.balance_config()
	return {
		"state_name": state_name,
		"balance": state_machine.balance,
		"bet": state_machine.bet,
		"stage": state_machine.stage,
		"stage_to_challenge": state_machine.stage_to_challenge(),
		"active_monster_stage": state_machine.active_monster_stage,
		"max_stage": state_machine.max_stage(),
		"current_multiplier": state_machine.current_multiplier,
		"current_payout": state_machine.current_payout,
		"next_stage_multiplier": state_machine.next_stage_multiplier,
		"next_stage_payout": state_machine.next_stage_payout,
		"has_next_stage": state_machine.stage < state_machine.max_stage(),
		"min_bet": int(balance_config.get("min_bet", 0)),
		"max_bet": int(balance_config.get("max_bet", 0)),
		"bet_step": int(balance_config.get("bet_step", 0)),
		"is_betting": state_machine.is_betting(),
		"is_reward_decision": state_machine.is_reward_decision(),
		"is_settle": state_machine.is_settle(),
		"is_bet_affordable": state_machine.is_bet_affordable(),
		"is_balance_below_min_bet": state_machine.is_balance_below_min_bet(),
		"best_payout": score_service.get_best_payout(),
		"can_advance": state_machine.can_advance(),
		"run_deepest_stage": _run_deepest_stage,
		"defeat_payout_before_loss": _defeat_payout_before_loss,
		"settlement_payout": _last_settlement_payout,
		"leaderboard_service": leaderboard_service
	}


func _update_auth_ui() -> void:
	if not is_node_ready():
		return
	var online_available := score_service.is_online_available()
	var signed_in := score_service.is_signed_in()
	login_button.visible = online_available
	login_button.text = Data.text("logout_button" if signed_in else "login_button")
	vertical_ui.set_profile_auth_state(signed_in, score_service.online_display_name())


# --- D-015 線上分數（UI 接點見 Codex/14；本層只做狀態同步，不做版面） ---

func _on_auth_changed(_signed_in: bool, _display_name: String) -> void:
	_update_auth_ui()
	_update_view()


func _on_cloud_merged() -> void:
	_try_apply_cloud_balance()
	_update_auth_ui()
	_update_view()


## 雲端餘額只在局外（BETTING）套用，避免覆寫進行中的一局（Docs/08 §五）。
func _try_apply_cloud_balance() -> void:
	if not score_service.has_pending_cloud_balance():
		return
	if not state_machine.is_betting():
		return
	score_service.apply_pending_cloud_balance()
	state_machine.refresh_balance_from_service()


func _reset_run_stats() -> void:
	_run_deepest_stage = 0
	_defeat_payout_before_loss = 0
	_last_settlement_payout = 0
