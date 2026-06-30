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
const ICON_PLUS := "res://Assets/final/ui/runtime/icon_plus_48.png"
const ICON_MINUS := "res://Assets/final/ui/runtime/icon_minus_48.png"
const ICON_CAT_CAN := "res://Assets/final/ui/runtime/icon_cat_can_48.png"
const ICON_WARNING := "res://Assets/final/ui/runtime/icon_warning_48.png"
const SKIN_CARD := "res://Assets/final/ui/skin_card.png"
const SKIN_PANEL := "res://Assets/final/ui/skin_panel.png"
const SKIN_BTN_PRIMARY := "res://Assets/final/ui/skin_btn_primary.png"
const SKIN_BTN_SECONDARY := "res://Assets/final/ui/skin_btn_secondary.png"
const SKIN_BTN_MINUS := "res://Assets/final/ui/skin_btn_minus.png"
const SKIN_BTN_PLUS := "res://Assets/final/ui/skin_btn_plus.png"
const SKIN_CHIP := "res://Assets/final/ui/skin_chip.png"
const SKIN_CHIP_ACTIVE := "res://Assets/final/ui/skin_chip_active.png"


static func apply_panel(panel: PanelContainer, style: String) -> void:
	if panel == null or not is_instance_valid(panel):
		return

	match style:
		"card":
			var card := _skin_or_sticker_box(
				SKIN_CARD if _is_round3_panel(panel, style) else "",
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
			var fallback := _sticker_box(CREAM, 32, 8, DEEP_NAVY, Color(0.08, 0.67, 0.62, 0.16))
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
		"small":
			fallback_color = CREAM
			font_color = DEEP_NAVY
			radius = 28
			content_margin = 10.0
			text_outline_size = 2
		"step_decrease":
			skin_path = SKIN_BTN_MINUS
			fallback_color = CREAM
			font_color = DEEP_NAVY
			radius = 28
			content_margin = 10.0
			text_outline_size = 2
			_apply_button_icon(button, ICON_MINUS)
		"step_increase":
			skin_path = SKIN_BTN_PLUS
			fallback_color = CREAM
			font_color = DEEP_NAVY
			radius = 28
			content_margin = 10.0
			text_outline_size = 2
			_apply_button_icon(button, ICON_PLUS)
		"chip":
			skin_path = SKIN_CHIP
			texture_margins = Vector4(CHIP_MARGIN_X, CHIP_MARGIN_Y, CHIP_MARGIN_X, CHIP_MARGIN_Y)
			fallback_color = CREAM
			font_color = DEEP_NAVY
			border_color = DEEP_NAVY
			radius = 28
			content_margin = 14.0
			text_outline_size = 2
		"chip_selected":
			skin_path = SKIN_CHIP_ACTIVE
			texture_margins = Vector4(CHIP_MARGIN_X, CHIP_MARGIN_Y, CHIP_MARGIN_X, CHIP_MARGIN_Y)
			fallback_color = Color(0.08, 0.67, 0.62, 1.0)
			font_color = Color(1.0, 0.98, 0.86, 1.0)
			border_color = DEEP_NAVY
			shadow_color = Color(1.0, 0.72, 0.12, 0.35)
			radius = 28
			content_margin = 14.0
			text_outline_size = 2
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
		"cat_can":
			path = ICON_CAT_CAN
		"warning":
			path = ICON_WARNING
		"plus":
			path = ICON_PLUS
		"minus":
			path = ICON_MINUS
	if path.is_empty() or not FileAccess.file_exists(path):
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
		"card":
			return path.contains("/Hud/Columns/")
		"large":
			return path.contains("/ActionArea/BetPanel/Panel")
	return false


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
	if not FileAccess.file_exists(path):
		return
	var texture := _load_texture(path)
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = false
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER if button.text.is_empty() else HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_constant_override("h_separation", 18)


static func _load_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	if ResourceLoader.exists(path, "Texture2D"):
		var imported := load(path) as Texture2D
		if imported != null:
			return imported

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
