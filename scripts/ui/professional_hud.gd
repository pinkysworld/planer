extends CanvasLayer
## ProfessionalHUD - Modern glassmorphism HUD with smooth animations
## Steam-quality user interface with dynamic updates and visual polish

signal hud_action(action: String)

# HUD Elements
@onready var top_bar: Panel
@onready var company_money_label: Label
@onready var private_money_label: Label
@onready var reputation_bar: ProgressBar
@onready var date_label: Label
@onready var time_label: Label
@onready var notification_container: VBoxContainer
@onready var quick_stats_panel: Panel
@onready var minimap_container: Panel

# Stats tracking
var displayed_company_money: float = 0.0
var displayed_private_money: float = 0.0
var displayed_reputation: float = 0.0

# Animation
var money_tween: Tween
var reputation_tween: Tween

# Notification queue
var notification_queue: Array = []
var active_notifications: Array = []
const MAX_NOTIFICATIONS: int = 3

# Weather overlay
var weather_overlay: ColorRect
var current_weather: String = "clear"

func _ready() -> void:
	_setup_hud()
	_connect_signals()
	_start_hud_updates()

func _setup_hud() -> void:
	# Create glassmorphism HUD elements
	_create_top_bar()
	_create_notification_system()
	_create_quick_stats()
	_create_weather_overlay()

func _create_top_bar() -> void:
	# Main top bar with glassmorphism effect
	top_bar = Panel.new()
	top_bar.name = "TopBar"
	top_bar.size = Vector2(1280, 80)
	top_bar.position = Vector2(0, 0)

	# Add custom shader for glassmorphism
	var glass_material = ShaderMaterial.new()
	var glass_shader = preload("res://shaders/glassmorphism.gdshader")
	glass_material.shader = glass_shader
	top_bar.material = glass_material

	add_child(top_bar)

	# Company Money Display
	var money_container = HBoxContainer.new()
	money_container.position = Vector2(20, 15)
	top_bar.add_child(money_container)

	var money_icon = TextureRect.new()
	money_icon.custom_minimum_size = Vector2(32, 32)
	money_container.add_child(money_icon)

	company_money_label = Label.new()
	company_money_label.text = "€ 0"
	company_money_label.add_theme_font_size_override("font_size", 20)
	company_money_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	money_container.add_child(company_money_label)

	# Private Money Display
	var private_container = HBoxContainer.new()
	private_container.position = Vector2(250, 15)
	top_bar.add_child(private_container)

	var wallet_icon = TextureRect.new()
	wallet_icon.custom_minimum_size = Vector2(32, 32)
	private_container.add_child(wallet_icon)

	private_money_label = Label.new()
	private_money_label.text = "€ 0"
	private_money_label.add_theme_font_size_override("font_size", 18)
	private_money_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.5))
	private_container.add_child(private_money_label)

	# Reputation Bar
	var reputation_container = VBoxContainer.new()
	reputation_container.position = Vector2(480, 15)
	reputation_container.size = Vector2(200, 50)
	top_bar.add_child(reputation_container)

	var rep_label = Label.new()
	rep_label.text = "Reputation"
	rep_label.add_theme_font_size_override("font_size", 12)
	reputation_container.add_child(rep_label)

	reputation_bar = ProgressBar.new()
	reputation_bar.custom_minimum_size = Vector2(200, 24)
	reputation_bar.max_value = 100
	reputation_bar.value = 50
	reputation_bar.show_percentage = true
	reputation_container.add_child(reputation_bar)

	# Date and Time
	var datetime_container = VBoxContainer.new()
	datetime_container.position = Vector2(1050, 10)
	top_bar.add_child(datetime_container)

	date_label = Label.new()
	date_label.text = "Day 1"
	date_label.add_theme_font_size_override("font_size", 16)
	date_label.add_theme_color_override("font_color", Color(1, 1, 1))
	datetime_container.add_child(date_label)

	time_label = Label.new()
	time_label.text = "08:00"
	time_label.add_theme_font_size_override("font_size", 20)
	time_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	datetime_container.add_child(time_label)

