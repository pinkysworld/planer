extends Control
## ProfessionalMainMenu - Steam-quality main menu

@onready var title_container: Control
@onready var button_container: VBoxContainer
@onready var version_label: Label
@onready var settings_panel: Control
@onready var credits_panel: Control

const VERSION: String = "v1.0.0"

func _ready() -> void:
	_create_professional_menu()
	_create_animated_background()
	AudioManager.play_music("menu")

	# Fade in effect
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _create_professional_menu() -> void:
	# Background gradient
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var gradient = Gradient.new()
	gradient.colors = [Color(0.1, 0.15, 0.2), Color(0.2, 0.25, 0.35)]
	bg.color = Color(0.15, 0.2, 0.25)
	add_child(bg)

	# Logo area
	var logo_container = VBoxContainer.new()
	logo_container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	logo_container.offset_top = 100
	logo_container.offset_left = -300
	logo_container.offset_right = 300
	logo_container.add_theme_constant_override("separation", 10)
	add_child(logo_container)

	# Game title with shadow
	var title_shadow = Label.new()
	title_shadow.text = "DER PLANER"
	title_shadow.add_theme_font_size_override("font_size", 72)
	title_shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.5))
	title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo_container.add_child(title_shadow)

	var title = Label.new()
	title.text = "DER PLANER"
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position.y = -2
	logo_container.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Transport Empire Simulator"
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo_container.add_child(subtitle)

	# Menu buttons
	button_container = VBoxContainer.new()
	button_container.set_anchors_preset(Control.PRESET_CENTER)
	button_container.offset_left = -150
	button_container.offset_right = 150
	button_container.offset_top = -120
	button_container.offset_bottom = 120
	button_container.add_theme_constant_override("separation", 15)
	add_child(button_container)

	# Create professional buttons
	var new_game_btn = _create_menu_button("NEW GAME", Color(0.3, 0.7, 0.4))
	new_game_btn.pressed.connect(_on_new_game_pressed)
	button_container.add_child(new_game_btn)

	var continue_btn = _create_menu_button("CONTINUE", Color(0.5, 0.7, 0.9))
	continue_btn.pressed.connect(_on_continue_pressed)
	button_container.add_child(continue_btn)

	var load_btn = _create_menu_button("LOAD GAME", Color(0.6, 0.6, 0.8))
	load_btn.pressed.connect(_on_load_pressed)
	button_container.add_child(load_btn)

	var settings_btn = _create_menu_button("SETTINGS", Color(0.7, 0.7, 0.7))
	settings_btn.pressed.connect(_on_settings_pressed)
	button_container.add_child(settings_btn)

	var credits_btn = _create_menu_button("CREDITS", Color(0.8, 0.7, 0.5))
	credits_btn.pressed.connect(_on_credits_pressed)
	button_container.add_child(credits_btn)

	var quit_btn = _create_menu_button("QUIT", Color(0.8, 0.3, 0.3))
	quit_btn.pressed.connect(_on_quit_pressed)
	button_container.add_child(quit_btn)

	# Version label
	version_label = Label.new()
	version_label.text = VERSION
	version_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	version_label.offset_left = -100
	version_label.offset_top = -30
	version_label.offset_right = -10
	version_label.offset_bottom = -10
	version_label.add_theme_font_size_override("font_size", 14)
	version_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	add_child(version_label)

	# Copyright
	var copyright = Label.new()
	copyright.text = "© 2024 - Built with Godot Engine"
	copyright.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	copyright.offset_left = 10
	copyright.offset_top = -30
	copyright.offset_right = 300
	copyright.offset_bottom = -10
	copyright.add_theme_font_size_override("font_size", 12)
	copyright.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
	add_child(copyright)

func _create_menu_button(text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(300, 50)

	# Normal style
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = color.darkened(0.3)
	normal_style.border_color = color
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", normal_style)

	# Hover style
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = color
	hover_style.border_color = color.lightened(0.3)
	hover_style.border_width_left = 2
	hover_style.border_width_right = 2
	hover_style.border_width_top = 2
	hover_style.border_width_bottom = 2
	hover_style.corner_radius_top_left = 4
	hover_style.corner_radius_top_right = 4
	hover_style.corner_radius_bottom_left = 4
	hover_style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("hover", hover_style)

	# Pressed style
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = color.darkened(0.5)
	pressed_style.border_color = color.darkened(0.2)
	pressed_style.border_width_left = 2
	pressed_style.border_width_right = 2
	pressed_style.border_width_top = 2
	pressed_style.border_width_bottom = 2
	pressed_style.corner_radius_top_left = 4
	pressed_style.corner_radius_top_right = 4
	pressed_style.corner_radius_bottom_left = 4
	pressed_style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("pressed", pressed_style)

	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.9))

	# Hover animation
	btn.mouse_entered.connect(func(): _animate_button_hover(btn, true))
	btn.mouse_exited.connect(func(): _animate_button_hover(btn, false))

	return btn

