extends Node
## VisualEffects - Enhanced visual effects system for better graphics
## Provides particles, lighting, weather effects, and animations

signal effect_spawned(effect_name: String, position: Vector2)
signal lighting_changed(time_of_day: float, intensity: float)

# Weather particles
var rain_particles: Array = []
var snow_particles: Array = []
var current_weather_effect: Node = null

# Lighting
var ambient_light: float = 1.0
var time_of_day: float = 0.5  # 0.0 = midnight, 0.5 = noon, 1.0 = midnight again

# Animation system
var active_animations: Array = []

# Effect templates
var effect_scenes: Dictionary = {}

func _ready() -> void:
	GameManager.time_changed.connect(_on_time_changed)
	EventBus.delivery_completed.connect(_on_delivery_completed) if EventBus.has_signal("delivery_completed") else null

	if has_node("/root/RouteAI"):
		RouteAI.weather_changed.connect(_on_weather_changed)

	_initialize_effects()

func _initialize_effects() -> void:
	# Pre-create effect templates (these would normally be scenes)
	pass

func _process(delta: float) -> void:
	_update_lighting(delta)
	_update_animations(delta)

func _on_time_changed(hour: int, minute: int) -> void:
	# Update time of day for lighting
	time_of_day = (hour + minute / 60.0) / 24.0
	_update_ambient_lighting()

func _update_ambient_lighting() -> void:
	# Calculate ambient light based on time of day
	# Create a smooth day/night cycle
	var sun_angle = time_of_day * TAU
	var sun_height = sin(sun_angle)

	# Ambient light ranges from 0.2 (night) to 1.0 (day)
	ambient_light = 0.2 + max(0.0, sun_height) * 0.8

	# Emit signal for other systems to update
	emit_signal("lighting_changed", time_of_day, ambient_light)

func _update_lighting(delta: float) -> void:
	# Smooth lighting transitions
	# This would apply to the game's visual nodes
	pass

func _update_animations(delta: float) -> void:
	# Update all active animations
	var completed_anims = []

	for anim in active_animations:
		anim.time += delta
		if anim.time >= anim.duration:
			completed_anims.append(anim)
		else:
			_process_animation(anim, delta)

	# Remove completed animations
	for anim in completed_anims:
		active_animations.erase(anim)

func _process_animation(anim: Dictionary, delta: float) -> void:
	# Process different animation types
	match anim.type:
		"float_text":
			_animate_floating_text(anim, delta)
		"pulse":
			_animate_pulse(anim, delta)
		"shake":
			_animate_shake(anim, delta)
		"fade":
			_animate_fade(anim, delta)

func _animate_floating_text(anim: Dictionary, delta: float) -> void:
	if anim.has("node") and is_instance_valid(anim.node):
		var progress = anim.time / anim.duration
		anim.node.position.y -= 30.0 * delta
		anim.node.modulate.a = 1.0 - progress

func _animate_pulse(anim: Dictionary, delta: float) -> void:
	if anim.has("node") and is_instance_valid(anim.node):
		var progress = anim.time / anim.duration
		var scale_factor = 1.0 + sin(progress * TAU * 3.0) * 0.1
		anim.node.scale = Vector2(scale_factor, scale_factor)

func _animate_shake(anim: Dictionary, delta: float) -> void:
	if anim.has("node") and is_instance_valid(anim.node):
		var intensity = anim.get("intensity", 5.0)
		var progress = 1.0 - (anim.time / anim.duration)
		anim.node.position += Vector2(
			randf_range(-intensity, intensity) * progress,
			randf_range(-intensity, intensity) * progress
		)

func _animate_fade(anim: Dictionary, delta: float) -> void:
	if anim.has("node") and is_instance_valid(anim.node):
		var progress = anim.time / anim.duration
		if anim.get("fade_in", false):
			anim.node.modulate.a = progress
		else:
			anim.node.modulate.a = 1.0 - progress

func _on_weather_changed(region: String, weather: String, impact: float) -> void:
	# Update visual weather effects
	print("Weather changed in %s: %s" % [region, weather])

func _on_delivery_completed(delivery: Dictionary, on_time: bool) -> void:
	# Visual celebration effect for completed delivery
	if on_time:
		_spawn_success_effect()

# Public API - Effect Spawning

