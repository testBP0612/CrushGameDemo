extends Node2D

const EventBusScript := preload("res://Scripts/core/event_bus.gd")
const GameStateMachineScript := preload("res://Scripts/core/game_state_machine.gd")

@onready var title_screen: Control = $UILayer/TitleScreen
@onready var battle_presenter = $BattleScene
@onready var title_label: Label = $UILayer/TitleScreen/TitleLayout/TitleLabel
@onready var best_record_label: Label = $UILayer/TitleScreen/TitleLayout/BestRecordLabel
@onready var start_button: Button = $UILayer/TitleScreen/TitleLayout/StartButton
@onready var vertical_ui: VerticalUi = $UILayer/VerticalUi

var event_bus := EventBusScript.new()
var state_machine := GameStateMachineScript.new()


func _ready() -> void:
	add_child(event_bus)
	state_machine.setup(event_bus)
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
	vertical_ui.bet_decrease_requested.connect(_on_decrease_pressed)
	vertical_ui.bet_increase_requested.connect(_on_increase_pressed)
	vertical_ui.bet_confirm_requested.connect(_on_confirm_bet_pressed)
	vertical_ui.quick_bet_requested.connect(_on_quick_bet_requested)
	vertical_ui.cashout_requested.connect(_on_cashout_pressed)
	vertical_ui.advance_requested.connect(_on_advance_pressed)
	vertical_ui.settle_acknowledged.connect(_on_settle_pressed)


func _connect_battle_presenter() -> void:
	battle_presenter.attack_sequence_finished.connect(_on_attack_sequence_finished)
	battle_presenter.monster_hurt_finished.connect(_on_monster_hurt_finished)
	battle_presenter.monster_death_finished.connect(_on_monster_death_finished)
	battle_presenter.advance_walk_finished.connect(_on_advance_walk_finished)
	battle_presenter.transition_finished.connect(_on_transition_finished)
	battle_presenter.monster_counter_finished.connect(_on_monster_counter_finished)
	battle_presenter.player_hurt_finished.connect(_on_player_hurt_finished)


func _apply_static_text() -> void:
	title_label.text = Data.text("title_game_name")
	best_record_label.text = Data.text("best_record", {"payout": 0})
	start_button.text = Data.text("title_tap_to_start")


func _on_start_pressed() -> void:
	state_machine.start_from_title()
	_update_view()


func _on_decrease_pressed() -> void:
	state_machine.change_bet_steps(-1)
	_update_view()


func _on_increase_pressed() -> void:
	state_machine.change_bet_steps(1)
	_update_view()


func _on_quick_bet_requested(amount: int) -> void:
	state_machine.set_bet(amount)
	_update_view()


func _on_confirm_bet_pressed() -> void:
	state_machine.confirm_bet()
	_update_view()


func _on_cashout_pressed() -> void:
	state_machine.cash_out()
	_update_view()


func _on_advance_pressed() -> void:
	state_machine.advance()
	_update_view()


func _on_settle_pressed() -> void:
	state_machine.acknowledge_settle()
	_update_view()


func _on_state_changed(state_name: String) -> void:
	_update_view()
	_play_presentation_for_state(state_name)


func _on_balance_changed(_balance: int) -> void:
	_update_view()


func _on_bet_changed(_bet: int) -> void:
	_update_view()


func _on_stage_advanced(stage: int, multiplier: float, payout: int) -> void:
	print("Stage advanced: stage=%d multiplier=%s payout=%d" % [stage, multiplier, payout])
	_update_view()


func _on_result_resolved(is_win: bool) -> void:
	print("Result resolved: is_win=%s" % is_win)
	_update_view()


func _on_settled(result: String) -> void:
	print("Settled: %s balance=%d" % [result, state_machine.balance])
	_update_view()


func _on_attack_sequence_finished(hit_count: int) -> void:
	print("Attack sequence finished: hit_count=%d" % hit_count)
	state_machine.finish_attack()


func _on_monster_hurt_finished() -> void:
	state_machine.finish_monster_hurt()


func _on_monster_death_finished() -> void:
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
			battle_presenter.play_monster_death()
		"ADVANCE_WALK":
			battle_presenter.play_advance_walk()
		"TRANSITION":
			battle_presenter.play_transition(state_machine.stage_to_challenge())
		"MONSTER_COUNTER":
			battle_presenter.play_monster_counter()
		"PLAYER_HURT":
			battle_presenter.play_player_hurt()


func _update_view() -> void:
	if not is_node_ready():
		return

	var state_name := state_machine.state_name()
	title_screen.visible = state_machine.is_title()
	vertical_ui.visible = not state_machine.is_title()
	vertical_ui.update_snapshot(_ui_snapshot(state_name))


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
		"min_bet": int(balance_config.get("min_bet", 0)),
		"max_bet": int(balance_config.get("max_bet", 0)),
		"bet_step": int(balance_config.get("bet_step", 0)),
		"is_betting": state_machine.is_betting(),
		"is_reward_decision": state_machine.is_reward_decision(),
		"is_settle": state_machine.is_settle(),
		"is_bet_affordable": state_machine.is_bet_affordable(),
		"can_advance": state_machine.can_advance()
	}
