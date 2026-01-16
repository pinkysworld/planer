extends Node
## EmployeeAI - Intelligent employee management with skill progression and events
## Simulates realistic employee behavior, morale, skill development, and life events

signal employee_skill_improved(employee: Dictionary, old_skill: float, new_skill: float)
signal employee_morale_changed(employee: Dictionary, change: float, reason: String)
signal employee_life_event(employee: Dictionary, event_type: String, details: Dictionary)
signal employee_request(employee: Dictionary, request_type: String, details: Dictionary)
signal employee_quit(employee: Dictionary, reason: String)

# Skill progression rates (per day)
const SKILL_GAIN_BASE: float = 0.05
const SKILL_GAIN_MAX: float = 0.20
const EXPERIENCE_GAIN_PER_DELIVERY: float = 0.1

# Morale factors
const MORALE_GOOD_SALARY_THRESHOLD: float = 1.2  # Multiplier of role average
const MORALE_LOW_SALARY_THRESHOLD: float = 0.8
const MORALE_DAILY_DECAY: float = 0.1  # Natural decay if nothing happens
const MORALE_RECOVERY: float = 0.2  # Recovery when treated well

# Employee personality traits
var personality_types: Array = [
	{"name": "ambitious", "skill_gain": 1.3, "salary_sensitivity": 1.2, "loyalty": 0.7},
	{"name": "loyal", "skill_gain": 1.0, "salary_sensitivity": 0.8, "loyalty": 1.3},
	{"name": "average", "skill_gain": 1.0, "salary_sensitivity": 1.0, "loyalty": 1.0},
	{"name": "lazy", "skill_gain": 0.7, "salary_sensitivity": 0.9, "loyalty": 0.9},
	{"name": "perfectionist", "skill_gain": 1.2, "salary_sensitivity": 1.1, "loyalty": 1.1}
]

# Life events
var life_events: Array = [
	{"type": "marriage", "morale": 15.0, "probability": 0.001},
	{"type": "baby", "morale": 10.0, "probability": 0.001, "time_off": 14},
	{"type": "illness", "morale": -20.0, "probability": 0.005, "time_off": 3},
	{"type": "family_issue", "morale": -10.0, "probability": 0.003},
	{"type": "achievement", "morale": 5.0, "probability": 0.01},
	{"type": "burnout", "morale": -25.0, "probability": 0.002},
	{"type": "promotion_request", "morale": 0.0, "probability": 0.005},
	{"type": "raise_request", "morale": 0.0, "probability": 0.008}
]

func _ready() -> void:
	GameManager.day_changed.connect(_on_day_changed)
	EventBus.delivery_completed.connect(_on_delivery_completed) if EventBus.has_signal("delivery_completed") else null

func _on_day_changed(day: int) -> void:
	for employee in GameManager.employees:
		_update_employee_daily(employee)
		_check_employee_events(employee)
		_update_employee_skills(employee)

func _update_employee_daily(employee: Dictionary) -> void:
	# Ensure employee has personality
	if "personality" not in employee:
		_assign_personality(employee)

	# Natural morale changes
	var salary_factor = _calculate_salary_satisfaction(employee)

	# Morale change based on salary
	var morale_change = 0.0
	if salary_factor > MORALE_GOOD_SALARY_THRESHOLD:
		morale_change = MORALE_RECOVERY
	elif salary_factor < MORALE_LOW_SALARY_THRESHOLD:
		morale_change = -MORALE_DAILY_DECAY * 2.0
	else:
		morale_change = -MORALE_DAILY_DECAY * 0.5

	# Workload stress
	if not employee.is_available and employee.role == "Driver":
		morale_change -= 0.05  # Working is slightly stressful

	# Apply morale change
	_change_employee_morale(employee, morale_change, "daily_routine")

	# Check if employee wants to quit
	if employee.morale < 20.0 and randf() < 0.1:
		_employee_quits(employee, "low_morale")
	elif salary_factor < 0.7 and randf() < 0.05:
		_employee_quits(employee, "low_salary")

	# Vacation days recovery
	if employee.vacation_days_remaining < 25:
		employee.vacation_days_remaining = min(25, employee.vacation_days_remaining + 2.0/365.0)

