extends Node
## CameraEffects - Professional camera effects and screen transitions
## Provides shake, zoom, transitions, and post-processing effects

signal transition_started(type: String)
signal transition_finished(type: String)
signal screen_effect_applied(effect: String)

# Camera references
var current_camera: Camera2D = null
var camera_original_position: Vector2 = Vector2.ZERO

# Shake effect
var shake_intensity: float = 0.0
var shake_decay: float = 5.0
var shake_timer: float = 0.0

# Zoom effect
var target_zoom: Vector2 = Vector2.ONE
var zoom_speed: float = 2.0

# Screen flash
var flash_overlay: ColorRect = null

# Transition overlay
var transition_overlay: ColorRect = null
var is_transitioning: bool = false

# Post-processing
var post_process_material: ShaderMaterial = null

func _ready() -> void:
	_setup_overlays()

func _setup_overlays() -> void:
	# Create flash overlay
	flash_overlay = ColorRect.new()
	flash_overlay.name = "FlashOverlay"
	flash_overlay.color = Color(1, 1, 1, 0)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_overlay.z_index = 100

	# Create transition overlay
	transition_overlay = ColorRect.new()
	transition_overlay.name = "TransitionOverlay"
	transition_overlay.color = Color(0, 0, 0, 0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.z_index = 99

func _process(delta: float) -> void:
	if current_camera:
		_update_camera_shake(delta)
		_update_camera_zoom(delta)

func _update_camera_shake(delta: float) -> void:
	if shake_intensity > 0:
		shake_timer += delta

		# Apply shake offset
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)

		current_camera.offset = shake_offset

		# Decay shake
		shake_intensity = lerp(shake_intensity, 0.0, delta * shake_decay)

		if shake_intensity < 0.1:
			shake_intensity = 0.0
			current_camera.offset = Vector2.ZERO

func _update_camera_zoom(delta: float) -> void:
	if current_camera.zoom != target_zoom:
		current_camera.zoom = current_camera.zoom.lerp(target_zoom, delta * zoom_speed)

# === CAMERA SHAKE ===

func shake_camera(intensity: float, duration: float = 0.5, decay: float = 5.0) -> void:
	"""Shake the camera with specified intensity"""
	shake_intensity = intensity
	shake_decay = decay
	shake_timer = 0.0

func impact_shake(strength: String = "medium") -> void:
	"""Predefined shake intensities for common impacts"""
	match strength:
		"light":
			shake_camera(2.0, 0.2, 10.0)
		"medium":
			shake_camera(5.0, 0.4, 7.0)
		"heavy":
			shake_camera(10.0, 0.6, 5.0)
		"extreme":
			shake_camera(15.0, 1.0, 4.0)

# === CAMERA ZOOM ===

func zoom_to(zoom_level: float, speed: float = 2.0) -> void:
	"""Smoothly zoom camera to target level"""
	target_zoom = Vector2(zoom_level, zoom_level)
	zoom_speed = speed

func zoom_in(amount: float = 0.2, speed: float = 2.0) -> void:
	"""Zoom in by amount"""
	var new_zoom = target_zoom.x + amount
	zoom_to(new_zoom, speed)

func zoom_out(amount: float = 0.2, speed: float = 2.0) -> void:
	"""Zoom out by amount"""
	var new_zoom = target_zoom.x - amount
	zoom_to(max(0.1, new_zoom), speed)

func reset_zoom(speed: float = 2.0) -> void:
	"""Reset to default zoom"""
	zoom_to(1.0, speed)

# === SCREEN FLASH ===

func flash_screen(color: Color = Color.WHITE, duration: float = 0.2, intensity: float = 1.0) -> void:
	"""Flash the screen with a color"""
	if not flash_overlay.get_parent():
		get_tree().root.add_child(flash_overlay)

	flash_overlay.color = Color(color.r, color.g, color.b, 0.0)

	var tween = create_tween()
	tween.tween_property(flash_overlay, "color:a", intensity, duration * 0.3)
	tween.tween_property(flash_overlay, "color:a", 0.0, duration * 0.7)

	emit_signal("screen_effect_applied", "flash")

func damage_flash() -> void:
	"""Red flash for damage/negative events"""
	flash_screen(Color(1.0, 0.2, 0.2), 0.2, 0.6)

func success_flash() -> void:
	"""Green flash for success/positive events"""
	flash_screen(Color(0.2, 1.0, 0.3), 0.3, 0.5)

func info_flash() -> void:
	"""Blue flash for information"""
	flash_screen(Color(0.3, 0.6, 1.0), 0.25, 0.4)

# === SCREEN TRANSITIONS ===

