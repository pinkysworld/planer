extends Node
## MinigameManager - Interactive mini-games for enhanced gameplay
## Adds skill-based gameplay and variety to the simulation

signal minigame_started(game_type: String)
signal minigame_completed(game_type: String, score: int, reward: Dictionary)
signal minigame_failed(game_type: String)

# Minigame types
enum MinigameType {
	LOADING_TETRIS,      # Tetris-like cargo loading
	ROUTE_PUZZLE,        # Plan optimal route
	NEGOTIATION,         # Haggle for better prices
	TRUCK_PARKING,       # Parking challenge
	FUEL_OPTIMIZATION,   # Optimize fuel consumption
	EMERGENCY_RESPONSE,  # Quick-time event for emergencies
	MARKET_TRADING       # Buy low, sell high mini stock market
}

# Active minigame
var active_minigame: Dictionary = {}
var minigame_highscores: Dictionary = {}

func _ready() -> void:
	_initialize_highscores()

func _initialize_highscores() -> void:
	for type in MinigameType.values():
		minigame_highscores[type] = 0

# === LOADING TETRIS ===
func start_loading_tetris(cargo_weight: float) -> void:
	"""Tetris-style cargo loading mini-game"""
	active_minigame = {
		"type": MinigameType.LOADING_TETRIS,
		"cargo_weight": cargo_weight,
		"target_efficiency": 0.85,  # 85% space utilization
		"time_limit": 60.0,  # 60 seconds
		"score": 0
	}

	emit_signal("minigame_started", "loading_tetris")

	# Would launch the actual minigame UI
	# For now, simulate quick result
	await get_tree().create_timer(2.0).timeout
	_complete_loading_tetris(randf_range(0.7, 0.95))

func _complete_loading_tetris(efficiency: float) -> void:
	"""Complete cargo loading minigame"""
	var score = int(efficiency * 100)

	var reward = {
		"cargo_bonus": efficiency * 500,  # Better loading = bonus money
		"time_saved": (efficiency - 0.5) * 2.0,  # Faster delivery start
		"reputation": floor((efficiency - 0.75) * 20)
	}

	if efficiency >= 0.9:
		reward.achievement = "master_loader"

	_finish_minigame("loading_tetris", score, reward)

# === ROUTE PUZZLE ===
func start_route_puzzle(origin: String, destination: String, waypoints: Array) -> void:
	"""Plan the optimal route through multiple waypoints"""
	active_minigame = {
		"type": MinigameType.ROUTE_PUZZLE,
		"origin": origin,
		"destination": destination,
		"waypoints": waypoints,
		"time_limit": 30.0
	}

	emit_signal("minigame_started", "route_puzzle")

	# Simulate
	await get_tree().create_timer(2.0).timeout
	var optimal_distance = 1000.0
	var player_distance = optimal_distance * randf_range(1.0, 1.3)
	_complete_route_puzzle(player_distance, optimal_distance)

func _complete_route_puzzle(player_distance: float, optimal_distance: float) -> void:
	"""Complete route planning minigame"""
	var efficiency = optimal_distance / player_distance
	var score = int(efficiency * 100)

	var reward = {
		"fuel_saved": (1.0 - efficiency) * -500,  # Penalty for inefficient route
		"time_bonus": efficiency * 1000,
		"reputation": floor((efficiency - 0.85) * 15)
	}

	if efficiency >= 0.98:
		reward.achievement = "route_master"

	_finish_minigame("route_puzzle", score, reward)

# === NEGOTIATION ===
func start_negotiation(base_price: float, max_price: float) -> void:
	"""Haggle for a better contract price"""
	active_minigame = {
		"type": MinigameType.NEGOTIATION,
		"base_price": base_price,
		"max_price": max_price,
		"rounds": 3,
		"current_offer": base_price,
		"client_satisfaction": 1.0
	}

	emit_signal("minigame_started", "negotiation")

	# Simulate negotiation
	await get_tree().create_timer(3.0).timeout
	var final_price = lerp(base_price, max_price, randf_range(0.4, 0.9))
	_complete_negotiation(final_price, max_price)

