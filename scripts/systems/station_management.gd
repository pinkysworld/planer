extends Node
## StationManagement - Multi-city station system from Planer series
## Open stations, manage regional operations, expand across Europe

signal station_opened(city: String, station: Dictionary)
signal station_upgraded(city: String, new_level: int)
signal station_closed(city: String)
signal station_profit_report(city: String, profit: float)

# Active stations
var stations: Dictionary = {}

# Available cities for expansion
var available_cities: Dictionary = {
	# Germany
	"Berlin": {
		"country": "Germany",
		"region": "Central Europe",
		"population": 3700000,
		"market_size": 0.85,
		"competition": 0.7,
		"opening_cost": 50000,
		"monthly_rent": 3000,
		"coordinates": Vector2(52.52, 13.40)
	},
	"Hamburg": {
		"country": "Germany",
		"region": "Central Europe",
		"population": 1900000,
		"market_size": 0.75,
		"competition": 0.6,
		"opening_cost": 45000,
		"monthly_rent": 2800,
		"coordinates": Vector2(53.55, 9.99)
	},
	"Munich": {
		"country": "Germany",
		"region": "Central Europe",
		"population": 1500000,
		"market_size": 0.80,
		"competition": 0.65,
		"opening_cost": 48000,
		"monthly_rent": 3200,
		"coordinates": Vector2(48.13, 11.57)
	},
	"Frankfurt": {
		"country": "Germany",
		"region": "Central Europe",
		"population": 750000,
		"market_size": 0.90,
		"competition": 0.75,
		"opening_cost": 52000,
		"monthly_rent": 3500,
		"coordinates": Vector2(50.11, 8.68)
	},

	# France
	"Paris": {
		"country": "France",
		"region": "Western Europe",
		"population": 2200000,
		"market_size": 0.88,
		"competition": 0.80,
		"opening_cost": 60000,
		"monthly_rent": 4000,
		"coordinates": Vector2(48.85, 2.35)
	},
	"Lyon": {
		"country": "France",
		"region": "Western Europe",
		"population": 520000,
		"market_size": 0.70,
		"competition": 0.55,
		"opening_cost": 42000,
		"monthly_rent": 2500,
		"coordinates": Vector2(45.76, 4.83)
	},

	# Netherlands
	"Amsterdam": {
		"country": "Netherlands",
		"region": "Western Europe",
		"population": 870000,
		"market_size": 0.82,
		"competition": 0.68,
		"opening_cost": 55000,
		"monthly_rent": 3600,
		"coordinates": Vector2(52.37, 4.89)
	},
	"Rotterdam": {
		"country": "Netherlands",
		"region": "Western Europe",
		"population": 650000,
		"market_size": 0.85,
		"competition": 0.70,
		"opening_cost": 50000,
		"monthly_rent": 3200,
		"coordinates": Vector2(51.92, 4.47)
	},

	# Belgium
	"Brussels": {
		"country": "Belgium",
		"region": "Western Europe",
		"population": 1200000,
		"market_size": 0.78,
		"competition": 0.65,
		"opening_cost": 48000,
		"monthly_rent": 3000,
		"coordinates": Vector2(50.85, 4.35)
	},

	# Austria
	"Vienna": {
		"country": "Austria",
		"region": "Central Europe",
		"population": 1900000,
		"market_size": 0.76,
		"competition": 0.60,
		"opening_cost": 46000,
		"monthly_rent": 2900,
		"coordinates": Vector2(48.20, 16.37)
	},

	# Switzerland
	"Zurich": {
		"country": "Switzerland",
		"region": "Central Europe",
		"population": 420000,
		"market_size": 0.92,
		"competition": 0.85,
		"opening_cost": 70000,
		"monthly_rent": 5000,
		"coordinates": Vector2(47.37, 8.54)
	},

	# Italy
	"Milan": {
		"country": "Italy",
		"region": "Southern Europe",
		"population": 1400000,
		"market_size": 0.83,
		"competition": 0.72,
		"opening_cost": 52000,
		"monthly_rent": 3400,
		"coordinates": Vector2(45.46, 9.18)
	},
	"Rome": {
		"country": "Italy",
		"region": "Southern Europe",
		"population": 2800000,
		"market_size": 0.80,
		"competition": 0.75,
		"opening_cost": 55000,
		"monthly_rent": 3600,
		"coordinates": Vector2(41.90, 12.48)
	},

	# Spain
	"Madrid": {
		"country": "Spain",
		"region": "Southern Europe",
		"population": 3200000,
		"market_size": 0.78,
		"competition": 0.68,
		"opening_cost": 48000,
		"monthly_rent": 2900,
		"coordinates": Vector2(40.41, -3.70)
	},
	"Barcelona": {
		"country": "Spain",
		"region": "Southern Europe",
		"population": 1600000,
		"market_size": 0.82,
		"competition": 0.70,
		"opening_cost": 50000,
		"monthly_rent": 3100,
		"coordinates": Vector2(41.38, 2.17)
	},

	# Poland
	"Warsaw": {
		"country": "Poland",
		"region": "Eastern Europe",
		"population": 1800000,
		"market_size": 0.72,
		"competition": 0.50,
		"opening_cost": 38000,
		"monthly_rent": 2200,
		"coordinates": Vector2(52.22, 21.01)
	},
	"Krakow": {
		"country": "Poland",
		"region": "Eastern Europe",
		"population": 780000,
		"market_size": 0.65,
		"competition": 0.45,
		"opening_cost": 35000,
		"monthly_rent": 2000,
		"coordinates": Vector2(50.06, 19.94)
	},

	# Czech Republic
	"Prague": {
		"country": "Czech Republic",
		"region": "Eastern Europe",
		"population": 1300000,
		"market_size": 0.70,
		"competition": 0.55,
		"opening_cost": 40000,
		"monthly_rent": 2400,
		"coordinates": Vector2(50.07, 14.43)
	},

	# Scandinavia
	"Copenhagen": {
		"country": "Denmark",
		"region": "Scandinavia",
		"population": 630000,
		"market_size": 0.88,
		"competition": 0.72,
		"opening_cost": 58000,
		"monthly_rent": 3800,
		"coordinates": Vector2(55.67, 12.56)
	},
	"Stockholm": {
		"country": "Sweden",
		"region": "Scandinavia",
		"population": 980000,
		"market_size": 0.85,
		"competition": 0.68,
		"opening_cost": 54000,
		"monthly_rent": 3500,
		"coordinates": Vector2(59.32, 18.06)
	},
	"Oslo": {
		"country": "Norway",
		"region": "Scandinavia",
		"population": 700000,
		"market_size": 0.90,
		"competition": 0.70,
		"opening_cost": 62000,
		"monthly_rent": 4200,
		"coordinates": Vector2(59.91, 10.75)
	}
}

