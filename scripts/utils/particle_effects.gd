extends Node
## ParticleEffects - Professional particle and visual effects

class_name ParticleEffects

## Creates money particles that float up
static func create_money_particles(parent: Node, start_position: Vector2, amount: int = 10) -> void:
	for i in range(amount):
		var particle = ColorRect.new()
		particle.size = Vector2(8, 8)
		particle.color = Color(1, 0.85, 0.2)
		particle.position = start_position + Vector2(randf_range(-20, 20), randf_range(-10, 10))
		parent.add_child(particle)

		# Animate upward with fade
		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position:y", particle.position.y - randf_range(50, 100), randf_range(0.8, 1.2))
		tween.tween_property(particle, "modulate:a", 0.0, randf_range(0.8, 1.2))
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)

## Creates success stars that burst outward
static func create_success_burst(parent: Node, center_position: Vector2, count: int = 8) -> void:
	for i in range(count):
		var star = _create_star_shape()
		star.position = center_position
		star.scale = Vector2(0.5, 0.5)
		parent.add_child(star)

		# Calculate outward direction
		var angle = (TAU / count) * i
		var direction = Vector2(cos(angle), sin(angle))
		var target_pos = center_position + direction * randf_range(80, 120)

		# Animate
		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(star, "position", target_pos, 0.6)
		tween.tween_property(star, "scale", Vector2(0, 0), 0.6)
		tween.tween_property(star, "modulate:a", 0.0, 0.6)
		tween.set_parallel(false)
		tween.tween_callback(star.queue_free)

## Creates sparkle effect
static func create_sparkle(parent: Node, position: Vector2) -> void:
	var sparkle = ColorRect.new()
	sparkle.size = Vector2(4, 4)
	sparkle.color = Color(1, 1, 0.8)
	sparkle.position = position - sparkle.size / 2
	parent.add_child(sparkle)

	# Pulse and fade
	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(sparkle, "scale", Vector2(2, 2), 0.3)
	tween.tween_property(sparkle, "modulate:a", 0.0, 0.3)
	tween.set_parallel(false)
	tween.tween_callback(sparkle.queue_free)

## Creates ripple effect
static func create_ripple(parent: Node, center: Vector2, color: Color = Color(0.5, 0.7, 1.0)) -> void:
	for i in range(3):
		var ring = Control.new()
		parent.add_child(ring)

		# Create ring using ColorRect (simplified)
		var outer = ColorRect.new()
		outer.color = color
		outer.size = Vector2(20, 20)
		outer.position = center - outer.size / 2
		ring.add_child(outer)

		# Delay each ring
		await parent.get_tree().create_timer(i * 0.1).timeout

		# Expand and fade
		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(outer, "size", Vector2(100, 100), 0.8)
		tween.tween_property(outer, "position", center - Vector2(50, 50), 0.8)
		tween.tween_property(outer, "modulate:a", 0.0, 0.8)
		tween.set_parallel(false)
		tween.tween_callback(ring.queue_free)

## Creates confetti explosion
static func create_confetti(parent: Node, center: Vector2, count: int = 20) -> void:
	var colors = [
		Color(1, 0.3, 0.3),
		Color(0.3, 1, 0.3),
		Color(0.3, 0.3, 1),
		Color(1, 1, 0.3),
		Color(1, 0.3, 1),
		Color(0.3, 1, 1)
	]

	for i in range(count):
		var piece = ColorRect.new()
		piece.size = Vector2(randf_range(4, 8), randf_range(8, 12))
		piece.color = colors[randi() % colors.size()]
		piece.position = center
		piece.rotation = randf_range(0, TAU)
		parent.add_child(piece)

		# Random trajectory
		var velocity = Vector2(randf_range(-150, 150), randf_range(-200, -100))
		var gravity = 300.0
		var duration = randf_range(1.0, 1.5)

		# Animate falling with rotation
		var tween = parent.create_tween()
		tween.set_parallel(true)

		# Calculate final position with gravity
		var final_pos = center + velocity * duration + Vector2(0, 0.5 * gravity * duration * duration)
		tween.tween_property(piece, "position", final_pos, duration)
		tween.tween_property(piece, "rotation", piece.rotation + randf_range(-TAU * 2, TAU * 2), duration)
		tween.tween_property(piece, "modulate:a", 0.0, duration)

		tween.set_parallel(false)
		tween.tween_callback(piece.queue_free)

## Creates screen shake effect
static func create_screen_shake(camera: Camera2D, intensity: float = 10.0, duration: float = 0.3) -> void:
	if not camera:
		return

	var original_offset = camera.offset
	var shake_timer = 0.0

	while shake_timer < duration:
		camera.offset = original_offset + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)

		shake_timer += 0.016  # ~60 FPS
		await camera.get_tree().create_timer(0.016).timeout

		# Reduce intensity over time
		intensity *= 0.9

	camera.offset = original_offset

## Creates floating text (damage numbers, +money, etc.)
static func create_floating_text(parent: Node, text: String, start_pos: Vector2, color: Color = Color.WHITE) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", color)
	label.position = start_pos
	parent.add_child(label)

	# Float up and fade
	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", start_pos.y - 50, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)

## Helper to create a star shape
static func _create_star_shape() -> Control:
	var star = Control.new()
	star.custom_minimum_size = Vector2(16, 16)

	# Simplified star using rectangles
	var h_bar = ColorRect.new()
	h_bar.size = Vector2(16, 4)
	h_bar.position = Vector2(0, 6)
	h_bar.color = Color(1, 1, 0.5)
	star.add_child(h_bar)

	var v_bar = ColorRect.new()
	v_bar.size = Vector2(4, 16)
	v_bar.position = Vector2(6, 0)
	v_bar.color = Color(1, 1, 0.5)
	star.add_child(v_bar)

	var diag1 = ColorRect.new()
	diag1.size = Vector2(12, 3)
	diag1.position = Vector2(2, 2)
	diag1.rotation = PI / 4
	diag1.color = Color(1, 1, 0.6)
	star.add_child(diag1)

	var diag2 = ColorRect.new()
	diag2.size = Vector2(12, 3)
	diag2.position = Vector2(14, 2)
	diag2.rotation = -PI / 4
	diag2.color = Color(1, 1, 0.6)
	star.add_child(diag2)

	return star