func _animate_button_hover(btn: Button, hover: bool) -> void:
	AudioManager.play_sfx("ui_hover")
	var tween = create_tween()
	if hover:
		tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1)
	else:
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)

func _create_animated_background() -> void:
	# Animated particles or subtle movement
	pass

func _on_new_game_pressed() -> void:
	AudioManager.play_sfx("click")
	_fade_to_scene("res://scenes/scenario_selector.tscn")

func _on_continue_pressed() -> void:
	AudioManager.play_sfx("click")
	# Load most recent save
	if SaveManager.load_game(1):
		_fade_to_scene("res://scenes/office_building_planer.tscn")

func _on_load_pressed() -> void:
	AudioManager.play_sfx("click")
	# Show load game dialog
	pass

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("click")
	_show_settings()

func _on_credits_pressed() -> void:
	AudioManager.play_sfx("click")
	_show_credits()

func _on_quit_pressed() -> void:
	AudioManager.play_sfx("click")
	# Fade out then quit
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(get_tree().quit)

func _fade_to_scene(scene_path: String) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))

func _show_settings() -> void:
	var settings = _create_settings_panel()
	add_child(settings)

func _create_settings_panel() -> Control:
	var panel = Control.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	panel.add_child(bg)

	var settings_box = Panel.new()
	settings_box.set_anchors_preset(Control.PRESET_CENTER)
	settings_box.offset_left = -300
	settings_box.offset_right = 300
	settings_box.offset_top = -250
	settings_box.offset_bottom = 250
	panel.add_child(settings_box)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 15)
	settings_box.add_child(vbox)

	var title = Label.new()
	title.text = "SETTINGS"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Resolution
	var res_label = Label.new()
	res_label.text = "Resolution"
	vbox.add_child(res_label)

	var res_option = OptionButton.new()
	for res in SettingsManager.RESOLUTIONS:
		res_option.add_item("%dx%d" % [res.x, res.y])
	res_option.selected = SettingsManager.get_resolution_index()
	res_option.item_selected.connect(func(idx): SettingsManager.set_resolution(SettingsManager.RESOLUTIONS[idx].x, SettingsManager.RESOLUTIONS[idx].y))
	vbox.add_child(res_option)

	# Fullscreen
	var fullscreen_check = CheckBox.new()
	fullscreen_check.text = "Fullscreen"
	fullscreen_check.button_pressed = SettingsManager.is_fullscreen
	fullscreen_check.toggled.connect(SettingsManager.set_fullscreen)
	vbox.add_child(fullscreen_check)

	# Close button
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var close_btn = _create_menu_button("CLOSE", Color(0.7, 0.7, 0.7))
	close_btn.pressed.connect(func(): panel.queue_free())
	vbox.add_child(close_btn)

	return panel

func _show_credits() -> void:
	var credits = _create_credits_panel()
	add_child(credits)

func _create_credits_panel() -> Control:
	var panel = Control.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.9)
	panel.add_child(bg)

	var credits_box = Panel.new()
	credits_box.set_anchors_preset(Control.PRESET_CENTER)
	credits_box.offset_left = -350
	credits_box.offset_right = 350
	credits_box.offset_top = -300
	credits_box.offset_bottom = 300
	panel.add_child(credits_box)

	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_top = 20
	scroll.offset_bottom = -70
	credits_box.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll.add_child(vbox)

	var title = Label.new()
	title.text = "CREDITS"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_add_credit_section(vbox, "Game Design & Programming", ["Claude AI Assistant", "Built with Godot Engine 4.2"])
	_add_credit_section(vbox, "Graphics", ["Procedural Texture System", "Der Planer Inspired Aesthetics"])
	_add_credit_section(vbox, "Special Thanks", ["Original Der Planer Team", "Godot Community"])

	var close_btn = _create_menu_button("CLOSE", Color(0.7, 0.7, 0.7))
	close_btn.position = Vector2(200, 520)
	close_btn.custom_minimum_size = Vector2(200, 40)
	close_btn.pressed.connect(func(): panel.queue_free())
	credits_box.add_child(close_btn)

	return panel

func _add_credit_section(parent: VBoxContainer, section_title: String, credits: Array) -> void:
	var section = Label.new()
	section.text = section_title
	section.add_theme_font_size_override("font_size", 20)
	section.add_theme_color_override("font_color", Color(0.9, 0.9, 0.5))
	section.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(section)

	for credit in credits:
		var line = Label.new()
		line.text = credit
		line.add_theme_font_size_override("font_size", 14)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		parent.add_child(line)
