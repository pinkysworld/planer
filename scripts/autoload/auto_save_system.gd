extends Node
## AutoSaveSystem - Automatic game saving at intervals

signal auto_save_started
signal auto_save_completed
signal auto_save_failed

const AUTO_SAVE_INTERVAL: float = 300.0  # 5 minutes
const AUTOSAVE_SLOT: int = 0  # Use slot 0 for autosaves

var auto_save_enabled: bool = true
var time_since_last_save: float = 0.0
var is_saving: bool = false

func _ready() -> void:
	# Load auto-save setting
	if FileAccess.file_exists("user://settings.cfg"):
		var config = ConfigFile.new()
		if config.load("user://settings.cfg") == OK:
			auto_save_enabled = config.get_value("gameplay", "auto_save", true)

func _process(delta: float) -> void:
	if not auto_save_enabled or is_saving:
		return

	time_since_last_save += delta

	if time_since_last_save >= AUTO_SAVE_INTERVAL:
		perform_auto_save()

## Manually trigger auto-save
func perform_auto_save() -> void:
	if is_saving:
		return

	is_saving = true
	auto_save_started.emit()

	# Use SaveManager to save the game
	if has_node("/root/SaveManager"):
		var result = await SaveManager.save_game(AUTOSAVE_SLOT, "Autosave")

		if result:
			auto_save_completed.emit()
			time_since_last_save = 0.0

			# Show notification
			if has_node("/root/NotificationManager"):
				NotificationManager.show_toast("Game auto-saved", 1.5)
		else:
			auto_save_failed.emit()
			push_error("Auto-save failed")
	else:
		auto_save_failed.emit()
		push_error("SaveManager not found")

	is_saving = false

## Enable/disable auto-save
func set_auto_save_enabled(enabled: bool) -> void:
	auto_save_enabled = enabled

	# Save setting
	var config = ConfigFile.new()
	if FileAccess.file_exists("user://settings.cfg"):
		config.load("user://settings.cfg")

	config.set_value("gameplay", "auto_save", enabled)
	config.save("user://settings.cfg")

## Get time until next auto-save
func get_time_until_next_save() -> float:
	if not auto_save_enabled:
		return -1.0

	return max(0.0, AUTO_SAVE_INTERVAL - time_since_last_save)

## Check if auto-save file exists
func has_auto_save() -> bool:
	if has_node("/root/SaveManager"):
		var saves = SaveManager.get_save_list()
		if saves.size() > AUTOSAVE_SLOT:
			return not saves[AUTOSAVE_SLOT].get("empty", true)
	return false

## Load auto-save
func load_auto_save() -> bool:
	if not has_auto_save():
		return false

	if has_node("/root/SaveManager"):
		return SaveManager.load_game(AUTOSAVE_SLOT)

	return false

## Delete auto-save
func delete_auto_save() -> void:
	if has_auto_save() and has_node("/root/SaveManager"):
		SaveManager.delete_save(AUTOSAVE_SLOT)

## Reset save timer (call after manual save)
func reset_timer() -> void:
	time_since_last_save = 0.0
