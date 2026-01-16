extends Node
## MarketAI - Intelligent market dynamics system
## Simulates realistic economic factors, fuel price fluctuations, demand changes

signal fuel_price_changed(fuel_type: String, new_price: float, change_percent: float)
signal market_demand_changed(cargo_type: String, demand_level: float)
signal economic_event(event_type: String, description: String, impact: Dictionary)
signal market_trend_updated(trend: String)

# Economic State
var current_economic_state: String = "stable"  # recession, stable, boom
var inflation_rate: float = 0.02  # 2% annual
var economic_cycle_day: int = 0
var market_volatility: float = 0.5  # 0.0 = stable, 1.0 = very volatile

# Fuel Price Dynamics
var base_fuel_prices: Dictionary = {
	"diesel": 1.50,
	"electric": 0.30,
	"hydrogen": 10.00
}

var fuel_price_trends: Dictionary = {
	"diesel": 0.0,  # -1.0 to 1.0 (decreasing to increasing)
	"electric": 0.0,
	"hydrogen": 0.0
}

# Market Demand (affects contract availability and pricing)
var cargo_demand: Dictionary = {
	"Electronics": 1.0,
	"Automotive Parts": 1.0,
	"Food Products": 1.0,
	"Chemicals": 0.8,
	"Machinery": 0.9,
	"Textiles": 0.7,
	"Furniture": 0.8,
	"Construction Materials": 1.1,
	"Medical Supplies": 1.2,
	"Consumer Goods": 1.0,
	"Raw Materials": 0.9,
	"Hazardous Materials": 0.7
}

# Seasonal Effects
var current_season: String = "spring"  # spring, summer, autumn, winter
var season_day: int = 0

# Random Events Pool
var pending_events: Array = []
var event_cooldown: int = 0

# Market Intelligence
var market_forecasts: Dictionary = {}  # Predictions for next 7 days
var competitor_activity: float = 0.5  # How active competitors are

func _ready() -> void:
	_initialize_market()
	EventBus.day_changed.connect(_on_day_changed) if EventBus.has_signal("day_changed") else null
	GameManager.day_changed.connect(_on_day_changed)

func _initialize_market() -> void:
	# Set initial market state
	_update_season(0)
	_generate_market_forecast()

func _on_day_changed(day: int) -> void:
	economic_cycle_day += 1
	season_day += 1
	event_cooldown = max(0, event_cooldown - 1)

	# Update season every 90 days
	if season_day >= 90:
		season_day = 0
		_advance_season()

	# Daily market updates
	_update_fuel_prices()
	_update_cargo_demand()
	_update_economic_state()
	_check_for_random_events()
	_update_competitor_activity()

	# Weekly forecast updates
	if day % 7 == 0:
		_generate_market_forecast()

func _update_fuel_prices() -> void:
	for fuel_type in ["diesel", "electric", "hydrogen"]:
		# Trend-based change with random fluctuations
		var trend = fuel_price_trends[fuel_type]
		var random_change = randf_range(-0.02, 0.02) * market_volatility
		var seasonal_factor = _get_seasonal_fuel_factor(fuel_type)
		var economic_factor = _get_economic_fuel_factor()

		# Calculate total change
		var change = (trend * 0.01) + random_change + seasonal_factor + economic_factor

		# Apply to game manager's fuel prices
		var current_price = _get_fuel_price(fuel_type)
		var new_price = current_price * (1.0 + change)

		# Clamp to reasonable ranges
		new_price = clamp(new_price, base_fuel_prices[fuel_type] * 0.5, base_fuel_prices[fuel_type] * 2.0)

		_set_fuel_price(fuel_type, new_price)

		# Update trend (with momentum and mean reversion)
		fuel_price_trends[fuel_type] += randf_range(-0.1, 0.1)
		fuel_price_trends[fuel_type] = lerp(fuel_price_trends[fuel_type], 0.0, 0.05)  # Mean reversion
		fuel_price_trends[fuel_type] = clamp(fuel_price_trends[fuel_type], -1.0, 1.0)

		# Emit signal if significant change
		if abs(change) > 0.01:
			emit_signal("fuel_price_changed", fuel_type, new_price, change * 100.0)

func _update_cargo_demand() -> void:
	for cargo_type in cargo_demand.keys():
		# Natural demand fluctuation
		var change = randf_range(-0.05, 0.05) * market_volatility

		# Seasonal effects
		change += _get_seasonal_cargo_factor(cargo_type)

		# Economic state effects
		change += _get_economic_cargo_factor(cargo_type)

		# Apply change
		cargo_demand[cargo_type] += change
		cargo_demand[cargo_type] = clamp(cargo_demand[cargo_type], 0.3, 2.0)

		# Emit signal if significant change
		if abs(change) > 0.05:
			emit_signal("market_demand_changed", cargo_type, cargo_demand[cargo_type])

