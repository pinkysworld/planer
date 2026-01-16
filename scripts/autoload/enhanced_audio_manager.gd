extends Node
## EnhancedAudioManager - Professional audio system with dynamic mixing and effects
## Replaces basic AudioManager with advanced features for Steam-quality audio

signal music_track_changed(track_name: String)
signal audio_settings_changed()
signal dynamic_audio_event(event_type: String)

# Audio buses (configured in audio bus layout)
const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_AMBIENT = "Ambient"
const BUS_SFX = "SFX"
const BUS_UI = "UI"
const BUS_VOICE = "Voice"

# Advanced audio settings
var master_volume: float = 1.0
var music_volume: float = 0.75
var ambient_volume: float = 0.6
var sfx_volume: float = 0.85
var ui_volume: float = 0.9

var music_enabled: bool = true
var sfx_enabled: bool = true

# Dynamic audio mixing
var combat_intensity: float = 0.0  # For adaptive music
var tension_level: float = 0.0
var is_ducking: bool = false

# Audio layers
var music_layers: Dictionary = {
	"base": null,
	"percussion": null,
	"melody": null,
	"tension": null
}

# Music system
var current_music_track: String = ""
var next_music_track: String = ""
var music_player_a: AudioStreamPlayer
var music_player_b: AudioStreamPlayer
var active_music_player: AudioStreamPlayer
var crossfade_duration: float = 2.0

# Ambient system
var ambient_players: Array[AudioStreamPlayer] = []
var active_ambients: Dictionary = {}

# SFX system with pooling
var sfx_pools: Dictionary = {}  # Sound name -> Array of players
var max_sfx_instances: int = 16
var sfx_cooldowns: Dictionary = {}  # Prevent sound spam

# 3D Audio simulation for 2D
var listener_position: Vector2 = Vector2.ZERO
var audio_sources_2d: Array = []

# Music library with metadata
var music_library: Dictionary = {
	"menu_main": {
		"file": "res://audio/music/menu_theme.ogg",
		"loop": true,
		"bpm": 120,
		"mood": "neutral",
		"layers": []
	},
	"office_calm": {
		"file": "res://audio/music/office_ambient.ogg",
		"loop": true,
		"bpm": 90,
		"mood": "calm",
		"layers": ["base", "melody"]
	},
	"business_active": {
		"file": "res://audio/music/business_theme.ogg",
		"loop": true,
		"bpm": 130,
		"mood": "energetic",
		"layers": ["base", "percussion", "melody"]
	},
	"tension_high": {
		"file": "res://audio/music/tension.ogg",
		"loop": true,
		"bpm": 140,
		"mood": "tense",
		"layers": ["base", "tension"]
	},
	"success_fanfare": {
		"file": "res://audio/music/success.ogg",
		"loop": false,
		"bpm": 120,
		"mood": "triumphant",
		"layers": []
	},
	"home_relaxed": {
		"file": "res://audio/music/home.ogg",
		"loop": true,
		"bpm": 80,
		"mood": "relaxed",
		"layers": ["base", "melody"]
	}
}