func _create_notification_system() -> void:
	# Notification container (right side of screen)
	notification_container = VBoxContainer.new()
	notification_container.name = "NotificationContainer"
	notification_container.position = Vector2(930, 100)
	notification_container.custom_minimum_size = Vector2(330, 500)
	notification_container.add_theme_constant_override("separation", 10)
	add_child(notification_container)

func _create_quick_stats() -> void:
	# Quick stats panel (bottom right)
	quick_stats_panel = Panel.new()
	quick_stats_panel.name = "QuickStats"
	quick_stats_panel.position = Vector2(930, 620)
	quick_stats_panel.size = Vector2(330, 90)

	# Add glassmorphism shader
	var glass_material = ShaderMaterial.new()
	var glass_shader = preload("res://shaders/glassmorphism.gdshader")
	glass_material.shader = glass_shader
	quick_stats_panel.material = glass_material

	add_child(quick_stats_panel)

	# Add quick stats content
	var stats_grid = GridContainer.new()
	stats_grid.columns = 2
	stats_grid.position = Vector2(15, 10)
	stats_grid.add_theme_constant_override("h_separation", 20)
	stats_grid.add_theme_constant_override("v_separation", 8)
	quick_stats_panel.add_child(stats_grid)

	# Trucks
	_add_stat_row(stats_grid, "🚛 Trucks:", "0/0")

	# Employees
	_add_stat_row(stats_grid, "👷 Employees:", "0")

	# Active Deliveries
	_add_stat_row(stats_grid, "📦 Deliveries:", "0")

func _add_stat_row(container: GridContainer, label_text: String, value_text: String) -> void:
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 14)
	container.add_child(label)

	var value = Label.new()
	value.text = value_text
	value.add_theme_font_size_override("font_size", 14)
	value.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	container.add_child(value)

func _create_weather_overlay() -> void:
	# Full-screen weather overlay
	weather_overlay = ColorRect.new()
	weather_overlay.name = "WeatherOverlay"
	weather_overlay.size = Vector2(1280, 720)
	weather_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weather_overlay.color = Color(1, 1, 1, 0)

	# Add weather shader
	var weather_material = ShaderMaterial.new()
	var weather_shader = preload("res://shaders/weather_overlay.gdshader")
	weather_material.shader = weather_shader
	weather_overlay.material = weather_material

	add_child(weather_overlay)
	move_child(weather_overlay, 0)  # Behind other HUD elements

func _connect_signals() -> void:
	if GameManager:
		GameManager.money_changed.connect(_on_money_changed)
		GameManager.reputation_changed.connect(_on_reputation_changed)
		GameManager.day_changed.connect(_on_day_changed)
		GameManager.time_changed.connect(_on_time_changed)

	if EventBus:
		EventBus.connect("delivery_completed", _on_delivery_completed)
		EventBus.connect("contract_accepted", _on_contract_accepted)
		EventBus.connect("truck_purchased", _on_truck_purchased)
		EventBus.connect("employee_hired", _on_employee_hired)

	if has_node("/root/RouteAI"):
		RouteAI.weather_changed.connect(_on_weather_changed)

	if has_node("/root/MarketAI"):
		MarketAI.fuel_price_changed.connect(_on_fuel_price_changed)
		MarketAI.economic_event.connect(_on_economic_event)

func _start_hud_updates() -> void:
	# Initialize displayed values
	displayed_company_money = GameManager.company_money if GameManager else 0.0
	displayed_private_money = GameManager.private_money if GameManager else 0.0
	displayed_reputation = GameManager.company_reputation if GameManager else 50.0

	_update_money_display()
	_update_reputation_display()
	_update_stats()

func _process(delta: float) -> void:
	# Smooth money counting animation
	if abs(displayed_company_money - GameManager.company_money) > 0.1:
		displayed_company_money = lerp(displayed_company_money, GameManager.company_money, delta * 5.0)
		_update_money_display()

	if abs(displayed_private_money - GameManager.private_money) > 0.1:
		displayed_private_money = lerp(displayed_private_money, GameManager.private_money, delta * 5.0)
		_update_money_display()