func _update_economic_state() -> void:
	# Economic cycles (simplified business cycle)
	var cycle_position = float(economic_cycle_day % 1080) / 1080.0  # ~3 year cycle
	var cycle_value = sin(cycle_position * TAU)

	# Determine economic state
	var prev_state = current_economic_state
	if cycle_value < -0.3:
		current_economic_state = "recession"
		market_volatility = 0.8
	elif cycle_value > 0.3:
		current_economic_state = "boom"
		market_volatility = 0.6
	else:
		current_economic_state = "stable"
		market_volatility = 0.5

	# Emit signal on state change
	if prev_state != current_economic_state:
		var description = _get_economic_state_description()
		emit_signal("economic_event", "state_change", description, {
			"state": current_economic_state,
			"volatility": market_volatility
		})

func _check_for_random_events() -> void:
	if event_cooldown > 0:
		return

	# Random chance of event (adjusted by volatility)
	if randf() < 0.05 * market_volatility:
		_trigger_random_market_event()

func _trigger_random_market_event() -> void:
	var events = [
		{
			"type": "fuel_crisis",
			"description": "Oil supply disruption causes diesel prices to spike!",
			"impact": {"fuel": "diesel", "change": 0.25}
		},
		{
			"type": "green_subsidy",
			"description": "Government subsidies reduce electric charging costs",
			"impact": {"fuel": "electric", "change": -0.15}
		},
		{
			"type": "construction_boom",
			"description": "Major construction projects increase demand for materials",
			"impact": {"cargo": "Construction Materials", "demand": 0.4}
		},
		{
			"type": "tech_shortage",
			"description": "Supply chain issues affect electronics shipments",
			"impact": {"cargo": "Electronics", "demand": -0.3}
		},
		{
			"type": "medical_emergency",
			"description": "Health crisis increases demand for medical supplies",
			"impact": {"cargo": "Medical Supplies", "demand": 0.5}
		},
		{
			"type": "trade_deal",
			"description": "New trade agreement boosts international shipping",
			"impact": {"all_cargo": 0.15}
		},
		{
			"type": "fuel_tech_breakthrough",
			"description": "Hydrogen production breakthrough lowers costs",
			"impact": {"fuel": "hydrogen", "change": -0.20}
		},
		{
			"type": "economic_stimulus",
			"description": "Government stimulus package boosts consumer goods demand",
			"impact": {"cargo": "Consumer Goods", "demand": 0.3}
		}
	]

	var event = events[randi() % events.size()]
	_apply_market_event(event)
	emit_signal("economic_event", event.type, event.description, event.impact)
	event_cooldown = randi_range(7, 21)  # 1-3 weeks cooldown

func _apply_market_event(event: Dictionary) -> void:
	var impact = event.impact

	if impact.has("fuel"):
		var fuel_type = impact.fuel
		var current_price = _get_fuel_price(fuel_type)
		var new_price = current_price * (1.0 + impact.change)
		_set_fuel_price(fuel_type, new_price)

	if impact.has("cargo"):
		var cargo_type = impact.cargo
		cargo_demand[cargo_type] = clamp(
			cargo_demand[cargo_type] + impact.demand,
			0.3, 2.0
		)

	if impact.has("all_cargo"):
		for cargo_type in cargo_demand.keys():
			cargo_demand[cargo_type] = clamp(
				cargo_demand[cargo_type] + impact.all_cargo,
				0.3, 2.0
			)

func _update_competitor_activity() -> void:
	# Competitors are more active in boom times
	var target_activity = 0.5
	match current_economic_state:
		"boom":
			target_activity = 0.7
		"recession":
			target_activity = 0.3
		"stable":
			target_activity = 0.5

	# Smooth transition
	competitor_activity = lerp(competitor_activity, target_activity, 0.1)
	competitor_activity += randf_range(-0.05, 0.05)
	competitor_activity = clamp(competitor_activity, 0.2, 0.9)

func _advance_season() -> void:
	match current_season:
		"spring": current_season = "summer"
		"summer": current_season = "autumn"
		"autumn": current_season = "winter"
		"winter": current_season = "spring"

	_update_season(season_day)

func _update_season(day: int) -> void:
	# Seasonal effects are applied in other functions
	pass

func _get_seasonal_fuel_factor(fuel_type: String) -> float:
	# Winter increases diesel demand (heating), summer increases electric (AC)
	match current_season:
		"winter":
			if fuel_type == "diesel":
				return 0.005
			elif fuel_type == "electric":
				return -0.002
		"summer":
			if fuel_type == "electric":
				return 0.003
			elif fuel_type == "diesel":
				return -0.002
	return 0.0

