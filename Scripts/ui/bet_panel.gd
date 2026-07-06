class_name BetPanel
extends Control

const ButtonFeedback := preload("res://Scripts/effects/button_feedback.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

signal decrease_requested
signal increase_requested
signal confirm_requested
signal quick_bet_requested(amount: int)
signal balance_reset_requested

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $TitleLabel
@onready var ribbon_rect: TextureRect = $RibbonRect
@onready var context_rect: TextureRect = $Panel/Content/ContextRect
@onready var chips_left: VBoxContainer = $Panel/Content/ChipsLeft
@onready var chips_right: VBoxContainer = $Panel/Content/ChipsRight
@onready var decrease_button: Button = $Panel/Content/DecreaseButton
@onready var bet_label: Label = $Panel/Content/BetLabel
@onready var increase_button: Button = $Panel/Content/IncreaseButton
@onready var insufficient_row: HBoxContainer = $Panel/Content/InsufficientRow
@onready var insufficient_label: Label = $Panel/Content/InsufficientRow/InsufficientLabel
@onready var insufficient_icon: TextureRect = $Panel/Content/InsufficientRow/InsufficientIcon
@onready var confirm_button: Button = $ConfirmButton

var _quick_buttons: Array[Button] = []
var _is_reset_mode := false
var _confirm_is_art := false
var _confirm_mode_initialized := false


func _ready() -> void:
	UiSkin.apply_panel(panel, "large")
	# 緞帶標題：有 bet_info.png 用圖（含烤字），缺檔退回粉紅文字標題
	var ribbon_ok := UiSkin.apply_art_texture(ribbon_rect, "bet_ribbon")
	title_label.visible = not ribbon_ok
	if not ribbon_ok:
		title_label.text = Data.text("bet_panel_title")
		UiSkin.apply_ribbon_label(title_label)
	# 中央貓糧插圖（缺檔自動隱藏）
	UiSkin.apply_art_texture(context_rect, "bet_context")
	decrease_button.text = ""
	increase_button.text = ""
	insufficient_label.text = Data.text("bet_insufficient")
	UiSkin.apply_button(decrease_button, "step_decrease")
	UiSkin.apply_button(increase_button, "step_increase")
	UiSkin.apply_number_display(bet_label)
	UiSkin.apply_icon(insufficient_icon, "warning")
	insufficient_row.visible = false
	_set_confirm_mode(false)
	_install_button_feedback(decrease_button)
	_install_button_feedback(increase_button)
	_install_button_feedback(confirm_button)
	decrease_button.pressed.connect(func() -> void: decrease_requested.emit())
	increase_button.pressed.connect(func() -> void: increase_requested.emit())
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	_build_quick_buttons()


func update_snapshot(snapshot: Dictionary) -> void:
	var bet := int(snapshot.get("bet", 0))
	var min_bet := int(snapshot.get("min_bet", 0))
	var max_bet := int(snapshot.get("max_bet", min_bet))
	var is_betting := bool(snapshot.get("is_betting", false))
	var is_affordable := bool(snapshot.get("is_bet_affordable", false))
	var is_balance_below_min_bet := bool(snapshot.get("is_balance_below_min_bet", false))

	bet_label.text = str(bet)
	_set_confirm_mode(is_betting and is_balance_below_min_bet)
	decrease_button.disabled = not is_betting or bet <= min_bet
	increase_button.disabled = not is_betting or bet >= max_bet
	confirm_button.disabled = not is_betting or (not is_affordable and not _is_reset_mode)
	insufficient_row.visible = is_betting and not is_affordable

	for button in _quick_buttons:
		var amount := int(button.get_meta("amount", 0))
		button.disabled = not is_betting or amount < min_bet or amount > max_bet
		UiSkin.apply_button(button, "chip_selected" if amount == bet else "chip")


## 一般模式用 next.png 大圖按鈕（烤字「喵準開始」）；重置模式退回文字按鈕。
## 缺 next.png 時兩種模式都走文字按鈕（缺檔不崩）。
func _set_confirm_mode(reset: bool) -> void:
	if _confirm_mode_initialized and reset == _is_reset_mode:
		return
	_confirm_mode_initialized = true
	_is_reset_mode = reset
	if reset:
		_confirm_is_art = false
		UiSkin.apply_button(confirm_button, "primary")
		confirm_button.text = Data.text("bet_reset_balance")
		return
	_confirm_is_art = UiSkin.apply_art_button(confirm_button, "btn_next")
	if _confirm_is_art:
		confirm_button.text = ""
	else:
		UiSkin.apply_button(confirm_button, "primary")
		confirm_button.text = Data.text("bet_confirm")


func _build_quick_buttons() -> void:
	for column in [chips_left, chips_right]:
		for child in column.get_children():
			child.queue_free()
	_quick_buttons.clear()

	var balance_config := Data.balance_config()
	var amounts: Array = balance_config.get("quick_bet_options", [])
	var seen := {}
	var unique_amounts: Array[int] = []

	for raw_amount in amounts:
		var amount := int(raw_amount)
		if seen.has(amount):
			continue
		seen[amount] = true
		unique_amounts.append(amount)

	# 對齊 mockup：小額放左欄（由上而下遞增），大額放右欄（由上而下遞減）
	var left_count := int(ceil(unique_amounts.size() / 2.0))
	for index in unique_amounts.size():
		var amount := unique_amounts[index]
		var button := Button.new()
		button.custom_minimum_size = Vector2(200.0, 64.0)
		button.text = str(amount)
		button.add_theme_font_size_override("font_size", 28)
		button.set_meta("amount", amount)
		UiSkin.apply_button(button, "chip")
		_install_button_feedback(button)
		button.pressed.connect(_on_quick_button_pressed.bind(amount))
		if index < left_count:
			chips_left.add_child(button)
		else:
			chips_right.add_child(button)
			chips_right.move_child(button, 0)
		_quick_buttons.append(button)


func _on_quick_button_pressed(amount: int) -> void:
	quick_bet_requested.emit(amount)


func _on_confirm_button_pressed() -> void:
	if _is_reset_mode:
		balance_reset_requested.emit()
	else:
		confirm_requested.emit()


func _install_button_feedback(button: Button) -> void:
	var duration := float(Data.animation_timing_config().get("ui", {}).get("button_feedback", 0.0))
	ButtonFeedback.install(button, duration)
