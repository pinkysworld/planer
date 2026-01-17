extends Control
## RetroGameHUD - Classic 90s pixel art style HUD with calculator-style display

const RetroTheme = preload("res://scripts/ui/retro_ui_theme.gd")

# HUD elements
var day_label: Label
var time_label: Label
var money_label: Label
var trucks_label: Label
var status_label: Label
var calculator_panel: Panel

func _ready() -> void:
	_create_retro_hud()
	_connect_signals()
	_update_display()

func _create_retro_hud() -> void:
	# Top information bar (classic DOS style)
	var top_bar = Panel.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.custom_minimum_size = Vector2(0, 30)
	top_bar.add_theme_stylebox_override("panel", RetroTheme.create_retro_panel(RetroTheme.COLOR_DARK_GRAY))
	add_child(top_bar)

	var top_hbox = HBoxContainer.new()
	top_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	top_hbox.offset_left = 10
	top_hbox.offset_right = -10
	top_hbox.offset_top = 5
	top_hbox.offset_bottom = -5
	top_hbox.add_theme_constant_override("separation", 20)
	top_bar.add_child(top_hbox)

	# Day display
	day_label = RetroTheme.create_retro_label("TAG: 1", 12, RetroTheme.COLOR_AMBER)
	top_hbox.add_child(day_label)

	# Time display (digital clock style)
	time_label = RetroTheme.create_retro_label("ZEIT: 08:00", 12, RetroTheme.COLOR_AMBER)
	top_hbox.add_child(time_label)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(spacer)

	# Money display
	money_label = RetroTheme.create_retro_label("KASSE: 50.000 DM", 12, RetroTheme.COLOR_GREEN)
	top_hbox.add_child(money_label)

	# Trucks display
	trucks_label = RetroTheme.create_retro_label("LKW: 0", 12, RetroTheme.COLOR_WHITE)
	top_hbox.add_child(trucks_label)

	# Bottom calculator-style control panel (like classic Der Planer)
	calculator_panel = Panel.new()
	calculator_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	calculator_panel.offset_top = -120
	calculator_panel.add_theme_stylebox_override("panel", RetroTheme.create_calculator_display())
	add_child(calculator_panel)

	# Calculator content area
	var calc_vbox = VBoxContainer.new()
	calc_vbox.position = Vector2(10, 10)
	calc_vbox.size = Vector2(get_viewport().get_visible_rect().size.x - 20, 100)
	calc_vbox.add_theme_constant_override("separation", 8)
	calculator_panel.add_child(calc_vbox)

	# Display area (like LCD screen)
	var display_panel = Panel.new()
	display_panel.custom_minimum_size = Vector2(0, 35)
	display_panel.add_theme_stylebox_override("panel", RetroTheme.create_retro_panel(Color(0.05, 0.1, 0.15)))
	calc_vbox.add_child(display_panel)

	status_label = Label.new()
	status_label.text = "BEREIT - WAEHLEN SIE EINE AKTION"  # Ready - Choose an action
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", RetroTheme.COLOR_AMBER)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	status_label.offset_left = 10
	status_label.offset_right = -10
	display_panel.add_child(status_label)

	# Button grid (calculator-style buttons)
	var button_grid = HBoxContainer.new()
	button_grid.add_theme_constant_override("separation", 5)
	calc_vbox.add_child(button_grid)

	# Speed control buttons
	var speed_panel = VBoxContainer.new()
	speed_panel.add_theme_constant_override("separation", 5)
	button_grid.add_child(speed_panel)

	var speed_label = RetroTheme.create_retro_label("GESCHWINDIGKEIT:", 10, RetroTheme.COLOR_LIGHT_GRAY)
	speed_panel.add_child(speed_label)

	var speed_hbox = HBoxContainer.new()
	speed_hbox.add_theme_constant_override("separation", 5)
	speed_panel.add_child(speed_hbox)

	# Pause button
	var pause_btn = _create_calc_button("||", 60)
	pause_btn.pressed.connect(_on_pause_pressed)
	speed_hbox.add_child(pause_btn)

	# Speed buttons
	var speed1_btn = _create_calc_button("1X", 60)
	speed1_btn.pressed.connect(_on_speed1_pressed)
	speed_hbox.add_child(speed1_btn)

	var speed2_btn = _create_calc_button("2X", 60)
	speed2_btn.pressed.connect(_on_speed2_pressed)
	speed_hbox.add_child(speed2_btn)

	var speed3_btn = _create_calc_button("5X", 60)
	speed3_btn.pressed.connect(_on_speed3_pressed)
	speed_hbox.add_child(speed3_btn)

	# Spacer
	var middle_spacer = Control.new()
	middle_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_grid.add_child(middle_spacer)

	# Menu button
	var menu_btn = _create_calc_button("MENU", 120)
	menu_btn.pressed.connect(_on_menu_pressed)
	button_grid.add_child(menu_btn)

