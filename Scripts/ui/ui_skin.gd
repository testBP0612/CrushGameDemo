class_name UiSkin
extends RefCounted

const CARD_MARGIN := 52
const PANEL_MARGIN := 58
const BUTTON_MARGIN := 54
const CHIP_MARGIN_X := 48
const CHIP_MARGIN_Y := 24
const DEEP_NAVY := Color(0.105882, 0.164706, 0.290196, 1.0)
const CREAM := Color(1.0, 0.964706, 0.901961, 1.0)
const TEAL := Color(0.08, 0.67, 0.62, 1.0)
const PINK := Color(0.96, 0.25, 0.42, 1.0)

# 註：Round 3 指定範圍使用生成的 StyleBoxTexture 9-slice skin；
# 缺圖、載入失敗或非本輪範圍時退回 _sticker_box（StyleBoxFlat）。
const ICON_STAGE := "res://Assets/final/ui/runtime/icon_stage_48.png"
const ICON_MULTIPLIER := "res://Assets/final/ui/runtime/icon_multiplier_48.png"
const ICON_PAYOUT := "res://Assets/final/ui/runtime/icon_payout_48.png"
const ICON_COIN := "res://Assets/final/ui/runtime/icon_coin_48.png"
const ICON_PAW := "res://Assets/final/ui/runtime/icon_paw_48.png"
const ICON_BACKPACK := "res://Assets/final/ui/runtime/icon_backpack_48.png"
const ICON_LOGIN := "res://Assets/final/ui/runtime/icon_login_48.png"
const ICON_CLOUD := "res://Assets/final/ui/runtime/icon_cloud_48.png"
const ICON_PLUS := "res://Assets/final/ui/runtime/icon_plus_48.png"
const ICON_MINUS := "res://Assets/final/ui/runtime/icon_minus_48.png"
const ICON_CAT_CAN := "res://Assets/final/ui/runtime/icon_cat_can_48.png"
const ICON_WARNING := "res://Assets/final/ui/runtime/icon_warning_48.png"
const ICON_TROPHY := "res://Assets/final/ui/runtime/icon_trophy_48.png"
const SKIN_CARD := "res://Assets/final/ui/skin_card.png"
const SKIN_PANEL := "res://Assets/final/ui/skin_panel.png"
const SKIN_BTN_PRIMARY := "res://Assets/final/ui/skin_btn_primary.png"
const SKIN_BTN_SECONDARY := "res://Assets/final/ui/skin_btn_secondary.png"
const SKIN_BTN_MINUS := "res://Assets/final/ui/skin_btn_minus.png"
const SKIN_BTN_PLUS := "res://Assets/final/ui/skin_btn_plus.png"
const SKIN_CHIP := "res://Assets/final/ui/skin_chip.png"
const SKIN_CHIP_ACTIVE := "res://Assets/final/ui/skin_chip_active.png"

# 對齊 ui_mockup_battle 的整圖美術素材（缺檔一律退回程式樣式，不崩）。
const TEX_LOGO := "res://Assets/final/logo.png"
const TEX_BOARD := "res://Assets/final/ui/board.png"
const TEX_BET_RIBBON := "res://Assets/final/ui/bet_info.png"
const TEX_BET_CONTEXT := "res://Assets/final/ui/bet_context.png"
const TEX_BTN_NEXT := "res://Assets/final/ui/next.png"
const TEX_BTN_RETREAT := "res://Assets/final/ui/retreat.png"

# mockup 色票（看板棕字、粉紅籌碼、藍色加號鈕）
const BOARD_BROWN := Color(0.47, 0.28, 0.16, 1.0)
const BOARD_INK := Color(0.3, 0.24, 0.19, 1.0)
const CHIP_PINK := Color(0.937, 0.337, 0.494, 1.0)
const CHIP_PINK_BORDER := Color(0.78, 0.2, 0.36, 1.0)
const CHIP_GOLD := Color(0.99, 0.76, 0.19, 1.0)
const CHIP_GOLD_BORDER := Color(0.85, 0.5, 0.1, 1.0)
const STEP_BLUE := Color(0.255, 0.71, 0.91, 1.0)
const STEP_BLUE_BORDER := Color(0.13, 0.5, 0.72, 1.0)


