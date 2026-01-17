extends Control
## RetroScenarioSelector - Classic 90s style scenario selection

const RetroTheme = preload("res://scripts/ui/retro_ui_theme.gd")

var scenarios: Dictionary = {
	"freeplay": {
		"name": "FREIES SPIEL",
		"description": "Bauen Sie Ihr Transport-Imperium ohne Einschraenkungen auf",
		"starting_money": 75000.0,
		"starting_private_money": 8000.0,
		"starting_reputation": 50.0,
		"starting_city": "Berlin",
		"goals": [],
		"difficulty": "normal"
	},
	"startup": {
		"name": "STARTUP HERAUSFORDERUNG",
		"description": "Starten Sie mit begrenzten Mitteln und bauen Sie ein erfolgreiches Unternehmen auf",
		"starting_money": 30000.0,
		"starting_private_money": 3000.0,
		"starting_reputation": 30.0,
		"starting_city": "Berlin",
		"goals": [
			{"type": "money", "target": 500000.0, "description": "Erreichen Sie 500.000 DM"}
		],
		"difficulty": "hard"
	},
	"european": {
		"name": "EUROPA EXPANSION",
		"description": "Erweitern Sie Ihr Geschaeft in ganz Europa",
		"starting_money": 100000.0,
		"starting_private_money": 10000.0,
		"starting_reputation": 60.0,
		"starting_city": "Berlin",
		"goals": [
			{"type": "stations", "target": 5, "description": "Eroeffnen Sie Stationen in 5 Laendern"}
		],
		"difficulty": "medium"
	}
}

func _ready() -> void:
	_create_retro_selector()

func _create_retro_selector() -> void:
	# Classic cyan background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = RetroTheme.COLOR_CYAN_BG
	add_child(bg)

	# Title
	var title = Label.new()
	title.text = "SZENARIO AUSWAHL"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", RetroTheme.COLOR_AMBER)
	title.add_theme_color_override("font_outline_color", RetroTheme.COLOR_BLACK)
	title.add_theme_constant_override("outline_size", 2)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 50
	title.offset_left = -300
	title.offset_right = 300
	add_child(title)

	# Scenarios panel
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -400
	panel.offset_right = 400
	panel.offset_top = -200
	panel.offset_bottom = 250
	panel.add_theme_stylebox_override("panel", RetroTheme.create_retro_panel())
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 20)
	vbox.size = Vector2(760, 420)
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)

	# Scenario buttons
	_add_scenario_button(vbox, "freeplay", scenarios.freeplay)
	_add_scenario_button(vbox, "startup", scenarios.startup)
	_add_scenario_button(vbox, "european", scenarios.european)

	# Back button
	var back_btn = Button.new()
	back_btn.text = "ZURUECK"
	back_btn.custom_minimum_size = Vector2(200, 40)
	back_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	RetroTheme.apply_retro_button_theme(back_btn, RetroTheme.COLOR_RED)
	back_btn.pressed.connect(_on_back_pressed)
	vbox.add_child(back_btn)

func _add_scenario_button(parent: VBoxContainer, key: String, data: Dictionary) -> void:
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 5)
	parent.add_child(container)

	var btn = Button.new()
	btn.text = data.name
	btn.custom_minimum_size = Vector2(0, 50)
	RetroTheme.apply_retro_button_theme(btn)
	btn.pressed.connect(func(): _start_scenario(key))
	container.add_child(btn)

	var desc = Label.new()
	desc.text = data.description
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", RetroTheme.COLOR_LIGHT_GRAY)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	container.add_child(desc)

	var info = Label.new()
	info.text = "START: %s DM | REPUTATION: %.0f%%" % [_format_money(data.starting_money), data.starting_reputation]
	info.add_theme_font_size_override("font_size", 10)
	info.add_theme_color_override("font_color", RetroTheme.COLOR_AMBER)
	container.add_child(info)

	parent.add_child(RetroTheme.create_separator_line(760))

func _format_money(amount: float) -> String:
	var formatted = "%.0f" % amount
	var result = ""
	var count = 0

	for i in range(formatted.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "." + result
		result = formatted[i] + result
		count += 1

	return result

func _start_scenario(scenario_key: String) -> void:
	AudioManager.play_sfx("click")
	var scenario = scenarios.get(scenario_key, scenarios.freeplay)
	GameManager.start_new_game(scenario)
	get_tree().change_scene_to_file("res://scenes/office_building_planer.tscn")

func _on_back_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
