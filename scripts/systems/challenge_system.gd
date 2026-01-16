extends Node
## ChallengeSystem - Daily and weekly challenges with rewards
## Provides short-term goals and keeps gameplay fresh

signal daily_challenge_available(challenge: Dictionary)
signal weekly_challenge_available(challenge: Dictionary)
signal challenge_completed(challenge: Dictionary, reward: Dictionary)
signal challenge_progress_updated(challenge_id: String, progress: float)
signal streak_bonus(days: int, bonus: Dictionary)

# Active challenges
var daily_challenge: Dictionary = {}
var weekly_challenges: Array = []
var special_challenges: Array = []

# Progress tracking
var challenge_progress: Dictionary = {}

# Streak tracking
var daily_streak: int = 0
var last_completion_day: int = 0

# Challenge types
enum ChallengeType {
	DELIVERY,
	SPEED,
	EFFICIENCY,
	EXPLORATION,
	BUSINESS,
	SOCIAL
}

# Difficulty levels
enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
	EXTREME
}

func _ready() -> void:
	if GameManager:
		GameManager.day_changed.connect(_on_day_changed)
		GameManager.time_changed.connect(_on_time_changed)

	if EventBus:
		EventBus.connect("delivery_completed", _on_delivery_completed)

func _on_day_changed(day: int) -> void:
	# Generate new daily challenge
	_generate_daily_challenge()

	# Check if it's Monday (new weekly challenges)
	if day % 7 == 1:
		_generate_weekly_challenges()

	# Check streak
	_update_streak()

func _on_time_changed(hour: int, minute: int) -> void:
	# Timed challenges (e.g., complete 3 deliveries before noon)
	_check_timed_challenges()

func _generate_daily_challenge() -> void:
	"""Generate a new daily challenge"""
	var challenges = [
		{
			"id": "daily_distance",
			"name": "Long Hauler",
			"description": "Travel 500 km today",
			"type": ChallengeType.DELIVERY,
			"difficulty": Difficulty.EASY,
			"icon": "🛣️",
			"target": 500.0,
			"progress_type": "distance",
			"reward": {
				"money": 2000,
				"reputation": 5
			}
		},
		{
			"id": "daily_deliveries",
			"name": "Busy Day",
			"description": "Complete 5 deliveries today",
			"type": ChallengeType.DELIVERY,
			"difficulty": Difficulty.MEDIUM,
			"icon": "📦",
			"target": 5,
			"progress_type": "deliveries",
			"reward": {
				"money": 3000,
				"reputation": 8
			}
		},
		{
			"id": "daily_perfect",
			"name": "Perfect Performance",
			"description": "Complete all deliveries on time today",
			"type": ChallengeType.SPEED,
			"difficulty": Difficulty.HARD,
			"icon": "⭐",
			"target": 1.0,  # 100% on time
			"progress_type": "on_time_rate",
			"reward": {
				"money": 5000,
				"reputation": 15
			}
		},
		{
			"id": "daily_efficiency",
			"name": "Fuel Saver",
			"description": "Complete deliveries using 20% less fuel than average",
			"type": ChallengeType.EFFICIENCY,
			"difficulty": Difficulty.MEDIUM,
			"icon": "⛽",
			"target": 0.80,
			"progress_type": "fuel_efficiency",
			"reward": {
				"money": 2500,
				"reputation": 10
			}
		},
		{
			"id": "daily_new_client",
			"name": "Network Expansion",
			"description": "Accept contracts from 3 new clients today",
			"type": ChallengeType.BUSINESS,
			"difficulty": Difficulty.EASY,
			"icon": "🤝",
			"target": 3,
			"progress_type": "new_clients",
			"reward": {
				"money": 1500,
				"reputation": 7
			}
		},
		{
			"id": "daily_no_damage",
			"name": "Safe Driver",
			"description": "Complete all deliveries with no truck damage",
			"type": ChallengeType.DELIVERY,
			"difficulty": Difficulty.MEDIUM,
			"icon": "🛡️",
			"target": 1.0,
			"progress_type": "no_damage",
			"reward": {
				"money": 2000,
				"reputation": 10
			}
		},
		{
			"id": "daily_speed_run",
			"name": "Speed Demon",
			"description": "Complete 3 express deliveries before noon",
			"type": ChallengeType.SPEED,
			"difficulty": Difficulty.HARD,
			"icon": "⚡",
			"target": 3,
			"progress_type": "express_before_noon",
			"time_limit": 12,  # Before noon
			"reward": {
				"money": 4000,
				"reputation": 12
			}
		}
	]

	# Pick random challenge based on player level/progression
	var available = challenges.filter(_is_challenge_appropriate)
	daily_challenge = available[randi() % available.size()].duplicate()

	daily_challenge.started_day = GameManager.current_day if GameManager else 0
	daily_challenge.completed = false

	# Reset progress
	challenge_progress[daily_challenge.id] = 0.0

	emit_signal("daily_challenge_available", daily_challenge)