static func art_texture(name: String) -> Texture2D:
	var path := ""
	match name:
		"logo":
			path = TEX_LOGO
		"board":
			path = TEX_BOARD
		"bet_ribbon":
			path = TEX_BET_RIBBON
		"bet_context":
			path = TEX_BET_CONTEXT
		"btn_next":
			path = TEX_BTN_NEXT
		"btn_retreat":
			path = TEX_BTN_RETREAT
	if path.is_empty():
		return null
	return _load_texture(path)


static func apply_art_texture(rect: TextureRect, name: String) -> bool:
	if rect == null or not is_instance_valid(rect):
		return false
	var texture := art_texture(name)
	if texture == null:
		rect.visible = false
		return false
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.visible = true
	return true


## 整張美術圖（含烤字）作為按鈕外觀。成功回傳 true，呼叫端應清空 text；
## 失敗（缺檔）回傳 false，呼叫端退回 apply_button 文字樣式。
static func apply_art_button(button: Button, name: String) -> bool:
	if button == null or not is_instance_valid(button):
		return false
	var texture := art_texture(name)
	if texture == null:
		return false
	button.icon = null
	var normal := StyleBoxTexture.new()
	normal.texture = texture
	normal.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	normal.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	normal.draw_center = true
	_set_content_margins(normal, 0.0, 0.0, 0.0, 0.0)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxTexture
	hover.modulate_color = Color(1.08, 1.08, 1.08, 1.0)
	button.add_theme_stylebox_override("hover", hover)
	var pressed := normal.duplicate() as StyleBoxTexture
	pressed.modulate_color = Color(0.85, 0.85, 0.88, 1.0)
	button.add_theme_stylebox_override("pressed", pressed)
	var disabled := normal.duplicate() as StyleBoxTexture
	disabled.modulate_color = Color(0.55, 0.55, 0.6, 0.8)
	button.add_theme_stylebox_override("disabled", disabled)
	return true


## 怪物名牌與血條：去掉預設灰主題，改為奶油描邊字 + 粉紅血條（貼齊 mockup 風格）。
static func style_monster_status(name_label: Label, hp_bar: ProgressBar) -> void:
	if name_label != null and is_instance_valid(name_label):
		name_label.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		name_label.add_theme_color_override("font_color", CREAM)
		name_label.add_theme_color_override("font_outline_color", DEEP_NAVY)
		name_label.add_theme_constant_override("outline_size", 10)
	if hp_bar != null and is_instance_valid(hp_bar):
		var background := _flat_box(Color(1.0, 0.964706, 0.901961, 0.92), 18, 6, DEEP_NAVY)
		var fill := _flat_box(PINK, 12)
		hp_bar.add_theme_stylebox_override("background", background)
		hp_bar.add_theme_stylebox_override("fill", fill)


## 缺 board.png 時給 HUD 數值標籤的底板（缺檔不崩，仍可讀）。
static func fallback_value_box() -> StyleBoxFlat:
	var style := _sticker_box(CREAM, 24, 6, DEEP_NAVY, Color(0.08, 0.67, 0.62, 0.16))
	_set_content_margins(style, 16.0, 6.0, 16.0, 6.0)
	return style


static func apply_panel(panel: PanelContainer, style: String) -> void:
	if panel == null or not is_instance_valid(panel):
		return

	match style:
		"card":
			# HUD 貓耳卡已由 board.png 看板取代，skin_card 不再套用（缺路徑=用 fallback flat）
			var card := _skin_or_sticker_box(
				"",
				Vector4(CARD_MARGIN, CARD_MARGIN, CARD_MARGIN, CARD_MARGIN),
				CREAM,
				32,
				8,
				DEEP_NAVY,
				Color(0.08, 0.67, 0.62, 0.16)
			)
			_set_content_margins(card, 28.0, 20.0, 28.0, 20.0)
			panel.add_theme_stylebox_override("panel", card)
		"large":
			var large := _skin_or_sticker_box(
				SKIN_PANEL if _is_round3_panel(panel, style) else "",
				Vector4(PANEL_MARGIN, PANEL_MARGIN, PANEL_MARGIN, PANEL_MARGIN),
				CREAM,
				32,
				8,
				DEEP_NAVY,
				Color(0.96, 0.25, 0.42, 0.16)
			)
			_set_content_margins(large, 32.0, 24.0, 32.0, 24.0)
			panel.add_theme_stylebox_override("panel", large)
		_:
			var fallback_color := Color(1.0, 0.96, 0.84, 1.0) if style == "leaderboard_me" else CREAM
			var fallback_shadow := Color(1.0, 0.72, 0.12, 0.32) if style == "leaderboard_me" else Color(0.08, 0.67, 0.62, 0.16)
			var fallback := _sticker_box(fallback_color, 32, 8, DEEP_NAVY, fallback_shadow)
			_set_content_margins(fallback, 28.0, 20.0, 28.0, 20.0)
			panel.add_theme_stylebox_override("panel", fallback)


