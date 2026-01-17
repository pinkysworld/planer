extends Control
## RetroMainMenu - Classic 90s pixel art style main menu

const RetroTheme = preload("res://scripts/ui/retro_ui_theme.gd")

func _ready() -> void:
	_create_retro_menu()
	AudioManager.play_music("menu")

	# Instant display (no fade - classic style)
	modulate.a = 1.0

func _create_retro_menu() -> void:
	# Classic cyan background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = RetroTheme.COLOR_CYAN_BG
	add_child(bg)

	# Add scanline effect for CRT monitor feel
	_add_scanline_effect(bg)

	# Top decorative border (classic DOS style)
	var top_border = ColorRect.new()
	top_border.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_border.custom_minimum_size = Vector2(0, 4)
	top_border.color = RetroTheme.COLOR_CYAN_LIGHT
	add_child(top_border)

	# Title area (upper third of screen)
	var title_container = VBoxContainer.new()
	title_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title_container.offset_top = 60
	title_container.offset_left = -400
	title_container.offset_right = 400
	title_container.add_theme_constant_override("separation", 5)
	add_child(title_container)

	# Game title - pixel art style
	var title = Label.new()
	title.text = "DER PLANER"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", RetroTheme.COLOR_AMBER)
	title.add_theme_color_override("font_outline_color", RetroTheme.COLOR_BLACK)
	title.add_theme_constant_override("outline_size", 2)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_container.add_child(title)

	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "TRANSPORT MANAGEMENT SIMULATION"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", RetroTheme.COLOR_WHITE)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_container.add_child(subtitle)

	# Separator line
	title_container.add_child(RetroTheme.create_separator_line(600))

	# Version info
	var version = Label.new()
	version.text = "VERSION 1.0 - ENTERPRISE EDITION"
	version.add_theme_font_size_override("font_size", 10)
	version.add_theme_color_override("font_color", RetroTheme.COLOR_LIGHT_GRAY)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_container.add_child(version)

	# Menu panel (center)
	var menu_panel = Panel.new()
	menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	menu_panel.offset_left = -250
	menu_panel.offset_right = 250
	menu_panel.offset_top = -150
	menu_panel.offset_bottom = 150
	menu_panel.add_theme_stylebox_override("panel", RetroTheme.create_retro_panel())
	add_child(menu_panel)

	# Menu title bar (like classic Windows 3.1)
	var menu_title_bar = ColorRect.new()
	menu_title_bar.custom_minimum_size = Vector2(0, 25)
	menu_title_bar.color = RetroTheme.COLOR_DARK_GRAY
	menu_title_bar.position = Vector2(2, 2)
	menu_title_bar.size = Vector2(496, 25)
	menu_panel.add_child(menu_title_bar)

	var menu_title = Label.new()
	menu_title.text = "[ HAUPTMENU ]"  # German: Main Menu
	menu_title.add_theme_font_size_override("font_size", 12)
	menu_title.add_theme_color_override("font_color", RetroTheme.COLOR_WHITE)
	menu_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	menu_title.position = Vector2(0, 0)
	menu_title.size = Vector2(496, 25)
	menu_title_bar.add_child(menu_title)

	# Button container
	var button_container = VBoxContainer.new()
	button_container.position = Vector2(50, 40)
	button_container.size = Vector2(400, 250)
	button_container.add_theme_constant_override("separation", 12)
	menu_panel.add_child(button_container)

	# Create menu buttons
	var buttons = [
		{"text": "NEUES SPIEL STARTEN", "callback": _on_new_game_pressed},  # New Game
		{"text": "SPIELSTAND LADEN", "callback": _on_load_game_pressed},  # Load Game
		{"text": "EINSTELLUNGEN", "callback": _on_settings_pressed},  # Settings
		{"text": "BEENDEN", "callback": _on_quit_pressed}  # Quit
	]

	for btn_data in buttons:
		var btn = _create_menu_button(btn_data.text)
		btn.pressed.connect(btn_data.callback)
		button_container.add_child(btn)

	# Bottom info bar (like classic DOS programs)
	var info_bar = Panel.new()
	info_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	info_bar.offset_top = -30
	info_bar.add_theme_stylebox_override("panel", RetroTheme.create_calculator_display())
	add_child(info_bar)

	var info_label = Label.new()
	info_label.text = "© 1995 SIMULATION SOFTWARE - F1=HILFE | ESC=BEENDEN"
	info_label.add_theme_font_size_override("font_size", 10)
	info_label.add_theme_color_override("font_color", RetroTheme.COLOR_AMBER)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	info_bar.add_child(info_label)

