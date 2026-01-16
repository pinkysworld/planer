extends Control
## Main Menu - Entry point for the game

@onready var scenario_selector = $ScenarioSelector
@onready var load_game_panel = $LoadGamePanel
@onready var settings_panel = $SettingsPanel
@onready var save_slot_list = $LoadGamePanel/Panel/VBox/SaveSlotList

func _ready() -> void:
	AudioManager.play_music("menu")
	_refresh_save_slots()

func _on_new_game_pressed() -> void:
	AudioManager.play_sfx("click")
	scenario_selector.visible = true

func _on_load_game_pressed() -> void:
	AudioManager.play_sfx("click")
	_refresh_save_slots()
	load_game_panel.visible = true

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("click")
	_load_current_settings()
	settings_panel.visible = true

func _on_quit_pressed() -> void:
	AudioManager.play_sfx("click")
	get_tree().quit()

# Load Game Panel

func _refresh_save_slots() -> void:
	# Clear existing slots
	for child in save_slot_list.get_children():
		child.queue_free()

	# Get save list
	var saves = SaveManager.get_save_list()

	for save_info in saves:
		var button = Button.new()
		button.custom_minimum_size = Vector2(0, 45)

		if save_info.get("empty", false):
			button.text = "Slot %d - Empty" % save_info.slot
			button.disabled = true
		else:
			var date_str = save_info.get("datetime", "Unknown")
			var day = save_info.get("game_day", 0)
			var money = save_info.get("company_money", 0)
			var trucks = save_info.get("trucks", 0)
			button.text = "%s\nDay %d | €%.0f | %d Trucks" % [save_info.get("name", "Save"), day, money, trucks]

			var slot = save_info.slot
			button.pressed.connect(func(): _load_slot(slot))

		save_slot_list.add_child(button)

func _load_slot(slot: int) -> void:
	AudioManager.play_sfx("click")
	if SaveManager.load_game(slot):
		get_tree().change_scene_to_file("res://scenes/office_building.tscn")

func _on_load_back_pressed() -> void:
	AudioManager.play_sfx("click")
	load_game_panel.visible = false

# Settings Panel

func _load_current_settings() -> void:
	var settings = AudioManager.get_audio_settings()
	$SettingsPanel/Panel/VBox/MusicHBox/MusicSlider.value = settings.music_volume
	$SettingsPanel/Panel/VBox/MusicHBox/MusicToggle.button_pressed = settings.music_enabled
	$SettingsPanel/Panel/VBox/SFXHBox/SFXSlider.value = settings.sfx_volume
	$SettingsPanel/Panel/VBox/SFXHBox/SFXToggle.button_pressed = settings.sfx_enabled

	# Load fullscreen and resolution settings from SettingsManager
	$SettingsPanel/Panel/VBox/FullscreenHBox/FullscreenToggle.button_pressed = SettingsManager.is_fullscreen

	# Update resolution option button if it exists
	var res_option = $SettingsPanel/Panel/VBox/ResolutionHBox/ResolutionOption
	if res_option:
		res_option.clear()
		var current_index = 0
		for i in range(SettingsManager.RESOLUTIONS.size()):
			var res = SettingsManager.RESOLUTIONS[i]
			res_option.add_item(SettingsManager.get_resolution_string(res))
			if res == SettingsManager.current_resolution:
				current_index = i
		res_option.select(current_index)

func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

func _on_music_toggled(enabled: bool) -> void:
	AudioManager.set_music_enabled(enabled)

func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

func _on_sfx_toggled(enabled: bool) -> void:
	AudioManager.set_sfx_enabled(enabled)

func _on_fullscreen_toggled(enabled: bool) -> void:
	SettingsManager.set_fullscreen(enabled)

func _on_resolution_selected(index: int) -> void:
	var resolution = SettingsManager.RESOLUTIONS[index]
	SettingsManager.set_resolution(resolution.x, resolution.y)

func _on_settings_back_pressed() -> void:
	AudioManager.play_sfx("click")
	settings_panel.visible = false
