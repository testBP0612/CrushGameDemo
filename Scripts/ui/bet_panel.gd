class_name BetPanel
extends Control

const ButtonFeedback := preload("res://Scripts/effects/button_feedback.gd")
const UiSkin := preload("res://Scripts/ui/ui_skin.gd")

signal decrease_requested
signal increase_requested
signal confirm_requested
signal quick_bet_requested(amount: int)
signal balance_reset_requested

@onready var title_label: Label = $Panel/Margin/Layout/TitleLabel
@onready var panel: PanelContainer = $Panel
@onready var decrease_button: Button = $Panel/Margin/Layout/BetRow/DecreaseButton
@onready var bet_label: Label = $Panel/Margin/Layout/BetRow/BetLabel
@onready var increase_button: Button = $Panel/Margin/Layout/BetRow/IncreaseButton
@onready var quick_chip_row: HBoxContainer = $Panel/Margin/Layout/QuickChipRow
@onready var insufficient_label: Label = $Panel/Margin/Layout/InsufficientLabel
@onready var insufficient_icon: TextureRect = $Panel/Margin/Layout/InsufficientIcon
@onready var confirm_button: Button = $Panel/Margin/Layout/ConfirmButton
var _quick_buttons: Array[Button] = []
var _is_reset_mode := false


func _ready() -> void:
	UiSkin.apply_panel(panel, "large")
	title_label.text = Data.text("bet_panel_title")
	decrease_button.text = ""
	increase_button.text = ""
	confirm_button.text = Data.text("bet_confirm")
	insufficient_label.text = Data.text("bet_insufficient")
	UiSkin.apply_button(decrease_button, "step_decrease")
	UiSkin.apply_button(increase_button, "step_increase")
	UiSkin.apply_button(confirm_button, "primary")
	UiSkin.apply_ribbon_label(title_label)
	UiSkin.apply_number_display(bet_label)
	UiSkin.apply_icon(insufficient_icon, "warning")
	insufficient_icon.visible = false
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
	_is_reset_mode = is_betting and is_balance_below_min_bet
	decrease_button.disabled = not is_betting or bet <= min_bet
	increase_button.disabled = not is_betting or bet >= max_bet
	confirm_button.text = Data.text("bet_reset_balance" if _is_reset_mode else "bet_confirm")
	confirm_button.disabled = not is_betting or (not is_affordable and not _is_reset_mode)
	insufficient_label.visible = is_betting and not is_affordable
	insufficient_icon.visible = insufficient_label.visible

	for button in _quick_buttons:
		var amount := int(button.get_meta("amount", 0))
		button.disabled = not is_betting or amount < min_bet or amount > max_bet
		UiSkin.apply_button(button, "chip_selected" if amount == bet else "chip")


func _build_quick_buttons() -> void:
	for child in quick_chip_row.get_children():
		child.queue_free()
	_quick_buttons.clear()

	var balance_config := Data.balance_config()
	var amounts: Array = balance_config.get("quick_bet_options", [])
	var seen := {}

	for raw_amount in amounts:
		var amount := int(raw_amount)
		if seen.has(amount):
			continue
		seen[amount] = true
		var button := Button.new()
		button.custom_minimum_size = Vector2(158.0, 64.0)
		button.text = str(amount)
		button.add_theme_font_size_override("font_size", 24)
		button.set_meta("amount", amount)
		UiSkin.apply_button(button, "chip")
		_install_button_feedback(button)
		button.pressed.connect(_on_quick_button_pressed.bind(amount))
		quick_chip_row.add_child(button)
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