func _get_seasonal_cargo_factor(cargo_type: String) -> float:
	match current_season:
		"winter":
			if cargo_type == "Construction Materials":
				return -0.02
			elif cargo_type == "Consumer Goods":
				return 0.03  # Holiday shopping
			elif cargo_type == "Food Products":
				return 0.02
		"summer":
			if cargo_type == "Construction Materials":
				return 0.03  # Construction season
			elif cargo_type == "Food Products":
				return -0.01
		"spring":
			if cargo_type == "Construction Materials":
				return 0.02
			elif cargo_type == "Machinery":
				return 0.02
		"autumn":
			if cargo_type == "Food Products":
				return 0.02  # Harvest
			elif cargo_type == "Textiles":
				return 0.02  # Fashion season
	return 0.0

func _get_economic_fuel_factor() -> float:
	match current_economic_state:
		"boom":
			return 0.003  # Higher demand = higher prices
		"recession":
			return -0.003  # Lower demand = lower prices
	return 0.0

func _get_economic_cargo_factor(cargo_type: String) -> float:
	match current_economic_state:
		"boom":
			if cargo_type in ["Electronics", "Consumer Goods", "Automotive Parts"]:
				return 0.02
			return 0.01
		"recession":
			if cargo_type in ["Electronics", "Consumer Goods", "Automotive Parts"]:
				return -0.02
			elif cargo_type == "Food Products":
				return 0.01  # Food is resilient
			return -0.01
	return 0.0

func _generate_market_forecast() -> void:
	# Generate 7-day forecast for fuel prices and cargo demand
	market_forecasts.clear()

	for days_ahead in range(1, 8):
		var forecast = {
			"day": GameManager.current_day + days_ahead,
			"fuel_trends": {},
			"cargo_trends": {},
			"confidence": 1.0 - (days_ahead * 0.1)  # Less confident further out
		}

		# Predict fuel price trends
		for fuel_type in fuel_price_trends.keys():
			var trend = fuel_price_trends[fuel_type]
			var prediction = "stable"
			if trend > 0.3:
				prediction = "increasing"
			elif trend < -0.3:
				prediction = "decreasing"
			forecast.fuel_trends[fuel_type] = prediction

		# Predict cargo demand trends
		for cargo_type in cargo_demand.keys():
			var demand = cargo_demand[cargo_type]
			var prediction = "normal"
			if demand > 1.2:
				prediction = "high"
			elif demand < 0.8:
				prediction = "low"
			forecast.cargo_trends[cargo_type] = prediction

		market_forecasts[days_ahead] = forecast

	emit_signal("market_trend_updated", current_economic_state)

func _get_economic_state_description() -> String:
	match current_economic_state:
		"boom":
			return "Economic boom! High demand for transport services and increased competition."
		"recession":
			return "Economic downturn. Lower cargo demand but less competition."
		"stable":
			return "Stable economic conditions. Normal market activity."
	return ""

# Helper functions to interface with GameManager
func _get_fuel_price(fuel_type: String) -> float:
	match fuel_type:
		"diesel":
			return GameManager.fuel_price_diesel
		"electric":
			return GameManager.fuel_price_electric
		"hydrogen":
			return GameManager.fuel_price_hydrogen
	return 0.0

func _set_fuel_price(fuel_type: String, price: float) -> void:
	match fuel_type:
		"diesel":
			GameManager.fuel_price_diesel = price
		"electric":
			GameManager.fuel_price_electric = price
		"hydrogen":
			GameManager.fuel_price_hydrogen = price

# Public API
func get_cargo_demand_multiplier(cargo_type: String) -> float:
	"""Get the current demand multiplier for a cargo type (affects payment)"""
	return cargo_demand.get(cargo_type, 1.0)

func get_market_forecast(days_ahead: int) -> Dictionary:
	"""Get market forecast for N days ahead"""
	return market_forecasts.get(days_ahead, {})

func get_fuel_price_trend(fuel_type: String) -> String:
	"""Get human-readable trend for fuel type"""
	var trend = fuel_price_trends.get(fuel_type, 0.0)
	if trend > 0.3:
		return "Rising"
	elif trend < -0.3:
		return "Falling"
	return "Stable"

func get_competitor_activity_level() -> String:
	"""Get human-readable competitor activity level"""
	if competitor_activity > 0.7:
		return "Very High"
	elif competitor_activity > 0.5:
		return "High"
	elif competitor_activity > 0.3:
		return "Moderate"
	return "Low"

func get_season() -> String:
	return current_season.capitalize()

func get_economic_state() -> String:
	return current_economic_state.capitalize()