# Comprehensive SFX library
var sfx_library: Dictionary = {
	# UI Sounds
	"ui_click": {"file": "res://audio/sfx/ui/click.wav", "volume": 0.8, "pitch_var": 0.05},
	"ui_hover": {"file": "res://audio/sfx/ui/hover.wav", "volume": 0.6, "pitch_var": 0.03},
	"ui_confirm": {"file": "res://audio/sfx/ui/confirm.wav", "volume": 0.9, "pitch_var": 0.0},
	"ui_cancel": {"file": "res://audio/sfx/ui/cancel.wav", "volume": 0.8, "pitch_var": 0.0},
	"ui_error": {"file": "res://audio/sfx/ui/error.wav", "volume": 0.85, "pitch_var": 0.0},
	"ui_notification": {"file": "res://audio/sfx/ui/notification.wav", "volume": 0.9, "pitch_var": 0.0},
	"ui_tab_switch": {"file": "res://audio/sfx/ui/tab.wav", "volume": 0.7, "pitch_var": 0.0},

	# Office Sounds
	"door_open": {"file": "res://audio/sfx/office/door_open.wav", "volume": 0.8, "pitch_var": 0.1},
	"door_close": {"file": "res://audio/sfx/office/door_close.wav", "volume": 0.8, "pitch_var": 0.1},
	"footstep": {"file": "res://audio/sfx/office/footstep.wav", "volume": 0.5, "pitch_var": 0.2},
	"elevator_ding": {"file": "res://audio/sfx/office/elevator_ding.wav", "volume": 0.9, "pitch_var": 0.0},
	"elevator_move": {"file": "res://audio/sfx/office/elevator_move.wav", "volume": 0.7, "pitch_var": 0.0},
	"phone_ring": {"file": "res://audio/sfx/office/phone_ring.wav", "volume": 0.85, "pitch_var": 0.0},
	"phone_pickup": {"file": "res://audio/sfx/office/phone_pickup.wav", "volume": 0.8, "pitch_var": 0.0},
	"keyboard_type": {"file": "res://audio/sfx/office/keyboard.wav", "volume": 0.6, "pitch_var": 0.15},
	"paper_shuffle": {"file": "res://audio/sfx/office/paper.wav", "volume": 0.7, "pitch_var": 0.1},
	"stamp": {"file": "res://audio/sfx/office/stamp.wav", "volume": 0.85, "pitch_var": 0.05},
	"cash_register": {"file": "res://audio/sfx/office/cash_register.wav", "volume": 0.9, "pitch_var": 0.0},

	# Business Sounds
	"money_gain": {"file": "res://audio/sfx/business/money_gain.wav", "volume": 0.9, "pitch_var": 0.0},
	"money_loss": {"file": "res://audio/sfx/business/money_loss.wav", "volume": 0.8, "pitch_var": 0.0},
	"contract_signed": {"file": "res://audio/sfx/business/contract.wav", "volume": 0.9, "pitch_var": 0.0},
	"delivery_complete": {"file": "res://audio/sfx/business/delivery_complete.wav", "volume": 0.95, "pitch_var": 0.0},
	"delivery_failed": {"file": "res://audio/sfx/business/delivery_failed.wav", "volume": 0.9, "pitch_var": 0.0},
	"achievement": {"file": "res://audio/sfx/business/achievement.wav", "volume": 1.0, "pitch_var": 0.0},

	# Vehicle Sounds
	"truck_start": {"file": "res://audio/sfx/vehicles/truck_start.wav", "volume": 0.85, "pitch_var": 0.1},
	"truck_idle": {"file": "res://audio/sfx/vehicles/truck_idle.wav", "volume": 0.6, "pitch_var": 0.05},
	"truck_horn": {"file": "res://audio/sfx/vehicles/truck_horn.wav", "volume": 0.9, "pitch_var": 0.0},
	"truck_brake": {"file": "res://audio/sfx/vehicles/brake.wav", "volume": 0.75, "pitch_var": 0.1},

	# Ambient Sounds
	"ambient_office": {"file": "res://audio/ambient/office_ambience.ogg", "volume": 0.4, "pitch_var": 0.0},
	"ambient_city": {"file": "res://audio/ambient/city_ambience.ogg", "volume": 0.5, "pitch_var": 0.0},
	"ambient_traffic": {"file": "res://audio/ambient/traffic.ogg", "volume": 0.45, "pitch_var": 0.0},
	"ambient_rain": {"file": "res://audio/ambient/rain.ogg", "volume": 0.6, "pitch_var": 0.0},
	"ambient_wind": {"file": "res://audio/ambient/wind.ogg", "volume": 0.5, "pitch_var": 0.0},

	# Weather Sounds
	"weather_rain_light": {"file": "res://audio/weather/rain_light.ogg", "volume": 0.5, "pitch_var": 0.0},
	"weather_rain_heavy": {"file": "res://audio/weather/rain_heavy.ogg", "volume": 0.7, "pitch_var": 0.0},
	"weather_thunder": {"file": "res://audio/weather/thunder.wav", "volume": 0.8, "pitch_var": 0.15},
	"weather_wind_strong": {"file": "res://audio/weather/wind_strong.ogg", "volume": 0.65, "pitch_var": 0.0}
}

func _ready() -> void:
	_setup_audio_players()
	_configure_audio_buses()