func _generate_weekly_challenges() -> void:
	"""Generate 3 weekly challenges"""
	weekly_challenges.clear()

	var challenges = [
		{
			"id": "weekly_master",
			"name": "Weekly Master",
			"description": "Complete 30 deliveries this week",
			"type": ChallengeType.DELIVERY,
			"difficulty": Difficulty.MEDIUM,
			"icon": "🏆",
			"target": 30,
			"progress_type": "deliveries",
			"reward": {
				"money": 15000,
				"reputation": 25,
				"special": "truck_skin"
			}
		},
		{
			"id": "weekly_explorer",
			"name": "European Explorer",
			"description": "Deliver to 5 different cities this week",
			"type": ChallengeType.EXPLORATION,
			"difficulty": Difficulty.EASY,
			"icon": "🌍",
			"target": 5,
			"progress_type": "cities_visited",
			"reward": {
				"money": 10000,
				"reputation": 20
			}
		},
		{
			"id": "weekly_profit",
			"name": "Profit Master",
			"description": "Earn €50,000 in profit this week",
			"type": ChallengeType.BUSINESS,
			"difficulty": Difficulty.HARD,
			"icon": "💰",
			"target": 50000,
			"progress_type": "profit",
			"reward": {
				"money": 20000,
				"reputation": 30
			}
		},
		{
			"id": "weekly_fleet",
			"name": "Fleet Expansion",
			"description": "Purchase 2 new trucks this week",
			"type": ChallengeType.BUSINESS,
			"difficulty": Difficulty.MEDIUM,
			"icon": "🚛",
			"target": 2,
			"progress_type": "trucks_purchased",
			"reward": {
				"money": 10000,
				"discount": "next_truck_10%"
			}
		},
		{
			"id": "weekly_reputation",
			"name": "Reputation Builder",
			"description": "Increase reputation by 10 points this week",
			"type": ChallengeType.SOCIAL,
			"difficulty": Difficulty.MEDIUM,
			"icon": "⭐",
			"target": 10,
			"progress_type": "reputation_gain",
			"reward": {
				"money": 8000,
				"reputation": 15
			}
		},
		{
			"id": "weekly_weather",
			"name": "Storm Survivor",
			"description": "Complete 15 deliveries in bad weather",
			"type": ChallengeType.DELIVERY,
			"difficulty": Difficulty.HARD,
			"icon": "⛈️",
			"target": 15,
			"progress_type": "bad_weather_deliveries",
			"reward": {
				"money": 12000,
				"reputation": 20,
				"title": "Storm Survivor"
			}
		}
	]

	# Pick 3 random weekly challenges
	var shuffled = challenges.duplicate()
	shuffled.shuffle()

	for i in range(min(3, shuffled.size())):
		var challenge = shuffled[i].duplicate()
		challenge.started_day = GameManager.current_day if GameManager else 0
		challenge.expires_day = challenge.started_day + 7
		challenge.completed = false
		challenge_progress[challenge.id] = 0.0
		weekly_challenges.append(challenge)

		emit_signal("weekly_challenge_available", challenge)

func _is_challenge_appropriate(challenge: Dictionary) -> bool:
	"""Check if challenge is appropriate for player's current level"""
	# Basic filtering based on game state
	if not GameManager:
		return true

	match challenge.difficulty:
		Difficulty.HARD, Difficulty.EXTREME:
			# Hard challenges only after some progress
			return GameManager.current_day > 30 and GameManager.company_reputation > 50
		_:
			return true

func _on_delivery_completed(delivery: Dictionary, on_time: bool) -> void:
	# Update challenge progress
	_update_challenge_progress("deliveries", 1)

	if on_time:
		_update_challenge_progress("on_time_rate", 1)

	_update_challenge_progress("distance", delivery.total_distance)

	# Check for completion
	_check_challenge_completion()

func _update_challenge_progress(progress_type: String, value: float) -> void:
	"""Update progress for challenges tracking this metric"""

	# Daily challenge
	if not daily_challenge.is_empty() and daily_challenge.progress_type == progress_type:
		challenge_progress[daily_challenge.id] = challenge_progress.get(daily_challenge.id, 0.0) + value
		emit_signal("challenge_progress_updated", daily_challenge.id,
			challenge_progress[daily_challenge.id] / daily_challenge.target)

	# Weekly challenges
	for challenge in weekly_challenges:
		if challenge.progress_type == progress_type:
			challenge_progress[challenge.id] = challenge_progress.get(challenge.id, 0.0) + value
			emit_signal("challenge_progress_updated", challenge.id,
				challenge_progress[challenge.id] / challenge.target)

