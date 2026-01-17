extends RefCounted
## RetroUITheme - Classic 90s DOS-era pixel art theme for Der Planer

# Classic DOS/Amiga color palette
const COLOR_CYAN_BG = Color(0.0, 0.6, 0.6)  # Classic cyan background
const COLOR_CYAN_LIGHT = Color(0.0, 0.8, 0.8)  # Light cyan for highlights
const COLOR_CYAN_DARK = Color(0.0, 0.4, 0.4)  # Dark cyan for shadows
const COLOR_AMBER = Color(1.0, 0.7, 0.0)  # Amber/orange text
const COLOR_WHITE = Color(1.0, 1.0, 1.0)  # White text
const COLOR_BLACK = Color(0.0, 0.0, 0.0)  # Black
const COLOR_DARK_GRAY = Color(0.2, 0.2, 0.3)  # Dark gray for panels
const COLOR_LIGHT_GRAY = Color(0.7, 0.7, 0.8)  # Light gray for borders
const COLOR_RED = Color(1.0, 0.2, 0.2)  # Red for warnings
const COLOR_GREEN = Color(0.2, 1.0, 0.3)  # Green for success

## Creates a retro-styled panel with beveled edges
static func create_retro_panel(bg_color: Color = COLOR_DARK_GRAY) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color

	# Beveled 3D effect (classic 90s style)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_LIGHT_GRAY

	# Sharp corners (no rounded edges - pixel perfect)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0

	# Inner shadow effect for 3D look
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 1

	return style

## Creates a retro button with classic raised/pressed effect
static func create_retro_button(color: Color = COLOR_CYAN_BG, pressed: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color

	if pressed:
		# Pressed state - inverted bevel
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = COLOR_CYAN_DARK
	else:
		# Normal state - raised bevel
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = COLOR_CYAN_LIGHT

	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0

	return style

## Creates a calculator-style display (like in classic Der Planer)
static func create_calculator_display() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.15, 0.2)  # Dark screen

	# Inset border effect
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.0, 0.0, 0.0)

	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0

	return style

## Applies retro theme to a button
static func apply_retro_button_theme(button: Button, color: Color = COLOR_CYAN_BG) -> void:
	button.add_theme_stylebox_override("normal", create_retro_button(color, false))
	button.add_theme_stylebox_override("hover", create_retro_button(color.lightened(0.1), false))
	button.add_theme_stylebox_override("pressed", create_retro_button(color.darkened(0.1), true))
	button.add_theme_color_override("font_color", COLOR_AMBER)
	button.add_theme_color_override("font_hover_color", COLOR_WHITE)
	button.add_theme_font_size_override("font_size", 14)

## Creates a retro-styled label with classic font
static func create_retro_label(text: String, size: int = 14, color: Color = COLOR_AMBER) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

## Creates pixelated separator line
static func create_separator_line(width: float, color: Color = COLOR_CYAN_LIGHT) -> ColorRect:
	var line = ColorRect.new()
	line.custom_minimum_size = Vector2(width, 2)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.color = color
	return line
