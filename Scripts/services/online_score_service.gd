class_name OnlineScoreService
extends "res://Scripts/services/local_score_service.gd"

## D-015 / Docs/08：線上分數服務。
## 設計：本機（LocalScoreService 行為）永遠是即時真實來源，狀態機同步取值；
## 雲端是非同步鏡像——登入時合併（best 取高者、balance 以雲端為準），
## 之後每次變更透過 JS 橋接 debounce 上傳。任何線上失敗都不影響遊戲（fallback 契約）。

signal auth_changed(signed_in: bool, display_name: String)
signal cloud_merged()

var _bridge: JavaScriptObject = null
var _auth_cb: JavaScriptObject = null
var _load_cb: JavaScriptObject = null
var _signed_in := false
var _display_name := ""
var _uid := ""
# 雲端餘額不可在局中套用（會覆寫進行中的存檔）；暫存待局外由 controller 觸發套用。
var _pending_cloud_balance := -1


## 必須在 Web 匯出環境的 _ready 階段呼叫一次；非 Web / 橋接缺失時安全 no-op。
func setup_bridge() -> void:
	if not OS.has_feature("web"):
		return
	_bridge = JavaScriptBridge.get_interface("CrushOnline")
	if _bridge == null:
		push_warning("OnlineScoreService: CrushOnline bridge not found; staying local-only.")
		return
	_auth_cb = JavaScriptBridge.create_callback(_on_auth_state)
	_load_cb = JavaScriptBridge.create_callback(_on_cloud_loaded)
	_bridge.bindCallbacks(_auth_cb, _load_cb)


func is_online_available() -> bool:
	return _bridge != null


func is_signed_in() -> bool:
	return _signed_in


func online_display_name() -> String:
	return _display_name


## 排行榜寫入需綁定 uid（Docs/08 §七：leaderboard/{uid} 僅本人可寫）。
func online_uid() -> String:
	return _uid


func sign_in() -> void:
	if _bridge != null:
		_bridge.signIn()


func sign_out() -> void:
	if _bridge != null:
		_bridge.signOut()


# --- ScoreService 覆寫：先走本機，再鏡像上雲（JS 端 debounce 合併） ---

func set_balance(value: int) -> void:
	super.set_balance(value)
	_push_to_cloud()


func submit_payout(payout: int) -> void:
	super.submit_payout(payout)
	_push_to_cloud()


func reset_balance() -> int:
	var new_balance := super.reset_balance()
	_push_to_cloud()
	return new_balance


# --- 內部 ---

func _push_to_cloud() -> void:
	if _bridge == null or not _signed_in:
		return
	_bridge.save(get_best_payout(), get_balance())


func _on_auth_state(args: Array) -> void:
	var payload := _parse_json_arg(args)
	if payload.is_empty():
		return
	_signed_in = bool(payload.get("signed_in", false))
	_display_name = str(payload.get("display_name", ""))
	_uid = str(payload.get("uid", ""))
	if _signed_in and _bridge != null:
		_bridge.requestLoad()
	auth_changed.emit(_signed_in, _display_name)


func _on_cloud_loaded(args: Array) -> void:
	var cloud := _parse_json_arg(args)
	if cloud.is_empty():
		return
	if bool(cloud.get("error", false)):
		# 載入失敗 ≠ 雲端無資料：不得以本機值回寫覆蓋雲端（Docs/08 §五）。
		push_warning("OnlineScoreService: cloud load failed; skip merge this time.")
		return
	if bool(cloud.get("found", false)):
		# 合併：best 取高者（單調遞增，隨時安全）；balance 以雲端為準，
		# 但只能在局外套用——先暫存，由 controller 在 BETTING 時觸發。
		super.submit_payout(int(cloud.get("best_payout", 0)))
		_pending_cloud_balance = int(cloud.get("balance", 0))
	else:
		# 雲端無資料：以本機值初始化雲端。
		_push_to_cloud()
	cloud_merged.emit()


func has_pending_cloud_balance() -> bool:
	return _pending_cloud_balance >= 0


## 只能在局外（BETTING）呼叫——由 game_controller 守門。
func apply_pending_cloud_balance() -> void:
	if _pending_cloud_balance < 0:
		return
	var cloud_balance := _pending_cloud_balance
	_pending_cloud_balance = -1
	super.set_balance(cloud_balance)
	# 合併結果回寫雲端（涵蓋「本機 best 較高」的情況）。
	_push_to_cloud()


func _parse_json_arg(args: Array) -> Dictionary:
	if args.is_empty() or typeof(args[0]) != TYPE_STRING:
		return {}
	var parsed: Variant = JSON.parse_string(args[0])
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("OnlineScoreService: malformed bridge payload ignored.")
		return {}
	return parsed
