extends Node
## StoryEventSystem - Random narrative events with choices and consequences
## Adds depth, humor, and meaningful decisions to gameplay

signal story_event_triggered(event: Dictionary)
signal choice_made(event_id: String, choice: String, consequence: Dictionary)
signal story_arc_completed(arc_name: String)

# Active story arcs
var active_story_arcs: Array = []
var completed_story_arcs: Array = []

# Event cooldown
var last_event_day: int = 0
var min_days_between_events: int = 3

# Story event library
var story_events: Array = []

func _ready() -> void:
	_initialize_story_events()

	if GameManager:
		GameManager.day_changed.connect(_on_day_changed)

func _initialize_story_events() -> void:
	# === BUSINESS EVENTS ===

	story_events.append({
		"id": "mystery_benefactor",
		"title": "Mystery Benefactor",
		"description": "A wealthy businessman offers to invest €50,000 in your company, but wants 20% of future profits for 1 year. His background is questionable.",
		"type": "business",
		"icon": "🎩",
		"choices": [
			{
				"text": "Accept the investment",
				"consequence": {
					"money": 50000,
					"future_profit_cut": 0.20,
					"duration": 365,
					"reputation": -5,
					"story_arc": "mystery_investor"
				}
			},
			{
				"text": "Politely decline",
				"consequence": {
					"reputation": 5,
					"random_event": "honest_reputation"
				}
			},
			{
				"text": "Investigate him first",
				"consequence": {
					"money": -2000,
					"delayed_event": "investor_revealed"
				}
			}
		],
		"requirements": {"min_reputation": 30}
	})

	story_events.append({
		"id": "rival_sabotage",
		"title": "Sabotage Suspicion",
		"description": "You discover one of your competitors may have been sabotaging your trucks. You have evidence but it's not conclusive.",
		"type": "drama",
		"icon": "🔧",
		"choices": [
			{
				"text": "Confront them publicly",
				"consequence": {
					"reputation": -10,
					"competitor_reputation": -20,
					"rival_relationship": -50
				}
			},
			{
				"text": "Report to authorities",
				"consequence": {
					"money": -5000,
					"delay": 14,
					"possible_reward": 25000
				}
			},
			{
				"text": "Improve your security quietly",
				"consequence": {
					"money": -3000,
					"sabotage_protection": true
				}
			}
		]
	})

	# === EMPLOYEE EVENTS ===

	story_events.append({
		"id": "driver_love_story",
		"title": "Office Romance",
		"description": "Two of your employees have fallen in love. One wants to quit to avoid workplace complications, but they're both excellent workers.",
		"type": "employee",
		"icon": "💕",
		"choices": [
			{
				"text": "Allow the relationship",
				"consequence": {
					"morale": 10,
					"productivity": -5,
					"story_arc": "office_romance"
				}
			},
			{
				"text": "Implement strict no-dating policy",
				"consequence": {
					"morale": -15,
					"employee_quit": true
				}
			},
			{
				"text": "Separate their schedules",
				"consequence": {
					"morale": 5,
					"logistics_complexity": 0.1
				}
			}
		],
		"requirements": {"min_employees": 5}
	})

	story_events.append({
		"id": "driver_lottery",
		"title": "Lottery Winner",
		"description": "Your best driver just won €100,000 in the lottery! They're considering quitting to start their own company.",
		"type": "employee",
		"icon": "🎰",
		"choices": [
			{
				"text": "Offer them a partnership",
				"consequence": {
					"profit_share": 0.10,
					"employee_loyalty": 100,
					"story_arc": "employee_partner"
				}
			},
			{
				"text": "Wish them well and let them go",
				"consequence": {
					"lose_employee": true,
					"reputation": 10,
					"possible_rival": true
				}
			},
			{
				"text": "Offer a huge raise to keep them",
				"consequence": {
					"money": -20000,
					"employee_salary": 1.5,
					"employee_loyalty": 50
				}
			}
		]
	})

	# === CUSTOMER EVENTS ===

	story_events.append({
		"id": "celebrity_client",
		"title": "Celebrity Endorsement",
		"description": "A famous influencer wants you to transport their merchandise for free in exchange for social media promotion.",
		"type": "marketing",
		"icon": "⭐",
		"choices": [
			{
				"text": "Accept the free promotion",
				"consequence": {
					"revenue_loss": 5000,
					"reputation": 20,
					"new_contracts": 10,
					"story_arc": "celebrity_partnership"
				}
			},
			{
				"text": "Offer a discount, not free",
				"consequence": {
					"revenue_loss": 2500,
					"reputation": 10,
					"new_contracts": 5
				}
			},
			{
				"text": "Decline politely",
				"consequence": {
					"reputation": -5
				}
			}
		],
		"requirements": {"min_reputation": 60}
	})

	story_events.append({
		"id": "urgent_medical",
		"title": "Medical Emergency",
		"description": "A hospital desperately needs medical supplies delivered immediately. They can't pay full price but lives are at stake.",
		"type": "moral",
		"icon": "🏥",
		"choices": [
			{
				"text": "Deliver for free (humanitarian)",
				"consequence": {
					"money": -2000,
					"reputation": 25,
					"karma": 50,
					"achievement": "humanitarian"
				}
			},
			{
				"text": "Deliver at cost price",
				"consequence": {
					"money": 0,
					"reputation": 15,
					"karma": 25
				}
			},
			{
				"text": "Business is business",
				"consequence": {
					"money": 5000,
					"reputation": -20,
					"karma": -30
				}
			}
		]
	})

	# === RANDOM FUN EVENTS ===

	story_events.append({
		"id": "truck_food_truck",
		"title": "The Food Truck Proposal",
		"description": "A chef offers to rent one of your idle trucks to convert into a food truck. They'll pay €500/month, but the truck won't be available for deliveries.",
		"type": "quirky",
		"icon": "🍕",
		"choices": [
			{
				"text": "Rent out the truck",
				"consequence": {
					"passive_income": 500,
					"truck_unavailable": true,
					"story_arc": "food_truck_empire"
				}
			},
			{
				"text": "Counter with profit sharing",
				"consequence": {
					"passive_income": 300,
					"profit_share": 0.15,
					"truck_unavailable": true
				}
			},
			{
				"text": "Keep the truck",
				"consequence": {}
			}
		],
		"requirements": {"idle_trucks": 1}
	})

	story_events.append({
		"id": "ghost_truck",
		"title": "The Ghost Truck",
		"description": "Drivers report seeing a \"ghost truck\" on a foggy mountain route. Superstitious employees are refusing to take that route.",
		"type": "mystery",
		"icon": "👻",
		"choices": [
			{
				"text": "Investigate the mystery",
				"consequence": {
					"money": -1000,
					"morale": 10,
					"reveal_easter_egg": "ghost_story"
				}
			},
			{
				"text": "Offer bonus pay for that route",
				"consequence": {
					"route_cost": 1.3,
					"morale": 0
				}
			},
			{
				"text": "Dismiss it as nonsense",
				"consequence": {
					"morale": -10,
					"employee_quit_chance": 0.2
				}
			}
		]
	})

	# === COMPETITOR EVENTS ===

	story_events.append({
		"id": "competitor_merge",
		"title": "Merger Proposal",
		"description": "Your biggest competitor proposes a merger. Together you'd dominate the market, but you'd lose some autonomy.",
		"type": "business",
		"icon": "🤝",
		"choices": [
			{
				"text": "Accept the merger",
				"consequence": {
					"money": 100000,
					"market_share": 0.4,
					"autonomy": -30,
					"story_arc": "merged_empire"
				}
			},
			{
				"text": "Counter with acquisition offer",
				"consequence": {
					"money": -200000,
					"market_share": 0.6,
					"competitor_removed": true
				}
			},
			{
				"text": "Stay independent",
				"consequence": {
					"reputation": 5,
					"rivalry_intensifies": true
				}
			}
		],
		"requirements": {"min_reputation": 70, "competitors_active": 2}
	})

	# === TECH/INNOVATION EVENTS ===

	story_events.append({
		"id": "ai_pilot_program",
		"title": "AI Pilot Program",
		"description": "A tech startup wants to test their autonomous truck AI with your company. Free trucks, but unknown safety record.",
		"type": "innovation",
		"icon": "🤖",
		"choices": [
			{
				"text": "Join the pilot program",
				"consequence": {
					"autonomous_trucks": 2,
					"reputation": 15,
					"risk": 0.3,
					"story_arc": "autonomous_future"
				}
			},
			{
				"text": "Wait for proven technology",
				"consequence": {
					"delayed_advantage": true
				}
			},
			{
				"text": "Develop your own AI",
				"consequence": {
					"money": -50000,
					"research_boost": 0.5
				}
			}
		],
		"requirements": {"min_reputation": 65}
	})

	# === WEATHER/DISASTER EVENTS ===

	story_events.append({
		"id": "flood_rescue",
		"title": "Flood Rescue Mission",
		"description": "Severe flooding has cut off a town. The government asks if you can help with emergency supplies. It's dangerous but heroic.",
		"type": "crisis",
		"icon": "🌊",
		"choices": [
			{
				"text": "Volunteer immediately",
				"consequence": {
					"money": -5000,
					"reputation": 30,
					"government_contract": true,
					"risk": 0.4,
					"achievement": "hero"
				}
			},
			{
				"text": "Help for payment",
				"consequence": {
					"money": 10000,
					"reputation": 10
				}
			},
			{
				"text": "Too dangerous, decline",
				"consequence": {
					"reputation": -10
				}
			}
		]
	})

