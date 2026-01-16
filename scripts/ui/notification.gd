extends PanelContainer
## Notification - Toast notification display

@onready var label = $MarginContainer/Label

func setup(message: String, type: String = "info") -> void:
	label.text = message

	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(8)

	match type:
		"success":
			style.bg_color = Color(0.1, 0.4, 0.2, 0.95)
		"warning":
			style.bg_color = Color(0.5, 0.4, 0.1, 0.95)
		"error":
			style.bg_color = Color(0.5, 0.1, 0.1, 0.95)
		_:  # info
			style.bg_color = Color(0.15, 0.2, 0.35, 0.95)

	add_theme_stylebox_override("panel", style)

	# Fade in animation
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(queue_free)
