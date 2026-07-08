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
	# 對齊 ui_mockup_battle：下注金額是本畫面視覺主角，加大字級（tscn 60 → 72）
	bet_label.add_theme_font_size_override("font_size", 72)
	# 8 檔籌碼（左右各 4）要塞進原本 3 檔的欄高，縮 separation
	for chip_column: VBoxContainer in [chips_left, chips_right]:
		chip_column.add_theme_constant_override("separation", 8)
	# ±/金額列內縮（mockup 比例），避開左右欄第四顆籌碼；金額框 300 寬置中
	decrease_button.offset_left = 180.0
	decrease_button.offset_right = 290.0
	bet_label.offset_left = 310.0
	bet_label.offset_right = 610.0
	increase_button.offset_left = 630.0
	increase_button.offset_right = 740.0
	UiSkin.apply_icon(insufficient_icon, "warning")
	# 夜間 UI 輪：警示列原本貼齊面板下緣（26px 字＋34px icon 被下注框陰影壓住），
	# 上移到插圖下緣、加大、標籤加奶油底板——警示出現時要一眼可見
	insufficient_row.offset_top = 166.0
	insufficient_row.offset_bottom = 236.0
	insufficient_icon.custom_minimum_size = Vector2(46.0, 46.0)
	insufficient_label.add_theme_font_size_override("font_size", 32)
	UiSkin.apply_resource_label(insufficient_label)
	insufficient_label.add_theme_color_override("font_color", Color(0.82, 0.22, 0.18, 1.0))
	# resource_label 的 54px 左留白是給疊放 icon 用的；這裡 icon 在列內獨立，改回對稱
	var warning_pill := insufficient_label.get_theme_stylebox("normal")
	if warning_pill != null:
		warning_pill.set_content_margin(SIDE_LEFT, 22.0)
	insufficient_row.visible = false
	# 確認鈕原 tscn 底緣離 ActionArea 下界僅 3px（貼邊），整體上移
	confirm_button.offset_top -= 20.0
	confirm_button.offset_bottom -= 20.0
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
	# 注意：icon 對齊依「套樣式當下有無文字」決定，text 必須先設再 apply_button
	if reset:
		_confirm_is_art = false
		confirm_button.text = Data.text("bet_reset_balance")
		UiSkin.apply_button(confirm_button, "primary")
		return
	_confirm_is_art = UiSkin.apply_art_button(confirm_button, "btn_next")
	if _confirm_is_art:
		confirm_button.text = ""
	else:
		confirm_button.text = Data.text("bet_confirm")
		UiSkin.apply_button(confirm_button, "primary")


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
		button.custom_minimum_size = Vector2(150.0, 52.0)
		button.text = str(amount)
		button.add_theme_font_size_override("font_size", 30)
		button.set_meta("amount", amount)
		UiSkin.apply_button(button, "chip")
		_install_button_feedback(button)
		button.pressed.connect(_on_quick_button_pressed.bind(amount))
		if index < left_count:
			button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			chips_left.add_child(button)
		else:
			button.size_flags_horizontal = Control.SIZE_SHRINK_END
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
