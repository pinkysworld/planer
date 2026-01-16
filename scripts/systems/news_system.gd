extends Node
## NewsSystem - Dynamic news feed with humor and world-building
## Provides context, humor, and personality to the game world

signal news_published(article: Dictionary)
signal breaking_news(article: Dictionary)
signal competitor_mentioned(competitor_name: String, article: Dictionary)

# News categories
enum NewsCategory {
	BUSINESS,
	ECONOMY,
	WEATHER,
	TECHNOLOGY,
	SCANDAL,
	HUMAN_INTEREST,
	SPORTS,
	ENTERTAINMENT
}

# News history
var published_news: Array = []
var breaking_news_queue: Array = []

# Player-related news tracking
var player_milestones_reported: Array = []

func _ready() -> void:
	if GameManager:
		GameManager.day_changed.connect(_on_day_changed)

	_connect_game_events()

func _connect_game_events() -> void:
	"""Connect to game events for reactive news"""
	if EventBus:
		EventBus.connect("delivery_completed", _on_delivery_completed)
		EventBus.connect("truck_purchased", _on_truck_purchased)

	if has_node("/root/MarketAI"):
		MarketAI.economic_event.connect(_on_economic_event)
		MarketAI.fuel_price_changed.connect(_on_fuel_price_changed)

	if has_node("/root/CompetitorAI"):
		CompetitorAI.competitor_bankrupted.connect(_on_competitor_bankrupted)
		CompetitorAI.new_competitor_entered.connect(_on_new_competitor)

func _on_day_changed(day: int) -> void:
	# Generate daily news (30% chance)
	if randf() < 0.3:
		_generate_random_news()

	# Weekly business report (every Monday)
	if day % 7 == 1:
		_generate_weekly_business_report()

func _generate_random_news() -> void:
	"""Generate a random news article"""
	var news_templates = [
		# Economy
		{
			"category": NewsCategory.ECONOMY,
			"headline": "European Economy Shows {trend} Growth",
			"body": "Economists report that the European economy is {trending} with GDP growth of {percent}% this quarter. Transport sector particularly {affected}.",
			"variables": {
				"trend": ["Strong", "Weak", "Moderate", "Unexpected"],
				"trending": ["booming", "struggling", "stabilizing", "fluctuating"],
				"percent": [2.5, 1.2, 3.8, -0.5, 4.2],
				"affected": ["benefiting", "suffering", "adapting", "thriving"]
			}
		},
		# Weather
		{
			"category": NewsCategory.WEATHER,
			"headline": "{Weather} Front Approaches Central Europe",
			"body": "Meteorologists warn of {weather_desc} conditions approaching the region. Truck drivers are advised to {advice}.",
			"variables": {
				"Weather": ["Storm", "Snow", "Heat Wave", "Fog"],
				"weather_desc": ["severe", "unusual", "dangerous", "challenging"],
				"advice": ["exercise caution", "delay travel", "prepare for delays", "check their vehicles"]
			}
		},
		# Technology
		{
			"category": NewsCategory.TECHNOLOGY,
			"headline": "Self-Driving Trucks: {position} or Fiction?",
			"body": "Industry experts {opinion} about autonomous trucks. Some say it's {timeline} years away, while others claim we're {reality}.",
			"variables": {
				"position": ["Reality", "Hype", "Future", "Revolution"],
				"opinion": ["debate", "argue", "disagree", "speculate"],
				"timeline": [5, 10, 2, 15, 20],
				"reality": ["not ready", "already here", "closer than we think", "decades away"]
			}
		},
		# Scandal
		{
			"category": NewsCategory.SCANDAL,
			"headline": "Transport Company Accused of {crime}",
			"body": "A major trucking company faces allegations of {violation}. Authorities are {action}. Industry reputation {impact}.",
			"variables": {
				"crime": ["Fraud", "Safety Violations", "Price Fixing", "Tax Evasion"],
				"violation": ["falsifying records", "ignoring regulations", "underpaying drivers", "illegal dumping"],
				"action": ["investigating", "filing charges", "monitoring the situation", "conducting raids"],
				"impact": ["suffers", "remains stable", "improves oddly", "crashes"]
			}
		},
		# Human Interest
		{
			"category": NewsCategory.HUMAN_INTEREST,
			"headline": "Truck Driver {achievement}",
			"body": "{name}, a veteran truck driver, recently {accomplishment}. The {age}-year-old driver says {quote}.",
			"variables": {
				"achievement": ["Saves Lives", "Retires After 40 Years", "Breaks Record", "Wins Award"],
				"name": ["Hans Schmidt", "Maria Rodriguez", "Jean Dupont", "Anna Kowalski"],
				"accomplishment": ["prevented a major accident", "completed their final delivery", "drove 1 million km", "received national recognition"],
				"age": [45, 62, 38, 55, 70],
				"quote": ["'It's been an honor'", "'Just doing my job'", "'I love the road'", "'Time for a new chapter'"]
			}
		},
		# Humor
		{
			"category": NewsCategory.ENTERTAINMENT,
			"headline": "Local Truck Stop Unveils {item}",
			"body": "In a surprising move, a popular truck stop has introduced {description}. Owner says '{quote}'. Truckers {reaction}.",
			"variables": {
				"item": ["Gourmet Menu", "Spa Services", "Art Gallery", "Gaming Lounge"],
				"description": ["five-star cuisine", "massage chairs", "contemporary art", "esports arena"],
				"quote": ["We're changing the industry", "Drivers deserve luxury", "Why not?", "It was time for innovation"],
				"reaction": ["are baffled", "love it", "are skeptical", "can't believe it"]
			}
		}
	]

	var template = news_templates[randi() % news_templates.size()]
	var article = _generate_article_from_template(template)

	_publish_news(article)

