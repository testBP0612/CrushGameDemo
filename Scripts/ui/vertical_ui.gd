class_name VerticalUi
extends Control

const UiEntrance := preload("res://Scripts/effects/ui_entrance.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")
const LeaderboardPanelScript := preload("res://Scripts/ui/leaderboard_panel.gd")

signal bet_decrease_requested
signal bet_increase_requested
signal bet_confirm_requested
signal quick_bet_requested(amount: int)
signal cashout_requested
signal advance_requested
signal settle_acknowledged
signal balance_reset_requested
signal leaderboard_requested

@onready var hud: Hud = $Hud
@onready var top_bar: Control = $TopBar
@onready var player_id_label: Label = $TopBar/PlayerIdRow/PlayerIdLabel
@onready var player_cloud_icon: TextureRect = $TopBar/PlayerIdRow/PlayerCloudIcon
@onready var money_card: TextureRect = $TopBar/MoneyCard
@onready var money_value: Label = $TopBar/MoneyValue
@onready var logo_label: Label = $TopBar/LogoLabel
@onready var logo_rect: TextureRect = $TopBar/LogoRect
@onready var battle_message: BattleMessage = $BattleMessage
@onready var bet_panel: BetPanel = $ActionArea/BetPanel
@onready var decision_panel: DecisionPanel = $ActionArea/DecisionPanel
@onready var settlement_panel: SettlementPanel = $ActionArea/SettlementPanel
@onready var leaderboard_entry_button: Button = $TopBar/LeaderboardEntryButton

var _visible_state := {
	"top_bar": false,
	"hud": false,
	"bet_panel": false,
	"decision_panel": false,
	"settlement_panel": false
}
var _leaderboard_panel: LeaderboardPanel
var _last_snapshot := {}
var _money_card_in_use := false


func _ready() -> void:
	# 玩家 ID：無框貼紙字（與怪物名牌同款：粉紅字＋奶油描邊＋深藍陰影）
	player_id_label.add_theme_color_override("font_color", UiSkin.CHIP_PINK)
	player_id_label.add_theme_color_override("font_outline_color", UiSkin.CREAM)
	player_id_label.add_theme_constant_override("outline_size", 12)
	player_id_label.add_theme_color_override("font_shadow_color", UiSkin.DEEP_NAVY)
	player_id_label.add_theme_constant_override("shadow_offset_x", 2)
	player_id_label.add_theme_constant_override("shadow_offset_y", 3)
	UiSkin.apply_icon(player_cloud_icon, "cloud")
	# money_card.png 缺檔 → 退回舊資源膠囊樣式（D-004）
	_money_card_in_use = UiSkin.apply_art_texture(money_card, "money_card")
	if _money_card_in_use:
		money_value.add_theme_color_override("font_color", UiSkin.BOARD_INK)
		money_value.add_theme_color_override("font_outline_color", UiSkin.CREAM)
		money_value.add_theme_constant_override("outline_size", 4)
	else:
		money_value.offset_left = 40.0
		UiSkin.apply_resource_label(money_value)
	logo_label.visible = false
	logo_rect.visible = false
	set_profile_auth_state(false, "")
	bet_panel.decrease_requested.connect(func() -> void: bet_decrease_requested.emit())
	bet_panel.increase_requested.connect(func() -> void: bet_increase_requested.emit())
	bet_panel.confirm_requested.connect(func() -> void: bet_confirm_requested.emit())
	bet_panel.quick_bet_requested.connect(func(amount: int) -> void: quick_bet_requested.emit(amount))
	bet_panel.balance_reset_requested.connect(func() -> void: balance_reset_requested.emit())
	decision_panel.cashout_requested.connect(func() -> void: cashout_requested.emit())
	decision_panel.advance_requested.connect(func() -> void: advance_requested.emit())
	settlement_panel.acknowledge_requested.connect(func() -> void: settle_acknowledged.emit())
	settlement_panel.leaderboard_requested.connect(_on_leaderboard_requested)
	# ranking_btn.png（頭像＋玩家排行整圖）缺檔 → 退回文字獎盃膠囊（D-004）
	if UiSkin.apply_art_button(leaderboard_entry_button, "ranking_btn"):
		leaderboard_entry_button.text = ""
	else:
		leaderboard_entry_button.text = Data.text("lb_button")
		UiSkin.apply_button(leaderboard_entry_button, "trophy_pill")
	leaderboard_entry_button.pressed.connect(_on_leaderboard_requested)
	_build_leaderboard_panel()


