extends Node
## SaveManager - Handles saving and loading game state

signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)
signal save_list_updated(saves: Array)

const SAVE_DIR = "user://saves/"
const SAVE_FILE_PREFIX = "save_"
const SAVE_FILE_EXTENSION = ".json"
const MAX_SAVE_SLOTS = 10
const AUTOSAVE_SLOT = 0

var current_slot: int = -1

func _ready() -> void:
	_ensure_save_directory()

func _ensure_save_directory() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			dir.make_dir("saves")

# Save Functions

func save_game(slot: int, save_name: String = "") -> bool:
	"""Save the current game state to a slot"""
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		emit_signal("save_completed", slot, false)
		return false

	var game_state = GameManager.get_game_state()

	var save_data = {
		"meta": {
			"slot": slot,
			"name": save_name if save_name != "" else _generate_save_name(),
			"timestamp": Time.get_unix_time_from_system(),
			"datetime": Time.get_datetime_string_from_system(),
			"game_day": game_state.current_day,
			"company_money": game_state.company_money,
			"trucks": game_state.trucks.size(),
			"version": game_state.version
		},
		"game_state": game_state,
		"audio_settings": AudioManager.get_audio_settings()
	}

	var file_path = _get_save_path(slot)
	var file = FileAccess.open(file_path, FileAccess.WRITE)

	if file == null:
		push_error("Failed to open save file: " + file_path)
		emit_signal("save_completed", slot, false)
		return false

	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

	current_slot = slot
	emit_signal("save_completed", slot, true)
	return true

func autosave() -> bool:
	"""Perform an autosave"""
	return save_game(AUTOSAVE_SLOT, "Autosave")

func quick_save() -> bool:
	"""Quick save to the current slot or slot 1 if no current slot"""
	var slot = current_slot if current_slot > 0 else 1
	return save_game(slot)

# Load Functions

func load_game(slot: int) -> bool:
	"""Load a game from a save slot"""
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		emit_signal("load_completed", slot, false)
		return false

	var file_path = _get_save_path(slot)

	if not FileAccess.file_exists(file_path):
		push_error("Save file does not exist: " + file_path)
		emit_signal("load_completed", slot, false)
		return false

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: " + file_path)
		emit_signal("load_completed", slot, false)
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("Failed to parse save file: " + json.get_error_message())
		emit_signal("load_completed", slot, false)
		return false

	var save_data = json.get_data()

	# Load game state
	if save_data.has("game_state"):
		GameManager.load_game_state(save_data.game_state)

	# Load audio settings
	if save_data.has("audio_settings"):
		AudioManager.load_audio_settings(save_data.audio_settings)

	current_slot = slot
	emit_signal("load_completed", slot, true)
	return true

func quick_load() -> bool:
	"""Quick load from the current slot or slot 1"""
	var slot = current_slot if current_slot > 0 else 1
	return load_game(slot)

# Save Management

func delete_save(slot: int) -> bool:
	"""Delete a save file"""
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		return false

	var file_path = _get_save_path(slot)

	if FileAccess.file_exists(file_path):
		var dir = DirAccess.open(SAVE_DIR)
		if dir:
			var error = dir.remove(SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXTENSION)
			emit_signal("save_list_updated", get_save_list())
			return error == OK

	return false

func save_exists(slot: int) -> bool:
	"""Check if a save exists in a slot"""
	var file_path = _get_save_path(slot)
	return FileAccess.file_exists(file_path)

func get_save_info(slot: int) -> Dictionary:
	"""Get metadata about a save without loading it"""
	if not save_exists(slot):
		return {}

	var file_path = _get_save_path(slot)
	var file = FileAccess.open(file_path, FileAccess.READ)

	if file == null:
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		return {}

	var save_data = json.get_data()
	return save_data.get("meta", {})

func get_save_list() -> Array:
	"""Get a list of all saves with their metadata"""
	var saves = []

	for slot in range(MAX_SAVE_SLOTS):
		var info = get_save_info(slot)
		if not info.is_empty():
			saves.append(info)
		else:
			saves.append({
				"slot": slot,
				"empty": true
			})

	return saves

# Helper Functions

func _get_save_path(slot: int) -> String:
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXTENSION

func _generate_save_name() -> String:
	var datetime = Time.get_datetime_dict_from_system()
	return "Save - Day %d - %02d/%02d/%04d %02d:%02d" % [
		GameManager.current_day,
		datetime.day,
		datetime.month,
		datetime.year,
		datetime.hour,
		datetime.minute
	]

# Export/Import for Steam Cloud

func export_save_to_string(slot: int) -> String:
	"""Export a save to a base64 string for cloud storage"""
	var file_path = _get_save_path(slot)

	if not FileAccess.file_exists(file_path):
		return ""

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return ""

	var data = file.get_as_text()
	file.close()

	return Marshalls.utf8_to_base64(data)

func import_save_from_string(slot: int, data: String) -> bool:
	"""Import a save from a base64 string"""
	var json_string = Marshalls.base64_to_utf8(data)

	if json_string == "":
		return false

	var file_path = _get_save_path(slot)
	var file = FileAccess.open(file_path, FileAccess.WRITE)

	if file == null:
		return false

	file.store_string(json_string)
	file.close()

	emit_signal("save_list_updated", get_save_list())
	return true