# Station levels and upgrades
enum StationLevel {
	SMALL,      # 1-3 trucks
	MEDIUM,     # 4-8 trucks
	LARGE,      # 9-15 trucks
	REGIONAL    # 16+ trucks
}

func _ready() -> void:
	if GameManager:
		GameManager.day_changed.connect(_on_day_changed)

func _on_day_changed(day: int) -> void:
	# Monthly station reports
	if day % 30 == 0:
		_process_monthly_stations()

func _process_monthly_stations() -> void:
	"""Process monthly station costs and profits"""
	for city in stations.keys():
		var station = stations[city]
		var city_data = available_cities[city]

		# Pay monthly rent
		var rent = city_data.monthly_rent * (1.0 + station.level * 0.2)
		GameManager.company_money -= rent

		# Calculate profit from this station
		var monthly_profit = _calculate_station_profit(city, station)
		station.total_profit += monthly_profit

		emit_signal("station_profit_report", city, monthly_profit)

		# Update statistics
		station.months_active += 1

func _calculate_station_profit(city: String, station: Dictionary) -> float:
	"""Calculate monthly profit for a station"""
	var city_data = available_cities[city]

	# Base revenue from contracts in this region
	var base_revenue = city_data.market_size * 10000.0

	# Station level multiplier
	var level_multiplier = 1.0 + (station.level * 0.5)

	# Employee and truck count affect capacity
	var capacity_mult = min(2.0, station.trucks.size() / 5.0)

	# Competition reduces profit
	var competition_penalty = 1.0 - (city_data.competition * 0.3)

	# Reputation bonus
	var reputation_mult = 1.0 + (GameManager.company_reputation / 200.0)

	var profit = base_revenue * level_multiplier * capacity_mult * competition_penalty * reputation_mult

	# Costs
	var costs = city_data.monthly_rent * (1.0 + station.level * 0.2)
	costs += station.employees.size() * 2000.0  # Employee salaries

	return profit - costs

# === STATION OPERATIONS ===

func open_station(city: String) -> bool:
	"""Open a new station in a city"""
	if stations.has(city):
		return false  # Already exists

	if not available_cities.has(city):
		return false  # City doesn't exist

	var city_data = available_cities[city]

	# Check if can afford
	if not GameManager or GameManager.company_money < city_data.opening_cost:
		return false

	# Deduct cost
	GameManager.company_money -= city_data.opening_cost

	# Create station
	var station = {
		"city": city,
		"level": StationLevel.SMALL,
		"opened_day": GameManager.current_day,
		"months_active": 0,
		"total_profit": 0.0,
		"trucks": [],  # Trucks assigned to this station
		"employees": [],  # Employees assigned
		"contracts": [],  # Active contracts from this region
		"upgrades": []
	}

	stations[city] = station

	emit_signal("station_opened", city, station)

	return true

