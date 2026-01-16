extends Node
## AchievementSystem - Comprehensive achievement and progression system
## Provides goals, rewards, unlockables, and progression tracking for fun gameplay

signal achievement_unlocked(achievement: Dictionary)
signal progress_updated(achievement_id: String, progress: float)
signal milestone_reached(milestone: String, reward: Dictionary)
signal title_unlocked(title: String)

# Achievement categories
enum AchievementCategory {
	BUSINESS,
	DELIVERY,
	FLEET,
	EMPLOYEES,
	FINANCIAL,
	EXPLORATION,
	MASTERY,
	HIDDEN,
	SEASONAL
}

# Achievement data
var achievements: Dictionary = {}
var unlocked_achievements: Array = []
var achievement_progress: Dictionary = {}

# Unlockable content
var unlocked_titles: Array = []
var unlocked_truck_skins: Array = []
var unlocked_office_decorations: Array = []
var unlocked_cheats: Array = []

# Statistics tracking
var stats: Dictionary = {
	"deliveries_completed": 0,
	"on_time_deliveries": 0,
	"perfect_deliveries": 0,  # No damage, on time
	"distance_traveled": 0.0,
	"money_earned": 0.0,
	"trucks_purchased": 0,
	"employees_hired": 0,
	"contracts_completed": 0,
	"cities_visited": [],
	"consecutive_successes": 0,
	"max_streak": 0,
	"bankruptcies_avoided": 0,
	"competitors_defeated": 0
}

func _ready() -> void:
	_initialize_achievements()
	_connect_signals()