static func apply_button(button: Button, style: String) -> void:
	if button == null or not is_instance_valid(button):
		return

	button.icon = null
	var fallback_color := TEAL
	var font_color := Color(0.98, 0.98, 0.93, 1.0)
	var border_color := DEEP_NAVY
	var shadow_color := Color(0.96, 0.25, 0.42, 0.2)
	var radius := 28
	var content_margin := 52.0
	var text_outline_size := 8
	var skin_path := ""
	var texture_margins := Vector4(BUTTON_MARGIN, BUTTON_MARGIN, BUTTON_MARGIN, BUTTON_MARGIN)
	match style:
		"primary":
			skin_path = SKIN_BTN_PRIMARY
			_apply_button_icon(button, ICON_PAW)
		"primary_plain":
			pass
		"secondary":
			skin_path = SKIN_BTN_SECONDARY
			fallback_color = Color(0.96, 0.47, 0.23, 1.0)
			shadow_color = Color(0.96, 0.25, 0.42, 0.32)
			_apply_button_icon(button, ICON_BACKPACK)
		"login":
			skin_path = SKIN_BTN_SECONDARY
			fallback_color = Color(0.96, 0.47, 0.23, 1.0)
			shadow_color = Color(0.96, 0.25, 0.42, 0.32)
			_apply_button_icon(button, ICON_LOGIN)
		"small":
			fallback_color = CREAM
			font_color = DEEP_NAVY
			radius = 28
			content_margin = 10.0
			text_outline_size = 2
		"trophy_small":
			fallback_color = CREAM
			font_color = DEEP_NAVY
			radius = 28
			content_margin = 18.0
			text_outline_size = 2
			_apply_button_icon(button, ICON_TROPHY)
		"trophy_pill":
			# mockup 左上「玩家排行」粉紅膠囊
			fallback_color = CHIP_PINK
			font_color = CREAM
			border_color = CHIP_PINK_BORDER
			shadow_color = Color(0.78, 0.2, 0.36, 0.3)
			radius = 44
			content_margin = 22.0
			text_outline_size = 4
			_apply_button_icon(button, ICON_TROPHY)
		"step_decrease":
			# mockup 粉紅方形減號鈕
			fallback_color = CHIP_PINK
			font_color = CREAM
			border_color = CHIP_PINK_BORDER
			shadow_color = Color(0.78, 0.2, 0.36, 0.3)
			radius = 24
			content_margin = 10.0
			text_outline_size = 2
			_apply_button_icon(button, ICON_MINUS)
		"step_increase":
			# mockup 天藍方形加號鈕
			fallback_color = STEP_BLUE
			font_color = CREAM
			border_color = STEP_BLUE_BORDER
			shadow_color = Color(0.13, 0.5, 0.72, 0.3)
			radius = 24
			content_margin = 10.0
			text_outline_size = 2
			_apply_button_icon(button, ICON_PLUS)
		"chip":
			# mockup 粉紅籌碼藥丸（奶油字）
			fallback_color = CHIP_PINK
			font_color = CREAM
			border_color = CHIP_PINK_BORDER
			shadow_color = Color(0.78, 0.2, 0.36, 0.24)
			radius = 30
			content_margin = 14.0
			text_outline_size = 0
		"chip_selected":
			fallback_color = CHIP_GOLD
			font_color = Color(0.42, 0.26, 0.05, 1.0)
			border_color = CHIP_GOLD_BORDER
			shadow_color = Color(1.0, 0.72, 0.12, 0.35)
			radius = 30
			content_margin = 14.0
			text_outline_size = 0
		_:
			_apply_button_icon(button, ICON_PAW)

	var normal := _skin_or_sticker_box(skin_path, texture_margins, fallback_color, radius, 8, border_color, shadow_color)
	_set_content_margins(normal, content_margin, 12.0, content_margin, 12.0)
	button.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	_tint_stylebox(hover, Color(1.08, 1.08, 1.08, 1.0))
	button.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	_tint_stylebox(pressed, Color(0.86, 0.86, 0.9, 1.0))
	button.add_theme_stylebox_override("pressed", pressed)

	var disabled := normal.duplicate()
	_tint_stylebox(disabled, Color(0.55, 0.55, 0.62, 0.75))
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.94, 0.97, 1.0, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.9, 0.9, 0.86, 0.72))
	button.add_theme_color_override("font_outline_color", DEEP_NAVY)
	button.add_theme_constant_override("outline_size", text_outline_size)


