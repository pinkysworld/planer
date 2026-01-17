extends CanvasLayer
## NotificationManager - Manages achievement and info notifications

const AchievementNotification = preload("res://scripts/ui/achievement_notification.gd")

var notification_queue: Array[Dictionary] = []
var current_notification: Control = null
var is_showing: bool = false

func _ready() -> void:
	layer = 100  # Above everything else

## Shows an achievement notification
func show_achievement(title: String, description: String) -> void:
	_queue_notification({
		"type": "achievement",
		"title": title,
		"description": description
	})

## Shows a custom notification
func show_notification(title: String, description: String) -> void:
	_queue_notification({
		"type": "notification",
		"title": title,
		"description": description
	})

func _queue_notification(notification_data: Dictionary) -> void:
	notification_queue.append(notification_data)

	if not is_showing:
		_show_next_notification()

func _show_next_notification() -> void:
	if notification_queue.is_empty():
		is_showing = false
		return

	is_showing = true
	var data = notification_queue.pop_front()

	# Create notification
	current_notification = AchievementNotification.new()
	add_child(current_notification)

	# Show it
	await current_notification.show_notification(data.title, data.description)

	# Show next
	_show_next_notification()

## Quick info toast (bottom center)
func show_toast(message: String, duration: float = 2.0) -> void:
	var toast = Panel.new()
	add_child(toast)

	# Style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	toast.add_theme_stylebox_override("panel", style)

	# Label
	var label = Label.new()
	label.text = message
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color.WHITE)
	toast.add_child(label)

	# Size and position
	await get_tree().process_frame
	var label_size = label.get_minimum_size()
	toast.custom_minimum_size = label_size + Vector2(20, 10)
	label.position = Vector2(10, 5)

	var viewport_size = get_viewport_rect().size
	toast.position = Vector2(
		(viewport_size.x - toast.custom_minimum_size.x) / 2,
		viewport_size.y - 100
	)

	# Fade in
	toast.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(toast, "modulate:a", 1.0, 0.2)

	# Wait
	await get_tree().create_timer(duration).timeout

	# Fade out
	tween = create_tween()
	tween.tween_property(toast, "modulate:a", 0.0, 0.3)
	await tween.finished

	toast.queue_free()
