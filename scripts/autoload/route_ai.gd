extends Node
## RouteAI - Advanced route planning with traffic and weather simulation
## Provides intelligent route optimization and dynamic travel conditions

signal traffic_incident(location: String, severity: String, delay: float)
signal weather_changed(region: String, weather: String, impact: float)
signal route_updated(delivery_id: String, new_eta: int, reason: String)

# Weather System
var regional_weather: Dictionary = {
	"Central Europe": {"condition": "clear", "severity": 0.0},
	"Scandinavia": {"condition": "clear", "severity": 0.0},
	"Southern Europe": {"condition": "clear", "severity": 0.0},
	"Western Europe": {"condition": "clear", "severity": 0.0},
	"Eastern Europe": {"condition": "clear", "severity": 0.0}
}

var weather_types: Array = [
	{"name": "clear", "speed_factor": 1.0, "risk_factor": 0.0},
	{"name": "light_rain", "speed_factor": 0.95, "risk_factor": 0.1},
	{"name": "heavy_rain", "speed_factor": 0.85, "risk_factor": 0.3},
	{"name": "fog", "speed_factor": 0.80, "risk_factor": 0.2},
	{"name": "snow", "speed_factor": 0.70, "risk_factor": 0.4},
	{"name": "ice", "speed_factor": 0.60, "risk_factor": 0.6},
	{"name": "storm", "speed_factor": 0.50, "risk_factor": 0.7}
]

# Traffic System
var traffic_conditions: Dictionary = {}  # Route-specific traffic
var traffic_events: Array = []  # Active traffic incidents

# Route Optimization
var route_cache: Dictionary = {}  # Cached optimal routes
var city_connections: Dictionary = {}  # Network graph of cities

func _ready() -> void:
	GameManager.day_changed.connect(_on_day_changed)
	_initialize_road_network()
	_initialize_weather()

func _initialize_road_network() -> void:
	# Build a network graph of European cities with connections
	city_connections = {
		"Berlin": [
			{"to": "Hamburg", "distance": 290.0, "quality": 0.9},
			{"to": "Munich", "distance": 585.0, "quality": 0.95},
			{"to": "Prague", "distance": 350.0, "quality": 0.85},
			{"to": "Warsaw", "distance": 575.0, "quality": 0.80}
		],
		"Hamburg": [
			{"to": "Berlin", "distance": 290.0, "quality": 0.9},
			{"to": "Amsterdam", "distance": 460.0, "quality": 0.95},
			{"to": "Copenhagen", "distance": 355.0, "quality": 0.90}
		],
		"Munich": [
			{"to": "Berlin", "distance": 585.0, "quality": 0.95},
			{"to": "Vienna", "distance": 435.0, "quality": 0.95},
			{"to": "Zurich", "distance": 315.0, "quality": 0.95},
			{"to": "Milan", "distance": 490.0, "quality": 0.90}
		],
		"Frankfurt": [
			{"to": "Munich", "distance": 390.0, "quality": 0.95},
			{"to": "Paris", "distance": 590.0, "quality": 0.95},
			{"to": "Amsterdam", "distance": 440.0, "quality": 0.95}
		],
		"Paris": [
			{"to": "Frankfurt", "distance": 590.0, "quality": 0.95},
			{"to": "Barcelona", "distance": 1035.0, "quality": 0.90},
			{"to": "Brussels", "distance": 310.0, "quality": 0.95}
		],
		"Vienna": [
			{"to": "Munich", "distance": 435.0, "quality": 0.95},
			{"to": "Prague", "distance": 330.0, "quality": 0.90}
		],
		"Warsaw": [
			{"to": "Berlin", "distance": 575.0, "quality": 0.80},
			{"to": "Prague", "distance": 680.0, "quality": 0.75}
		]
	}

func _initialize_weather() -> void:
	# Set initial weather for all regions
	for region in regional_weather.keys():
		_update_regional_weather(region)

func _on_day_changed(day: int) -> void:
	# Update weather daily
	_update_weather_system()

	# Update traffic hourly (simulated daily for performance)
	_update_traffic_conditions()

	# Clean up old traffic events
	_cleanup_traffic_events()

func _process(delta: float) -> void:
	# Real-time updates for active deliveries
	_update_active_delivery_conditions(delta)

func _update_weather_system() -> void:
	# Change weather for each region based on season and randomness
	for region in regional_weather.keys():
		if randf() < 0.3:  # 30% chance of weather change daily
			_update_regional_weather(region)