func _create_menu_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(400, 45)
	RetroTheme.apply_retro_button_theme(btn)

	# Add hover sound
	btn.mouse_entered.connect(func(): AudioManager.play_sfx("ui_hover"))

	return btn

func _add_scanline_effect(bg: ColorRect) -> void:
	# Create subtle scanline overlay for CRT effect
	var scanlines = ColorRect.new()
	scanlines.set_anchors_preset(Control.PRESET_FULL_RECT)
	scanlines.color = Color(0, 0, 0, 0.1)
	scanlines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(scanlines)

func _on_new_game_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/scenario_selector.tscn")

func _on_load_game_pressed() -> void:
	AudioManager.play_sfx("click")
	# Load most recent save
	if SaveManager.load_game(1):
		get_tree().change_scene_to_file("res://scenes/office_building_planer.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("click")
	_show_settings_dialog()

func _on_quit_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().quit()

func _show_settings_dialog() -> void:
	# Create modal settings dialog (classic DOS style)
	var dialog_bg = ColorRect.new()
	dialog_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialog_bg.color = Color(0, 0, 0, 0.7)
	add_child(dialog_bg)

	var dialog = Panel.new()
	dialog.set_anchors_preset(Control.PRESET_CENTER)
	dialog.offset_left = -300
	dialog.offset_right = 300
	dialog.offset_top = -200
	dialog.offset_bottom = 200
	dialog.add_theme_stylebox_override("panel", RetroTheme.create_retro_panel())
	dialog_bg.add_child(dialog)

	# Dialog title bar
	var title_bar = ColorRect.new()
	title_bar.custom_minimum_size = Vector2(0, 25)
	title_bar.color = RetroTheme.COLOR_DARK_GRAY
	title_bar.position = Vector2(2, 2)
	title_bar.size = Vector2(596, 25)
	dialog.add_child(title_bar)

	var title = Label.new()
	title.text = "[ EINSTELLUNGEN ]"
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", RetroTheme.COLOR_WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.size = Vector2(596, 25)
	title_bar.add_child(title)

	# Settings content
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(30, 40)
	vbox.size = Vector2(540, 320)
	vbox.add_theme_constant_override("separation", 15)
	dialog.add_child(vbox)

	# Resolution
	var res_hbox = HBoxContainer.new()
	var res_label = RetroTheme.create_retro_label("AUFLÖSUNG:", 12, RetroTheme.COLOR_WHITE)
	res_label.custom_minimum_size = Vector2(200, 0)
	res_hbox.add_child(res_label)

	var res_option = OptionButton.new()
	for res in SettingsManager.RESOLUTIONS:
		res_option.add_item("%dx%d" % [res.x, res.y])
	res_option.selected = SettingsManager.get_resolution_index()
	res_option.item_selected.connect(func(idx): SettingsManager.set_resolution(SettingsManager.RESOLUTIONS[idx].x, SettingsManager.RESOLUTIONS[idx].y))
	res_hbox.add_child(res_option)
	vbox.add_child(res_hbox)

	# Fullscreen
	var fs_hbox = HBoxContainer.new()
	var fs_label = RetroTheme.create_retro_label("VOLLBILD:", 12, RetroTheme.COLOR_WHITE)
	fs_label.custom_minimum_size = Vector2(200, 0)
	fs_hbox.add_child(fs_label)

	var fs_check = CheckBox.new()
	fs_check.button_pressed = SettingsManager.is_fullscreen
	fs_check.toggled.connect(SettingsManager.set_fullscreen)
	fs_hbox.add_child(fs_check)
	vbox.add_child(fs_hbox)

	# Close button
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer)

	var close_btn = _create_menu_button("SCHLIESSEN")  # Close
	close_btn.custom_minimum_size = Vector2(200, 40)
	close_btn.pressed.connect(func(): dialog_bg.queue_free())
	vbox.add_child(close_btn)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_quit_pressed()
