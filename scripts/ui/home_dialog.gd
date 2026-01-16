extends Control
## HomeDialog - Private life, family, and retirement

signal closed

@onready var happiness_progress = $Panel/VBox/MainContent/FamilySection/HappinessBar/HappinessProgress
@onready var wife_request = $Panel/VBox/MainContent/FamilySection/WifeSection/WifeRequest
@onready var wife_btn = $Panel/VBox/MainContent/FamilySection/WifeSection/WifeGiveBtn
@onready var child_request = $Panel/VBox/MainContent/FamilySection/ChildSection/ChildRequest
@onready var child_btn = $Panel/VBox/MainContent/FamilySection/ChildSection/ChildGiveBtn
@onready var private_money_label = $Panel/VBox/MainContent/StatusSection/PrivateMoneyLabel
@onready var status_progress = $Panel/VBox/MainContent/StatusSection/SocialStatusBar/StatusProgress
@onready var retire_btn = $Panel/VBox/MainContent/StatusSection/RetirementSection/RetireButton
@onready var info_label = $Panel/VBox/Footer/InfoLabel

var wife_request_amount: float = 500.0
var child_request_amount: float = 100.0

var wife_requests: Array = [
	"\"Could you give me some money for shopping?\"",
	"\"I saw a beautiful dress, can I have some money?\"",
	"\"The kitchen needs new appliances, dear.\"",
	"\"My friends are going to the spa, can I join them?\"",
	"\"We should redecorate the living room.\""
]

var child_requests: Array = [
	"\"Dad, I need money for a new video game!\"",
	"\"Can I have money for the movies with friends?\"",
	"\"I want to buy a new bicycle!\"",
	"\"School trip is coming up, I need some cash.\"",
	"\"My phone is old, can I get a new one?\""
]

func _ready() -> void:
	_refresh_display()
	_generate_requests()

func _refresh_display() -> void:
	happiness_progress.value = GameManager.family_happiness
	_color_progress_bar(happiness_progress)

	private_money_label.text = "Private Money: €%.0f" % GameManager.private_money
	status_progress.value = GameManager.social_status
	_color_progress_bar(status_progress)

	# Check retirement eligibility
	retire_btn.disabled = not GameManager.can_retire()

	# Update button states
	wife_btn.disabled = GameManager.private_money < wife_request_amount
	child_btn.disabled = GameManager.private_money < child_request_amount

func _color_progress_bar(bar: ProgressBar) -> void:
	var value = bar.value
	if value < 30:
		bar.modulate = Color(1, 0.3, 0.3)
	elif value < 60:
		bar.modulate = Color(1, 0.8, 0.3)
	else:
		bar.modulate = Color(0.3, 1, 0.5)

func _generate_requests() -> void:
	wife_request.text = wife_requests[randi() % wife_requests.size()]
	child_request.text = child_requests[randi() % child_requests.size()]

	# Vary request amounts based on social status
	wife_request_amount = 300.0 + GameManager.social_status * 5.0
	child_request_amount = 50.0 + GameManager.social_status * 2.0

	wife_btn.text = "Give €%.0f" % wife_request_amount
	child_btn.text = "Give €%.0f" % child_request_amount

func _on_give_wife_money() -> void:
	AudioManager.play_sfx("cash_register")

	if GameManager.give_family_money(wife_request_amount):
		info_label.text = "Your partner is happy with the gift!"
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))

		# Additional happiness boost
		GameManager.family_happiness += 5.0
		GameManager.family_happiness = min(GameManager.family_happiness, 100.0)

		_refresh_display()
		_generate_requests()
	else:
		info_label.text = "Not enough private money."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_give_child_money() -> void:
	AudioManager.play_sfx("cash_register")

	if GameManager.give_family_money(child_request_amount):
		info_label.text = "Your child is thrilled!"
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))

		# Additional happiness boost
		GameManager.family_happiness += 3.0
		GameManager.family_happiness = min(GameManager.family_happiness, 100.0)

		_refresh_display()
		_generate_requests()
	else:
		info_label.text = "Not enough private money."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_retire_pressed() -> void:
	AudioManager.play_sfx("success")

	# Show retirement ending screen
	var retirement_dialog = _create_retirement_dialog()
	add_child(retirement_dialog)

func _create_retirement_dialog() -> Control:
	var dialog = Control.new()
	dialog.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.95)
	dialog.add_child(bg)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -300
	vbox.offset_right = 300
	vbox.offset_top = -200
	vbox.offset_bottom = 200
	vbox.add_theme_constant_override("separation", 20)
	dialog.add_child(vbox)

	var title = Label.new()
	title.text = "CONGRATULATIONS!"
	title.add_theme_font_size_override("font_size", 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	vbox.add_child(title)

	var message = Label.new()
	message.text = "You have successfully retired!\n\nAfter %d days of hard work, you built a successful\ntransport empire and achieved a comfortable life\nfor you and your family.\n\nFinal Statistics:\n- Total Revenue: €%.0f\n- Total Deliveries: %d\n- Trucks Owned: %d\n- Social Status: %.0f%%\n- Family Happiness: %.0f%%" % [
		GameManager.current_day,
		GameManager.total_revenue,
		GameManager.total_deliveries_completed,
		GameManager.trucks.size(),
		GameManager.social_status,
		GameManager.family_happiness
	]
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(message)

	var btn = Button.new()
	btn.text = "Return to Main Menu"
	btn.custom_minimum_size = Vector2(200, 50)
	btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	vbox.add_child(btn)

	var center_btn = Control.new()
	center_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.reparent(center_btn)
	vbox.add_child(center_btn)

	return dialog

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