# === UPDATES ===

func _update_money_display() -> void:
	if company_money_label:
		company_money_label.text = _format_money(displayed_company_money)

		# Color based on amount
		if displayed_company_money < 0:
			company_money_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		elif displayed_company_money > 100000:
			company_money_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		else:
			company_money_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))

	if private_money_label:
		private_money_label.text = _format_money(displayed_private_money)

func _update_reputation_display() -> void:
	if reputation_bar:
		if reputation_tween:
			reputation_tween.kill()

		reputation_tween = create_tween()
		reputation_tween.tween_property(reputation_bar, "value", GameManager.company_reputation, 0.5)

		# Color based on reputation
		var rep_color = Color.WHITE
		if GameManager.company_reputation >= 80:
			rep_color = Color(0.2, 1.0, 0.3)
		elif GameManager.company_reputation >= 50:
			rep_color = Color(0.7, 0.9, 0.3)
		elif GameManager.company_reputation >= 30:
			rep_color = Color(1.0, 0.7, 0.2)
		else:
			rep_color = Color(1.0, 0.3, 0.2)

		# Apply color to progress bar (would need theme override)

func _update_stats() -> void:
	if not quick_stats_panel:
		return

	var stats_grid = quick_stats_panel.get_node_or_null("GridContainer")
	if not stats_grid:
		return

	# Update stat values
	var children = stats_grid.get_children()
	if children.size() >= 6:
		# Trucks (available/total)
		var trucks_available = GameManager.trucks.filter(func(t): return t.is_available).size()
		children[1].text = "%d/%d" % [trucks_available, GameManager.trucks.size()]

		# Employees
		children[3].text = str(GameManager.employees.size())

		# Active deliveries
		children[5].text = str(GameManager.active_deliveries.size())

func _update_datetime() -> void:
	if date_label:
		date_label.text = "Day %d" % GameManager.current_day

	if time_label:
		time_label.text = "%02d:%02d" % [GameManager.current_hour, GameManager.current_minute]

# === NOTIFICATIONS ===

