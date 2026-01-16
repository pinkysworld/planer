extends Node
## GameManager - Central game state and simulation management
## Handles all core business simulation logic, time management, and game state

signal day_changed(day: int)
signal time_changed(hour: int, minute: int)
signal money_changed(company_money: float, private_money: float)
signal reputation_changed(reputation: float)
signal game_over(reason: String)
signal scenario_completed(scenario_name: String)

# Time Management
var current_day: int = 1
var current_hour: int = 8
var current_minute: int = 0
var game_speed: float = 1.0  # 1.0 = normal, 2.0 = fast, 0.5 = slow
var is_paused: bool = false
var time_per_minute: float = 1.0  # Real seconds per game minute
var _time_accumulator: float = 0.0

# Company Finances
var company_money: float = 50000.0
var company_debt: float = 0.0
var monthly_expenses: float = 0.0
var monthly_income: float = 0.0

# Private Finances
var private_money: float = 5000.0
var monthly_salary: float = 3000.0
var bonus_percentage: float = 0.05  # 5% of monthly profit

# Reputation & Status
var company_reputation: float = 50.0  # 0-100
var social_status: float = 10.0  # 0-100, needed for retirement
var family_happiness: float = 75.0  # 0-100

# Current Scenario
var current_scenario: Dictionary = {}
var is_freeplay: bool = true
var scenario_goals: Array = []

# Game World
var current_city: String = "Berlin"
var unlocked_cities: Array = ["Berlin"]
var available_regions: Array = ["Central Europe"]

# Collections (populated during gameplay)
var trucks: Array = []  # Array of TruckData
var employees: Array = []  # Array of EmployeeData
var contracts: Array = []  # Array of ContractData
var active_deliveries: Array = []  # Array of DeliveryData
var completed_contracts: Array = []
var stations: Array = []  # Array of StationData
var luxury_items: Array = []  # Owned luxury items

# Statistics
var total_deliveries_completed: int = 0
var total_distance_traveled: float = 0.0
var total_revenue: float = 0.0
var total_expenses: float = 0.0

# Constants
const STARTING_TRUCKS: int = 2
const STARTING_EMPLOYEES: int = 1
const WORK_START_HOUR: int = 8
const WORK_END_HOUR: int = 18
const MAX_REPUTATION: float = 100.0
const MIN_RETIREMENT_STATUS: float = 75.0

# Fuel prices (modernized - per liter in euros)
var fuel_price_diesel: float = 1.85
var fuel_price_electric: float = 0.35  # per kWh
var fuel_price_hydrogen: float = 12.50  # per kg

func _ready() -> void:
	_initialize_game_data()

func _process(delta: float) -> void:
	if is_paused:
		return

	_update_game_time(delta)
	_update_deliveries(delta)
	_check_random_events()

func _initialize_game_data() -> void:
	# This will be called when starting a new game
	pass

func start_new_game(scenario: Dictionary = {}) -> void:
	"""Start a new game with optional scenario settings"""
	if scenario.is_empty():
		is_freeplay = true
		current_scenario = _get_freeplay_settings()
	else:
		is_freeplay = false
		current_scenario = scenario
		scenario_goals = scenario.get("goals", [])

	# Reset all game state
	current_day = 1
	current_hour = WORK_START_HOUR
	current_minute = 0

	company_money = current_scenario.get("starting_money", 50000.0)
	private_money = current_scenario.get("starting_private_money", 5000.0)
	company_reputation = current_scenario.get("starting_reputation", 50.0)
	social_status = 10.0
	family_happiness = 75.0

	current_city = current_scenario.get("starting_city", "Berlin")
	unlocked_cities = [current_city]

	# Clear collections
	trucks.clear()
	employees.clear()
	contracts.clear()
	active_deliveries.clear()
	completed_contracts.clear()
	stations.clear()
	luxury_items.clear()

	# Initialize starting assets
	_create_starting_trucks()
	_create_starting_employees()
	_create_starting_station()

	# Generate initial contracts
	_generate_initial_contracts()

	emit_signal("money_changed", company_money, private_money)
	emit_signal("reputation_changed", company_reputation)

