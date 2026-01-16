extends Node
## FamilyLifeSystem - Home and family management inspired by Planer series
## Balance work and private life, keep family happy, manage home

signal family_happiness_changed(happiness: float)
signal family_event(event_type: String, description: String)
signal relationship_milestone(milestone: String)
signal vacation_needed(stress_level: float)
signal retirement_ready()

# Family members
var family_members: Dictionary = {
	"spouse": {
		"name": "Maria",
		"happiness": 75.0,
		"relationship": 80.0,
		"wishes": [],
		"last_gift_day": 0
	},
	"child1": {
		"name": "Thomas",
		"age": 8,
		"happiness": 80.0,
		"needs_attention": false,
		"school_performance": 75.0
	},
	"child2": {
		"name": "Anna",
		"age": 5,
		"happiness": 85.0,
		"needs_attention": false,
		"school_performance": 0.0  # Too young
	}
}

# Player stats
var player_stress: float = 20.0
var player_health: float = 90.0
var work_life_balance: float = 50.0  # 0=all work, 100=all life
var days_without_home: int = 0
var vacation_days_taken: int = 0
var retirement_savings: float = 0.0

# Home stats
var home_owned: bool = false
var home_value: float = 0.0
var home_quality: int = 2  # 1-5 stars
var home_happiness_bonus: float = 0.0

# Lifestyle items owned
var luxury_items: Array = []

# Life milestones
var milestones_achieved: Array = []

# Random family events
var last_family_event_day: int = 0

func _ready() -> void:
	if GameManager:
		GameManager.day_changed.connect(_on_day_changed)

func _on_day_changed(day: int) -> void:
	_update_family_happiness()
	_update_player_stress()
	_check_family_events()
	_check_relationship_status()

	# Track days without going home
	# This would be set to 0 when player goes home
	days_without_home += 1

	if days_without_home > 7:
		emit_signal("vacation_needed", player_stress)

func _update_family_happiness() -> void:
	"""Daily happiness updates based on various factors"""

	# Spouse happiness factors
	var spouse = family_members.spouse

	# Work-life balance affects spouse
	if work_life_balance < 30:  # Working too much
		spouse.happiness -= 0.5
	elif work_life_balance > 70:  # Good balance
		spouse.happiness += 0.3

	# Days away from home
	if days_without_home > 3:
		spouse.happiness -= 0.3 * days_without_home

	# Financial security
	if GameManager and GameManager.company_money > 50000:
		spouse.happiness += 0.2
	elif GameManager and GameManager.company_money < 0:
		spouse.happiness -= 0.5

	# Home quality
	spouse.happiness += home_happiness_bonus

	# Children happiness
	for child_key in ["child1", "child2"]:
		var child = family_members[child_key]

		# Time with family
		if days_without_home > 5:
			child.happiness -= 0.5

		# Living conditions
		child.happiness += home_happiness_bonus * 0.5

		# Attention needs
		if child.needs_attention:
			child.happiness -= 1.0

	# Clamp all values
	spouse.happiness = clamp(spouse.happiness, 0.0, 100.0)
	spouse.relationship = clamp(spouse.relationship, 0.0, 100.0)

	for child_key in ["child1", "child2"]:
		var child = family_members[child_key]
		child.happiness = clamp(child.happiness, 0.0, 100.0)

	# Overall family happiness
	var overall = _calculate_overall_happiness()
	emit_signal("family_happiness_changed", overall)

	# Warning if family very unhappy
	if overall < 30:
		emit_signal("family_event", "unhappy", "Your family is very unhappy! Spend more time with them.")

func _update_player_stress() -> void:
	"""Update player stress based on work and life"""

	# Work stress
	if GameManager:
		var active_deliveries = GameManager.active_deliveries.size()
		player_stress += active_deliveries * 0.5

		# Financial stress
		if GameManager.company_money < 0:
			player_stress += 1.0
		elif GameManager.company_money < 5000:
			player_stress += 0.5

	# Vacation reduces stress
	if days_without_home == 0:  # At home
		player_stress -= 2.0

	# Luxury items reduce stress
	player_stress -= luxury_items.size() * 0.1

	player_stress = clamp(player_stress, 0.0, 100.0)

	# Health affected by stress
	if player_stress > 80:
		player_health -= 0.5
	elif player_stress < 30:
		player_health += 0.3

	player_health = clamp(player_health, 0.0, 100.0)

	# Update work-life balance
	if days_without_home > 0:
		work_life_balance -= 0.5
	else:
		work_life_balance += 1.0

	work_life_balance = clamp(work_life_balance, 0.0, 100.0)