func _initialize_achievements() -> void:
	# STARTER ACHIEVEMENTS (Easy, for new players)
	_add_achievement("first_delivery", {
		"name": "First Steps",
		"description": "Complete your first delivery",
		"category": AchievementCategory.DELIVERY,
		"icon": "🚚",
		"reward_type": "money",
		"reward_value": 1000.0,
		"hidden": false,
		"condition": {"type": "deliveries", "target": 1}
	})

	_add_achievement("first_truck", {
		"name": "Fleet Expansion",
		"description": "Purchase your first truck",
		"category": AchievementCategory.FLEET,
		"icon": "🏪",
		"reward_type": "title",
		"reward_value": "Fleet Owner",
		"hidden": false,
		"condition": {"type": "trucks_purchased", "target": 1}
	})

	_add_achievement("first_employee", {
		"name": "Team Builder",
		"description": "Hire your first employee",
		"category": AchievementCategory.EMPLOYEES,
		"icon": "👷",
		"reward_type": "reputation",
		"reward_value": 5.0,
		"hidden": false,
		"condition": {"type": "employees_hired", "target": 1}
	})

	# DELIVERY ACHIEVEMENTS
	_add_achievement("delivery_master", {
		"name": "Delivery Master",
		"description": "Complete 100 deliveries",
		"category": AchievementCategory.DELIVERY,
		"icon": "📦",
		"reward_type": "money",
		"reward_value": 10000.0,
		"hidden": false,
		"condition": {"type": "deliveries", "target": 100}
	})

	_add_achievement("perfect_streak", {
		"name": "Perfect Streak",
		"description": "Complete 10 deliveries in a row on time",
		"category": AchievementCategory.DELIVERY,
		"icon": "⭐",
		"reward_type": "title",
		"reward_value": "Perfectionist",
		"hidden": false,
		"condition": {"type": "consecutive_successes", "target": 10}
	})

	_add_achievement("speed_demon", {
		"name": "Speed Demon",
		"description": "Complete 50 express deliveries",
		"category": AchievementCategory.DELIVERY,
		"icon": "⚡",
		"reward_type": "truck_skin",
		"reward_value": "lightning_stripes",
		"hidden": false,
		"condition": {"type": "express_deliveries", "target": 50}
	})

	# BUSINESS ACHIEVEMENTS
	_add_achievement("millionaire", {
		"name": "Millionaire",
		"description": "Earn €1,000,000 total",
		"category": AchievementCategory.FINANCIAL,
		"icon": "💰",
		"reward_type": "title",
		"reward_value": "Millionaire",
		"hidden": false,
		"condition": {"type": "money_earned", "target": 1000000.0}
	})

	_add_achievement("debt_free", {
		"name": "Debt Free",
		"description": "Pay off €100,000 in loans",
		"category": AchievementCategory.FINANCIAL,
		"icon": "💳",
		"reward_type": "money",
		"reward_value": 5000.0,
		"hidden": false,
		"condition": {"type": "debt_paid", "target": 100000.0}
	})

	_add_achievement("empire_builder", {
		"name": "Empire Builder",
		"description": "Own 20 trucks",
		"category": AchievementCategory.FLEET,
		"icon": "🏭",
		"reward_type": "office_decoration",
		"reward_value": "golden_truck_model",
		"hidden": false,
		"condition": {"type": "trucks_owned", "target": 20}
	})

	# EXPLORATION ACHIEVEMENTS
	_add_achievement("european_traveler", {
		"name": "European Traveler",
		"description": "Visit 10 different cities",
		"category": AchievementCategory.EXPLORATION,
		"icon": "🌍",
		"reward_type": "reputation",
		"reward_value": 10.0,
		"hidden": false,
		"condition": {"type": "cities_visited", "target": 10}
	})

	_add_achievement("long_hauler", {
		"name": "Long Hauler",
		"description": "Travel 50,000 km total",
		"category": AchievementCategory.EXPLORATION,
		"icon": "🛣️",
		"reward_type": "title",
		"reward_value": "Road Warrior",
		"hidden": false,
		"condition": {"type": "distance", "target": 50000.0}
	})

	# MASTERY ACHIEVEMENTS
	_add_achievement("five_star_company", {
		"name": "Five Star Company",
		"description": "Reach 95% reputation",
		"category": AchievementCategory.MASTERY,
		"icon": "⭐",
		"reward_type": "cheat",
		"reward_value": "instant_delivery",
		"hidden": false,
		"condition": {"type": "reputation", "target": 95.0}
	})

	_add_achievement("market_dominator", {
		"name": "Market Dominator",
		"description": "Achieve 60% market share",
		"category": AchievementCategory.MASTERY,
		"icon": "👑",
		"reward_type": "title",
		"reward_value": "Industry Leader",
		"hidden": false,
		"condition": {"type": "market_share", "target": 60.0}
	})

	# HIDDEN/FUN ACHIEVEMENTS
	_add_achievement("night_owl", {
		"name": "Night Owl",
		"description": "Complete 20 deliveries between midnight and 5am",
		"category": AchievementCategory.HIDDEN,
		"icon": "🦉",
		"reward_type": "truck_skin",
		"reward_value": "stealth_black",
		"hidden": true,
		"condition": {"type": "night_deliveries", "target": 20}
	})

	_add_achievement("coffee_addict", {
		"name": "Coffee Addict",
		"description": "Work 100 days straight without going home",
		"category": AchievementCategory.HIDDEN,
		"icon": "☕",
		"reward_type": "title",
		"reward_value": "Workaholic",
		"hidden": true,
		"condition": {"type": "consecutive_work_days", "target": 100}
	})

	_add_achievement("lucky_thirteen", {
		"name": "Lucky Thirteen",
		"description": "Complete exactly 13 deliveries on Friday the 13th",
		"category": AchievementCategory.HIDDEN,
		"icon": "🍀",
		"reward_type": "money",
		"reward_value": 13000.0,
		"hidden": true,
		"condition": {"type": "friday_13th_deliveries", "target": 13}
	})

	_add_achievement("rival_crusher", {
		"name": "Rival Crusher",
		"description": "Drive 3 competitors to bankruptcy",
		"category": AchievementCategory.MASTERY,
		"icon": "💥",
		"reward_type": "title",
		"reward_value": "Ruthless",
		"hidden": true,
		"condition": {"type": "competitors_defeated", "target": 3}
	})

	# SEASONAL/EVENT ACHIEVEMENTS
	_add_achievement("winter_warrior", {
		"name": "Winter Warrior",
		"description": "Complete 50 deliveries in snow/ice conditions",
		"category": AchievementCategory.SEASONAL,
		"icon": "❄️",
		"reward_type": "truck_skin",
		"reward_value": "winter_camo",
		"hidden": false,
		"condition": {"type": "winter_deliveries", "target": 50}
	})

	_add_achievement("storm_chaser", {
		"name": "Storm Chaser",
		"description": "Complete 10 deliveries during storms",
		"category": AchievementCategory.SEASONAL,
		"icon": "⛈️",
		"reward_type": "reputation",
		"reward_value": 15.0,
		"hidden": false,
		"condition": {"type": "storm_deliveries", "target": 10}
	})

