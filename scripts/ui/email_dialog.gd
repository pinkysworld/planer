extends Control
## EmailDialog - Modern replacement for fax - view emails and messages

signal closed

@onready var email_container = $Panel/VBox/EmailList/EmailContainer
@onready var info_label = $Panel/VBox/Footer/InfoLabel

var emails: Array = []

func _ready() -> void:
	_generate_initial_emails()
	_refresh_emails()

func _generate_initial_emails() -> void:
	emails = [
		{
			"from": "Board of Directors",
			"subject": "Welcome to Modern Transport Co.",
			"body": "Welcome to your new position as CEO! We have high expectations for the company's growth. Good luck!",
			"read": true,
			"timestamp": GameManager.current_day - 1
		},
		{
			"from": "IT Department",
			"subject": "System Updates Complete",
			"body": "All company systems have been updated to the latest version. The new GPS tracking and route optimization software is now available for all trucks.",
			"read": false,
			"timestamp": GameManager.current_day
		},
		{
			"from": "HR Department",
			"subject": "New Hiring Procedures",
			"body": "Please note that all new employee hires must go through the HR room. We have streamlined the hiring process for your convenience.",
			"read": false,
			"timestamp": GameManager.current_day
		}
	]

	# Add emails based on game state
	if GameManager.trucks.size() < 3:
		emails.append({
			"from": "Fleet Advisor",
			"subject": "Expand Your Fleet",
			"body": "Consider purchasing more trucks to take on additional contracts. Visit the Truck Dealer in the basement to see our current inventory.",
			"read": false,
			"timestamp": GameManager.current_day
		})

	if GameManager.employees.size() < 2:
		emails.append({
			"from": "Operations Manager",
			"subject": "Hire More Drivers",
			"body": "To maximize your delivery capacity, you should hire more drivers. Visit the HR department to review candidates.",
			"read": false,
			"timestamp": GameManager.current_day
		})

func _refresh_emails() -> void:
	for child in email_container.get_children():
		child.queue_free()

	if emails.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No emails. Your inbox is empty."
		empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		email_container.add_child(empty_label)
		return

	var unread_count = 0
	for email in emails:
		if not email.read:
			unread_count += 1
		var card = _create_email_card(email)
		email_container.add_child(card)

	info_label.text = "%d unread email(s)" % unread_count if unread_count > 0 else "All emails read"

func _create_email_card(email: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)

	if not email.read:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.25, 0.35)
		style.set_corner_radius_all(5)
		card.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var vbox = VBoxContainer.new()
	margin.add_child(vbox)

	var header = HBoxContainer.new()

	var from_label = Label.new()
	from_label.text = email.from
	from_label.add_theme_font_size_override("font_size", 14)
	if not email.read:
		from_label.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
	header.add_child(from_label)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	var day_label = Label.new()
	day_label.text = "Day %d" % email.timestamp
	day_label.add_theme_font_size_override("font_size", 12)
	day_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	header.add_child(day_label)

	vbox.add_child(header)

	var subject_label = Label.new()
	subject_label.text = email.subject
	subject_label.add_theme_font_size_override("font_size", 16)
	if not email.read:
		subject_label.modulate = Color(1, 1, 1)
	else:
		subject_label.modulate = Color(0.8, 0.8, 0.8)
	vbox.add_child(subject_label)

	var preview_label = Label.new()
	preview_label.text = email.body.substr(0, 80) + "..." if email.body.length() > 80 else email.body
	preview_label.add_theme_font_size_override("font_size", 12)
	preview_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(preview_label)

	# Make card clickable
	var btn = Button.new()
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.pressed.connect(func(): _open_email(email))
	card.add_child(btn)

	return card

func _open_email(email: Dictionary) -> void:
	AudioManager.play_sfx("click")
	email.read = true

	# Show email detail dialog
	var dialog = _create_email_detail_dialog(email)
	add_child(dialog)

func _create_email_detail_dialog(email: Dictionary) -> Control:
	var dialog = Control.new()
	dialog.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.9)
	dialog.add_child(bg)

	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -350
	panel.offset_right = 350
	panel.offset_top = -200
	panel.offset_bottom = 200
	dialog.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	panel.add_child(vbox)

	var from_label = Label.new()
	from_label.text = "From: " + email.from
	from_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(from_label)

	var subject_label = Label.new()
	subject_label.text = email.subject
	subject_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(subject_label)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	var body_scroll = ScrollContainer.new()
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(body_scroll)

	var body_label = Label.new()
	body_label.text = email.body
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.add_child(body_label)

	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(100, 35)
	close_btn.pressed.connect(func():
		dialog.queue_free()
		_refresh_emails()
	)
	vbox.add_child(close_btn)

	return dialog

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
