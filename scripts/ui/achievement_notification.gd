extends Control
## AchievementNotification - Steam-style achievement popup

signal notification_complete

const NOTIFICATION_DURATION: float = 4.0
const SLIDE_DURATION: float = 0.3

@onready var panel: Panel
@onready var icon_rect: ColorRect
@onready var title_label: Label
@onready var description_label: Label

var is_showing: bool = false

func _ready() -> void:
	_create_notification()
	position.x = get_viewport_rect().size.x  # Start off-screen

func _create_notification() -> void:
	# Main panel
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(320, 80)
	add_child(panel)

	# Style panel (dark with gradient)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.18, 0.95)
	style.border_color = Color(0.3, 0.6, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	panel.add_theme_stylebox_override("panel", style)

	# Icon background
	icon_rect = ColorRect.new()
	icon_rect.position = Vector2(10, 10)
	icon_rect.size = Vector2(60, 60)
	icon_rect.color = Color(0.2, 0.5, 0.8)
	panel.add_child(icon_rect)

	# Achievement icon (trophy shape using rectangles)
	_create_trophy_icon()

	# Title label
	title_label = Label.new()
	title_label.position = Vector2(80, 15)
	title_label.custom_minimum_size = Vector2(230, 0)
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1))
	panel.add_child(title_label)

	# Description label
	description_label = Label.new()
	description_label.position = Vector2(80, 40)
	description_label.custom_minimum_size = Vector2(230, 0)
	description_label.add_theme_font_size_override("font_size", 11)
	description_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(description_label)

func _create_trophy_icon() -> void:
	# Trophy cup (using simple shapes)
	var cup_base = ColorRect.new()
	cup_base.position = Vector2(20, 45)
	cup_base.size = Vector2(20, 8)
	cup_base.color = Color(1, 0.85, 0.2)
	icon_rect.add_child(cup_base)

	var cup_body = ColorRect.new()
	cup_body.position = Vector2(22, 30)
	cup_body.size = Vector2(16, 18)
	cup_body.color = Color(1, 0.85, 0.2)
	icon_rect.add_child(cup_body)

	var cup_top = ColorRect.new()
	cup_top.position = Vector2(20, 28)
	cup_top.size = Vector2(20, 4)
	cup_top.color = Color(1, 0.9, 0.3)
	icon_rect.add_child(cup_top)

	# Shine effect
	var shine = ColorRect.new()
	shine.position = Vector2(24, 32)
	shine.size = Vector2(6, 10)
	shine.color = Color(1, 1, 0.8, 0.6)
	icon_rect.add_child(shine)

## Shows the notification with title and description
func show_notification(title: String, description: String) -> void:
	if is_showing:
		return

	is_showing = true
	title_label.text = title
	description_label.text = description

	# Slide in from right
	var start_x = get_viewport_rect().size.x
	var end_x = get_viewport_rect().size.x - 340  # 320 width + 20 margin
	position = Vector2(start_x, 20)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:x", end_x, SLIDE_DURATION)

	# Wait
	await get_tree().create_timer(NOTIFICATION_DURATION).timeout

	# Slide out
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:x", start_x, SLIDE_DURATION)

	await tween.finished

	is_showing = false
	notification_complete.emit()

	# Auto cleanup
	queue_free()