func fade_to_black(duration: float = 1.0) -> void:
	"""Fade screen to black"""
	await _fade_transition(Color.BLACK, duration, true)

func fade_from_black(duration: float = 1.0) -> void:
	"""Fade from black to clear"""
	await _fade_transition(Color.BLACK, duration, false)

func fade_to_white(duration: float = 1.0) -> void:
	"""Fade screen to white"""
	await _fade_transition(Color.WHITE, duration, true)

func fade_from_white(duration: float = 1.0) -> void:
	"""Fade from white to clear"""
	await _fade_transition(Color.WHITE, duration, false)

func _fade_transition(color: Color, duration: float, fade_in: bool) -> void:
	"""Internal fade transition handler"""
	if is_transitioning:
		return

	is_transitioning = true
	emit_signal("transition_started", "fade")

	if not transition_overlay.get_parent():
		get_tree().root.add_child(transition_overlay)

	transition_overlay.color = color if not fade_in else Color(color.r, color.g, color.b, 0.0)

	var tween = create_tween()
	if fade_in:
		tween.tween_property(transition_overlay, "color:a", 1.0, duration)
	else:
		transition_overlay.color.a = 1.0
		tween.tween_property(transition_overlay, "color:a", 0.0, duration)

	await tween.finished

	is_transitioning = false
	emit_signal("transition_finished", "fade")

func crossfade_scene(next_scene: PackedScene, duration: float = 1.0) -> void:
	"""Crossfade transition between scenes"""
	await fade_to_black(duration / 2.0)

	# Change scene
	get_tree().change_scene_to_packed(next_scene)

	await get_tree().process_frame
	await fade_from_black(duration / 2.0)

func wipe_transition(direction: String = "left", duration: float = 0.8) -> void:
	"""Wipe transition effect"""
	# Would implement a shader-based wipe transition
	emit_signal("transition_started", "wipe_" + direction)
	await fade_to_black(duration)
	emit_signal("transition_finished", "wipe_" + direction)

# === SPECIAL EFFECTS ===

func vignette_effect(intensity: float, duration: float = 1.0) -> void:
	"""Apply vignette effect (darkening edges)"""
	# Would modify post-processing shader
	emit_signal("screen_effect_applied", "vignette")

func chromatic_aberration(intensity: float, duration: float = 0.5) -> void:
	"""Apply chromatic aberration effect"""
	# Would modify post-processing shader
	emit_signal("screen_effect_applied", "chromatic_aberration")

func motion_blur(intensity: float, duration: float = 0.3) -> void:
	"""Apply motion blur effect"""
	# Would modify post-processing shader
	emit_signal("screen_effect_applied", "motion_blur")

func slow_motion(time_scale: float = 0.5, duration: float = 2.0) -> void:
	"""Slow down time with visual effects"""
	Engine.time_scale = time_scale

	# Add visual feedback
	vignette_effect(0.5, 0.3)

	await get_tree().create_timer(duration * time_scale).timeout

	# Restore normal speed
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 1.0, 0.5)

func pause_with_effect() -> void:
	"""Pause with visual effect"""
	var tree = get_tree()
	tree.paused = true

	# Dim and blur effect
	if transition_overlay.get_parent():
		transition_overlay.color = Color(0, 0, 0, 0)
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(transition_overlay, "color:a", 0.5, 0.2)

func unpause_with_effect() -> void:
	"""Unpause with visual effect"""
	if transition_overlay.get_parent():
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(transition_overlay, "color:a", 0.0, 0.2)

		await tween.finished

	get_tree().paused = false

# === CINEMATIC EFFECTS ===

func letterbox(enable: bool, duration: float = 0.5) -> void:
	"""Add cinematic letterbox bars"""
	# Would create black bars at top/bottom
	emit_signal("screen_effect_applied", "letterbox_" + ("on" if enable else "off"))

func focus_effect(target_position: Vector2, radius: float = 200.0) -> void:
	"""Focus on specific point, blur surroundings"""
	# Would apply radial blur shader
	emit_signal("screen_effect_applied", "focus")

# === UTILITY ===

func set_camera(camera: Camera2D) -> void:
	"""Set the active camera for effects"""
	current_camera = camera
	if camera:
		camera_original_position = camera.position
		target_zoom = camera.zoom

func reset_all_effects() -> void:
	"""Reset all active camera effects"""
	shake_intensity = 0.0
	if current_camera:
		current_camera.offset = Vector2.ZERO
		target_zoom = Vector2.ONE

	if flash_overlay.get_parent():
		flash_overlay.get_parent().remove_child(flash_overlay)

	if transition_overlay.get_parent():
		transition_overlay.get_parent().remove_child(transition_overlay)

	Engine.time_scale = 1.0
	is_transitioning = false