func _get_freeplay_settings() -> Dictionary:
	return {
		"name": "Freeplay",
		"description": "Build your transport empire without restrictions",
		"starting_money": 75000.0,
		"starting_private_money": 8000.0,
		"starting_reputation": 50.0,
		"starting_city": "Berlin",
		"goals": [],
		"difficulty": "normal"
	}

func _create_starting_trucks() -> void:
	# Add 2 basic trucks
	for i in range(STARTING_TRUCKS):
		var truck = _create_truck_data("Basic Cargo Truck", "diesel", 15000.0)
		trucks.append(truck)

func _create_truck_data(model: String, fuel_type: String, value: float) -> Dictionary:
	return {
		"id": _generate_id(),
		"model": model,
		"fuel_type": fuel_type,  # diesel, electric, hydrogen
		"value": value,
		"condition": 100.0,
		"mileage": 0.0,
		"capacity": 20.0,  # tons
		"fuel_efficiency": 30.0,  # L/100km for diesel
		"max_speed": 90.0,  # km/h average
		"is_available": true,
		"assigned_driver": "",
		"purchase_date": current_day,
		"last_maintenance": current_day,
		"maintenance_interval": 30  # days
	}

func _create_starting_employees() -> void:
	# Add 1 starting driver
	var driver = _create_employee_data("Driver", "Klaus Schmidt")
	employees.append(driver)

func _create_employee_data(role: String, name: String) -> Dictionary:
	return {
		"id": _generate_id(),
		"name": name,
		"role": role,  # Driver, Mechanic, Secretary, Accountant, Manager
		"salary": _get_base_salary(role),
		"experience": randf_range(1.0, 10.0),
		"skill": randf_range(50.0, 80.0),
		"morale": 75.0,
		"hired_day": current_day,
		"is_available": true,
		"assigned_truck": "",
		"vacation_days_remaining": 25
	}

func _get_base_salary(role: String) -> float:
	match role:
		"Driver": return 2800.0
		"Mechanic": return 3200.0
		"Secretary": return 2500.0
		"Accountant": return 3500.0
		"Manager": return 4500.0
		_: return 2500.0

func _create_starting_station() -> void:
	var station = {
		"id": _generate_id(),
		"city": current_city,
		"region": "Central Europe",
		"level": 1,
		"capacity": 5,  # max trucks
		"monthly_cost": 2000.0,
		"opened_day": current_day
	}
	stations.append(station)

func _generate_initial_contracts() -> void:
	# Generate 5-10 initial contracts
	for i in range(randi_range(5, 10)):
		var contract = _generate_contract()
		contracts.append(contract)

func _generate_contract() -> Dictionary:
	var destinations = _get_available_destinations()
	var destination = destinations[randi() % destinations.size()]
	var distance = _calculate_distance(current_city, destination)
	var cargo_weight = randf_range(5.0, 20.0)
	var urgency = ["standard", "express", "urgent"][randi() % 3]
	var base_pay = distance * 1.5 + cargo_weight * 50.0

	var urgency_multiplier = 1.0
	var deadline_days = 7
	match urgency:
		"express":
			urgency_multiplier = 1.5
			deadline_days = 3
		"urgent":
			urgency_multiplier = 2.0
			deadline_days = 1

	return {
		"id": _generate_id(),
		"client": _generate_client_name(),
		"origin": current_city,
		"destination": destination,
		"cargo_type": _get_random_cargo_type(),
		"cargo_weight": cargo_weight,
		"distance": distance,
		"payment": base_pay * urgency_multiplier,
		"deadline_day": current_day + deadline_days,
		"urgency": urgency,
		"status": "available",  # available, accepted, in_progress, completed, failed
		"penalty": base_pay * 0.5,
		"posted_day": current_day
	}

func _get_available_destinations() -> Array:
	var all_cities = [
		"Berlin", "Hamburg", "Munich", "Frankfurt", "Cologne",
		"Stuttgart", "Düsseldorf", "Leipzig", "Dresden", "Hanover",
		"Amsterdam", "Brussels", "Paris", "Vienna", "Prague",
		"Warsaw", "Copenhagen", "Zurich", "Milan", "Barcelona"
	]
	# Filter based on unlocked regions
	return all_cities.filter(func(city): return city != current_city)

