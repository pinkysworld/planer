extends Control
## GameHUD - In-game heads-up display showing time, money, and status

@onready var day_label = $TopBar/HBox/TimeDisplay/DayLabel
@onready var time_label = $TopBar/HBox/TimeDisplay/TimeLabel
@onready var company_money_label = $TopBar/HBox/MoneyDisplay/CompanyMoney
@onready var private_money_label = $TopBar/HBox/MoneyDisplay/PrivateMoney
@onready var reputation_label = $TopBar/HBox/StatsDisplay/ReputationLabel
@onready var trucks_label = $TopBar/HBox/StatsDisplay/TrucksLabel
@onready var location_label = $BottomBar/HBox/LocationLabel
@onready var interaction_hint = $BottomBar/HBox/InteractionHint
@onready var notification_container = $NotificationContainer

func _ready() -> void:
	_connect_signals()
	_update_display()
	interaction_hint.visible = true

func _connect_signals() -> void:
	GameManager.day_changed.connect(_on_day_changed)
	GameManager.time_changed.connect(_on_time_changed)
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.reputation_changed.connect(_on_reputation_changed)
	EventBus.notification_shown.connect(_show_notification)

func _process(_delta: float) -> void:
	_update_time_display()

func _update_display() -> void:
	_update_day_display()
	_update_time_display()
	_update_money_display()
	_update_stats_display()

func _update_day_display() -> void:
	if day_label:
		day_label.text = "Day %d" % GameManager.current_day

func _update_time_display() -> void:
	if time_label:
		time_label.text = "%02d:%02d" % [GameManager.current_hour, GameManager.current_minute]

func _update_money_display() -> void:
	if company_money_label:
		company_money_label.text = "Company: €%s" % _format_money(GameManager.company_money)
		
		if GameManager.company_money < 10000:
			company_money_label.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
		elif GameManager.company_money > 100000:
			company_money_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
		else:
			company_money_label.remove_theme_color_override("font_color")
	
	if private_money_label:
		private_money_label.text = "Private: €%s" % _format_money(GameManager.private_money)

func _update_stats_display() -> void:
	if reputation_label:
		reputation_label.text = "Reputation: %.0f%%" % GameManager.company_reputation
	if trucks_label:
		var drivers = GameManager.employees.filter(func(e): return e.role == "Driver").size()
		trucks_label.text = "Trucks: %d | Drivers: %d" % [GameManager.trucks.size(), drivers]

func _format_money(amount: float) -> String:
	if amount >= 1000000:
		return "%.2fM" % (amount / 1000000.0)
	elif amount >= 1000:
		return "%.1fK" % (amount / 1000.0)
	else:
		return "%.0f" % amount

func _on_day_changed(_day: int) -> void:
	_update_day_display()

func _on_time_changed(_hour: int, _minute: int) -> void:
	_update_time_display()

func _on_money_changed(_company: float, _private: float) -> void:
	_update_money_display()

func _on_reputation_changed(_reputation: float) -> void:
	_update_stats_display()

func update_location(location: String) -> void:
	if location_label:
		location_label.text = location

func show_interaction_hint(text: String) -> void:
	if interaction_hint:
		interaction_hint.text = text
		interaction_hint.visible = true

func hide_interaction_hint() -> void:
	if interaction_hint:
		interaction_hint.text = "Click on a door or press E to interact"

func _show_notification(message: String, type: String) -> void:
	if notification_container == null:
		return
	
	var notification = PanelContainer.new()
	notification.custom_minimum_size = Vector2(300, 50)
	
	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification.add_child(label)
	
	match type:
		"success":
			label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		"error":
			label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
		"warning":
			label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	
	notification_container.add_child(notification)
	
	# Auto-remove after delay
	var timer = get_tree().create_timer(4.0)
	timer.timeout.connect(func():
		if is_instance_valid(notification):
			notification.queue_free()
	)

func _on_pause_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.set_game_speed(0.0)
	GameManager.pause_game()

func _on_speed1_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.resume_game()
	GameManager.set_game_speed(1.0)

func _on_speed2_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.resume_game()
	GameManager.set_game_speed(2.0)

func _on_speed3_pressed() -> void:
	AudioManager.play_sfx("click")
	GameManager.resume_game()
	GameManager.set_game_speed(4.0)

func _on_menu_pressed() -> void:
	AudioManager.play_sfx("click")
	var pause_menu = get_parent().get_node_or_null("PauseMenu")
	if pause_menu:
		pause_menu.visible = true
		GameManager.pause_game()