func update_snapshot(snapshot: Dictionary) -> void:
	_last_snapshot = snapshot
	var state_name := str(snapshot.get("state_name", ""))
	# result.jpg：結算時只留街景與中央結果卡，上方 HUD/角色由呈現層暫時隱藏。
	var show_game_ui := state_name != "TITLE" and not bool(snapshot.get("is_settle", false))
	_set_visible_with_entrance("top_bar", top_bar, show_game_ui)
	_set_visible_with_entrance("hud", hud, show_game_ui, hud.entrance_targets())
	hud.update_snapshot(snapshot)
	# ranking_btn 含玩家頭像，隨 TopBar 常駐顯示；非下注/決策階段僅禁用點擊
	var leaderboard_available := bool(snapshot.get("is_betting", false)) \
		or bool(snapshot.get("is_reward_decision", false))
	leaderboard_entry_button.visible = show_game_ui
	leaderboard_entry_button.disabled = not leaderboard_available
	money_value.text = _format_balance(int(snapshot.get("balance", 0)))
	battle_message.update_snapshot(snapshot)

	_set_visible_with_entrance("bet_panel", bet_panel, bool(snapshot.get("is_betting", false)))
	bet_panel.update_snapshot(snapshot)

	_set_visible_with_entrance("decision_panel", decision_panel, bool(snapshot.get("is_reward_decision", false)))
	decision_panel.update_snapshot(snapshot)

	_set_visible_with_entrance("settlement_panel", settlement_panel, bool(snapshot.get("is_settle", false)), settlement_panel.entrance_targets())
	settlement_panel.update_snapshot(snapshot)


func set_profile_auth_state(signed_in: bool, display_name: String) -> void:
	player_id_label.text = display_name if signed_in and not display_name.is_empty() else Data.text("profile_mock_display_name")
	player_cloud_icon.visible = signed_in and player_cloud_icon.texture != null


## 錢卡上只放數字（icon 已烙在卡圖上）；千分位便於大數目讀取。
## 缺卡圖的 fallback 膠囊則沿用舊「金幣 N」文案。
func _format_balance(balance: int) -> String:
	if not _money_card_in_use:
		return Data.text("hud_balance", {"balance": balance})
	var digits := str(balance)
	var grouped := ""
	var count := 0
	for index in range(digits.length() - 1, -1, -1):
		grouped = digits[index] + grouped
		count += 1
		if count % 3 == 0 and index > 0:
			grouped = "," + grouped
	return grouped


func hold_payout_count_up(max_hold: float) -> void:
	hud.hold_payout_count_up(max_hold)


func release_payout_count_up() -> void:
	hud.release_payout_count_up()


func payout_anchor_canvas_position() -> Vector2:
	return hud.payout_anchor_canvas_position()


func _set_visible_with_entrance(key: String, control: Control, should_show: bool, stagger_targets: Array[Control] = []) -> void:
	if control == null or not is_instance_valid(control):
		push_warning("VerticalUi skipped visibility update for invalid control: %s" % key)
		return

	var was_visible := bool(_visible_state.get(key, false))
	control.visible = should_show
	_visible_state[key] = should_show

	if should_show and not was_visible:
		var ui_config: Dictionary = Data.animation_timing_config().get("ui", {})
		var fade := float(ui_config.get("panel_fade", 0.0))
		var slide := float(ui_config.get("panel_slide", 0.0))
		var offset := float(ui_config.get("panel_slide_offset", 0.0))
		var stagger := float(ui_config.get("entrance_stagger", 0.0))
		UiEntrance.play(control, fade, slide, offset)
		if not stagger_targets.is_empty():
			UiEntrance.play_fade_group(stagger_targets, fade, stagger)
	elif not should_show and was_visible:
		UiEntrance.reset(control)
		for target in stagger_targets:
			UiEntrance.reset_fade(target)


func _build_leaderboard_panel() -> void:
	_leaderboard_panel = LeaderboardPanelScript.new()
	_leaderboard_panel.name = "LeaderboardPanel"
	_leaderboard_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_leaderboard_panel)


func _on_leaderboard_requested() -> void:
	if _leaderboard_panel == null:
		return
	if not (bool(_last_snapshot.get("is_betting", false)) \
			or bool(_last_snapshot.get("is_reward_decision", false)) \
			or bool(_last_snapshot.get("is_settle", false))):
		return
	leaderboard_requested.emit()
	_leaderboard_panel.open(_last_snapshot.get("leaderboard_service", null))