static func apply_light_panel_label(label: Label) -> void:
	if label == null or not is_instance_valid(label):
		return
	label.add_theme_color_override("font_color", DEEP_NAVY)
	label.add_theme_color_override("font_outline_color", CREAM)
	label.add_theme_constant_override("outline_size", 2)


static func apply_hud_card_text(label: Label, role: String) -> void:
	if label == null or not is_instance_valid(label):
		return
	var color := DEEP_NAVY
	var outline_color := CREAM
	var outline_size := 2
	match role:
		"pink":
			color = PINK
		"teal":
			color = TEAL
		"gold":
			color = Color(0.95, 0.62, 0.06, 1.0)
		"value":
			color = CREAM
			outline_color = DEEP_NAVY
			outline_size = 10
		"board_caption":
			# 木質看板上的棕色欄位標題（底圖本身是奶油色，不需描邊）
			color = BOARD_BROWN
			outline_size = 0
		"board_value":
			color = BOARD_INK
			outline_size = 0
		"board_value_pink":
			color = PINK
			outline_size = 0
		"board_tab":
			# 粉紅頁籤上的奶油色小標
			color = CREAM
			outline_color = Color(0.78, 0.2, 0.36, 1.0)
			outline_size = 4
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", outline_color)
	label.add_theme_constant_override("outline_size", outline_size)


static func apply_title_label(label: Label) -> void:
	if label == null or not is_instance_valid(label):
		return
	label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", DEEP_NAVY)
	label.add_theme_constant_override("shadow_offset_x", 4)
	label.add_theme_constant_override("shadow_offset_y", 5)
	label.add_theme_color_override("font_outline_color", DEEP_NAVY)
	label.add_theme_constant_override("outline_size", 4)


static func apply_resource_label(label: Label) -> void:
	if label == null or not is_instance_valid(label):
		return
	var style := _sticker_box(CREAM, 28, 8, DEEP_NAVY, Color(0.08, 0.67, 0.62, 0.16))
	_set_content_margins(style, 54.0, 8.0, 18.0, 8.0)
	label.add_theme_stylebox_override("normal", style)
	label.add_theme_color_override("font_color", DEEP_NAVY)
	label.add_theme_color_override("font_outline_color", CREAM)
	label.add_theme_constant_override("outline_size", 2)


static func apply_ribbon_label(label: Label) -> void:
	if label == null or not is_instance_valid(label):
		return
	var style := _sticker_box(PINK, 32, 8, DEEP_NAVY, Color(0.96, 0.25, 0.42, 0.3))
	_set_content_margins(style, 28.0, 18.0, 28.0, 18.0)
	label.add_theme_stylebox_override("normal", style)
	label.add_theme_color_override("font_color", CREAM)
	label.add_theme_color_override("font_outline_color", DEEP_NAVY)
	label.add_theme_constant_override("outline_size", 10)


static func apply_number_display(label: Label) -> void:
	if label == null or not is_instance_valid(label):
		return
	var style := _sticker_box(Color(1.0, 0.96, 0.84, 1.0), 28, 8, DEEP_NAVY, Color(0.08, 0.67, 0.62, 0.18))
	_set_content_margins(style, 24.0, 10.0, 24.0, 10.0)
	label.add_theme_stylebox_override("normal", style)
	label.add_theme_color_override("font_color", CREAM)
	label.add_theme_color_override("font_outline_color", DEEP_NAVY)
	label.add_theme_constant_override("outline_size", 10)