func _generate_article_from_template(template: Dictionary) -> Dictionary:
	"""Generate an article by filling template variables"""
	var headline = template.headline
	var body = template.body

	# Replace variables
	for var_name in template.variables.keys():
		var options = template.variables[var_name]
		var value = options[randi() % options.size()]

		headline = headline.replace("{" + var_name + "}", str(value))
		body = body.replace("{" + var_name + "}", str(value))

	return {
		"category": template.category,
		"headline": headline,
		"body": body,
		"date": GameManager.current_day if GameManager else 1,
		"breaking": false
	}

func _generate_weekly_business_report() -> void:
	"""Generate weekly business report"""
	var article = {
		"category": NewsCategory.BUSINESS,
		"headline": "Weekly Transport Industry Report",
		"body": _generate_business_report_body(),
		"date": GameManager.current_day if GameManager else 1,
		"breaking": false
	}

	_publish_news(article)

func _generate_business_report_body() -> String:
	"""Generate detailed business report text"""
	var report = "This week in European transport:\n\n"

	# Fuel prices
	if GameManager:
		report += "• Diesel: €%.2f/L\n" % GameManager.fuel_price_diesel

	# Market conditions
	if has_node("/root/MarketAI"):
		report += "• Economic state: %s\n" % MarketAI.get_economic_state()
		report += "• Market volatility: %s\n" % ("High" if MarketAI.market_volatility > 0.7 else "Normal")

	# Competition
	if has_node("/root/CompetitorAI"):
		report += "• Active companies: %d\n" % CompetitorAI.get_competitor_count()
		report += "• Competition level: %s\n" % CompetitorAI.get_market_competition_level()

	report += "\nAnalysts remain %s about the sector's outlook." % (
		["optimistic", "cautious", "concerned", "bullish"][randi() % 4]
	)

	return report

# === REACTIVE NEWS (based on game events) ===

func _on_delivery_completed(delivery: Dictionary, on_time: bool) -> void:
	# Major milestones get news coverage
	if not GameManager:
		return

	var total = GameManager.total_deliveries_completed

	# Every 100 deliveries
	if total % 100 == 0 and total > 0 and total not in player_milestones_reported:
		player_milestones_reported.append(total)

		var article = {
			"category": NewsCategory.BUSINESS,
			"headline": "Local Company Reaches %d Delivery Milestone" % total,
			"body": "A rising transport company has completed their %dth delivery, showing impressive growth in the competitive European market. Industry watchers are taking notice." % total,
			"date": GameManager.current_day,
			"breaking": false,
			"player_related": true
		}

		_publish_news(article)

func _on_truck_purchased(truck: Dictionary) -> void:
	# Large fleet expansion
	if not GameManager:
		return

	if GameManager.trucks.size() >= 20 and "fleet_20" not in player_milestones_reported:
		player_milestones_reported.append("fleet_20")

		var article = {
			"category": NewsCategory.BUSINESS,
			"headline": "Growing Company Expands Fleet to 20 Vehicles",
			"body": "A local transport company continues its expansion with the purchase of its 20th truck. The company is quickly becoming a major player in the regional market.",
			"date": GameManager.current_day,
			"breaking": false,
			"player_related": true
		}

		_publish_news(article)