func _check_family_events() -> void:
	"""Random family events"""

	var day = GameManager.current_day if GameManager else 0

	if day - last_family_event_day < 14:  # 2 weeks cooldown
		return

	if randf() < 0.1:  # 10% chance
		_trigger_family_event()

func _trigger_family_event() -> void:
	"""Trigger a random family event"""

	var events = [
		{
			"type": "birthday",
			"title": "Birthday Coming Up!",
			"description": "Your spouse's birthday is next week. Time to buy a gift!",
			"happiness_cost": 10  # If ignored
		},
		{
			"type": "school_play",
			"title": "School Performance",
			"description": "Thomas has a school play this weekend. Your family hopes you'll attend.",
			"happiness_cost": 15
		},
		{
			"type": "anniversary",
			"title": "Wedding Anniversary",
			"description": "Your wedding anniversary is coming up. Plan something special!",
			"happiness_cost": 20
		},
		{
			"type": "child_sick",
			"title": "Child is Sick",
			"description": "Anna isn't feeling well and needs to see a doctor.",
			"cost": 500,
			"urgent": true
		},
		{
			"type": "family_trip_request",
			"title": "Family Vacation Request",
			"description": "Your family would love to go on a vacation together.",
			"happiness_cost": 12
		},
		{
			"type": "house_repair",
			"title": "House Needs Repairs",
			"description": "The house needs some maintenance work.",
			"cost": 2000
		},
		{
			"type": "school_fees",
			"title": "School Expenses",
			"description": "Time to pay for school supplies and activities.",
			"cost": 800
		}
	]

	var event = events[randi() % events.size()]
	last_family_event_day = GameManager.current_day if GameManager else 0

	family_members.spouse.wishes.append(event)

	emit_signal("family_event", event.type, event.description)

func _check_relationship_status() -> void:
	"""Check for relationship milestones"""

	var spouse = family_members.spouse

	# Check milestones
	if spouse.relationship >= 90 and "excellent_relationship" not in milestones_achieved:
		milestones_achieved.append("excellent_relationship")
		emit_signal("relationship_milestone", "Excellent relationship with spouse!")

	if spouse.relationship < 30 and "crisis" not in milestones_achieved:
		milestones_achieved.append("crisis")
		emit_signal("relationship_milestone", "Relationship crisis! Take immediate action!")

	# Check retirement readiness
	if GameManager and GameManager.private_money >= 500000 and not "retirement_ready" in milestones_achieved:
		milestones_achieved.append("retirement_ready")
		emit_signal("retirement_ready")

# === PLAYER ACTIONS ===

func go_home() -> void:
	"""Player goes home (reduces stress, increases family happiness)"""

	days_without_home = 0

	# Spending time with family
	family_members.spouse.happiness += 5.0
	family_members.spouse.relationship += 2.0

	for child_key in ["child1", "child2"]:
		family_members[child_key].happiness += 5.0
		family_members[child_key].needs_attention = false

	player_stress = max(0, player_stress - 10.0)

	emit_signal("family_event", "homecoming", "You spent quality time with your family!")

func buy_gift_for_spouse(cost: float, quality: float) -> bool:
	"""Buy a gift for spouse"""

	if not GameManager or GameManager.private_money < cost:
		return false

	GameManager.private_money -= cost

	# Happiness boost based on gift quality
	var happiness_boost = 5.0 + (quality * 10.0)
	family_members.spouse.happiness += happiness_boost
	family_members.spouse.relationship += quality * 5.0
	family_members.spouse.last_gift_day = GameManager.current_day

	emit_signal("family_event", "gift", "Your spouse loved the gift!")

	return true