func _update_regional_weather(region: String) -> void:
	var season = MarketAI.current_season if has_node("/root/MarketAI") else "spring"

	# Weather probabilities based on region and season
	var weather_chances = _get_weather_probabilities(region, season)

	var roll = randf()
	var cumulative = 0.0
	var new_weather = "clear"

	for weather_chance in weather_chances:
		cumulative += weather_chance.probability
		if roll <= cumulative:
			new_weather = weather_chance.weather
			break

	var weather_data = _get_weather_data(new_weather)
	regional_weather[region] = {
		"condition": new_weather,
		"severity": weather_data.risk_factor
	}

	emit_signal("weather_changed", region, new_weather, weather_data.speed_factor)

func _get_weather_probabilities(region: String, season: String) -> Array:
	# Base probabilities
	var base = [
		{"weather": "clear", "probability": 0.50},
		{"weather": "light_rain", "probability": 0.25},
		{"weather": "heavy_rain", "probability": 0.10},
		{"weather": "fog", "probability": 0.10},
		{"weather": "snow", "probability": 0.03},
		{"weather": "ice", "probability": 0.01},
		{"weather": "storm", "probability": 0.01}
	]

	# Adjust for season
	match season:
		"winter":
			if region in ["Scandinavia", "Eastern Europe"]:
				base[4].probability = 0.25  # More snow
				base[5].probability = 0.15  # More ice
				base[0].probability = 0.20  # Less clear
		"summer":
			base[0].probability = 0.70  # More clear days
			base[4].probability = 0.0   # No snow
			base[5].probability = 0.0   # No ice
		"autumn":
			base[1].probability = 0.35  # More rain
			base[3].probability = 0.15  # More fog

	# Adjust for region
	match region:
		"Scandinavia":
			base[4].probability += 0.05  # More snow prone
		"Southern Europe":
			base[0].probability += 0.10  # Generally sunnier

	# Normalize probabilities
	var total = 0.0
	for item in base:
		total += item.probability
	for item in base:
		item.probability /= total

	return base

func _get_weather_data(weather_name: String) -> Dictionary:
	for weather in weather_types:
		if weather.name == weather_name:
			return weather
	return weather_types[0]  # Default to clear

func _update_traffic_conditions() -> void:
	# Simulate traffic based on time, day of week, and events
	var hour = GameManager.current_hour
	var day = GameManager.current_day % 7

	# Base traffic (rush hours)
	var traffic_multiplier = 1.0
	if hour in [7, 8, 9, 17, 18, 19]:  # Rush hours
		traffic_multiplier = 1.3
	elif hour >= 22 or hour <= 5:  # Night
		traffic_multiplier = 0.7

	# Weekend effect
	if day in [5, 6]:  # Saturday, Sunday
		traffic_multiplier *= 0.8

	# Random traffic incidents
	if randf() < 0.05:  # 5% chance daily
		_create_traffic_incident()

func _create_traffic_incident() -> void:
	var cities = city_connections.keys()
	if cities.size() < 2:
		return

	var from_city = cities[randi() % cities.size()]
	var connections = city_connections.get(from_city, [])
	if connections.is_empty():
		return

	var to_city = connections[randi() % connections.size()].to

	var severities = [
		{"name": "minor", "delay_factor": 1.1, "duration": 4},
		{"name": "moderate", "delay_factor": 1.3, "duration": 8},
		{"name": "major", "delay_factor": 1.6, "duration": 16},
		{"name": "severe", "delay_factor": 2.0, "duration": 24}
	]

	var severity = severities[randi() % severities.size()]

	var incident = {
		"id": _generate_id(),
		"from": from_city,
		"to": to_city,
		"severity": severity.name,
		"delay_factor": severity.delay_factor,
		"duration_hours": severity.duration,
		"created_hour": GameManager.current_hour,
		"created_day": GameManager.current_day,
		"type": ["accident", "construction", "weather_damage", "protest"][randi() % 4]
	}

	traffic_events.append(incident)
	emit_signal("traffic_incident", from_city + " to " + to_city, severity.name, severity.delay_factor)

func _cleanup_traffic_events() -> void:
	# Remove expired traffic incidents
	var current_time = GameManager.current_day * 24 + GameManager.current_hour

	traffic_events = traffic_events.filter(func(incident):
		var incident_time = incident.created_day * 24 + incident.created_hour
		return current_time - incident_time < incident.duration_hours
	)

func _update_active_delivery_conditions(delta: float) -> void:
	# Update active deliveries with weather and traffic effects
	for delivery in GameManager.active_deliveries:
		if delivery.status != "in_transit":
			continue

		var region = _get_region_for_route(delivery.origin, delivery.destination)
		var weather = regional_weather.get(region, {"condition": "clear", "severity": 0.0})
		var weather_data = _get_weather_data(weather.condition)

		# Check for traffic incidents on this route
		var traffic_delay = _get_traffic_delay_for_route(delivery.origin, delivery.destination)

		# Calculate combined speed factor
		var speed_factor = weather_data.speed_factor * (1.0 / traffic_delay)

		# Update delivery speed (this modifies the original speed_factor)
		if "route_speed_modifier" not in delivery:
			delivery.route_speed_modifier = 1.0

		# Smooth transition to new speed
		delivery.route_speed_modifier = lerp(delivery.route_speed_modifier, speed_factor, 0.1)

		# Check for random incidents (accidents, breakdowns)
		if randf() < weather_data.risk_factor * 0.0001:  # Very small chance per frame
			_trigger_delivery_incident(delivery)

