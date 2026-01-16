extends CanvasLayer
## PauseMenu - In-game pause menu with save/load functionality

signal game_resumed

var save_panel: Control = null
var load_panel: Control = null
var settings_panel: Control = null

func _on_resume_pressed() -> void:
	AudioManager.play_sfx("click")
	visible = false
	GameManager.resume_game()
	emit_signal("game_resumed")

func _on_save_pressed() -> void:
	AudioManager.play_sfx("click")
	_show_save_panel()

func _on_load_pressed() -> void:
	AudioManager.play_sfx("click")
	_show_load_panel()

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("click")
	_show_settings_panel()

func _on_main_menu_pressed() -> void:
	AudioManager.play_sfx("click")
	# Confirm before returning to main menu
	_show_confirm_dialog("Return to main menu? Unsaved progress will be lost.", func():
		GameManager.resume_game()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

func _on_quit_pressed() -> void:
	AudioManager.play_sfx("click")
	_show_confirm_dialog("Quit game? Unsaved progress will be lost.", func():
		get_tree().quit()
	)

func _show_save_panel() -> void:
	if save_panel:
		save_panel.queue_free()

	save_panel = _create_save_load_panel(true)
	add_child(save_panel)

func _show_load_panel() -> void:
	if load_panel:
		load_panel.queue_free()

	load_panel = _create_save_load_panel(false)
	add_child(load_panel)

func _create_save_load_panel(is_save: bool) -> Control:
	var panel = Control.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	panel.add_child(bg)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -250
	vbox.offset_right = 250
	vbox.offset_top = -250
	vbox.offset_bottom = 250
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "Save Game" if is_save else "Load Game"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)

	# Save slots
	var saves = SaveManager.get_save_list()
	for i in range(1, 10):  # Slots 1-9 (0 is autosave)
		var slot_btn = Button.new()
		slot_btn.custom_minimum_size = Vector2(0, 50)

		var save_info = saves[i] if i < saves.size() else {"slot": i, "empty": true}

		if save_info.get("empty", true):
			slot_btn.text = "Slot %d - Empty" % i
			if not is_save:
				slot_btn.disabled = true
		else:
			var name = save_info.get("name", "Save")
			var day = save_info.get("game_day", 0)
			var money = save_info.get("company_money", 0)
			slot_btn.text = "Slot %d: %s (Day %d, €%.0f)" % [i, name, day, money]

		var slot_num = i
		if is_save:
			slot_btn.pressed.connect(func(): _save_to_slot(slot_num, panel))
		else:
			slot_btn.pressed.connect(func(): _load_from_slot(slot_num, panel))

		vbox.add_child(slot_btn)

	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.custom_minimum_size = Vector2(150, 40)
	back_btn.pressed.connect(func(): panel.queue_free())
	vbox.add_child(back_btn)

	return panel

func _save_to_slot(slot: int, panel: Control) -> void:
	AudioManager.play_sfx("click")
	if SaveManager.save_game(slot):
		EventBus.show_notification("Game saved to slot %d" % slot, "success")
		panel.queue_free()
	else:
		EventBus.show_notification("Failed to save game", "error")

func _load_from_slot(slot: int, panel: Control) -> void:
	AudioManager.play_sfx("click")
	if SaveManager.load_game(slot):
		EventBus.show_notification("Game loaded from slot %d" % slot, "success")
		panel.queue_free()
		visible = false
		GameManager.resume_game()
	else:
		EventBus.show_notification("Failed to load game", "error")

func _show_settings_panel() -> void:
	if settings_panel:
		settings_panel.queue_free()

	settings_panel = Control.new()
	settings_panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	settings_panel.add_child(bg)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -200
	vbox.offset_right = 200
	vbox.offset_top = -150
	vbox.offset_bottom = 150
	settings_panel.add_child(vbox)

	var title = Label.new()
	title.text = "Settings"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Music volume
	var music_hbox = HBoxContainer.new()
	var music_label = Label.new()
	music_label.text = "Music Volume"
	music_label.custom_minimum_size = Vector2(120, 0)
	var music_slider = HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.value = AudioManager.music_volume
	music_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_slider.value_changed.connect(func(v): AudioManager.set_music_volume(v))
	music_hbox.add_child(music_label)
	music_hbox.add_child(music_slider)
	vbox.add_child(music_hbox)

	# SFX volume
	var sfx_hbox = HBoxContainer.new()
	var sfx_label = Label.new()
	sfx_label.text = "SFX Volume"
	sfx_label.custom_minimum_size = Vector2(120, 0)
	var sfx_slider = HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = AudioManager.sfx_volume
	sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_slider.value_changed.connect(func(v): AudioManager.set_sfx_volume(v))
	sfx_hbox.add_child(sfx_label)
	sfx_hbox.add_child(sfx_slider)
	vbox.add_child(sfx_hbox)

	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.custom_minimum_size = Vector2(150, 40)
	back_btn.pressed.connect(func(): settings_panel.queue_free())
	vbox.add_child(back_btn)

	add_child(settings_panel)

func _show_confirm_dialog(message: String, on_confirm: Callable) -> void:
	var dialog = Control.new()
	dialog.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.8)
	dialog.add_child(bg)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -200
	vbox.offset_right = 200
	vbox.offset_top = -80
	vbox.offset_bottom = 80
	dialog.add_child(vbox)

	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(label)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var yes_btn = Button.new()
	yes_btn.text = "Yes"
	yes_btn.custom_minimum_size = Vector2(100, 40)
	yes_btn.pressed.connect(func():
		dialog.queue_free()
		on_confirm.call()
	)
	hbox.add_child(yes_btn)

	var no_btn = Button.new()
	no_btn.text = "No"
	no_btn.custom_minimum_size = Vector2(100, 40)
	no_btn.pressed.connect(func(): dialog.queue_free())
	hbox.add_child(no_btn)

	vbox.add_child(hbox)
	add_child(dialog)