func _calculate_distance(from: String, to: String) -> float:
	# Simplified distance calculation (would use real data in full game)
	var distances = {
		"Berlin-Hamburg": 290.0, "Berlin-Munich": 585.0, "Berlin-Frankfurt": 545.0,
		"Berlin-Cologne": 575.0, "Berlin-Amsterdam": 650.0, "Berlin-Paris": 1055.0,
		"Berlin-Vienna": 680.0, "Berlin-Prague": 350.0, "Berlin-Warsaw": 575.0,
		"Berlin-Copenhagen": 355.0, "Berlin-Zurich": 845.0, "Berlin-Milan": 1035.0,
		"Hamburg-Munich": 775.0, "Hamburg-Frankfurt": 490.0, "Hamburg-Amsterdam": 460.0,
		"Munich-Vienna": 435.0, "Munich-Milan": 490.0, "Munich-Zurich": 315.0,
		"Frankfurt-Paris": 590.0, "Frankfurt-Amsterdam": 440.0, "Frankfurt-Zurich": 405.0
	}

	var key1 = from + "-" + to
	var key2 = to + "-" + from

	if distances.has(key1):
		return distances[key1]
	elif distances.has(key2):
		return distances[key2]
	else:
		# Default random distance for unmapped routes
		return randf_range(300.0, 1200.0)

func _generate_client_name() -> String:
	var companies = [
		"TechCorp GmbH", "EuroLogistics AG", "Global Trade Inc",
		"Continental Supplies", "Northern Freight Ltd", "MetroGoods",
		"SwiftShip International", "Atlas Industries", "Precision Parts Co",
		"GreenEnergy Solutions", "AutoParts Express", "FreshFood Distributors",
		"ChemTrans Safety", "BuildMaster Supplies", "ElectroniX Europe"
	]
	return companies[randi() % companies.size()]

func _get_random_cargo_type() -> String:
	var cargo_types = [
		"Electronics", "Automotive Parts", "Food Products", "Chemicals",
		"Machinery", "Textiles", "Furniture", "Construction Materials",
		"Medical Supplies", "Consumer Goods", "Raw Materials", "Hazardous Materials"
	]
	return cargo_types[randi() % cargo_types.size()]

func _generate_id() -> String:
	return str(randi()) + str(Time.get_ticks_msec())

func _update_game_time(delta: float) -> void:
	_time_accumulator += delta * game_speed

	while _time_accumulator >= time_per_minute:
		_time_accumulator -= time_per_minute
		current_minute += 1

		if current_minute >= 60:
			current_minute = 0
			current_hour += 1
			emit_signal("time_changed", current_hour, current_minute)

			if current_hour >= 24:
				current_hour = 0
				_advance_day()

func _advance_day() -> void:
	current_day += 1
	emit_signal("day_changed", current_day)

	# Daily updates
	_update_contracts()
	_process_daily_expenses()
	_update_truck_conditions()
	_check_employee_events()
	_generate_new_contracts()
	_check_scenario_goals()

	# Monthly processing (every 30 days)
	if current_day % 30 == 0:
		_process_monthly()

func _update_contracts() -> void:
	for contract in contracts:
		if contract.status == "available" and contract.posted_day < current_day - 7:
			# Contract expires after 7 days if not accepted
			contracts.erase(contract)

func _process_daily_expenses() -> void:
	# Station maintenance
	for station in stations:
		company_money -= station.monthly_cost / 30.0

	emit_signal("money_changed", company_money, private_money)

func _update_truck_conditions() -> void:
	for truck in trucks:
		if not truck.is_available:
			# Truck is on delivery, condition degrades
			truck.condition -= randf_range(0.1, 0.5)
			truck.condition = max(0.0, truck.condition)

func _check_employee_events() -> void:
	# Random employee events
	for employee in employees:
		if randf() < 0.01:  # 1% chance per day
			employee.morale -= randf_range(5.0, 15.0)
			EventBus.emit_signal("employee_event", employee, "unhappy")

func _generate_new_contracts() -> void:
	# Add 1-3 new contracts daily
	var new_count = randi_range(1, 3)
	for i in range(new_count):
		if contracts.size() < 20:  # Max 20 available contracts
			contracts.append(_generate_contract())

