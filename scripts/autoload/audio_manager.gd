extends Node
## AudioManager - Handles all game audio including music and sound effects

signal music_volume_changed(volume: float)
signal sfx_volume_changed(volume: float)

# Audio settings
var music_enabled: bool = true
var sfx_enabled: bool = true
var music_volume: float = 0.7
var sfx_volume: float = 0.8

# Audio players
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 8

# Music tracks
var current_track: String = ""
var music_tracks: Dictionary = {}

# Sound effect cache
var sfx_cache: Dictionary = {}

func _ready() -> void:
	_setup_audio_players()
	_load_audio_resources()

func _setup_audio_players() -> void:
	# Main music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.volume_db = linear_to_db(music_volume)
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)

	# Ambient sounds player
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Ambient"
	ambient_player.volume_db = linear_to_db(music_volume * 0.5)
	add_child(ambient_player)

	# SFX player pool
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		player.volume_db = linear_to_db(sfx_volume)
		add_child(player)
		sfx_players.append(player)

func _load_audio_resources() -> void:
	# These would be loaded from actual audio files
	# For now, we'll set up the structure
	music_tracks = {
		"menu": "res://assets/audio/music/menu_theme.ogg",
		"office": "res://assets/audio/music/office_ambience.ogg",
		"business": "res://assets/audio/music/business_theme.ogg",
		"home": "res://assets/audio/music/home_relaxed.ogg",
		"success": "res://assets/audio/music/success_fanfare.ogg",
		"tension": "res://assets/audio/music/tension_theme.ogg"
	}

	sfx_cache = {
		"click": "res://assets/audio/sfx/click.wav",
		"door_open": "res://assets/audio/sfx/door_open.wav",
		"door_close": "res://assets/audio/sfx/door_close.wav",
		"phone_ring": "res://assets/audio/sfx/phone_ring.wav",
		"email_notification": "res://assets/audio/sfx/email_notification.wav",
		"cash_register": "res://assets/audio/sfx/cash_register.wav",
		"truck_start": "res://assets/audio/sfx/truck_start.wav",
		"truck_horn": "res://assets/audio/sfx/truck_horn.wav",
		"paper_shuffle": "res://assets/audio/sfx/paper_shuffle.wav",
		"typing": "res://assets/audio/sfx/typing.wav",
		"stamp": "res://assets/audio/sfx/stamp.wav",
		"success": "res://assets/audio/sfx/success.wav",
		"error": "res://assets/audio/sfx/error.wav",
		"notification": "res://assets/audio/sfx/notification.wav",
		"footsteps": "res://assets/audio/sfx/footsteps.wav",
		"elevator": "res://assets/audio/sfx/elevator.wav",
		"ambient_office": "res://assets/audio/sfx/ambient_office.wav"
	}

# Music Controls

func play_music(track_name: String, fade_duration: float = 1.0) -> void:
	if not music_enabled:
		return

	if track_name == current_track and music_player.playing:
		return

	if not music_tracks.has(track_name):
		push_warning("Music track not found: " + track_name)
		return

	current_track = track_name

	# Fade out current music
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		await tween.finished

	# Load and play new track
	var stream = load(music_tracks[track_name])
	if stream:
		music_player.stream = stream
		music_player.volume_db = -80.0
		music_player.play()

		# Fade in
		var fade_in = create_tween()
		fade_in.tween_property(music_player, "volume_db", linear_to_db(music_volume), fade_duration)

func stop_music(fade_duration: float = 1.0) -> void:
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		await tween.finished
		music_player.stop()
		current_track = ""

func pause_music() -> void:
	music_player.stream_paused = true

func resume_music() -> void:
	music_player.stream_paused = false

func _on_music_finished() -> void:
	# Loop music by default
	if current_track != "" and music_enabled:
		music_player.play()

# Sound Effects

func play_sfx(sfx_name: String, pitch_variation: float = 0.0) -> void:
	if not sfx_enabled:
		return

	if not sfx_cache.has(sfx_name):
		push_warning("SFX not found: " + sfx_name)
		return

	# Find available player
	var player = _get_available_sfx_player()
	if player == null:
		return

	var stream = load(sfx_cache[sfx_name])
	if stream:
		player.stream = stream
		player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
		player.play()

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	# If all busy, use the first one (oldest sound)
	return sfx_players[0]

func play_sfx_at_position(sfx_name: String, position: Vector2) -> void:
	# For 2D positional audio (if needed)
	play_sfx(sfx_name)

# Ambient Sounds

func play_ambient(ambient_name: String) -> void:
	if not sfx_cache.has(ambient_name):
		return

	var stream = load(sfx_cache[ambient_name])
	if stream:
		ambient_player.stream = stream
		ambient_player.play()

func stop_ambient() -> void:
	ambient_player.stop()

# Volume Controls

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)
	ambient_player.volume_db = linear_to_db(music_volume * 0.5)
	emit_signal("music_volume_changed", music_volume)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	for player in sfx_players:
		player.volume_db = linear_to_db(sfx_volume)
	emit_signal("sfx_volume_changed", sfx_volume)

func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	if not enabled:
		stop_music(0.5)
	else:
		if current_track != "":
			play_music(current_track)

func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled

func toggle_music() -> void:
	set_music_enabled(not music_enabled)

func toggle_sfx() -> void:
	set_sfx_enabled(not sfx_enabled)

# Settings persistence

func get_audio_settings() -> Dictionary:
	return {
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}

func load_audio_settings(settings: Dictionary) -> void:
	music_enabled = settings.get("music_enabled", true)
	sfx_enabled = settings.get("sfx_enabled", true)
	music_volume = settings.get("music_volume", 0.7)
	sfx_volume = settings.get("sfx_volume", 0.8)

	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)