func _on_day_changed(day: int) -> void:
	# Check if enough time has passed since last event
	if day - last_event_day < min_days_between_events:
		return

	# Random chance to trigger event (10% per day)
	if randf() < 0.10:
		_trigger_random_event()

func _trigger_random_event() -> void:
	# Filter events based on requirements
	var available_events = story_events.filter(_check_event_requirements)

	if available_events.is_empty():
		return

	# Pick random event
	var event = available_events[randi() % available_events.size()]

	last_event_day = GameManager.current_day if GameManager else 0

	emit_signal("story_event_triggered", event)

	# Would show UI for player to make choice
	_show_event_dialog(event)

func _check_event_requirements(event: Dictionary) -> bool:
	if not event.has("requirements"):
		return true

	var req = event.requirements

	# Check various requirements
	if req.has("min_reputation"):
		if not GameManager or GameManager.company_reputation < req.min_reputation:
			return false

	if req.has("min_employees"):
		if not GameManager or GameManager.employees.size() < req.min_employees:
			return false

	if req.has("idle_trucks"):
		if not GameManager:
			return false
		var idle = GameManager.trucks.filter(func(t): return t.is_available).size()
		if idle < req.idle_trucks:
			return false

	if req.has("competitors_active"):
		if not has_node("/root/CompetitorAI"):
			return false
		if CompetitorAI.get_competitor_count() < req.competitors_active:
			return false

	return true