func _check_scenario_goals() -> void:
	if is_freeplay:
		return

	var all_goals_met = true
	for goal in scenario_goals:
		if not _check_goal(goal):
			all_goals_met = false
			break

	if all_goals_met and scenario_goals.size() > 0:
		emit_signal("scenario_completed", current_scenario.name)

func _check_goal(goal: Dictionary) -> bool:
	match goal.type:
		"money":
			return company_money >= goal.target
		"reputation":
			return company_reputation >= goal.target
		"trucks":
			return trucks.size() >= goal.target
		"stations":
			return stations.size() >= goal.target
		"deliveries":
			return total_deliveries_completed >= goal.target
		_:
			return false

func _process_monthly() -> void:
	# Pay salaries
	for employee in employees:
		company_money -= employee.salary

	# Pay player salary
	private_money += monthly_salary

	# Calculate and pay bonus
	var monthly_profit = monthly_income - monthly_expenses
	if monthly_profit > 0:
		private_money += monthly_profit * bonus_percentage

	# Reset monthly tracking
	monthly_income = 0.0
	monthly_expenses = 0.0

	# Loan interest
	if company_debt > 0:
		var interest = company_debt * 0.005  # 0.5% monthly interest
		company_money -= interest
		monthly_expenses += interest

	emit_signal("money_changed", company_money, private_money)

func _update_deliveries(delta: float) -> void:
	for delivery in active_deliveries:
		if delivery.status == "in_transit":
			delivery.progress += delta * game_speed * delivery.speed_factor

			if delivery.progress >= delivery.total_distance:
				_complete_delivery(delivery)

func _complete_delivery(delivery: Dictionary) -> void:
	delivery.status = "completed"

	# Find the contract
	var contract = null
	for c in contracts:
		if c.id == delivery.contract_id:
			contract = c
			break

	if contract:
		contract.status = "completed"
		completed_contracts.append(contract)
		contracts.erase(contract)

		# Check if on time
		var on_time = current_day <= contract.deadline_day
		var payment = contract.payment

		if not on_time:
			payment -= contract.penalty
			company_reputation -= 5.0
		else:
			company_reputation += 2.0

		company_money += payment
		monthly_income += payment
		total_revenue += payment
		total_deliveries_completed += 1

		# Free up truck and driver
		for truck in trucks:
			if truck.id == delivery.truck_id:
				truck.is_available = true
				truck.mileage += delivery.total_distance
				break

		for employee in employees:
			if employee.id == delivery.driver_id:
				employee.is_available = true
				break

		emit_signal("money_changed", company_money, private_money)
		emit_signal("reputation_changed", company_reputation)
		EventBus.emit_signal("delivery_completed", delivery, on_time)

	active_deliveries.erase(delivery)

func _check_random_events() -> void:
	# Random events occur occasionally
	if randf() < 0.0001:  # Very small chance per frame
		_trigger_random_event()

func _trigger_random_event() -> void:
	var events = ["breakdown", "traffic", "bonus_contract", "fuel_price_change", "robbery"]
	var event = events[randi() % events.size()]
	EventBus.emit_signal("random_event", event)

# Public API Methods

func accept_contract(contract_id: String) -> bool:
	"""Accept a contract for delivery"""
	for contract in contracts:
		if contract.id == contract_id and contract.status == "available":
			contract.status = "accepted"
			EventBus.emit_signal("contract_accepted", contract)
			return true
	return false

