class_name GameStateMachine
extends RefCounted

const PayoutCalculatorScript := preload("res://Scripts/battle/payout_calculator.gd")
const RiskResolverScript := preload("res://Scripts/battle/risk_resolver.gd")

enum State {
	BOOT,
	TITLE,
	BETTING,
	CHALLENGE_START,
	BATTLE_ATTACK,
	MONSTER_HURT,
	MONSTER_DEATH,
	REWARD_DECISION,
	ADVANCE_WALK,
	TRANSITION,
	CASH_OUT_SETTLE,
	MONSTER_COUNTER,
	PLAYER_HURT,
	DEFEAT_SETTLE,
	CLEAR_SETTLE
}

const STATE_NAMES := {
	State.BOOT: "BOOT",
	State.TITLE: "TITLE",
	State.BETTING: "BETTING",
	State.CHALLENGE_START: "CHALLENGE_START",
	State.BATTLE_ATTACK: "BATTLE_ATTACK",
	State.MONSTER_HURT: "MONSTER_HURT",
	State.MONSTER_DEATH: "MONSTER_DEATH",
	State.REWARD_DECISION: "REWARD_DECISION",
	State.ADVANCE_WALK: "ADVANCE_WALK",
	State.TRANSITION: "TRANSITION",
	State.CASH_OUT_SETTLE: "CASH_OUT_SETTLE",
	State.MONSTER_COUNTER: "MONSTER_COUNTER",
	State.PLAYER_HURT: "PLAYER_HURT",
	State.DEFEAT_SETTLE: "DEFEAT_SETTLE",
	State.CLEAR_SETTLE: "CLEAR_SETTLE"
}

var event_bus: EventBus
var score_service
var state: State = State.BOOT
var balance := 0
var bet := 0
var stage := 0
var current_payout := 0
var current_multiplier := 1.0
# D-019：下一關（未清）的倍率/可得金額，供決策畫面「過關可得」與結算 FOMO 行使用；
# 已在最終關（無下一關）時為 0.0 / 0，UI 依此隱藏對應資訊。
var next_stage_multiplier := 0.0
var next_stage_payout := 0
var last_result := ""
var active_monster_stage := 1

var _payout_calculator := PayoutCalculatorScript.new()
var _risk_resolver := RiskResolverScript.new()
var _bet_charged_this_round := false
var _settled_this_round := false
# D-019 本局隨機倍率盤：index 0..max_stage；空陣列＝未擲/停用，一律退回基準曲線。
# 專用 RNG 與 risk_resolver 的全域隨機流分離，倍率抖動不影響成功率擲骰序列。
var _run_multiplier_table: Array[float] = []
var _rng := RandomNumberGenerator.new()


func setup(bus: EventBus, score) -> void:
	event_bus = bus
	score_service = score
	randomize()
	_rng.randomize()


func start() -> bool:
	_set_state(State.BOOT)
	if not Data.is_loaded():
		push_error("GameStateMachine BOOT failed: Data autoload is not loaded.")
		return false
	if score_service == null:
		push_error("GameStateMachine BOOT failed: ScoreService is not injected.")
		return false

	var balance_config := Data.balance_config()
	score_service.load_save()
	balance = score_service.get_balance()
	bet = _clamp_bet(int(balance_config.get("default_bet", 0)))
	_emit_data_loaded()
	_set_state(State.TITLE)
	return true


func start_from_title() -> void:
	if state != State.TITLE:
		return
	_set_state(State.BETTING)


func change_bet_steps(step_count: int) -> void:
	if state != State.BETTING:
		return

	var balance_config := Data.balance_config()
	var step := int(balance_config.get("bet_step", 0))
	bet = _clamp_bet(bet + step * step_count)
	_emit_bet_changed()


func set_bet(value: int) -> void:
	if state != State.BETTING:
		return

	bet = _clamp_bet(value)
	_emit_bet_changed()


func confirm_bet() -> bool:
	if state != State.BETTING:
		return false
	if balance < bet:
		push_error("Cannot confirm bet: balance is lower than bet.")
		return false

	_roll_run_multiplier_table()
	event_bus.bet_confirmed.emit(bet)
	_set_state(State.CHALLENGE_START)
	_set_state(State.BATTLE_ATTACK)
	return true


