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

@onready var hud: Hud = $Hud
@onready var top_bar: Control = $TopBar
@onready var profile_frame: PanelContainer = $TopBar/ProfileFrame
@onready var profile_cloud_icon: TextureRect = $TopBar/ProfileFrame/ProfileContent/ProfileCloudIcon
@onready var profile_label: Label = $TopBar/ProfileFrame/ProfileContent/ProfileLabel
@onready var logo_label: Label = $TopBar/LogoLabel
@onready var logo_rect: TextureRect = $TopBar/LogoRect
@onready var battle_message: BattleMessage = $BattleMessage
@onready var bet_panel: BetPanel = $ActionArea/BetPanel
@onready var decision_panel: DecisionPanel = $ActionArea/DecisionPanel
@onready var settlement_panel: SettlementPanel = $ActionArea/SettlementPanel
@onready var leaderboard_entry_button: Button = $LeaderboardEntryButton

var _visible_state := {
	"top_bar": false,
	"hud": false,
	"bet_panel": false,
	"decision_panel": false,
	"settlement_panel": false
}
var _leaderboard_panel: LeaderboardPanel
var _last_snapshot := {}


func _ready() -> void:
	UiSkin.apply_panel(profile_frame, "card")
	UiSkin.apply_icon(profile_cloud_icon, "cloud")
	UiSkin.apply_light_panel_label(profile_label)
	logo_label.text = Data.text("title_game_name")
	# 有 logo.png 用圖（mockup 右上 Logo），缺檔退回文字標題
	var logo_ok := UiSkin.apply_art_texture(logo_rect, "logo")
	logo_label.visible = not logo_ok
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
	leaderboard_entry_button.text = Data.text("lb_button")
	UiSkin.apply_button(leaderboard_entry_button, "trophy_pill")
	leaderboard_entry_button.pressed.connect(_on_leaderboard_requested)
	_build_leaderboard_panel()


func update_snapshot(snapshot: Dictionary) -> void:
	_last_snapshot = snapshot
	var state_name := str(snapshot.get("state_name", ""))
	var show_game_ui := state_name != "TITLE"
	_set_visible_with_entrance("top_bar", top_bar, show_game_ui)
	_set_visible_with_entrance("hud", hud, show_game_ui, hud.entrance_targets())
	hud.update_snapshot(snapshot)
	leaderboard_entry_button.visible = bool(snapshot.get("is_betting", false))
	leaderboard_entry_button.disabled = not bool(snapshot.get("is_betting", false))
	battle_message.update_snapshot(snapshot)

	_set_visible_with_entrance("bet_panel", bet_panel, bool(snapshot.get("is_betting", false)))
	bet_panel.update_snapshot(snapshot)

	_set_visible_with_entrance("decision_panel", decision_panel, bool(snapshot.get("is_reward_decision", false)))
	decision_panel.update_snapshot(snapshot)

	_set_visible_with_entrance("settlement_panel", settlement_panel, bool(snapshot.get("is_settle", false)), settlement_panel.entrance_targets())
	settlement_panel.update_snapshot(snapshot)


func set_profile_auth_state(signed_in: bool, display_name: String) -> void:
	profile_label.text = display_name if signed_in and not display_name.is_empty() else Data.text("profile_mock_display_name")
	profile_cloud_icon.visible = signed_in and profile_cloud_icon.texture != null


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
	if not (bool(_last_snapshot.get("is_betting", false)) or bool(_last_snapshot.get("is_settle", false))):
		return
	_leaderboard_panel.open(_last_snapshot.get("leaderboard_service", null))
