class_name VerticalUi
extends Control

const UiEntrance := preload("res://Scripts/effects/ui_entrance.gd")

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
@onready var logo_label: Label = $TopBar/LogoLabel
@onready var battle_message: BattleMessage = $BattleMessage
@onready var bet_panel: BetPanel = $ActionArea/BetPanel
@onready var decision_panel: DecisionPanel = $ActionArea/DecisionPanel
@onready var settlement_panel: SettlementPanel = $ActionArea/SettlementPanel

var _visible_state := {
	"top_bar": false,
	"hud": false,
	"bet_panel": false,
	"decision_panel": false,
	"settlement_panel": false
}


func _ready() -> void:
	logo_label.text = Data.text("title_game_name")
	bet_panel.decrease_requested.connect(func() -> void: bet_decrease_requested.emit())
	bet_panel.increase_requested.connect(func() -> void: bet_increase_requested.emit())
	bet_panel.confirm_requested.connect(func() -> void: bet_confirm_requested.emit())
	bet_panel.quick_bet_requested.connect(func(amount: int) -> void: quick_bet_requested.emit(amount))
	bet_panel.balance_reset_requested.connect(func() -> void: balance_reset_requested.emit())
	decision_panel.cashout_requested.connect(func() -> void: cashout_requested.emit())
	decision_panel.advance_requested.connect(func() -> void: advance_requested.emit())
	settlement_panel.acknowledge_requested.connect(func() -> void: settle_acknowledged.emit())


func update_snapshot(snapshot: Dictionary) -> void:
	var state_name := str(snapshot.get("state_name", ""))
	var show_game_ui := state_name != "TITLE"
	_set_visible_with_entrance("top_bar", top_bar, show_game_ui)
	_set_visible_with_entrance("hud", hud, show_game_ui, hud.entrance_targets())
	hud.update_snapshot(snapshot)
	battle_message.update_snapshot(snapshot)

	_set_visible_with_entrance("bet_panel", bet_panel, bool(snapshot.get("is_betting", false)))
	bet_panel.update_snapshot(snapshot)

	_set_visible_with_entrance("decision_panel", decision_panel, bool(snapshot.get("is_reward_decision", false)))
	decision_panel.update_snapshot(snapshot)

	_set_visible_with_entrance("settlement_panel", settlement_panel, bool(snapshot.get("is_settle", false)), settlement_panel.entrance_targets())
	settlement_panel.update_snapshot(snapshot)


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
