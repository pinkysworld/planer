extends Node
## StartupManager - Handles game initialization and texture preloading

signal startup_complete

var is_initialized: bool = false

func _ready() -> void:
	# Preload common textures on startup
	call_deferred("_initialize_game")

func _initialize_game() -> void:
	if is_initialized:
		return

	# Preload common textures for better performance
	if has_node("/root/TextureCache"):
		TextureCache.preload_common_textures()

	# Initialize managers
	if has_node("/root/GameManager"):
		GameManager._ready()

	# Mark as initialized
	is_initialized = true
	startup_complete.emit()

	# Log startup info
	print("=== Modern Planer ===")
	print("Game initialized successfully")
	print("Texture cache ready with %d cached textures" % TextureCache.texture_cache.size())
	print("===================")