func _check_challenge_completion() -> void:
	"""Check if any challenges are completed"""

	# Check daily challenge
	if not daily_challenge.is_empty() and not daily_challenge.completed:
		if _is_challenge_complete(daily_challenge):
			_complete_challenge(daily_challenge)

	# Check weekly challenges
	for challenge in weekly_challenges:
		if not challenge.completed and _is_challenge_complete(challenge):
			_complete_challenge(challenge)

func _is_challenge_complete(challenge: Dictionary) -> bool:
	"""Check if a challenge's requirements are met"""
	var progress = challenge_progress.get(challenge.id, 0.0)
	return progress >= challenge.target

func _complete_challenge(challenge: Dictionary) -> void:
	"""Mark challenge as complete and grant rewards"""
	challenge.completed = true

	# Grant rewards
	var reward = _apply_rewards(challenge.reward)

	emit_signal("challenge_completed", challenge, reward)

	# Update streak
	if challenge.id.begins_with("daily_"):
		_update_daily_streak()

	# Visual feedback
	if has_node("/root/EnhancedAudioManager"):
		EnhancedAudioManager.play_sfx("achievement")

	if has_node("/root/VisualEffects"):
		VisualEffects.spawn_particle_effect("success", Vector2(640, 360), null)

func _apply_rewards(reward: Dictionary) -> Dictionary:
	"""Apply challenge rewards to the player"""

	if reward.has("money") and GameManager:
		GameManager.company_money += reward.money

	if reward.has("reputation") and GameManager:
		GameManager.company_reputation = min(100.0, GameManager.company_reputation + reward.reputation)

	if reward.has("title") and has_node("/root/AchievementSystem"):
		AchievementSystem.unlocked_titles.append(reward.title)

	if reward.has("special"):
		# Special rewards like skins, decorations, etc.
		pass

	return reward

func _update_daily_streak() -> void:
	"""Update the daily completion streak"""
	var current_day = GameManager.current_day if GameManager else 0

	if current_day - last_completion_day == 1:
		# Consecutive day
		daily_streak += 1
	elif current_day - last_completion_day > 1:
		# Streak broken
		daily_streak = 1

	last_completion_day = current_day

	# Streak bonus every 7 days
	if daily_streak > 0 and daily_streak % 7 == 0:
		var bonus = _calculate_streak_bonus(daily_streak)
		emit_signal("streak_bonus", daily_streak, bonus)
		_apply_rewards(bonus)

func _calculate_streak_bonus(streak: int) -> Dictionary:
	"""Calculate bonus for maintaining a streak"""
	var weeks = streak / 7
	return {
		"money": 5000 * weeks,
		"reputation": 10 * weeks,
		"title": "Consistent Performer" if weeks >= 4 else ""
	}

func _update_streak() -> void:
	"""Check and update streak status"""
	var current_day = GameManager.current_day if GameManager else 0

	if not daily_challenge.completed and current_day > daily_challenge.get("started_day", 0):
		# Didn't complete yesterday's challenge
		if daily_streak > 0 and current_day - last_completion_day > 1:
			daily_streak = 0  # Streak broken

func _check_timed_challenges() -> void:
	"""Check challenges with time limits"""
	var current_hour = GameManager.current_hour if GameManager else 12

	# Check if any timed challenges have expired
	if not daily_challenge.is_empty() and daily_challenge.has("time_limit"):
		if current_hour >= daily_challenge.time_limit and not daily_challenge.completed:
			# Challenge failed
			daily_challenge.failed = true

# Public API
func get_daily_challenge() -> Dictionary:
	return daily_challenge.duplicate()

func get_weekly_challenges() -> Array:
	return weekly_challenges.duplicate()

func get_challenge_progress(challenge_id: String) -> float:
	var challenge = _find_challenge(challenge_id)
	if challenge.is_empty():
		return 0.0

	var progress = challenge_progress.get(challenge_id, 0.0)
	return progress / challenge.target

func get_daily_streak() -> int:
	return daily_streak

func _find_challenge(challenge_id: String) -> Dictionary:
	if daily_challenge.get("id") == challenge_id:
		return daily_challenge

	for challenge in weekly_challenges:
		if challenge.id == challenge_id:
			return challenge

	return {}

func add_special_challenge(challenge: Dictionary) -> void:
	"""Add a special event challenge"""
	challenge.started_day = GameManager.current_day if GameManager else 0
	challenge.completed = false
	challenge_progress[challenge.id] = 0.0
	special_challenges.append(challenge)