func spawn_particle_effect(effect_type: String, position: Vector2, parent: Node = null) -> void:
	"""Spawn a particle effect at a position"""
	match effect_type:
		"success":
			_spawn_success_particles(position, parent)
		"money":
			_spawn_money_particles(position, parent)
		"warning":
			_spawn_warning_particles(position, parent)
		"smoke":
			_spawn_smoke_effect(position, parent)
		"sparkle":
			_spawn_sparkle_effect(position, parent)

func _spawn_success_particles(position: Vector2, parent: Node) -> void:
	# Create success particle effect (green sparkles)
	var particle_count = 20
	for i in range(particle_count):
		var angle = randf() * TAU
		var speed = randf_range(50.0, 150.0)
		_create_particle({
			"position": position,
			"velocity": Vector2(cos(angle), sin(angle)) * speed,
			"color": Color(0.2, 1.0, 0.3),
			"lifetime": randf_range(0.5, 1.0),
			"size": randf_range(2.0, 5.0)
		}, parent)

func _spawn_money_particles(position: Vector2, parent: Node) -> void:
	# Create money particle effect (golden sparkles)
	var particle_count = 15
	for i in range(particle_count):
		var angle = randf() * TAU
		var speed = randf_range(30.0, 100.0)
		_create_particle({
			"position": position,
			"velocity": Vector2(cos(angle), sin(angle)) * speed,
			"color": Color(1.0, 0.84, 0.0),
			"lifetime": randf_range(0.5, 1.2),
			"size": randf_range(3.0, 6.0)
		}, parent)

func _spawn_warning_particles(position: Vector2, parent: Node) -> void:
	# Create warning particle effect (red/orange)
	var particle_count = 10
	for i in range(particle_count):
		var angle = randf() * TAU
		var speed = randf_range(20.0, 80.0)
		_create_particle({
			"position": position,
			"velocity": Vector2(cos(angle), sin(angle)) * speed,
			"color": Color(1.0, 0.3, 0.0),
			"lifetime": randf_range(0.3, 0.8),
			"size": randf_range(2.0, 4.0)
		}, parent)

func _spawn_smoke_effect(position: Vector2, parent: Node) -> void:
	# Create smoke effect (gray puffs)
	var particle_count = 8
	for i in range(particle_count):
		var angle = randf_range(-PI/4, PI/4) - PI/2  # Upward
		var speed = randf_range(10.0, 40.0)
		_create_particle({
			"position": position,
			"velocity": Vector2(cos(angle), sin(angle)) * speed,
			"color": Color(0.5, 0.5, 0.5, 0.7),
			"lifetime": randf_range(1.0, 2.0),
			"size": randf_range(8.0, 15.0),
			"grow": true
		}, parent)

func _spawn_sparkle_effect(position: Vector2, parent: Node) -> void:
	# Create sparkle effect (white/yellow stars)
	var particle_count = 12
	for i in range(particle_count):
		var angle = randf() * TAU
		var speed = randf_range(40.0, 120.0)
		_create_particle({
			"position": position,
			"velocity": Vector2(cos(angle), sin(angle)) * speed,
			"color": Color(1.0, 1.0, 0.8),
			"lifetime": randf_range(0.4, 0.9),
			"size": randf_range(3.0, 7.0),
			"twinkle": true
		}, parent)

func _create_particle(data: Dictionary, parent: Node) -> void:
	# This would create an actual particle node in the game
	# For now, just store the data for processing
	if parent == null:
		return

	# Create a simple ColorRect as particle (in a full game, use proper sprites)
	var particle = ColorRect.new()
	particle.color = data.color
	particle.size = Vector2(data.size, data.size)
	particle.position = data.position
	parent.add_child(particle)

	# Add animation
	var anim = {
		"node": particle,
		"type": "particle",
		"time": 0.0,
		"duration": data.lifetime,
		"velocity": data.get("velocity", Vector2.ZERO),
		"gravity": data.get("gravity", 100.0),
		"grow": data.get("grow", false),
		"twinkle": data.get("twinkle", false),
		"initial_size": data.size
	}
	active_animations.append(anim)

func _spawn_success_effect() -> void:
	# Global success effect (could be shown on HUD)
	emit_signal("effect_spawned", "success", Vector2.ZERO)

func show_floating_text(text: String, position: Vector2, color: Color, parent: Node) -> void:
	"""Show floating text effect (like +€1000)"""
	if parent == null:
		return

	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.position = position
	parent.add_child(label)

	var anim = {
		"node": label,
		"type": "float_text",
		"time": 0.0,
		"duration": 1.5
	}
	active_animations.append(anim)