func _complete_negotiation(final_price: float, max_price: float) -> void:
	"""Complete negotiation minigame"""
	var success_rate = final_price / max_price
	var score = int(success_rate * 100)

	var reward = {
		"bonus_money": final_price - active_minigame.base_price,
		"reputation": floor((success_rate - 0.5) * 10)
	}

	if success_rate >= 0.95:
		reward.title = "Master Negotiator"

	_finish_minigame("negotiation", score, reward)

# === TRUCK PARKING ===
func start_truck_parking(difficulty: String = "medium") -> void:
	"""Parking challenge - precision driving"""
	active_minigame = {
		"type": MinigameType.TRUCK_PARKING,
		"difficulty": difficulty,
		"time_limit": 45.0,
		"damage_taken": 0.0
	}

	emit_signal("minigame_started", "truck_parking")

	# Simulate
	await get_tree().create_timer(2.5).timeout
	var time_taken = randf_range(15.0, 40.0)
	var damage = randf_range(0.0, 20.0)
	_complete_truck_parking(time_taken, damage)

func _complete_truck_parking(time_taken: float, damage: float) -> void:
	"""Complete parking minigame"""
	var time_score = (45.0 - time_taken) / 45.0  # Faster = better
	var damage_penalty = damage / 100.0
	var final_score = max(0, (time_score - damage_penalty) * 100)

	var reward = {
		"reputation": floor(final_score / 10),
		"truck_damage": -damage
	}

	if damage == 0 and time_taken < 20:
		reward.achievement = "parking_pro"

	_finish_minigame("truck_parking", int(final_score), reward)

# === FUEL OPTIMIZATION ===
func start_fuel_optimization(distance: float, terrain: String) -> void:
	"""Optimize driving for fuel efficiency"""
	active_minigame = {
		"type": MinigameType.FUEL_OPTIMIZATION,
		"distance": distance,
		"terrain": terrain,
		"optimal_consumption": distance * 0.3,  # L/km
		"time_limit": 20.0
	}

	emit_signal("minigame_started", "fuel_optimization")

	# Simulate
	await get_tree().create_timer(2.0).timeout
	var actual_consumption = distance * randf_range(0.25, 0.45)
	_complete_fuel_optimization(actual_consumption)

func _complete_fuel_optimization(actual_consumption: float) -> void:
	"""Complete fuel optimization minigame"""
	var optimal = active_minigame.optimal_consumption
	var efficiency = optimal / actual_consumption
	var score = int(efficiency * 100)

	var fuel_price = GameManager.fuel_price_diesel if GameManager else 1.85
	var fuel_saved = (actual_consumption - optimal) * fuel_price

	var reward = {
		"money_saved": -fuel_saved,  # Negative if wasted
		"reputation": floor((efficiency - 1.0) * 20)
	}

	if efficiency >= 1.15:
		reward.achievement = "eco_driver"

	_finish_minigame("fuel_optimization", score, reward)

# === EMERGENCY RESPONSE ===
func start_emergency_response(event_type: String) -> void:
	"""Quick-time event for handling emergencies"""
	active_minigame = {
		"type": MinigameType.EMERGENCY_RESPONSE,
		"event": event_type,
		"time_limit": 5.0,  # Very fast!
		"correct_actions": []
	}

	emit_signal("minigame_started", "emergency_response")

	# Simulate
	await get_tree().create_timer(1.0).timeout
	var reaction_time = randf_range(0.5, 4.0)
	var correct = randf() > 0.3
	_complete_emergency_response(reaction_time, correct)

func _complete_emergency_response(reaction_time: float, correct_action: bool) -> void:
	"""Complete emergency response minigame"""
	var time_score = (5.0 - reaction_time) / 5.0
	var final_score = int(time_score * (100 if correct_action else 20))

	var reward = {}

	if correct_action:
		reward.damage_prevented = 5000.0
		reward.reputation = floor(time_score * 15)
		if reaction_time < 1.0:
			reward.achievement = "lightning_reflexes"
	else:
		reward.damage_taken = -2000.0
		reward.reputation = -5

	_finish_minigame("emergency_response", final_score, reward)

# === MARKET TRADING ===
func start_market_trading(initial_funds: float) -> void:
	"""Mini stock market for trading truck supplies"""
	active_minigame = {
		"type": MinigameType.MARKET_TRADING,
		"funds": initial_funds,
		"rounds": 5,
		"current_round": 0,
		"portfolio": {}
	}

	emit_signal("minigame_started", "market_trading")

	# Simulate
	await get_tree().create_timer(3.0).timeout
	var final_funds = initial_funds * randf_range(0.8, 1.5)
	_complete_market_trading(final_funds)