func start_delivery(contract_id: String, truck_id: String, driver_id: String) -> bool:
	"""Start a delivery with assigned truck and driver"""
	var contract = null
	var truck = null
	var driver = null

	for c in contracts:
		if c.id == contract_id and c.status == "accepted":
			contract = c
			break

	for t in trucks:
		if t.id == truck_id and t.is_available:
			truck = t
			break

	for e in employees:
		if e.id == driver_id and e.role == "Driver" and e.is_available:
			driver = e
			break

	if contract and truck and driver:
		truck.is_available = false
		truck.assigned_driver = driver.id
		driver.is_available = false
		driver.assigned_truck = truck.id
		contract.status = "in_progress"

		var delivery = {
			"id": _generate_id(),
			"contract_id": contract.id,
			"truck_id": truck.id,
			"driver_id": driver.id,
			"origin": contract.origin,
			"destination": contract.destination,
			"total_distance": contract.distance,
			"progress": 0.0,
			"speed_factor": truck.max_speed / 100.0 * (driver.skill / 100.0),
			"status": "in_transit",
			"started_day": current_day,
			"started_hour": current_hour
		}
		active_deliveries.append(delivery)

		# Calculate fuel cost
		var fuel_cost = (contract.distance / 100.0) * truck.fuel_efficiency * fuel_price_diesel
		company_money -= fuel_cost
		monthly_expenses += fuel_cost
		total_expenses += fuel_cost

		emit_signal("money_changed", company_money, private_money)
		EventBus.emit_signal("delivery_started", delivery)
		return true

	return false

func buy_truck(model: String, price: float, fuel_type: String) -> bool:
	"""Purchase a new truck"""
	if company_money >= price:
		company_money -= price
		var truck = _create_truck_data(model, fuel_type, price)
		trucks.append(truck)
		emit_signal("money_changed", company_money, private_money)
		EventBus.emit_signal("truck_purchased", truck)
		return true
	return false

func sell_truck(truck_id: String) -> bool:
	"""Sell a truck"""
	for truck in trucks:
		if truck.id == truck_id and truck.is_available:
			var sale_price = truck.value * (truck.condition / 100.0) * 0.7
			company_money += sale_price
			trucks.erase(truck)
			emit_signal("money_changed", company_money, private_money)
			EventBus.emit_signal("truck_sold", truck, sale_price)
			return true
	return false

func hire_employee(role: String, name: String) -> bool:
	"""Hire a new employee"""
	var salary = _get_base_salary(role)
	# Check if we can afford first month's salary
	if company_money >= salary:
		var employee = _create_employee_data(role, name)
		employees.append(employee)
		EventBus.emit_signal("employee_hired", employee)
		return true
	return false

func fire_employee(employee_id: String) -> bool:
	"""Fire an employee"""
	for employee in employees:
		if employee.id == employee_id and employee.is_available:
			# Severance pay (1 month salary)
			company_money -= employee.salary
			employees.erase(employee)
			emit_signal("money_changed", company_money, private_money)
			EventBus.emit_signal("employee_fired", employee)
			return true
	return false

func repair_truck(truck_id: String) -> bool:
	"""Repair a truck to full condition"""
	for truck in trucks:
		if truck.id == truck_id and truck.is_available:
			var repair_cost = (100.0 - truck.condition) * truck.value * 0.002
			if company_money >= repair_cost:
				company_money -= repair_cost
				truck.condition = 100.0
				truck.last_maintenance = current_day
				emit_signal("money_changed", company_money, private_money)
				EventBus.emit_signal("truck_repaired", truck)
				return true
	return false

func open_station(city: String, region: String) -> bool:
	"""Open a new station in a city"""
	var cost = 50000.0  # Base cost for new station
	if region != "Central Europe":
		cost *= 1.5  # Higher cost for other regions

	if company_money >= cost and city not in unlocked_cities:
		company_money -= cost
		unlocked_cities.append(city)
		var station = {
			"id": _generate_id(),
			"city": city,
			"region": region,
			"level": 1,
			"capacity": 5,
			"monthly_cost": 2000.0,
			"opened_day": current_day
		}
		stations.append(station)
		emit_signal("money_changed", company_money, private_money)
		EventBus.emit_signal("station_opened", station)
		return true
	return false

func buy_luxury_item(item: Dictionary) -> bool:
	"""Buy a luxury item with private money"""
	if private_money >= item.price:
		private_money -= item.price
		luxury_items.append(item)
		social_status += item.status_bonus
		social_status = min(social_status, 100.0)
		emit_signal("money_changed", company_money, private_money)
		EventBus.emit_signal("luxury_purchased", item)
		return true
	return false

func give_family_money(amount: float) -> bool:
	"""Give money to family members"""
	if private_money >= amount:
		private_money -= amount
		family_happiness += amount / 100.0
		family_happiness = min(family_happiness, 100.0)
		emit_signal("money_changed", company_money, private_money)
		return true
	return false