static func apply_modal_title(label: Label) -> void:
	if label == null or not is_instance_valid(label):
		return
	label.remove_theme_stylebox_override("normal")
	label.add_theme_color_override("font_color", CREAM)
	label.add_theme_color_override("font_outline_color", DEEP_NAVY)
	label.add_theme_constant_override("outline_size", 10)


static func apply_icon(texture_rect: TextureRect, name: String) -> void:
	if texture_rect == null or not is_instance_valid(texture_rect):
		return
	var path := ""
	match name:
		"stage":
			path = ICON_STAGE
		"multiplier":
			path = ICON_MULTIPLIER
		"payout":
			path = ICON_PAYOUT
		"coin":
			path = ICON_COIN
		"paw":
			path = ICON_PAW
		"backpack":
			path = ICON_BACKPACK
		"login":
			path = ICON_LOGIN
		"cloud":
			path = ICON_CLOUD
		"cat_can":
			path = ICON_CAT_CAN
		"warning":
			path = ICON_WARNING
		"trophy":
			path = ICON_TROPHY
		"plus":
			path = ICON_PLUS
		"minus":
			path = ICON_MINUS
	if path.is_empty():
		texture_rect.visible = false
		return
	var texture := _load_texture(path)
	if texture == null:
		texture_rect.visible = false
		return
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.visible = true


static func _sticker_box(color: Color, radius: int, border_width: int, border_color: Color, shadow_color: Color) -> StyleBoxFlat:
	var style := _flat_box(color, radius, border_width, border_color)
	style.shadow_color = shadow_color
	style.shadow_size = 8
	style.shadow_offset = Vector2(0.0, 4.0)
	style.anti_aliasing = true
	return style


static func _skin_or_sticker_box(
	path: String,
	texture_margins: Vector4,
	fallback_color: Color,
	radius: int,
	border_width: int,
	border_color: Color,
	shadow_color: Color
) -> StyleBox:
	if not path.is_empty():
		var texture := _load_texture(path)
		if texture != null:
			var style := StyleBoxTexture.new()
			style.texture = texture
			style.texture_margin_left = texture_margins.x
			style.texture_margin_top = texture_margins.y
			style.texture_margin_right = texture_margins.z
			style.texture_margin_bottom = texture_margins.w
			style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
			style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
			style.draw_center = true
			return style

	return _sticker_box(fallback_color, radius, border_width, border_color, shadow_color)


static func _is_round3_panel(panel: PanelContainer, style: String) -> bool:
	var path := str(panel.get_path())
	match style:
		"large":
			return path.contains("/ActionArea/BetPanel/Panel")
	return false


static func apply_leaderboard_hint(panel: PanelContainer) -> void:
	if panel == null or not is_instance_valid(panel):
		return
	var style := _sticker_box(Color(1.0, 0.96, 0.84, 1.0), 26, 7, DEEP_NAVY, Color(0.08, 0.67, 0.62, 0.18))
	_set_content_margins(style, 24.0, 12.0, 24.0, 12.0)
	panel.add_theme_stylebox_override("panel", style)


static func _flat_box(color: Color, radius: int, border_width: int = 0, border_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	_set_content_margins(style, 0.0, 0.0, 0.0, 0.0)
	return style


static func _tint_stylebox(style: StyleBox, color: Color) -> void:
	if style is StyleBoxFlat:
		var flat := style as StyleBoxFlat
		flat.bg_color = flat.bg_color * color


static func _apply_button_icon(button: Button, path: String) -> void:
	var texture := _load_texture(path)
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = false
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER if button.text.is_empty() else HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_constant_override("h_separation", 18)


static func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path, "Texture2D"):
		var imported := load(path) as Texture2D
		if imported != null:
			return imported

	if not FileAccess.file_exists(path):
		return null

	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_warning("UiSkin could not load PNG texture: %s" % path)
		return null
	return ImageTexture.create_from_image(image)


static func _set_content_margins(style: StyleBox, left: float, top: float, right: float, bottom: float) -> void:
	style.set_content_margin(SIDE_LEFT, left)
	style.set_content_margin(SIDE_TOP, top)
	style.set_content_margin(SIDE_RIGHT, right)
	style.set_content_margin(SIDE_BOTTOM, bottom)
