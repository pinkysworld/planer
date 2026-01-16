extends Node
## CompetitorAI - Simulates AI competitor companies
## Competitors bid on contracts, expand, and create market pressure

signal competitor_won_contract(competitor_name: String, contract: Dictionary)
signal competitor_action(competitor_name: String, action: String, details: Dictionary)
signal new_competitor_entered(competitor: Dictionary)
signal competitor_bankrupted(competitor_name: String)

# Competitor Companies
var competitors: Array = []
var max_competitors: int = 5

# Competition difficulty settings
var competition_level: float = 0.5  # 0.0 = easy, 1.0 = hard

# Market share tracking
var total_market_contracts: int = 0
var player_market_share: float = 0.0

func _ready() -> void:
	GameManager.day_changed.connect(_on_day_changed)
	EventBus.delivery_completed.connect(_on_player_delivery_completed) if EventBus.has_signal("delivery_completed") else null
	_initialize_starting_competitors()

func _initialize_starting_competitors() -> void:
	# Start with 3 competitor companies
	var starting_names = [
		{"name": "EuroTransport GmbH", "strength": 0.6, "specialty": "long_distance"},
		{"name": "QuickShip Logistics", "strength": 0.5, "specialty": "express"},
		{"name": "Regional Freight Co.", "strength": 0.4, "specialty": "regional"}
	]

	for comp_data in starting_names:
		_create_competitor(comp_data.name, comp_data.strength, comp_data.specialty)

func _create_competitor(comp_name: String, strength: float, specialty: String) -> Dictionary:
	var competitor = {
		"id": _generate_id(),
		"name": comp_name,
		"strength": strength,  # 0.0-1.0, affects bidding and success
		"specialty": specialty,  # long_distance, express, regional, bulk, hazmat
		"reputation": randf_range(40.0, 70.0),
		"fleet_size": randi_range(3, 10),
		"money": randf_range(30000.0, 100000.0),
		"active_contracts": 0,
		"completed_deliveries": 0,
		"founded_day": GameManager.current_day,
		"ai_personality": _generate_ai_personality(),
		"expansion_chance": randf_range(0.1, 0.4),
		"aggression": randf_range(0.3, 0.9)  # How aggressively they bid
	}

	competitors.append(competitor)
	emit_signal("new_competitor_entered", competitor)
	return competitor

func _generate_ai_personality() -> Dictionary:
	var personalities = [
		{"type": "aggressive", "bid_modifier": 0.85, "expansion_focus": "high"},
		{"type": "cautious", "bid_modifier": 0.95, "expansion_focus": "low"},
		{"type": "opportunist", "bid_modifier": 0.90, "expansion_focus": "medium"},
		{"type": "specialist", "bid_modifier": 0.88, "expansion_focus": "medium"},
		{"type": "balanced", "bid_modifier": 0.92, "expansion_focus": "medium"}
	]
	return personalities[randi() % personalities.size()]

func _generate_id() -> String:
	return str(randi()) + str(Time.get_ticks_msec())

func _on_day_changed(day: int) -> void:
	# Daily competitor actions
	_update_competitor_stats()
	_competitors_evaluate_contracts()
	_competitors_random_actions()

	# Weekly actions
	if day % 7 == 0:
		_competitors_strategic_decisions()

	# Monthly actions
	if day % 30 == 0:
		_competitors_monthly_update()
		_check_for_new_competitors()

func _update_competitor_stats() -> void:
	for competitor in competitors:
		# Simulate their business activities
		var daily_expense = competitor.fleet_size * 50.0
		competitor.money -= daily_expense

		# Random revenue from their contracts
		if competitor.active_contracts > 0 and randf() < 0.2:
			var revenue = randf_range(1000.0, 5000.0)
			competitor.money += revenue
			competitor.active_contracts -= 1
			competitor.completed_deliveries += 1

		# Check bankruptcy
		if competitor.money < -10000.0:
			_bankrupt_competitor(competitor)

func _competitors_evaluate_contracts() -> void:
	# Competitors look at available contracts and may "snatch" them
	var available_contracts = GameManager.contracts.filter(
		func(c): return c.status == "available"
	)

	for contract in available_contracts:
		# Each competitor has a chance to bid on this contract
		for competitor in competitors:
			if _should_competitor_bid(competitor, contract):
				if _competitor_wins_contract(competitor, contract):
					break  # Contract taken

func _should_competitor_bid(competitor: Dictionary, contract: Dictionary) -> bool:
	# More active in boom times
	var market_factor = MarketAI.competitor_activity if has_node("/root/MarketAI") else 0.5

	# Base chance affected by market activity
	var base_chance = 0.05 * market_factor * competitor.aggression

	# Specialty bonus
	if _matches_specialty(competitor.specialty, contract):
		base_chance *= 1.5

	# Lower chance if they're overloaded
	if competitor.active_contracts >= competitor.fleet_size:
		base_chance *= 0.3

	return randf() < base_chance

func _matches_specialty(specialty: String, contract: Dictionary) -> bool:
	match specialty:
		"long_distance":
			return contract.distance > 600.0
		"express":
			return contract.urgency in ["express", "urgent"]
		"regional":
			return contract.distance < 400.0
		"bulk":
			return contract.cargo_weight > 15.0
		"hazmat":
			return contract.cargo_type == "Hazardous Materials"
	return false