func finish_attack() -> void:
	if state != State.BATTLE_ATTACK:
		return

	event_bus.attack_finished.emit()
	var stage_to_challenge := stage + 1
	var is_win := _risk_resolver.resolve(stage_to_challenge)
	event_bus.result_resolved.emit(is_win)

	if is_win:
		_set_state(State.MONSTER_HURT)
	else:
		_set_state(State.MONSTER_COUNTER)


func finish_monster_hurt() -> void:
	if state != State.MONSTER_HURT:
		return
	_set_state(State.MONSTER_DEATH)


func finish_monster_death() -> void:
	if state != State.MONSTER_DEATH:
		return
	if stage >= max_stage():
		_set_state(State.CLEAR_SETTLE)
	else:
		_set_state(State.REWARD_DECISION)


func finish_monster_counter() -> void:
	if state != State.MONSTER_COUNTER:
		return
	_set_state(State.PLAYER_HURT)


func finish_player_hurt() -> void:
	if state != State.PLAYER_HURT:
		return
	_set_state(State.DEFEAT_SETTLE)


func cash_out() -> void:
	if state != State.REWARD_DECISION:
		return

	event_bus.cashout_requested.emit()
	_set_state(State.CASH_OUT_SETTLE)


func advance() -> void:
	if state != State.REWARD_DECISION:
		return
	if stage >= max_stage():
		_set_state(State.CLEAR_SETTLE)
		return

	event_bus.advance_requested.emit()
	_set_state(State.ADVANCE_WALK)


func finish_advance_walk() -> void:
	if state != State.ADVANCE_WALK:
		return
	_set_state(State.TRANSITION)


func finish_transition() -> void:
	if state != State.TRANSITION:
		return
	_set_state(State.CHALLENGE_START)
	_set_state(State.BATTLE_ATTACK)


func acknowledge_settle() -> void:
	if state not in [State.CASH_OUT_SETTLE, State.DEFEAT_SETTLE, State.CLEAR_SETTLE]:
		return
	_set_state(State.BETTING)


func state_name() -> String:
	return STATE_NAMES[state]


func max_stage() -> int:
	return int(Data.stage_progression_config().get("max_stage", 0))


func can_advance() -> bool:
	return state == State.REWARD_DECISION and stage < max_stage()


func is_title() -> bool:
	return state == State.TITLE


func is_betting() -> bool:
	return state == State.BETTING


func is_reward_decision() -> bool:
	return state == State.REWARD_DECISION


func is_settle() -> bool:
	return state in [State.CASH_OUT_SETTLE, State.DEFEAT_SETTLE, State.CLEAR_SETTLE]


func is_bet_affordable() -> bool:
	return balance >= bet


func is_balance_below_min_bet() -> bool:
	return balance < int(Data.balance_config().get("min_bet", 0))


func reset_balance_to_starting() -> void:
	if state != State.BETTING or score_service == null:
		return
	balance = score_service.reset_balance()
	_emit_balance_changed()


## D-015：登入後雲端合併可能改變存檔餘額；僅允許在 BETTING（局外）同步回狀態機。
func refresh_balance_from_service() -> void:
	if state != State.BETTING or score_service == null:
		return
	balance = score_service.get_balance()
	_emit_balance_changed()


func stage_to_challenge() -> int:
	return stage + 1


func _set_state(next_state: State) -> void:
	state = next_state
	print("STATE -> %s balance=%d bet=%d stage=%d payout=%d" % [state_name(), balance, bet, stage, current_payout])
	if event_bus != null:
		event_bus.state_changed.emit(state_name())

	match state:
		State.BETTING:
			_enter_betting()
		State.CHALLENGE_START:
			_enter_challenge_start()
		State.MONSTER_DEATH:
			_enter_monster_death()
		State.REWARD_DECISION:
			_enter_reward_decision()
		State.CASH_OUT_SETTLE:
			_enter_cash_out_settle()
		State.DEFEAT_SETTLE:
			_enter_defeat_settle()
		State.CLEAR_SETTLE:
			_enter_clear_settle()


func _enter_betting() -> void:
	stage = 0
	_run_multiplier_table.clear()
	_bet_charged_this_round = false
	_settled_this_round = false
	_update_payout()
	_emit_balance_changed()
	_emit_bet_changed()