func _on_economic_event(event_type: String, description: String, impact: Dictionary) -> void:
	"""Economic events make breaking news"""
	var article = {
		"category": NewsCategory.ECONOMY,
		"headline": "Breaking: %s" % _get_event_headline(event_type),
		"body": description + " Industry experts predict significant impact on transport costs.",
		"date": GameManager.current_day if GameManager else 1,
		"breaking": true
	}

	_publish_breaking_news(article)

func _get_event_headline(event_type: String) -> String:
	match event_type:
		"fuel_crisis":
			return "Fuel Supply Crisis Hits Europe"
		"trade_deal":
			return "New Trade Agreement Signed"
		"economic_stimulus":
			return "Government Announces Stimulus Package"
		"construction_boom":
			return "Construction Boom Drives Demand"
		_:
			return "Major Economic Event"

func _on_fuel_price_changed(fuel_type: String, new_price: float, change_percent: float) -> void:
	"""Significant fuel price changes make news"""
	if abs(change_percent) > 5.0:  # More than 5% change
		var direction = "Surge" if change_percent > 0 else "Drop"

		var article = {
			"category": NewsCategory.ECONOMY,
			"headline": "%s Prices %s by %.1f%%" % [fuel_type.capitalize(), direction, abs(change_percent)],
			"body": "%s prices have %s significantly, affecting transport companies across Europe. The change is attributed to %s." % [
				fuel_type.capitalize(),
				"increased" if change_percent > 0 else "decreased",
				["market conditions", "supply changes", "geopolitical factors", "seasonal demand"][randi() % 4]
			],
			"date": GameManager.current_day if GameManager else 1,
			"breaking": change_percent > 10.0
		}

		if article.breaking:
			_publish_breaking_news(article)
		else:
			_publish_news(article)

func _on_competitor_bankrupted(competitor_name: String) -> void:
	"""Competitor bankruptcy makes news"""
	var article = {
		"category": NewsCategory.BUSINESS,
		"headline": "%s Declares Bankruptcy" % competitor_name,
		"body": "Transport company %s has filed for bankruptcy after struggling with mounting debts and fierce competition. Their fleet of trucks will be auctioned off." % competitor_name,
		"date": GameManager.current_day if GameManager else 1,
		"breaking": true
	}

	emit_signal("competitor_mentioned", competitor_name, article)
	_publish_breaking_news(article)

func _on_new_competitor(competitor: Dictionary) -> void:
	"""New competitor entry makes news"""
	var article = {
		"category": NewsCategory.BUSINESS,
		"headline": "New Transport Company '%s' Enters Market" % competitor.name,
		"body": "A new player has entered the competitive European transport market. %s promises to bring innovation and quality service to the industry." % competitor.name,
		"date": GameManager.current_day if GameManager else 1,
		"breaking": false
	}

	emit_signal("competitor_mentioned", competitor.name, article)
	_publish_news(article)

# === PUBLISHING ===

func _publish_news(article: Dictionary) -> void:
	"""Publish a regular news article"""
	published_news.append(article)
	emit_signal("news_published", article)

	# Keep only last 50 articles
	if published_news.size() > 50:
		published_news.pop_front()

func _publish_breaking_news(article: Dictionary) -> void:
	"""Publish breaking news (higher priority)"""
	article.breaking = true
	breaking_news_queue.append(article)
	published_news.append(article)

	emit_signal("breaking_news", article)

	# Show notification
	print("\n🚨 BREAKING NEWS: ", article.headline)

# === PUBLIC API ===

func get_latest_news(count: int = 10) -> Array:
	"""Get the latest news articles"""
	var start = max(0, published_news.size() - count)
	return published_news.slice(start)

func get_breaking_news() -> Array:
	"""Get current breaking news"""
	return breaking_news_queue.duplicate()

func clear_breaking_news() -> void:
	"""Clear breaking news queue (after player has seen them)"""
	breaking_news_queue.clear()

func get_news_by_category(category: NewsCategory, count: int = 5) -> Array:
	"""Get news filtered by category"""
	var filtered = published_news.filter(func(article): return article.category == category)
	var start = max(0, filtered.size() - count)
	return filtered.slice(start)

func search_news(keyword: String) -> Array:
	"""Search news articles for keyword"""
	return published_news.filter(func(article):
		return keyword.to_lower() in article.headline.to_lower() or keyword.to_lower() in article.body.to_lower()
	)

func generate_custom_news(headline: String, body: String, category: NewsCategory = NewsCategory.BUSINESS) -> void:
	"""Manually generate a custom news article"""
	var article = {
		"category": category,
		"headline": headline,
		"body": body,
		"date": GameManager.current_day if GameManager else 1,
		"breaking": false
	}

	_publish_news(article)
