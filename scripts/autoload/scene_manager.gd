extends Node
## SceneManager - Handles scene transitions with professional loading screens

const LoadingScreen = preload("res://scripts/utils/loading_screen.gd")

var loading_screen: Control = null
var current_scene: Node = null
var is_transitioning: bool = false

func _ready() -> void:
	# Get initial scene
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

## Changes scene with loading screen transition
func change_scene(scene_path: String) -> void:
	if is_transitioning:
		return

	is_transitioning = true

	# Create and show loading screen
	loading_screen = LoadingScreen.new()
	get_tree().root.call_deferred("add_child", loading_screen)

	# Wait for loading screen to appear
	await get_tree().create_timer(0.1).timeout

	# Fade out current scene and fade in loading screen
	if current_scene and current_scene.has_method("fade_out"):
		await current_scene.fade_out()

	if loading_screen:
		loading_screen.show_screen()

	# Start loading
	call_deferred("_load_scene", scene_path)

func _load_scene(scene_path: String) -> void:
	# Remove current scene
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	# Small delay to show loading screen
	await get_tree().create_timer(0.5).timeout

	# Load new scene
	var loader = ResourceLoader.load_threaded_request(scene_path)

	# Simulate loading progress
	var progress = 0.0
	while progress < 1.0:
		var status = ResourceLoader.load_threaded_get_status(scene_path, [progress])

		if loading_screen:
			loading_screen.update_progress(progress)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE or status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: " + scene_path)
			is_transitioning = false
			if loading_screen:
				loading_screen.queue_free()
			return

		await get_tree().create_timer(0.05).timeout

	# Get loaded resource
	var packed_scene = ResourceLoader.load_threaded_get(scene_path)
	if not packed_scene:
		push_error("Failed to get loaded scene: " + scene_path)
		is_transitioning = false
		if loading_screen:
			loading_screen.queue_free()
		return

	# Complete loading bar
	if loading_screen:
		loading_screen.update_progress(1.0)

	await get_tree().create_timer(0.3).timeout

	# Instance new scene
	current_scene = packed_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

	# Hide loading screen
	if loading_screen:
		loading_screen.hide_screen()
		await get_tree().create_timer(0.5).timeout
		loading_screen.queue_free()
		loading_screen = null

	is_transitioning = false

## Quick scene change without loading screen (for fast transitions)
func quick_change_scene(scene_path: String) -> void:
	if is_transitioning:
		return

	is_transitioning = true

	# Remove current scene
	if current_scene:
		current_scene.queue_free()

	# Load and add new scene
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	current_scene = new_scene
	get_tree().current_scene = new_scene

	is_transitioning = false

## Reload current scene
func reload_scene() -> void:
	if current_scene and current_scene.scene_file_path:
		change_scene(current_scene.scene_file_path)

## Returns to main menu
func return_to_main_menu() -> void:
	change_scene("res://scenes/main_menu.tscn")