func _update_employee_skills(employee: Dictionary) -> void:
	# Skills improve with experience and work
	var personality = employee.get("personality", {"skill_gain": 1.0})
	var skill_gain = SKILL_GAIN_BASE * personality.skill_gain

	# Reduce gain as skill gets higher (diminishing returns)
	var skill_penalty = employee.skill / 100.0
	skill_gain *= (1.0 - skill_penalty * 0.8)

	# Better morale = better learning
	var morale_bonus = (employee.morale - 50.0) / 100.0
	skill_gain *= (1.0 + morale_bonus * 0.3)

	var old_skill = employee.skill
	employee.skill += skill_gain
	employee.skill = clamp(employee.skill, 0.0, 100.0)

	# Significant improvement notification
	if employee.skill - old_skill >= 1.0:
		emit_signal("employee_skill_improved", employee, old_skill, employee.skill)

	# Experience increases
	employee.experience += 0.01

func _check_employee_events(employee: Dictionary) -> void:
	# Random life events
	for event in life_events:
		if randf() < event.probability:
			_trigger_life_event(employee, event)
			break  # Only one event per day

func _trigger_life_event(employee: Dictionary, event: Dictionary) -> void:
	var event_details = {
		"type": event.type,
		"description": _get_event_description(employee, event.type)
	}

	# Apply morale change
	_change_employee_morale(employee, event.morale, event.type)

	# Handle time off
	if "time_off" in event:
		employee.is_available = false
		employee.time_off_days = event.time_off
		event_details.time_off = event.time_off

	# Handle requests
	if event.type == "promotion_request":
		_handle_promotion_request(employee)
	elif event.type == "raise_request":
		_handle_raise_request(employee)

	emit_signal("employee_life_event", employee, event.type, event_details)

func _handle_promotion_request(employee: Dictionary) -> void:
	# Employee wants a promotion (only if skilled enough)
	if employee.skill >= 70.0:
		emit_signal("employee_request", employee, "promotion", {
			"current_role": employee.role,
			"desired_role": _get_promotion_role(employee.role),
			"salary_increase": 500.0
		})

func _handle_raise_request(employee: Dictionary) -> void:
	# Employee wants a raise
	var desired_increase = employee.salary * randf_range(0.05, 0.15)
	emit_signal("employee_request", employee, "raise", {
		"current_salary": employee.salary,
		"desired_increase": desired_increase,
		"reason": _get_raise_reason(employee)
	})

func _get_promotion_role(current_role: String) -> String:
	match current_role:
		"Driver":
			return "Senior Driver"
		"Mechanic":
			return "Chief Mechanic"
		"Secretary":
			return "Office Manager"
		"Accountant":
			return "Senior Accountant"
	return "Manager"

func _get_raise_reason(employee: Dictionary) -> String:
	if employee.experience > 5.0:
		return "years of loyal service"
	elif employee.skill > 80.0:
		return "exceptional performance"
	elif employee.completed_deliveries > 50:
		return "outstanding track record"
	else:
		return "increased living costs"

func _employee_quits(employee: Dictionary, reason: String) -> void:
	if employee.is_available:  # Only quit if not currently working
		GameManager.employees.erase(employee)
		emit_signal("employee_quit", employee, reason)

func _on_delivery_completed(delivery: Dictionary, on_time: bool) -> void:
	# Find the driver who completed this delivery
	for employee in GameManager.employees:
		if employee.id == delivery.driver_id:
			# Increase experience
			employee.experience += EXPERIENCE_GAIN_PER_DELIVERY

			# Skill improvement
			var skill_bonus = SKILL_GAIN_BASE * 2.0
			employee.skill += skill_bonus
			employee.skill = clamp(employee.skill, 0.0, 100.0)

			# Morale impact
			if on_time:
				_change_employee_morale(employee, 2.0, "successful_delivery")
			else:
				_change_employee_morale(employee, -3.0, "failed_deadline")

			# Track deliveries
			if "completed_deliveries" not in employee:
				employee.completed_deliveries = 0
			employee.completed_deliveries += 1

			break

func _assign_personality(employee: Dictionary) -> void:
	var personality = personality_types[randi() % personality_types.size()]
	employee.personality = personality

func _calculate_salary_satisfaction(employee: Dictionary) -> float:
	var base_salary = GameManager._get_base_salary(employee.role)
	return employee.salary / base_salary

