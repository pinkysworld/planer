extends Control
## NavigationBar - Der Planer style top navigation bar for room dialogs

const ICON_SIZE: int = 32

signal laptop_clicked()
signal money_clicked()
signal statistics_clicked()
signal email_clicked()
signal settings_clicked()
signal close_clicked()

var laptop_btn: Button
var money_btn: Button
var stats_btn: Button
var email_btn: Button
var settings_btn: Button
var close_btn: Button

func _ready() -> void:
	_create_navigation_bar()

func _create_navigation_bar() -> void:
	# Main container
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bg.size.y = 48
	bg.color = Color(0.2, 0.25, 0.3, 0.95)
	add_child(bg)

	# Icon container
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hbox.offset_left = 10
	hbox.offset_right = -10
	hbox.offset_top = 8
	hbox.offset_bottom = 40
	hbox.add_theme_constant_override("separation", 8)
	add_child(hbox)

	# Create nav buttons
	laptop_btn = _create_nav_button("COMPUTER", Color(0.5, 0.7, 0.9))
	laptop_btn.pressed.connect(func(): emit_signal("laptop_clicked"))
	hbox.add_child(laptop_btn)

	money_btn = _create_nav_button("MONEY", Color(0.3, 0.9, 0.4))
	money_btn.pressed.connect(func(): emit_signal("money_clicked"))
	hbox.add_child(money_btn)

	stats_btn = _create_nav_button("STATS", Color(0.9, 0.7, 0.3))
	stats_btn.pressed.connect(func(): emit_signal("statistics_clicked"))
	hbox.add_child(stats_btn)

	email_btn = _create_nav_button("EMAIL", Color(0.9, 0.5, 0.5))
	email_btn.pressed.connect(func(): emit_signal("email_clicked"))
	hbox.add_child(email_btn)

	settings_btn = _create_nav_button("OPTIONS", Color(0.7, 0.7, 0.7))
	settings_btn.pressed.connect(func(): emit_signal("settings_clicked"))
	hbox.add_child(settings_btn)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# Close button on right
	close_btn = _create_nav_button("X", Color(1, 0.4, 0.4))
	close_btn.pressed.connect(func(): emit_signal("close_clicked"))
	hbox.add_child(close_btn)

func _create_nav_button(text: String, icon_color: Color) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(80, 32)

	# Create icon representation using ColorRect
	var icon_container = Control.new()
	icon_container.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)

	# Icon background
	var icon_bg = ColorRect.new()
	icon_bg.size = Vector2(ICON_SIZE, ICON_SIZE)
	icon_bg.color = icon_color
	icon_container.add_child(icon_bg)

	# Icon border
	var border = Control.new()
	for i in range(ICON_SIZE):
		# Top and bottom
		var top_pixel = ColorRect.new()
		top_pixel.size = Vector2(1, 1)
		top_pixel.position = Vector2(i, 0)
		top_pixel.color = Color(0, 0, 0)
		border.add_child(top_pixel)

		var bottom_pixel = ColorRect.new()
		bottom_pixel.size = Vector2(1, 1)
		bottom_pixel.position = Vector2(i, ICON_SIZE - 1)
		bottom_pixel.color = Color(0, 0, 0)
		border.add_child(bottom_pixel)

	for i in range(ICON_SIZE):
		# Left and right
		var left_pixel = ColorRect.new()
		left_pixel.size = Vector2(1, 1)
		left_pixel.position = Vector2(0, i)
		left_pixel.color = Color(0, 0, 0)
		border.add_child(left_pixel)

		var right_pixel = ColorRect.new()
		right_pixel.size = Vector2(1, 1)
		right_pixel.position = Vector2(ICON_SIZE - 1, i)
		right_pixel.color = Color(0, 0, 0)
		border.add_child(right_pixel)

	icon_container.add_child(border)

	# Label below icon
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Combine in vbox
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.add_child(icon_container)
	vbox.add_child(label)

	# Note: In actual implementation, you'd set this as a custom icon
	# For now, we set the text
	btn.text = text
	btn.add_theme_font_size_override("font_size", 11)

	return btn

func set_laptop_enabled(enabled: bool) -> void:
	if laptop_btn:
		laptop_btn.disabled = not enabled

func set_money_enabled(enabled: bool) -> void:
	if money_btn:
		money_btn.disabled = not enabled

func set_stats_enabled(enabled: bool) -> void:
	if stats_btn:
		stats_btn.disabled = not enabled

func set_email_enabled(enabled: bool) -> void:
	if email_btn:
		email_btn.disabled = not enabled