func pulse_node(node: Node, duration: float = 0.5) -> void:
	"""Make a node pulse (scale animation)"""
	if node == null:
		return

	var anim = {
		"node": node,
		"type": "pulse",
		"time": 0.0,
		"duration": duration
	}
	active_animations.append(anim)

func shake_node(node: Node, intensity: float = 5.0, duration: float = 0.3) -> void:
	"""Shake a node (screen shake effect)"""
	if node == null:
		return

	var anim = {
		"node": node,
		"type": "shake",
		"time": 0.0,
		"duration": duration,
		"intensity": intensity
	}
	active_animations.append(anim)

func fade_in_node(node: Node, duration: float = 0.5) -> void:
	"""Fade in a node"""
	if node == null:
		return

	var anim = {
		"node": node,
		"type": "fade",
		"time": 0.0,
		"duration": duration,
		"fade_in": true
	}
	active_animations.append(anim)

func fade_out_node(node: Node, duration: float = 0.5) -> void:
	"""Fade out a node"""
	if node == null:
		return

	var anim = {
		"node": node,
		"type": "fade",
		"time": 0.0,
		"duration": duration,
		"fade_in": false
	}
	active_animations.append(anim)

# Weather visualization
func create_weather_layer(weather_type: String, parent: Node) -> Node:
	"""Create a weather effect layer for the scene"""
	if current_weather_effect:
		current_weather_effect.queue_free()
		current_weather_effect = null

	var weather_node = Node2D.new()
	weather_node.name = "WeatherEffect"
	parent.add_child(weather_node)

	match weather_type:
		"rain", "light_rain", "heavy_rain":
			_create_rain_effect(weather_node, weather_type == "heavy_rain")
		"snow":
			_create_snow_effect(weather_node)
		"fog":
			_create_fog_effect(weather_node)

	current_weather_effect = weather_node
	return weather_node

func _create_rain_effect(parent: Node, heavy: bool) -> void:
	# Create rain particle effect
	var particle_count = 200 if heavy else 100
	# In a full game, this would use GPUParticles2D or CPUParticles2D
	pass

func _create_snow_effect(parent: Node) -> void:
	# Create snow particle effect
	# In a full game, this would use GPUParticles2D
	pass

func _create_fog_effect(parent: Node) -> void:
	# Create fog overlay effect
	var fog = ColorRect.new()
	fog.color = Color(0.8, 0.8, 0.9, 0.3)
	fog.size = Vector2(1280, 720)
	parent.add_child(fog)

# Lighting
func get_ambient_light_color() -> Color:
	"""Get the current ambient light color based on time of day"""
	var hour = GameManager.current_hour + GameManager.current_minute / 60.0

	if hour >= 6.0 and hour < 8.0:
		# Dawn - orange/pink tint
		var t = (hour - 6.0) / 2.0
		return Color(1.0, 0.8 + t * 0.2, 0.6 + t * 0.4)
	elif hour >= 8.0 and hour < 18.0:
		# Day - full brightness
		return Color(1.0, 1.0, 1.0)
	elif hour >= 18.0 and hour < 20.0:
		# Dusk - orange tint
		var t = (hour - 18.0) / 2.0
		return Color(1.0, 0.9 - t * 0.3, 0.7 - t * 0.4)
	else:
		# Night - blue tint
		return Color(0.3, 0.3, 0.5)

func get_ambient_light_intensity() -> float:
	"""Get the current ambient light intensity (0.0-1.0)"""
	return ambient_light

# UI Effects
func create_notification_effect(message: String, type: String = "info") -> void:
	"""Create an on-screen notification with effects"""
	emit_signal("effect_spawned", "notification", Vector2.ZERO)
	# In a full game, this would create a notification popup

func create_screen_flash(color: Color, duration: float = 0.2) -> void:
	"""Create a screen flash effect"""
	emit_signal("effect_spawned", "screen_flash", Vector2.ZERO)

# Performance
func set_effects_quality(quality: String) -> void:
	"""Set visual effects quality (low, medium, high)"""
	match quality:
		"low":
			# Reduce particle counts, disable some effects
			pass
		"medium":
			# Standard effects
			pass
		"high":
			# Maximum effects
			pass
