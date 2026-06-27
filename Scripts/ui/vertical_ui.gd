class_name VerticalUi
extends Control

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
	top_bar.visible = state_name != "TITLE"
	hud.visible = state_name != "TITLE"
	hud.update_snapshot(snapshot)
	battle_message.update_snapshot(snapshot)

	bet_panel.visible = bool(snapshot.get("is_betting", false))
	bet_panel.update_snapshot(snapshot)

	decision_panel.visible = bool(snapshot.get("is_reward_decision", false))
	decision_panel.update_snapshot(snapshot)

	settlement_panel.visible = bool(snapshot.get("is_settle", false))
	settlement_panel.update_snapshot(snapshot)