func _change_employee_morale(employee: Dictionary, change: float, reason: String) -> void:
	var personality = employee.get("personality", {"loyalty": 1.0})

	# Personality affects morale sensitivity
	if change < 0:
		change *= (2.0 - personality.loyalty)  # Loyal employees less affected by negative

	var old_morale = employee.morale
	employee.morale += change
	employee.morale = clamp(employee.morale, 0.0, 100.0)

	# Emit signal if significant change
	if abs(employee.morale - old_morale) >= 1.0:
		emit_signal("employee_morale_changed", employee, change, reason)

func _get_event_description(employee: Dictionary, event_type: String) -> String:
	match event_type:
		"marriage":
			return employee.name + " got married!"
		"baby":
			return employee.name + " is expecting a baby!"
		"illness":
			return employee.name + " is ill and needs time off."
		"family_issue":
			return employee.name + " is dealing with family problems."
		"achievement":
			return employee.name + " achieved a personal goal!"
		"burnout":
			return employee.name + " is experiencing burnout."
		"promotion_request":
			return employee.name + " would like to discuss a promotion."
		"raise_request":
			return employee.name + " is requesting a salary increase."
	return employee.name + " had a life event."

# Public API
func approve_raise_request(employee_id: String, amount: float) -> bool:
	"""Approve a raise request for an employee"""
	for employee in GameManager.employees:
		if employee.id == employee_id:
			employee.salary += amount
			_change_employee_morale(employee, 15.0, "raise_approved")
			return true
	return false

func deny_raise_request(employee_id: String) -> bool:
	"""Deny a raise request (may hurt morale)"""
	for employee in GameManager.employees:
		if employee.id == employee_id:
			_change_employee_morale(employee, -10.0, "raise_denied")
			return true
	return false

func approve_promotion(employee_id: String, new_role: String, salary_increase: float) -> bool:
	"""Promote an employee"""
	for employee in GameManager.employees:
		if employee.id == employee_id:
			employee.role = new_role
			employee.salary += salary_increase
			_change_employee_morale(employee, 20.0, "promoted")
			return true
	return false

func give_bonus(employee_id: String, amount: float) -> bool:
	"""Give an employee a bonus (improves morale)"""
	for employee in GameManager.employees:
		if employee.id == employee_id:
			GameManager.company_money -= amount
			_change_employee_morale(employee, amount / 100.0, "bonus_received")
			return true
	return false

func send_on_vacation(employee_id: String, days: int) -> bool:
	"""Send employee on vacation (restores morale)"""
	for employee in GameManager.employees:
		if employee.id == employee_id and employee.is_available:
			if employee.vacation_days_remaining >= days:
				employee.is_available = false
				employee.time_off_days = days
				employee.vacation_days_remaining -= days
				_change_employee_morale(employee, days * 2.0, "vacation")
				return true
	return false

func get_employee_performance_rating(employee: Dictionary) -> String:
	"""Get a human-readable performance rating"""
	var score = (employee.skill + employee.morale + employee.experience * 5.0) / 3.0

	if score >= 80.0:
		return "Excellent"
	elif score >= 60.0:
		return "Good"
	elif score >= 40.0:
		return "Average"
	elif score >= 20.0:
		return "Poor"
	else:
		return "Very Poor"

func get_employee_status(employee: Dictionary) -> String:
	"""Get employee status description"""
	if not employee.is_available:
		if "time_off_days" in employee and employee.time_off_days > 0:
			return "On Leave (%d days)" % employee.time_off_days
		return "Busy"

	if employee.morale < 30.0:
		return "Unhappy"
	elif employee.morale > 80.0:
		return "Very Happy"
	else:
		return "Available"

func calculate_turnover_risk(employee: Dictionary) -> float:
	"""Calculate probability employee will quit (0.0-1.0)"""
	var risk = 0.0

	# Morale factor
	risk += (50.0 - employee.morale) / 100.0

	# Salary factor
	var salary_satisfaction = _calculate_salary_satisfaction(employee)
	if salary_satisfaction < 0.8:
		risk += (0.8 - salary_satisfaction)

	# Loyalty factor
	var personality = employee.get("personality", {"loyalty": 1.0})
	risk *= (2.0 - personality.loyalty)

	return clamp(risk, 0.0, 1.0)