func _competitor_wins_contract(competitor: Dictionary, contract: Dictionary) -> bool:
	# Calculate if competitor successfully wins this contract
	# They compete against player and other competitors

	# Competitor's bid (lower = more competitive)
	var competitor_bid = contract.payment * competitor.ai_personality.bid_modifier
	competitor_bid *= (1.0 + randf_range(-0.1, 0.1))  # Some randomness

	# Player's "implicit bid" based on reputation
	var player_bid = contract.payment * (1.0 - GameManager.company_reputation / 200.0)

	# Competitor wins if their bid is better AND they pass a random check
	var win_chance = competitor.strength * 0.3
	if competitor.reputation > GameManager.company_reputation:
		win_chance += 0.2

	if competitor_bid < player_bid and randf() < win_chance:
		# Competitor wins!
		GameManager.contracts.erase(contract)
		competitor.active_contracts += 1
		competitor.money -= contract.distance * 0.5  # Fuel costs
		total_market_contracts += 1

		emit_signal("competitor_won_contract", competitor.name, contract)
		return true

	return false

func _competitors_random_actions() -> void:
	# Random events for competitors
	for competitor in competitors:
		var action_roll = randf()

		if action_roll < 0.01:  # 1% chance
			# Competitor expands fleet
			_competitor_expand_fleet(competitor)
		elif action_roll < 0.02:  # 1% chance
			# Competitor has accident/issue
			_competitor_incident(competitor)

func _competitor_expand_fleet(competitor: Dictionary) -> void:
	var truck_cost = randf_range(15000.0, 40000.0)
	if competitor.money > truck_cost * 2.0:  # Only if they can afford it
		competitor.fleet_size += 1
		competitor.money -= truck_cost
		emit_signal("competitor_action", competitor.name, "expanded_fleet", {
			"new_fleet_size": competitor.fleet_size
		})

func _competitor_incident(competitor: Dictionary) -> void:
	# Something bad happens to competitor
	var incidents = [
		{"type": "accident", "cost": randf_range(5000.0, 15000.0), "reputation": -5.0},
		{"type": "breakdown", "cost": randf_range(2000.0, 8000.0), "reputation": -2.0},
		{"type": "delay", "cost": randf_range(1000.0, 5000.0), "reputation": -3.0}
	]

	var incident = incidents[randi() % incidents.size()]
	competitor.money -= incident.cost
	competitor.reputation = max(0.0, competitor.reputation + incident.reputation)

	emit_signal("competitor_action", competitor.name, incident.type, incident)

func _competitors_strategic_decisions() -> void:
	# Weekly strategic decisions
	for competitor in competitors:
		# Decide whether to expand operations
		if randf() < competitor.expansion_chance and competitor.money > 50000.0:
			_competitor_expand_fleet(competitor)

		# Adjust pricing strategy based on performance
		if competitor.completed_deliveries < 2:
			# Struggling, become more aggressive
			competitor.aggression = min(1.0, competitor.aggression + 0.1)
		else:
			# Doing well, can be more selective
			competitor.aggression = max(0.3, competitor.aggression - 0.05)

		competitor.completed_deliveries = 0  # Reset weekly counter

func _competitors_monthly_update() -> void:
	# Monthly financial updates for competitors
	for competitor in competitors:
		# Pay monthly expenses
		var monthly_cost = competitor.fleet_size * 1500.0
		competitor.money -= monthly_cost

		# Reputation changes
		if competitor.active_contracts > 0:
			competitor.reputation += 1.0
		else:
			competitor.reputation -= 0.5

		competitor.reputation = clamp(competitor.reputation, 0.0, 100.0)

func _check_for_new_competitors() -> void:
	# New competitors may enter the market
	if competitors.size() < max_competitors:
		# Higher chance during boom times
		var market_factor = 1.0
		if has_node("/root/MarketAI"):
			match MarketAI.current_economic_state:
				"boom":
					market_factor = 2.0
				"recession":
					market_factor = 0.3

		if randf() < 0.15 * market_factor:
			_create_new_random_competitor()

func _create_new_random_competitor() -> void:
	var names = [
		"TransEuropa Express", "Nordic Freight Lines", "Alpine Logistics",
		"Mediterra Transport", "Baltic Shipping Co.", "Continental Cargo",
		"Express Road Services", "Prime Logistics Group", "Unity Transport",
		"Apex Freight Solutions", "Crown Carriers", "Diamond Delivery Co."
	]

	var specialties = ["long_distance", "express", "regional", "bulk", "hazmat"]

	var available_names = []
	for name in names:
		var exists = false
		for comp in competitors:
			if comp.name == name:
				exists = true
				break
		if not exists:
			available_names.append(name)

	if available_names.size() > 0:
		var new_name = available_names[randi() % available_names.size()]
		var specialty = specialties[randi() % specialties.size()]
		_create_competitor(new_name, randf_range(0.3, 0.6), specialty)

func _bankrupt_competitor(competitor: Dictionary) -> void:
	competitors.erase(competitor)
	emit_signal("competitor_bankrupted", competitor.name)

func _on_player_delivery_completed(delivery: Dictionary, on_time: bool) -> void:
	# Track player's market share
	total_market_contracts += 1
	_calculate_market_share()

func _calculate_market_share() -> void:
	if total_market_contracts == 0:
		player_market_share = 0.0
		return

	var player_contracts = GameManager.total_deliveries_completed
	player_market_share = float(player_contracts) / float(total_market_contracts) * 100.0

# Public API
func get_market_competition_level() -> String:
	"""Get human-readable competition level"""
	var active_competitors = competitors.size()
	if active_competitors >= 5:
		return "Very High"
	elif active_competitors >= 3:
		return "High"
	elif active_competitors >= 2:
		return "Moderate"
	return "Low"

func get_player_market_share() -> float:
	return player_market_share

func get_competitor_count() -> int:
	return competitors.size()

func get_competitors() -> Array:
	return competitors.duplicate()

func get_strongest_competitor() -> Dictionary:
	if competitors.is_empty():
		return {}

	var strongest = competitors[0]
	for comp in competitors:
		if comp.strength > strongest.strength:
			strongest = comp

	return strongest.duplicate()