func _setup_audio_players() -> void:
	# Dual music players for crossfading
	music_player_a = AudioStreamPlayer.new()
	music_player_a.name = "MusicPlayerA"
	music_player_a.bus = BUS_MUSIC
	add_child(music_player_a)

	music_player_b = AudioStreamPlayer.new()
	music_player_b.name = "MusicPlayerB"
	music_player_b.bus = BUS_MUSIC
	add_child(music_player_b)

	active_music_player = music_player_a

	# Ambient player pool
	for i in range(4):
		var ambient = AudioStreamPlayer.new()
		ambient.name = "AmbientPlayer" + str(i)
		ambient.bus = BUS_AMBIENT
		add_child(ambient)
		ambient_players.append(ambient)

	# SFX player pool
	for i in range(max_sfx_instances):
		var sfx = AudioStreamPlayer.new()
		sfx.name = "SFXPlayer" + str(i)
		sfx.bus = BUS_SFX
		add_child(sfx)

func _configure_audio_buses() -> void:
	# Set initial volumes
	_set_bus_volume(BUS_MASTER, master_volume)
	_set_bus_volume(BUS_MUSIC, music_volume)
	_set_bus_volume(BUS_AMBIENT, ambient_volume)
	_set_bus_volume(BUS_SFX, sfx_volume)
	_set_bus_volume(BUS_UI, ui_volume)

func _set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))

# === MUSIC SYSTEM ===

func play_music(track_name: String, fade_in: float = 2.0, immediate: bool = false) -> void:
	if not music_enabled or track_name == current_music_track:
		return

	if not music_library.has(track_name):
		push_warning("Music track not found: " + track_name)
		return

	if immediate:
		_play_music_immediate(track_name)
	else:
		_crossfade_music(track_name, fade_in)

	emit_signal("music_track_changed", track_name)

func _play_music_immediate(track_name: String) -> void:
	var track_data = music_library[track_name]

	# Stop current music
	active_music_player.stop()

	# Load and play new track
	var stream = load(track_data.file) if ResourceLoader.exists(track_data.file) else null
	if stream:
		active_music_player.stream = stream
		active_music_player.volume_db = linear_to_db(music_volume)
		active_music_player.play()
		current_music_track = track_name

func _crossfade_music(track_name: String, duration: float) -> void:
	var track_data = music_library[track_name]

	# Get the inactive player for new track
	var new_player = music_player_b if active_music_player == music_player_a else music_player_a
	var old_player = active_music_player

	# Load new track
	var stream = load(track_data.file) if ResourceLoader.exists(track_data.file) else null
	if stream:
		new_player.stream = stream
		new_player.volume_db = -80.0  # Start silent
		new_player.play()

		# Crossfade
		var tween = create_tween().set_parallel(true)
		tween.tween_property(old_player, "volume_db", -80.0, duration)
		tween.tween_property(new_player, "volume_db", linear_to_db(music_volume), duration)

		await tween.finished

		old_player.stop()
		active_music_player = new_player
		current_music_track = track_name

func stop_music(fade_out: float = 1.0) -> void:
	if active_music_player.playing:
		var tween = create_tween()
		tween.tween_property(active_music_player, "volume_db", -80.0, fade_out)
		await tween.finished
		active_music_player.stop()
		current_music_track = ""

func set_music_layer_volume(layer_name: String, volume: float, duration: float = 0.5) -> void:
	# For adaptive music with layers
	if music_layers.has(layer_name) and music_layers[layer_name] != null:
		var player = music_layers[layer_name]
		var tween = create_tween()
		tween.tween_property(player, "volume_db", linear_to_db(volume), duration)

# === AMBIENT SYSTEM ===

func play_ambient(ambient_name: String, fade_in: float = 1.0, loop: bool = true) -> void:
	if active_ambients.has(ambient_name):
		return  # Already playing

	if not sfx_library.has(ambient_name):
		return

	var player = _get_available_ambient_player()
	if not player:
		return

	var ambient_data = sfx_library[ambient_name]
	var stream = load(ambient_data.file) if ResourceLoader.exists(ambient_data.file) else null

	if stream:
		player.stream = stream
		player.volume_db = -80.0
		player.play()

		# Fade in
		var tween = create_tween()
		tween.tween_property(player, "volume_db", linear_to_db(ambient_data.volume * ambient_volume), fade_in)

		active_ambients[ambient_name] = player

func stop_ambient(ambient_name: String, fade_out: float = 1.0) -> void:
	if not active_ambients.has(ambient_name):
		return

	var player = active_ambients[ambient_name]
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, fade_out)
	await tween.finished

	player.stop()
	active_ambients.erase(ambient_name)

func _get_available_ambient_player() -> AudioStreamPlayer:
	for player in ambient_players:
		if not player.playing:
			return player
	return null

# === SFX SYSTEM ===