func take_family_vacation(destination: String, cost: float, duration: int) -> bool:
	"""Take family on vacation"""

	if not GameManager or GameManager.private_money < cost:
		return false

	GameManager.private_money -= cost
	vacation_days_taken += duration

	# Major happiness boost
	family_members.spouse.happiness = min(100, family_members.spouse.happiness + 20.0)
	family_members.spouse.relationship = min(100, family_members.spouse.relationship + 15.0)

	for child_key in ["child1", "child2"]:
		family_members[child_key].happiness = min(100, family_members[child_key].happiness + 25.0)

	# Stress reduction
	player_stress = max(0, player_stress - 30.0)

	# Reset days without home
	days_without_home = 0

	emit_signal("family_event", "vacation", "Amazing family vacation to " + destination + "!")

	return true

func buy_home(home_type: String, price: float) -> bool:
	"""Purchase a home"""

	if not GameManager or GameManager.private_money < price:
		return false

	GameManager.private_money -= price

	home_owned = true
	home_value = price

	# Set quality based on price
	if price < 150000:
		home_quality = 2
		home_happiness_bonus = 0.2
	elif price < 300000:
		home_quality = 3
		home_happiness_bonus = 0.4
	elif price < 500000:
		home_quality = 4
		home_happiness_bonus = 0.6
	else:
		home_quality = 5
		home_happiness_bonus = 1.0

	# Major family happiness boost
	family_members.spouse.happiness = min(100, family_members.spouse.happiness + 30.0)
	family_members.spouse.relationship = min(100, family_members.spouse.relationship + 20.0)

	emit_signal("family_event", "new_home", "Your family is thrilled with the new home!")

	return true

func buy_luxury_item(item: Dictionary) -> bool:
	"""Buy a luxury item"""

	if not GameManager or GameManager.private_money < item.price:
		return false

	GameManager.private_money -= item.price

	luxury_items.append(item)

	# Happiness and status boost
	family_members.spouse.happiness += item.happiness_boost
	family_members.spouse.relationship += item.relationship_boost

	if GameManager:
		GameManager.social_status += item.status_boost

	emit_signal("family_event", "luxury_purchase", "You bought a " + item.name + "!")

	return true

func contribute_to_retirement(amount: float) -> bool:
	"""Add money to retirement savings"""

	if not GameManager or GameManager.private_money < amount:
		return false

	GameManager.private_money -= amount
	retirement_savings += amount

	# Spouse appreciates financial planning
	family_members.spouse.happiness += 2.0

	return true

# === PUBLIC API ===

func get_family_happiness() -> float:
	return _calculate_overall_happiness()

func _calculate_overall_happiness() -> float:
	var total = family_members.spouse.happiness
	for child_key in ["child1", "child2"]:
		total += family_members[child_key].happiness
	return total / 3.0

func get_spouse_happiness() -> float:
	return family_members.spouse.happiness

func get_player_stress() -> float:
	return player_stress

func get_work_life_balance() -> float:
	return work_life_balance

func needs_vacation() -> bool:
	return player_stress > 70 or days_without_home > 10 or get_family_happiness() < 40

func can_retire() -> bool:
	return retirement_savings >= 500000 and GameManager.private_money >= 200000

func get_family_status() -> Dictionary:
	return {
		"overall_happiness": get_family_happiness(),
		"spouse": family_members.spouse.duplicate(),
		"children": [
			family_members.child1.duplicate(),
			family_members.child2.duplicate()
		],
		"player_stress": player_stress,
		"player_health": player_health,
		"work_life_balance": work_life_balance,
		"days_without_home": days_without_home,
		"home_owned": home_owned,
		"home_quality": home_quality,
		"luxury_items_count": luxury_items.size(),
		"retirement_savings": retirement_savings,
		"can_retire": can_retire()
	}

func get_pending_wishes() -> Array:
	return family_members.spouse.wishes.duplicate()

func fulfill_wish(wish: Dictionary) -> bool:
	"""Fulfill a family wish/event"""

	if wish.has("cost"):
		if not GameManager or GameManager.private_money < wish.cost:
			return false
		GameManager.private_money -= wish.cost

	# Remove wish
	family_members.spouse.wishes.erase(wish)

	# Happiness boost
	family_members.spouse.happiness += 10.0

	return true