func _show_event_dialog(event: Dictionary) -> void:
	# This would create a UI dialog
	# For now, just log it
	print("\n📖 STORY EVENT: ", event.title)
	print("   ", event.description)
	print("   Choices:")
	for i in range(event.choices.size()):
		print("   ", i + 1, ". ", event.choices[i].text)

func make_choice(event_id: String, choice_index: int) -> void:
	"""Player makes a choice for an event"""
	var event = null
	for e in story_events:
		if e.id == event_id:
			event = e
			break

	if not event or choice_index < 0 or choice_index >= event.choices.size():
		return

	var choice = event.choices[choice_index]
	var consequence = choice.consequence

	# Apply consequences
	_apply_consequences(consequence, event)

	emit_signal("choice_made", event_id, choice.text, consequence)

	# Check for story arcs
	if consequence.has("story_arc"):
		_start_story_arc(consequence.story_arc)

func _apply_consequences(consequence: Dictionary, event: Dictionary) -> void:
	"""Apply the consequences of a player's choice"""

	if consequence.has("money"):
		GameManager.company_money += consequence.money

	if consequence.has("reputation"):
		GameManager.company_reputation = clamp(
			GameManager.company_reputation + consequence.reputation,
			0.0, 100.0
		)

	if consequence.has("morale"):
		for employee in GameManager.employees:
			if has_node("/root/EmployeeAI"):
				EmployeeAI._change_employee_morale(employee, consequence.morale, "story_event")

	if consequence.has("new_contracts"):
		for i in range(consequence.new_contracts):
			var contract = GameManager._generate_contract()
			GameManager.contracts.append(contract)

	if consequence.has("achievement"):
		if has_node("/root/AchievementSystem"):
			# Would trigger special achievement
			pass

	# Many more consequences...

func _start_story_arc(arc_name: String) -> void:
	"""Start a multi-part story arc"""
	active_story_arcs.append({
		"name": arc_name,
		"started_day": GameManager.current_day if GameManager else 0,
		"progress": 0
	})

func get_active_story_arcs() -> Array:
	return active_story_arcs.duplicate()

func trigger_specific_event(event_id: String) -> void:
	"""Manually trigger a specific event (for testing or story progression)"""
	for event in story_events:
		if event.id == event_id:
			emit_signal("story_event_triggered", event)
			_show_event_dialog(event)
			return