func _add_achievement(id: String, data: Dictionary) -> void:
	achievements[id] = data
	achievement_progress[id] = 0.0

func _connect_signals() -> void:
	if GameManager:
		GameManager.day_changed.connect(_on_day_changed)

	if EventBus:
		EventBus.connect("delivery_completed", _on_delivery_completed)
		EventBus.connect("truck_purchased", _on_truck_purchased)
		EventBus.connect("employee_hired", _on_employee_hired)
		EventBus.connect("contract_accepted", _on_contract_accepted)

	if has_node("/root/CompetitorAI"):
		CompetitorAI.competitor_bankrupted.connect(_on_competitor_bankrupted)

func _on_day_changed(day: int) -> void:
	_check_achievements()

func _on_delivery_completed(delivery: Dictionary, on_time: bool) -> void:
	stats.deliveries_completed += 1
	stats.distance_traveled += delivery.total_distance

	if on_time:
		stats.on_time_deliveries += 1
		stats.consecutive_successes += 1
		stats.max_streak = max(stats.max_streak, stats.consecutive_successes)
	else:
		stats.consecutive_successes = 0

	# Track city visits
	if delivery.destination not in stats.cities_visited:
		stats.cities_visited.append(delivery.destination)

	# Check for night delivery
	var hour = GameManager.current_hour if GameManager else 12
	if hour >= 0 and hour < 5:
		stats["night_deliveries"] = stats.get("night_deliveries", 0) + 1

	# Check for weather conditions
	if has_node("/root/RouteAI"):
		var weather = RouteAI.get_weather_for_region("Central Europe")
		if weather.condition in ["snow", "ice"]:
			stats["winter_deliveries"] = stats.get("winter_deliveries", 0) + 1
		elif weather.condition == "storm":
			stats["storm_deliveries"] = stats.get("storm_deliveries", 0) + 1

	_check_achievements()

func _on_truck_purchased(truck: Dictionary) -> void:
	stats.trucks_purchased += 1
	_check_achievements()

func _on_employee_hired(employee: Dictionary) -> void:
	stats.employees_hired += 1
	_check_achievements()

func _on_contract_accepted(contract: Dictionary) -> void:
	if contract.urgency in ["express", "urgent"]:
		stats["express_deliveries"] = stats.get("express_deliveries", 0) + 1

func _on_competitor_bankrupted(competitor_name: String) -> void:
	stats.competitors_defeated += 1
	_check_achievements()

func _check_achievements() -> void:
	for achievement_id in achievements.keys():
		if achievement_id in unlocked_achievements:
			continue

		var achievement = achievements[achievement_id]
		var condition = achievement.condition

		var progress = _calculate_progress(condition)
		achievement_progress[achievement_id] = progress

		if progress >= 1.0:
			_unlock_achievement(achievement_id)

		emit_signal("progress_updated", achievement_id, progress)