func _create_calc_button(text: String, width: int = 80) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(width, 40)
	RetroTheme.apply_retro_button_theme(btn, RetroTheme.COLOR_CYAN_DARK)
	btn.mouse_entered.connect(func(): AudioManager.play_sfx("ui_hover"))
	return btn

func _connect_signals() -> void:
	GameManager.day_changed.connect(_on_day_changed)
	GameManager.time_changed.connect(_on_time_changed)
	GameManager.money_changed.connect(_on_money_changed)

func _process(_delta: float) -> void:
	_update_time_display()

func _update_display() -> void:
	_update_day_display()
	_update_time_display()
	_update_money_display()
	_update_trucks_display()

func _update_day_display() -> void:
	if day_label:
		day_label.text = "TAG: %d" % GameManager.current_day

func _update_time_display() -> void:
	if time_label:
		time_label.text = "ZEIT: %02d:%02d" % [GameManager.current_hour, GameManager.current_minute]

func _update_money_display() -> void:
	if money_label:
		var money = GameManager.company_money
		money_label.text = "KASSE: %s DM" % _format_money(money)

		# Color coding
		if money < 10000:
			money_label.add_theme_color_override("font_color", RetroTheme.COLOR_RED)
		elif money > 100000:
			money_label.add_theme_color_override("font_color", RetroTheme.COLOR_GREEN)
		else:
			money_label.add_theme_color_override("font_color", RetroTheme.COLOR_AMBER)

func _update_trucks_display() -> void:
	if trucks_label:
		trucks_label.text = "LKW: %d" % GameManager.trucks.size()

func _format_money(amount: float) -> String:
	# German-style number formatting with periods as thousand separators
	var formatted = "%.0f" % amount
	var result = ""
	var count = 0

	for i in range(formatted.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "." + result
		result = formatted[i] + result
		count += 1

	return result

func _on_day_changed(_day: int) -> void:
	_update_day_display()

func _on_time_changed(_hour: int, _minute: int) -> void:
	_update_time_display()

func _on_money_changed(_company: float, _private: float) -> void:
	_update_money_display()

func update_status(message: String) -> void:
	if status_label:
		status_label.text = message

func show_hint(text: String) -> void:
	update_status(text)

func hide_hint() -> void:
	update_status("BEREIT - WAEHLEN SIE EINE AKTION")

func update_location(location: String) -> void:
	update_status("STANDORT: %s" % location)

func show_interaction_hint(text: String) -> void:
	show_hint(text)

func hide_interaction_hint() -> void:
	hide_hint()

func _on_pause_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.set_game_speed(0.0)
	GameManager.pause_game()
	update_status("PAUSE")

func _on_speed1_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.resume_game()
	GameManager.set_game_speed(1.0)
	update_status("GESCHWINDIGKEIT: NORMAL")

func _on_speed2_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.resume_game()
	GameManager.set_game_speed(2.0)
	update_status("GESCHWINDIGKEIT: SCHNELL")

func _on_speed3_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.resume_game()
	GameManager.set_game_speed(4.0)
	update_status("GESCHWINDIGKEIT: SEHR SCHNELL")

func _on_menu_pressed() -> void:
	AudioManager.play_sfx("click")
	var pause_menu = get_parent().get_node_or_null("PauseMenu")
	if pause_menu:
		pause_menu.visible = true
		GameManager.pause_game()