func show_notification(title: String, message: String, type: String = "info", duration: float = 5.0) -> void:
	"""Show a notification with glassmorphism design"""
	if active_notifications.size() >= MAX_NOTIFICATIONS:
		notification_queue.append({"title": title, "message": message, "type": type, "duration": duration})
		return

	var notification = _create_notification_panel(title, message, type)
	notification_container.add_child(notification)
	active_notifications.append(notification)

	# Animate in
	notification.modulate.a = 0.0
	notification.position.x = 100

	var tween = create_tween().set_parallel(true)
	tween.tween_property(notification, "modulate:a", 1.0, 0.3)
	tween.tween_property(notification, "position:x", 0.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Auto-dismiss after duration
	await get_tree().create_timer(duration).timeout
	_dismiss_notification(notification)

func _create_notification_panel(title: String, message: String, type: String) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(310, 80)

	# Color based on type
	var border_color = Color.WHITE
	match type:
		"success":
			border_color = Color(0.3, 1.0, 0.3)
		"warning":
			border_color = Color(1.0, 0.7, 0.2)
		"error":
			border_color = Color(1.0, 0.3, 0.2)
		"info":
			border_color = Color(0.3, 0.7, 1.0)

	# Content
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(15, 10)
	panel.add_child(vbox)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", border_color)
	vbox.add_child(title_label)

	var message_label = Label.new()
	message_label.text = message
	message_label.add_theme_font_size_override("font_size", 12)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size = Vector2(280, 0)
	vbox.add_child(message_label)

	return panel

func _dismiss_notification(notification: Panel) -> void:
	if not is_instance_valid(notification):
		return

	# Animate out
	var tween = create_tween().set_parallel(true)
	tween.tween_property(notification, "modulate:a", 0.0, 0.2)
	tween.tween_property(notification, "position:x", 100.0, 0.2)

	await tween.finished

	active_notifications.erase(notification)
	notification.queue_free()

	# Show queued notification
	if notification_queue.size() > 0:
		var queued = notification_queue.pop_front()
		show_notification(queued.title, queued.message, queued.type, queued.duration)

# === WEATHER DISPLAY ===

func update_weather_overlay(weather: String) -> void:
	if not weather_overlay or not weather_overlay.material:
		return

	current_weather = weather

	var material: ShaderMaterial = weather_overlay.material

	# Update shader parameters based on weather
	match weather:
		"rain", "light_rain":
			material.set_shader_parameter("weather_type", 1)
			material.set_shader_parameter("intensity", 0.5)
		"heavy_rain":
			material.set_shader_parameter("weather_type", 1)
			material.set_shader_parameter("intensity", 0.8)
		"snow":
			material.set_shader_parameter("weather_type", 2)
			material.set_shader_parameter("intensity", 0.6)
		"fog":
			material.set_shader_parameter("weather_type", 3)
			material.set_shader_parameter("intensity", 0.7)
		"clear":
			material.set_shader_parameter("weather_type", 0)
			material.set_shader_parameter("intensity", 0.0)

# === SIGNAL HANDLERS ===

func _on_money_changed(company_money: float, private_money: float) -> void:
	# Trigger counter animation
	var old_company = displayed_company_money
	var diff = company_money - old_company

	if abs(diff) > 1000:
		# Show money change notification
		var sign = "+" if diff > 0 else ""
		show_notification(
			"Money Changed",
			sign + _format_money(diff),
			"success" if diff > 0 else "warning",
			2.0
		)

	_update_stats()

func _on_reputation_changed(reputation: float) -> void:
	_update_reputation_display()

func _on_day_changed(day: int) -> void:
	_update_datetime()
	_update_stats()

func _on_time_changed(hour: int, minute: int) -> void:
	_update_datetime()

func _on_delivery_completed(delivery: Dictionary, on_time: bool) -> void:
	var type = "success" if on_time else "warning"
	var message = "Delivery completed " + ("on time!" if on_time else "late")
	show_notification("Delivery Complete", message, type, 3.0)

	if has_node("/root/VisualEffects"):
		VisualEffects.spawn_particle_effect("success" if on_time else "warning", Vector2(640, 360), self)

func _on_contract_accepted(contract: Dictionary) -> void:
	show_notification(
		"Contract Accepted",
		"New delivery to " + contract.destination,
		"info",
		2.5
	)

func _on_truck_purchased(truck: Dictionary) -> void:
	show_notification(
		"Truck Purchased",
		truck.model + " added to fleet",
		"success",
		3.0
	)

func _on_employee_hired(employee: Dictionary) -> void:
	show_notification(
		"Employee Hired",
		employee.name + " joined as " + employee.role,
		"success",
		3.0
	)

func _on_weather_changed(region: String, weather: String, impact: float) -> void:
	update_weather_overlay(weather)
	show_notification(
		"Weather Update",
		region + ": " + weather.capitalize(),
		"info",
		2.0
	)

func _on_fuel_price_changed(fuel_type: String, new_price: float, change_percent: float) -> void:
	var type = "warning" if change_percent > 0 else "info"
	show_notification(
		"Fuel Price Change",
		"%s %+.1f%%" % [fuel_type.capitalize(), change_percent],
		type,
		2.5
	)

func _on_economic_event(event_type: String, description: String, impact: Dictionary) -> void:
	show_notification(
		"Economic Event",
		description,
		"warning",
		4.0
	)

# === UTILITIES ===

func _format_money(amount: float) -> String:
	var sign = "" if amount >= 0 else "-"
	var abs_amount = abs(amount)

	if abs_amount >= 1000000:
		return sign + "€%.1fM" % (abs_amount / 1000000.0)
	elif abs_amount >= 1000:
		return sign + "€%.1fK" % (abs_amount / 1000.0)
	else:
		return sign + "€%.0f" % abs_amount