func _calculate_progress(condition: Dictionary) -> float:
	var type = condition.type
	var target = condition.target

	match type:
		"deliveries":
			return float(stats.deliveries_completed) / target
		"trucks_purchased":
			return float(stats.trucks_purchased) / target
		"employees_hired":
			return float(stats.employees_hired) / target
		"money_earned":
			return float(stats.money_earned) / target
		"distance":
			return stats.distance_traveled / target
		"reputation":
			if GameManager:
				return GameManager.company_reputation / target
		"market_share":
			if has_node("/root/CompetitorAI"):
				return CompetitorAI.get_player_market_share() / target
		"consecutive_successes":
			return float(stats.consecutive_successes) / target
		"cities_visited":
			return float(stats.cities_visited.size()) / target
		"trucks_owned":
			if GameManager:
				return float(GameManager.trucks.size()) / target
		"competitors_defeated":
			return float(stats.competitors_defeated) / target
		_:
			# Special stats
			return float(stats.get(type, 0)) / target

	return 0.0

func _unlock_achievement(achievement_id: String) -> void:
	if achievement_id in unlocked_achievements:
		return

	unlocked_achievements.append(achievement_id)
	var achievement = achievements[achievement_id]

	# Apply reward
	var reward = _apply_reward(achievement)

	# Notify
	emit_signal("achievement_unlocked", achievement)

	# Visual/audio feedback
	if has_node("/root/EnhancedAudioManager"):
		EnhancedAudioManager.play_sfx("achievement")
	if has_node("/root/VisualEffects"):
		VisualEffects.spawn_particle_effect("sparkle", Vector2(640, 360), null)

	# Show notification with achievement details
	_show_achievement_notification(achievement, reward)

func _apply_reward(achievement: Dictionary) -> Dictionary:
	var reward = {
		"type": achievement.reward_type,
		"value": achievement.reward_value
	}

	match achievement.reward_type:
		"money":
			if GameManager:
				GameManager.company_money += achievement.reward_value
		"reputation":
			if GameManager:
				GameManager.company_reputation = min(100.0, GameManager.company_reputation + achievement.reward_value)
		"title":
			unlocked_titles.append(achievement.reward_value)
			emit_signal("title_unlocked", achievement.reward_value)
		"truck_skin":
			unlocked_truck_skins.append(achievement.reward_value)
		"office_decoration":
			unlocked_office_decorations.append(achievement.reward_value)
		"cheat":
			unlocked_cheats.append(achievement.reward_value)

	return reward

func _show_achievement_notification(achievement: Dictionary, reward: Dictionary) -> void:
	var message = achievement.description + "\nReward: " + _format_reward(reward)
	print("🏆 Achievement Unlocked: " + achievement.name + " " + achievement.icon)

func _format_reward(reward: Dictionary) -> String:
	match reward.type:
		"money":
			return "€" + str(reward.value)
		"reputation":
			return "+" + str(reward.value) + " Reputation"
		"title":
			return "Title: " + reward.value
		"truck_skin":
			return "Truck Skin: " + reward.value
		"office_decoration":
			return "Decoration: " + reward.value
		"cheat":
			return "Unlocked: " + reward.value
	return ""

# Public API
func get_unlocked_achievements() -> Array:
	return unlocked_achievements.duplicate()

func get_achievement_progress(achievement_id: String) -> float:
	return achievement_progress.get(achievement_id, 0.0)

func get_achievements_by_category(category: AchievementCategory) -> Array:
	var result = []
	for id in achievements.keys():
		if achievements[id].category == category:
			var ach = achievements[id].duplicate()
			ach.id = id
			ach.unlocked = id in unlocked_achievements
			ach.progress = achievement_progress.get(id, 0.0)
			result.append(ach)
	return result

func get_completion_percentage() -> float:
	if achievements.size() == 0:
		return 0.0
	return float(unlocked_achievements.size()) / float(achievements.size()) * 100.0

func get_unlocked_titles() -> Array:
	return unlocked_titles.duplicate()

func get_unlocked_truck_skins() -> Array:
	return unlocked_truck_skins.duplicate()

func get_stats() -> Dictionary:
	return stats.duplicate()

func is_cheat_unlocked(cheat_name: String) -> bool:
	return cheat_name in unlocked_cheats