func _enter_challenge_start() -> void:
	# 鎖定本回合挑戰的怪物（= 目前已擊敗數 + 1）；整個回合不隨 stage 增減而改變，
	# 避免勝利訊息在 MONSTER_DEATH 增加 stage 後顯示成下一隻怪物的名字。
	active_monster_stage = stage + 1

	if _bet_charged_this_round:
		return

	balance = max(0, balance - bet)
	score_service.set_balance(balance)
	_bet_charged_this_round = true
	_emit_balance_changed()


func _enter_monster_death() -> void:
	stage += 1
	_update_payout()
	event_bus.stage_advanced.emit(stage, current_multiplier, current_payout)


func _enter_reward_decision() -> void:
	_update_payout()


func _enter_cash_out_settle() -> void:
	if not _settled_this_round:
		balance += current_payout
		score_service.set_balance(balance)
		score_service.submit_payout(current_payout)
		_settled_this_round = true
		last_result = "cash_out"
		_emit_balance_changed()
	event_bus.settled.emit(last_result)


func _enter_defeat_settle() -> void:
	current_payout = 0
	score_service.set_balance(balance)
	_settled_this_round = true
	last_result = "defeat"
	event_bus.settled.emit(last_result)


func _enter_clear_settle() -> void:
	if not _settled_this_round:
		balance += current_payout
		score_service.set_balance(balance)
		score_service.submit_payout(current_payout)
		_settled_this_round = true
		last_result = "clear"
		_emit_balance_changed()
	event_bus.settled.emit(last_result)


## D-019：本局盤查詢——已擲用本局盤，未擲/停用退回基準曲線（enabled=false 回歸路徑）。
func run_multiplier_at(stage_index: int) -> float:
	if stage_index >= 0 and stage_index < _run_multiplier_table.size():
		return _run_multiplier_table[stage_index]
	return Data.multiplier_at(stage_index)


## D-019：每局下注確認時擲一次本局倍率盤。抖動隨關卡由 stage_1 線性放大到
## stage_max，並以 min_growth_ratio 強制單調遞增（永不倒退）。
func _roll_run_multiplier_table() -> void:
	_run_multiplier_table.clear()
	var config := Data.multiplier_random_config()
	if not bool(config.get("enabled", false)):
		return

	var stages := max_stage()
	var jitter_start := float(config.get("jitter_pct_stage_1", 0.0))
	var jitter_end := float(config.get("jitter_pct_stage_max", jitter_start))
	var min_growth := float(config.get("min_growth_ratio", 1.0))
	var step: float = pow(10.0, -int(config.get("round_decimals", 2)))
	var previous := Data.multiplier_at(0)
	_run_multiplier_table.append(previous)
	for stage_index in range(1, stages + 1):
		var t := 0.0 if stages <= 1 else float(stage_index - 1) / float(stages - 1)
		var jitter := lerpf(jitter_start, jitter_end, t)
		var rolled := Data.multiplier_at(stage_index) * _rng.randf_range(1.0 - jitter, 1.0 + jitter)
		var final_value := snappedf(maxf(rolled, previous * min_growth), step)
		_run_multiplier_table.append(final_value)
		previous = final_value


func _update_payout() -> void:
	current_multiplier = run_multiplier_at(stage)
	current_payout = _payout_calculator.current_payout(bet, current_multiplier)
	if stage < max_stage():
		next_stage_multiplier = run_multiplier_at(stage + 1)
		next_stage_payout = _payout_calculator.current_payout(bet, next_stage_multiplier)
	else:
		next_stage_multiplier = 0.0
		next_stage_payout = 0


func _clamp_bet(value: int) -> int:
	var balance_config := Data.balance_config()
	var min_bet := int(balance_config.get("min_bet", 0))
	var max_bet := int(balance_config.get("max_bet", min_bet))
	return clampi(value, min_bet, max_bet)


func _emit_data_loaded() -> void:
	if event_bus != null:
		event_bus.data_loaded.emit()


func _emit_balance_changed() -> void:
	if event_bus != null:
		event_bus.balance_changed.emit(balance)


func _emit_bet_changed() -> void:
	if event_bus != null:
		event_bus.bet_changed.emit(bet)