func play_sfx(sfx_name: String, position: Vector2 = Vector2.ZERO, volume_multiplier: float = 1.0) -> void:
	if not sfx_enabled or not sfx_library.has(sfx_name):
		return

	# Check cooldown to prevent spam
	if _is_on_cooldown(sfx_name):
		return

	var sfx_data = sfx_library[sfx_name]
	var player = _get_available_sfx_player()

	if not player:
		return

	var stream = load(sfx_data.file) if ResourceLoader.exists(sfx_data.file) else null
	if stream:
		player.stream = stream
		player.volume_db = linear_to_db(sfx_data.volume * sfx_volume * volume_multiplier)

		# Add pitch variation if specified
		if sfx_data.pitch_var > 0:
			player.pitch_scale = 1.0 + randf_range(-sfx_data.pitch_var, sfx_data.pitch_var)
		else:
			player.pitch_scale = 1.0

		player.play()
		_set_cooldown(sfx_name, 0.05)  # 50ms cooldown

func play_ui_sfx(sfx_name: String) -> void:
	# UI sounds go to UI bus
	if not sfx_enabled or not sfx_library.has(sfx_name):
		return

	var player = _get_available_sfx_player()
	if player:
		player.bus = BUS_UI
		play_sfx(sfx_name)
		player.bus = BUS_SFX  # Reset to SFX bus

func _get_available_sfx_player() -> AudioStreamPlayer:
	for child in get_children():
		if child is AudioStreamPlayer and child.name.begins_with("SFXPlayer"):
			if not child.playing:
				return child
	# Return first player if all busy
	for child in get_children():
		if child is AudioStreamPlayer and child.name.begins_with("SFXPlayer"):
			return child
	return null

func _is_on_cooldown(sfx_name: String) -> bool:
	if sfx_cooldowns.has(sfx_name):
		return Time.get_ticks_msec() < sfx_cooldowns[sfx_name]
	return false

func _set_cooldown(sfx_name: String, duration: float) -> void:
	sfx_cooldowns[sfx_name] = Time.get_ticks_msec() + int(duration * 1000)

# === DYNAMIC AUDIO ===

func set_tension_level(level: float) -> void:
	"""Dynamically adjust music based on tension (0.0 = calm, 1.0 = intense)"""
	tension_level = clamp(level, 0.0, 1.0)

	# Adjust music layers based on tension
	if current_music_track != "":
		# Could crossfade to more intense version
		if tension_level > 0.7 and current_music_track != "tension_high":
			play_music("tension_high", 3.0)
		elif tension_level < 0.3 and current_music_track != "office_calm":
			play_music("office_calm", 3.0)

func audio_duck(duration: float = 0.5, duck_amount: float = 0.3) -> void:
	"""Temporarily lower music/ambient for dialogue or important sounds"""
	if is_ducking:
		return

	is_ducking = true
	var target_volume = music_volume * (1.0 - duck_amount)

	var tween = create_tween()
	tween.tween_method(_set_bus_volume.bind(BUS_MUSIC), music_volume, target_volume, duration)
	await tween.finished

	# Wait a moment
	await get_tree().create_timer(1.0).timeout

	# Restore
	var restore = create_tween()
	restore.tween_method(_set_bus_volume.bind(BUS_MUSIC), target_volume, music_volume, duration)
	await restore.finished

	is_ducking = false

# === VOLUME CONTROLS ===

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(BUS_MASTER, master_volume)
	emit_signal("audio_settings_changed")

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(BUS_MUSIC, music_volume)
	emit_signal("audio_settings_changed")

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(BUS_SFX, sfx_volume)
	emit_signal("audio_settings_changed")

func set_ambient_volume(volume: float) -> void:
	ambient_volume = clamp(volume, 0.0, 1.0)
	_set_bus_volume(BUS_AMBIENT, ambient_volume)

# === SETTINGS ===

func get_audio_settings() -> Dictionary:
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"ambient_volume": ambient_volume,
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled
	}

func apply_audio_settings(settings: Dictionary) -> void:
	set_master_volume(settings.get("master_volume", 1.0))
	set_music_volume(settings.get("music_volume", 0.75))
	set_sfx_volume(settings.get("sfx_volume", 0.85))
	set_ambient_volume(settings.get("ambient_volume", 0.6))
	music_enabled = settings.get("music_enabled", true)
	sfx_enabled = settings.get("sfx_enabled", true)