func take_loan(amount: float) -> bool:
	"""Take a bank loan"""
	var max_loan = company_reputation * 1000.0
	if company_debt + amount <= max_loan:
		company_money += amount
		company_debt += amount
		emit_signal("money_changed", company_money, private_money)
		EventBus.emit_signal("loan_taken", amount)
		return true
	return false

func repay_loan(amount: float) -> bool:
	"""Repay part of the loan"""
	if company_money >= amount and company_debt >= amount:
		company_money -= amount
		company_debt -= amount
		emit_signal("money_changed", company_money, private_money)
		EventBus.emit_signal("loan_repaid", amount)
		return true
	return false

func set_game_speed(speed: float) -> void:
	game_speed = clamp(speed, 0.0, 4.0)

func pause_game() -> void:
	is_paused = true

func resume_game() -> void:
	is_paused = false

func toggle_pause() -> void:
	is_paused = not is_paused

func can_retire() -> bool:
	"""Check if player meets retirement conditions"""
	return social_status >= MIN_RETIREMENT_STATUS and family_happiness >= 50.0

func get_game_state() -> Dictionary:
	"""Get full game state for saving"""
	return {
		"version": "1.0",
		"current_day": current_day,
		"current_hour": current_hour,
		"current_minute": current_minute,
		"company_money": company_money,
		"company_debt": company_debt,
		"private_money": private_money,
		"monthly_salary": monthly_salary,
		"company_reputation": company_reputation,
		"social_status": social_status,
		"family_happiness": family_happiness,
		"current_city": current_city,
		"unlocked_cities": unlocked_cities,
		"available_regions": available_regions,
		"trucks": trucks,
		"employees": employees,
		"contracts": contracts,
		"active_deliveries": active_deliveries,
		"completed_contracts": completed_contracts,
		"stations": stations,
		"luxury_items": luxury_items,
		"total_deliveries_completed": total_deliveries_completed,
		"total_distance_traveled": total_distance_traveled,
		"total_revenue": total_revenue,
		"total_expenses": total_expenses,
		"current_scenario": current_scenario,
		"is_freeplay": is_freeplay,
		"fuel_price_diesel": fuel_price_diesel,
		"fuel_price_electric": fuel_price_electric,
		"fuel_price_hydrogen": fuel_price_hydrogen
	}

func load_game_state(state: Dictionary) -> void:
	"""Load game state from save data"""
	current_day = state.get("current_day", 1)
	current_hour = state.get("current_hour", 8)
	current_minute = state.get("current_minute", 0)
	company_money = state.get("company_money", 50000.0)
	company_debt = state.get("company_debt", 0.0)
	private_money = state.get("private_money", 5000.0)
	monthly_salary = state.get("monthly_salary", 3000.0)
	company_reputation = state.get("company_reputation", 50.0)
	social_status = state.get("social_status", 10.0)
	family_happiness = state.get("family_happiness", 75.0)
	current_city = state.get("current_city", "Berlin")
	unlocked_cities = state.get("unlocked_cities", ["Berlin"])
	available_regions = state.get("available_regions", ["Central Europe"])
	trucks = state.get("trucks", [])
	employees = state.get("employees", [])
	contracts = state.get("contracts", [])
	active_deliveries = state.get("active_deliveries", [])
	completed_contracts = state.get("completed_contracts", [])
	stations = state.get("stations", [])
	luxury_items = state.get("luxury_items", [])
	total_deliveries_completed = state.get("total_deliveries_completed", 0)
	total_distance_traveled = state.get("total_distance_traveled", 0.0)
	total_revenue = state.get("total_revenue", 0.0)
	total_expenses = state.get("total_expenses", 0.0)
	current_scenario = state.get("current_scenario", {})
	is_freeplay = state.get("is_freeplay", true)
	fuel_price_diesel = state.get("fuel_price_diesel", 1.85)
	fuel_price_electric = state.get("fuel_price_electric", 0.35)
	fuel_price_hydrogen = state.get("fuel_price_hydrogen", 12.50)

	emit_signal("money_changed", company_money, private_money)
	emit_signal("reputation_changed", company_reputation)