func close_station(city: String) -> bool:
	"""Close a station"""
	if not stations.has(city):
		return false

	var station = stations[city]

	# Return trucks to headquarters
	for truck in station.trucks:
		truck.station = "HQ"

	# Return employees
	for employee in station.employees:
		employee.station = "HQ"

	stations.erase(city)

	emit_signal("station_closed", city)

	return true

func upgrade_station(city: String) -> bool:
	"""Upgrade a station to next level"""
	if not stations.has(city):
		return false

	var station = stations[city]

	if station.level >= StationLevel.REGIONAL:
		return false  # Max level

	var upgrade_cost = _get_upgrade_cost(station.level)

	if not GameManager or GameManager.company_money < upgrade_cost:
		return false

	GameManager.company_money -= upgrade_cost
	station.level += 1

	emit_signal("station_upgraded", city, station.level)

	return true

func _get_upgrade_cost(current_level: int) -> float:
	match current_level:
		StationLevel.SMALL:
			return 25000
		StationLevel.MEDIUM:
			return 40000
		StationLevel.LARGE:
			return 60000
	return 0

func assign_truck_to_station(truck_id: String, city: String) -> bool:
	"""Assign a truck to a station"""
	if not stations.has(city):
		return false

	var truck = _find_truck(truck_id)
	if not truck:
		return false

	stations[city].trucks.append(truck)
	truck.station = city

	return true

func assign_employee_to_station(employee_id: String, city: String) -> bool:
	"""Assign an employee to a station"""
	if not stations.has(city):
		return false

	var employee = _find_employee(employee_id)
	if not employee:
		return false

	stations[city].employees.append(employee)
	employee.station = city

	return true

func _find_truck(truck_id: String) -> Dictionary:
	if not GameManager:
		return {}

	for truck in GameManager.trucks:
		if truck.id == truck_id:
			return truck

	return {}

func _find_employee(employee_id: String) -> Dictionary:
	if not GameManager:
		return {}

	for employee in GameManager.employees:
		if employee.id == employee_id:
			return employee

	return {}

# === PUBLIC API ===

func get_active_stations() -> Array:
	var result = []
	for city in stations.keys():
		var station = stations[city].duplicate()
		station.city_data = available_cities[city]
		result.append(station)
	return result

func get_available_cities_for_expansion() -> Array:
	var result = []
	for city in available_cities.keys():
		if not stations.has(city):
			var city_info = available_cities[city].duplicate()
			city_info.name = city
			result.append(city_info)
	return result

func get_station(city: String) -> Dictionary:
	if stations.has(city):
		var station = stations[city].duplicate()
		station.city_data = available_cities[city]
		return station
	return {}

func get_cities_by_region(region: String) -> Array:
	var result = []
	for city in available_cities.keys():
		if available_cities[city].region == region:
			var city_info = available_cities[city].duplicate()
			city_info.name = city
			city_info.has_station = stations.has(city)
			result.append(city_info)
	return result

func get_total_monthly_station_costs() -> float:
	var total = 0.0
	for city in stations.keys():
		var city_data = available_cities[city]
		var station = stations[city]
		total += city_data.monthly_rent * (1.0 + station.level * 0.2)
	return total

func get_total_stations() -> int:
	return stations.size()

func get_countries_covered() -> Array:
	var countries = []
	for city in stations.keys():
		var country = available_cities[city].country
		if country not in countries:
			countries.append(country)
	return countries

func is_station_profitable(city: String) -> bool:
	if not stations.has(city):
		return false

	return stations[city].total_profit > 0

func get_most_profitable_station() -> String:
	var best_city = ""
	var best_profit = -999999.0

	for city in stations.keys():
		if stations[city].total_profit > best_profit:
			best_profit = stations[city].total_profit
			best_city = city

	return best_city

func get_station_capacity(city: String) -> Dictionary:
	if not stations.has(city):
		return {}

	var station = stations[city]
	var max_trucks = _get_max_trucks_for_level(station.level)

	return {
		"current_trucks": station.trucks.size(),
		"max_trucks": max_trucks,
		"current_employees": station.employees.size(),
		"utilization": float(station.trucks.size()) / max_trucks
	}

func _get_max_trucks_for_level(level: int) -> int:
	match level:
		StationLevel.SMALL:
			return 3
		StationLevel.MEDIUM:
			return 8
		StationLevel.LARGE:
			return 15
		StationLevel.REGIONAL:
			return 30
	return 3
