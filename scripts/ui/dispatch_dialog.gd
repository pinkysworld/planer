extends Control
## DispatchDialog - Assign trucks and drivers to accepted contracts

signal closed

@onready var contracts_container = $Panel/VBox/MainContent/AcceptedContracts/ContractsList/ContractsContainer
@onready var trucks_container = $Panel/VBox/MainContent/AvailableTrucks/TrucksList/TrucksContainer
@onready var drivers_container = $Panel/VBox/MainContent/AvailableDrivers/DriversList/DriversContainer
@onready var info_label = $Panel/VBox/Footer/InfoLabel
@onready var start_button = $Panel/VBox/Footer/StartDeliveryButton

var selected_contract: Dictionary = {}
var selected_truck: Dictionary = {}
var selected_driver: Dictionary = {}

func _ready() -> void:
	_refresh_all()

func _refresh_all() -> void:
	_refresh_contracts()
	_refresh_trucks()
	_refresh_drivers()
	_update_start_button()

func _refresh_contracts() -> void:
	for child in contracts_container.get_children():
		child.queue_free()

	var accepted_contracts = GameManager.contracts.filter(func(c): return c.status == "accepted")

	if accepted_contracts.is_empty():
		var label = Label.new()
		label.text = "No accepted contracts.\nGo to Contracts room to accept some."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		contracts_container.add_child(label)
		return

	for contract in accepted_contracts:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 60)
		btn.text = "%s\n%s → %s" % [contract.client, contract.origin, contract.destination]
		btn.pressed.connect(func(): _select_contract(contract, btn))
		contracts_container.add_child(btn)

func _refresh_trucks() -> void:
	for child in trucks_container.get_children():
		child.queue_free()

	var available_trucks = GameManager.trucks.filter(func(t): return t.is_available)

	if available_trucks.is_empty():
		var label = Label.new()
		label.text = "No trucks available.\nAll trucks are on delivery."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		trucks_container.add_child(label)
		return

	for truck in available_trucks:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 60)
		btn.text = "%s\nCondition: %.0f%%" % [truck.model, truck.condition]

		if truck.condition < 30:
			btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

		btn.pressed.connect(func(): _select_truck(truck, btn))
		trucks_container.add_child(btn)

func _refresh_drivers() -> void:
	for child in drivers_container.get_children():
		child.queue_free()

	var available_drivers = GameManager.employees.filter(func(e): return e.role == "Driver" and e.is_available)

	if available_drivers.is_empty():
		var label = Label.new()
		label.text = "No drivers available.\nHire more drivers in HR."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		drivers_container.add_child(label)
		return

	for driver in available_drivers:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 60)
		btn.text = "%s\nSkill: %.0f%% | Exp: %.1f yrs" % [driver.name, driver.skill, driver.experience]
		btn.pressed.connect(func(): _select_driver(driver, btn))
		drivers_container.add_child(btn)

func _select_contract(contract: Dictionary, btn: Button) -> void:
	AudioManager.play_sfx("click")
	selected_contract = contract
	_highlight_selection(contracts_container, btn)
	_update_start_button()

func _select_truck(truck: Dictionary, btn: Button) -> void:
	AudioManager.play_sfx("click")
	selected_truck = truck
	_highlight_selection(trucks_container, btn)
	_update_start_button()

func _select_driver(driver: Dictionary, btn: Button) -> void:
	AudioManager.play_sfx("click")
	selected_driver = driver
	_highlight_selection(drivers_container, btn)
	_update_start_button()

func _highlight_selection(container: VBoxContainer, selected_btn: Button) -> void:
	for child in container.get_children():
		if child is Button:
			child.modulate = Color(0.7, 0.7, 0.7) if child != selected_btn else Color(1, 1, 1)

func _update_start_button() -> void:
	var can_start = not selected_contract.is_empty() and not selected_truck.is_empty() and not selected_driver.is_empty()
	start_button.disabled = not can_start

	if can_start:
		# Calculate estimated delivery time
		var hours = selected_contract.distance / selected_truck.max_speed
		info_label.text = "Est. travel time: %.1f hours | Fuel cost: €%.0f" % [
			hours,
			(selected_contract.distance / 100.0) * selected_truck.fuel_efficiency * GameManager.fuel_price_diesel
		]
	else:
		info_label.text = "Select a contract, truck, and driver to start a delivery"

func _on_start_delivery_pressed() -> void:
	AudioManager.play_sfx("truck_start")

	if GameManager.start_delivery(selected_contract.id, selected_truck.id, selected_driver.id):
		info_label.text = "Delivery started! %s is on the way to %s" % [selected_driver.name, selected_contract.destination]
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))

		selected_contract = {}
		selected_truck = {}
		selected_driver = {}
		_refresh_all()
	else:
		info_label.text = "Failed to start delivery. Please try again."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
