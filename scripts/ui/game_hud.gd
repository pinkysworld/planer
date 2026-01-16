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
@onready var pause_menu = %PauseMenu

var notification_scene = preload("res://scenes/ui/notification.tscn")

func _ready() -> void:
	_connect_signals()
	_update_display()
	interaction_hint.visible = false

func _connect_signals() -> void:
	GameManager.day_changed.connect(_on_day_changed)
	GameManager.time_changed.connect(_on_time_changed)
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.reputation_changed.connect(_on_reputation_changed)
	EventBus.notification_shown.connect(_show_notification)
	EventBus.contract_accepted.connect(_on_contract_accepted)
	EventBus.delivery_completed.connect(_on_delivery_completed)
	EventBus.truck_purchased.connect(_on_truck_purchased)
	EventBus.employee_hired.connect(_on_employee_hired)

func _process(_delta: float) -> void:
	# Update time display every frame for smooth updating
	_update_time_display()

func _update_display() -> void:
	_update_day_display()
	_update_time_display()
	_update_money_display()
	_update_stats_display()

func _update_day_display() -> void:
	day_label.text = "Day %d" % GameManager.current_day

func _update_time_display() -> void:
	time_label.text = "%02d:%02d" % [GameManager.current_hour, GameManager.current_minute]

func _update_money_display() -> void:
	company_money_label.text = "Company: €%s" % _format_money(GameManager.company_money)
	private_money_label.text = "Private: €%s" % _format_money(GameManager.private_money)

	# Color coding for money
	if GameManager.company_money < 10000:
		company_money_label.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	elif GameManager.company_money > 100000:
		company_money_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	else:
		company_money_label.remove_theme_color_override("font_color")

func _update_stats_display() -> void:
	reputation_label.text = "Reputation: %.0f%%" % GameManager.company_reputation
	trucks_label.text = "Trucks: %d | Employees: %d" % [
		GameManager.trucks.size(),
		GameManager.employees.size()
	]

func _format_money(amount: float) -> String:
	if amount >= 1000000:
		return "%.2fM" % (amount / 1000000.0)
	elif amount >= 1000:
		return "%.1fK" % (amount / 1000.0)
	else:
		return "%.0f" % amount

# Signal handlers
func _on_day_changed(day: int) -> void:
	_update_day_display()

func _on_time_changed(hour: int, minute: int) -> void:
	_update_time_display()

func _on_money_changed(company: float, private: float) -> void:
	_update_money_display()

func _on_reputation_changed(reputation: float) -> void:
	_update_stats_display()

func _on_contract_accepted(contract: Dictionary) -> void:
	_show_notification("Contract accepted: %s" % contract.client, "success")
	_update_stats_display()

func _on_delivery_completed(delivery: Dictionary, on_time: bool) -> void:
	if on_time:
		_show_notification("Delivery completed on time!", "success")
	else:
		_show_notification("Delivery completed late - penalty applied", "warning")
	_update_stats_display()

func _on_truck_purchased(truck: Dictionary) -> void:
	_show_notification("New truck purchased: %s" % truck.model, "info")
	_update_stats_display()

func _on_employee_hired(employee: Dictionary) -> void:
	_show_notification("New employee hired: %s" % employee.name, "info")
	_update_stats_display()

# Location and interaction hints
func update_location(location: String) -> void:
	location_label.text = location

func show_interaction_hint(text: String) -> void:
	interaction_hint.text = text
	interaction_hint.visible = true

func hide_interaction_hint() -> void:
	interaction_hint.visible = false

# Notifications
func _show_notification(message: String, type: String) -> void:
	var notification = notification_scene.instantiate()
	notification.setup(message, type)
	notification_container.add_child(notification)

	# Auto-remove after delay
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(func():
		if is_instance_valid(notification):
			notification.queue_free()
	)

# Speed controls
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
	get_parent().get_node("PauseMenu").visible = true
	GameManager.pause_game()