func _trigger_delivery_incident(delivery: Dictionary) -> void:
	var incidents = [
		{"type": "breakdown", "delay": 3.0, "cost": 500.0},
		{"type": "minor_accident", "delay": 2.0, "cost": 1000.0},
		{"type": "flat_tire", "delay": 1.0, "cost": 200.0},
		{"type": "customs_delay", "delay": 4.0, "cost": 0.0}
	]

	var incident = incidents[randi() % incidents.size()]

	# Add delay to delivery
	delivery.progress = max(0.0, delivery.progress - incident.delay)

	# Apply cost
	GameManager.company_money -= incident.cost

	EventBus.emit_signal("delivery_incident", delivery, incident)

func _get_traffic_delay_for_route(from: String, to: String) -> float:
	var delay = 1.0

	for incident in traffic_events:
		if (incident.from == from and incident.to == to) or (incident.from == to and incident.to == from):
			delay = max(delay, incident.delay_factor)

	return delay

func _get_region_for_route(from: String, to: String) -> String:
	# Simplified region detection based on city
	var northern_cities = ["Hamburg", "Copenhagen", "Stockholm", "Oslo"]
	var southern_cities = ["Milan", "Barcelona", "Rome", "Athens"]
	var eastern_cities = ["Warsaw", "Prague", "Budapest", "Bucharest"]
	var western_cities = ["Paris", "Brussels", "Amsterdam", "London"]

	if from in northern_cities or to in northern_cities:
		return "Scandinavia"
	elif from in southern_cities or to in southern_cities:
		return "Southern Europe"
	elif from in eastern_cities or to in eastern_cities:
		return "Eastern Europe"
	elif from in western_cities or to in western_cities:
		return "Western Europe"

	return "Central Europe"

func _generate_id() -> String:
	return str(randi()) + str(Time.get_ticks_msec())

# Public API
func calculate_optimal_route(from: String, to: String, truck_type: String = "diesel") -> Dictionary:
	"""Calculate the optimal route considering current conditions"""
	var cache_key = from + "_" + to + "_" + truck_type

	# Check cache (valid for 1 hour of game time)
	if route_cache.has(cache_key):
		var cached = route_cache[cache_key]
		if GameManager.current_hour == cached.hour:
			return cached.route

	# Calculate new route using Dijkstra's algorithm (simplified)
	var route = _find_best_path(from, to, truck_type)

	# Cache the route
	route_cache[cache_key] = {
		"route": route,
		"hour": GameManager.current_hour
	}

	return route

func _find_best_path(from: String, to: String, truck_type: String) -> Dictionary:
	# Simple pathfinding - in a full game this would use proper pathfinding
	var region = _get_region_for_route(from, to)
	var weather = regional_weather.get(region, {"condition": "clear", "severity": 0.0})
	var weather_data = _get_weather_data(weather.condition)
	var traffic_delay = _get_traffic_delay_for_route(from, to)

	var base_distance = GameManager._calculate_distance(from, to)

	return {
		"from": from,
		"to": to,
		"distance": base_distance,
		"estimated_time": base_distance / 80.0 * traffic_delay / weather_data.speed_factor,
		"weather_factor": weather_data.speed_factor,
		"traffic_factor": traffic_delay,
		"risk_level": weather_data.risk_factor,
		"recommended_speed": 80.0 * weather_data.speed_factor / traffic_delay,
		"fuel_efficiency_modifier": 1.0 / weather_data.speed_factor  # Worse weather = more fuel
	}

func get_weather_for_region(region: String) -> Dictionary:
	return regional_weather.get(region, {"condition": "clear", "severity": 0.0})

func get_current_traffic_incidents() -> Array:
	return traffic_events.duplicate()

func get_route_conditions(from: String, to: String) -> Dictionary:
	"""Get current conditions for a specific route"""
	return calculate_optimal_route(from, to)

func get_weather_forecast(region: String, days_ahead: int = 1) -> String:
	"""Simple weather forecast (could be enhanced with MarketAI integration)"""
	var current = regional_weather.get(region, {"condition": "clear"})

	# Simple forecast - just slightly random from current
	if randf() < 0.7:
		return current.condition
	else:
		return ["clear", "light_rain", "fog"][randi() % 3]