func _complete_market_trading(final_funds: float) -> void:
	"""Complete market trading minigame"""
	var initial = active_minigame.funds
	var profit = final_funds - initial
	var roi = (final_funds / initial - 1.0) * 100

	var reward = {
		"money": profit,
		"reputation": floor(roi / 5)
	}

	if roi >= 40:
		reward.title = "Market Wizard"
		reward.achievement = "trader"

	_finish_minigame("market_trading", int(roi), reward)

# === GENERIC COMPLETION ===
func _finish_minigame(game_type: String, score: int, reward: Dictionary) -> void:
	"""Generic minigame completion handler"""

	# Update highscore
	var type_enum = _get_minigame_enum(game_type)
	if minigame_highscores.has(type_enum):
		minigame_highscores[type_enum] = max(minigame_highscores[type_enum], score)

	# Apply rewards
	_apply_minigame_rewards(reward)

	emit_signal("minigame_completed", game_type, score, reward)

	# Show results UI
	_show_minigame_results(game_type, score, reward)

	active_minigame.clear()

func _apply_minigame_rewards(reward: Dictionary) -> void:
	"""Apply rewards from minigame"""

	if reward.has("money") and GameManager:
		GameManager.company_money += reward.money

	if reward.has("reputation") and GameManager:
		GameManager.company_reputation = clamp(
			GameManager.company_reputation + reward.reputation,
			0.0, 100.0
		)

	if reward.has("bonus_money") and GameManager:
		GameManager.company_money += reward.bonus_money

	if reward.has("money_saved") and GameManager:
		GameManager.company_money += reward.money_saved

	if reward.has("damage_prevented"):
		# Would prevent damage to truck
		pass

	if reward.has("damage_taken"):
		# Would apply damage to truck
		pass

	if reward.has("achievement"):
		if has_node("/root/AchievementSystem"):
			# Would unlock achievement
			pass

	if reward.has("title"):
		if has_node("/root/AchievementSystem"):
			AchievementSystem.unlocked_titles.append(reward.title)

func _show_minigame_results(game_type: String, score: int, reward: Dictionary) -> void:
	"""Show results screen for completed minigame"""
	print("\n🎮 MINIGAME COMPLETE: ", game_type.capitalize())
	print("   Score: ", score)
	print("   Rewards: ", reward)

func _get_minigame_enum(game_type: String) -> int:
	match game_type:
		"loading_tetris":
			return MinigameType.LOADING_TETRIS
		"route_puzzle":
			return MinigameType.ROUTE_PUZZLE
		"negotiation":
			return MinigameType.NEGOTIATION
		"truck_parking":
			return MinigameType.TRUCK_PARKING
		"fuel_optimization":
			return MinigameType.FUEL_OPTIMIZATION
		"emergency_response":
			return MinigameType.EMERGENCY_RESPONSE
		"market_trading":
			return MinigameType.MARKET_TRADING
	return 0

# Public API
func is_minigame_active() -> bool:
	return not active_minigame.is_empty()

func get_active_minigame() -> Dictionary:
	return active_minigame.duplicate()

func get_highscore(game_type: MinigameType) -> int:
	return minigame_highscores.get(game_type, 0)

func get_all_highscores() -> Dictionary:
	return minigame_highscores.duplicate()

func cancel_minigame() -> void:
	"""Cancel active minigame (no rewards)"""
	if not active_minigame.is_empty():
		emit_signal("minigame_failed", _get_minigame_type_string(active_minigame.type))
		active_minigame.clear()

func _get_minigame_type_string(type: int) -> String:
	match type:
		MinigameType.LOADING_TETRIS:
			return "loading_tetris"
		MinigameType.ROUTE_PUZZLE:
			return "route_puzzle"
		MinigameType.NEGOTIATION:
			return "negotiation"
		MinigameType.TRUCK_PARKING:
			return "truck_parking"
		MinigameType.FUEL_OPTIMIZATION:
			return "fuel_optimization"
		MinigameType.EMERGENCY_RESPONSE:
			return "emergency_response"
		MinigameType.MARKET_TRADING:
			return "market_trading"
	return "unknown"
