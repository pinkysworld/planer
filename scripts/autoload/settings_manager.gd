extends Node
## SettingsManager - Handles game settings including resolution, fullscreen, audio, etc.

signal settings_changed()
signal resolution_changed(width: int, height: int)
signal fullscreen_changed(is_fullscreen: bool)

# Available resolutions
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(800, 600),
	Vector2i(1024, 768),
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

# Current settings
var current_resolution: Vector2i = Vector2i(1280, 720)
var is_fullscreen: bool = false
var vsync_enabled: bool = true
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9

# Config file path
const CONFIG_PATH: String = "user://settings.cfg"

func _ready() -> void:
	load_settings()
	apply_settings()

func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)

	if err != OK:
		# Use defaults
		return

	current_resolution.x = config.get_value("display", "resolution_x", 1280)
	current_resolution.y = config.get_value("display", "resolution_y", 720)
	is_fullscreen = config.get_value("display", "fullscreen", false)
	vsync_enabled = config.get_value("display", "vsync", true)

	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 0.8)
	sfx_volume = config.get_value("audio", "sfx_volume", 0.9)

func save_settings() -> void:
	var config = ConfigFile.new()

	config.set_value("display", "resolution_x", current_resolution.x)
	config.set_value("display", "resolution_y", current_resolution.y)
	config.set_value("display", "fullscreen", is_fullscreen)
	config.set_value("display", "vsync", vsync_enabled)

	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)

	config.save(CONFIG_PATH)

func apply_settings() -> void:
	# Apply resolution
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(current_resolution)
		# Center window
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - current_resolution) / 2
		DisplayServer.window_set_position(window_pos)

	# Apply vsync
	if vsync_enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# Apply audio volumes
	_apply_audio_volumes()

	emit_signal("settings_changed")

func _apply_audio_volumes() -> void:
	if AudioServer.get_bus_index("Master") != -1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),
			linear_to_db(master_volume))

	if AudioServer.get_bus_index("Music") != -1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
			linear_to_db(music_volume))

	if AudioServer.get_bus_index("SFX") != -1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),
			linear_to_db(sfx_volume))

func set_resolution(width: int, height: int) -> void:
	current_resolution = Vector2i(width, height)
	apply_settings()
	save_settings()
	emit_signal("resolution_changed", width, height)

func set_fullscreen(enabled: bool) -> void:
	is_fullscreen = enabled
	apply_settings()
	save_settings()
	emit_signal("fullscreen_changed", enabled)

func toggle_fullscreen() -> void:
	set_fullscreen(not is_fullscreen)

func set_vsync(enabled: bool) -> void:
	vsync_enabled = enabled
	apply_settings()
	save_settings()

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	_apply_audio_volumes()
	save_settings()

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	_apply_audio_volumes()
	save_settings()

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	_apply_audio_volumes()
	save_settings()

func get_resolution_index() -> int:
	for i in range(RESOLUTIONS.size()):
		if RESOLUTIONS[i] == current_resolution:
			return i
	return 2  # Default to 1280x720

func get_resolution_string(resolution: Vector2i) -> String:
	return "%d x %d" % [resolution.x, resolution.y]
