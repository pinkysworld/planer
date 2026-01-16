extends Node
## InsuranceSystem - Risk management and insurance system
## Simulates insurance policies, claims, and risk assessment

signal policy_purchased(policy_type: String, cost: float)
signal claim_filed(claim: Dictionary)
signal claim_processed(claim: Dictionary, payout: float)
signal premium_due(policy_type: String, amount: float)
signal policy_expired(policy_type: String)

# Insurance policies
var active_policies: Array = []

# Claims history
var claims_history: Array = []
var pending_claims: Array = []

# Risk factors
var company_risk_level: float = 0.5  # 0.0 = low risk, 1.0 = high risk

# Policy types
var available_policies: Dictionary = {
	"truck_basic": {
		"name": "Basic Truck Insurance",
		"description": "Covers basic truck damage and accidents",
		"monthly_cost": 150.0,
		"coverage": 0.6,  # 60% coverage
		"deductible": 1000.0,
		"max_payout": 25000.0
	},
	"truck_comprehensive": {
		"name": "Comprehensive Truck Insurance",
		"description": "Full coverage for all truck damage, theft, and accidents",
		"monthly_cost": 300.0,
		"coverage": 0.9,
		"deductible": 500.0,
		"max_payout": 50000.0
	},
	"cargo_basic": {
		"name": "Basic Cargo Insurance",
		"description": "Covers cargo damage and loss (basic)",
		"monthly_cost": 100.0,
		"coverage": 0.5,
		"deductible": 500.0,
		"max_payout": 15000.0
	},
	"cargo_premium": {
		"name": "Premium Cargo Insurance",
		"description": "Full cargo protection including hazardous materials",
		"monthly_cost": 250.0,
		"coverage": 0.95,
		"deductible": 250.0,
		"max_payout": 40000.0
	},
	"liability": {
		"name": "Liability Insurance",
		"description": "Third-party liability protection",
		"monthly_cost": 200.0,
		"coverage": 0.8,
		"deductible": 0.0,
		"max_payout": 100000.0
	},
	"business_interruption": {
		"name": "Business Interruption Insurance",
		"description": "Covers lost income during incidents",
		"monthly_cost": 180.0,
		"coverage": 0.7,
		"deductible": 1000.0,
		"max_payout": 30000.0
	}
}

func _ready() -> void:
	GameManager.day_changed.connect(_on_day_changed)
	EventBus.delivery_completed.connect(_on_delivery_completed) if EventBus.has_signal("delivery_completed") else null

	if has_node("/root/RouteAI"):
		RouteAI.traffic_incident.connect(_on_traffic_incident)

func _on_day_changed(day: int) -> void:
	_update_risk_assessment()
	_process_pending_claims()
	_check_policy_renewals()

	# Monthly premium payments
	if day % 30 == 0:
		_process_monthly_premiums()

func _update_risk_assessment() -> void:
	# Calculate company risk level based on various factors
	var risk = 0.5  # Base risk

	# Fleet condition factor
	var avg_condition = 0.0
	if GameManager.trucks.size() > 0:
		for truck in GameManager.trucks:
			avg_condition += truck.condition
		avg_condition /= GameManager.trucks.size()
		risk += (100.0 - avg_condition) / 200.0  # Poor condition = higher risk

	# Driver experience factor
	var avg_experience = 0.0
	var driver_count = 0
	for employee in GameManager.employees:
		if employee.role == "Driver":
			avg_experience += employee.experience
			driver_count += 1
	if driver_count > 0:
		avg_experience /= driver_count
		risk -= min(avg_experience / 20.0, 0.2)  # Experienced drivers = lower risk

	# Reputation factor
	risk -= (GameManager.company_reputation - 50.0) / 200.0

	# Claims history factor
	var recent_claims = claims_history.filter(func(c):
		return GameManager.current_day - c.filed_day < 180
	).size()
	risk += recent_claims * 0.05

	company_risk_level = clamp(risk, 0.1, 1.0)

func _process_monthly_premiums() -> void:
	# Charge premiums for active policies
	for policy in active_policies:
		var policy_data = available_policies.get(policy.type, {})
		var premium = policy_data.get("monthly_cost", 0.0)

		# Adjust premium based on risk
		premium *= (0.8 + company_risk_level * 0.4)  # 80%-120% of base cost

		GameManager.company_money -= premium
		emit_signal("premium_due", policy.type, premium)

		# Update policy
		policy.months_active += 1
		policy.total_paid += premium

func _check_policy_renewals() -> void:
	# Check if any policies need renewal
	var expired = []
	for policy in active_policies:
		if "term_months" in policy and policy.months_active >= policy.term_months:
			expired.append(policy)

	for policy in expired:
		active_policies.erase(policy)
		emit_signal("policy_expired", policy.type)

func _process_pending_claims() -> void:
	# Process pending insurance claims
	var processed = []

	for claim in pending_claims:
		var days_pending = GameManager.current_day - claim.filed_day

		if days_pending >= claim.processing_time:
			_process_claim(claim)
			processed.append(claim)

	for claim in processed:
		pending_claims.erase(claim)

func _process_claim(claim: Dictionary) -> void:
	# Process an insurance claim
	var policy = _find_policy(claim.policy_type)
	if not policy:
		claim.status = "denied"
		claim.denial_reason = "Policy not active"
		emit_signal("claim_processed", claim, 0.0)
		claims_history.append(claim)
		return

	var policy_data = available_policies.get(policy.type, {})

	# Calculate payout
	var damage_cost = claim.damage_amount
	var coverage = policy_data.coverage
	var deductible = policy_data.deductible
	var max_payout = policy_data.max_payout

	var payout = max(0.0, (damage_cost - deductible) * coverage)
	payout = min(payout, max_payout)

	# Apply payout
	GameManager.company_money += payout

	claim.status = "approved"
	claim.payout = payout
	claim.processed_day = GameManager.current_day

	emit_signal("claim_processed", claim, payout)
	claims_history.append(claim)

	# Adjust risk level after claim
	company_risk_level = min(1.0, company_risk_level + 0.05)

func _find_policy(policy_type: String) -> Dictionary:
	for policy in active_policies:
		if policy.type == policy_type:
			return policy
	return {}

func _on_delivery_completed(delivery: Dictionary, on_time: bool) -> void:
	# Potential for incidents that need insurance claims
	if not on_time:
		# Check for damage incidents
		if randf() < 0.05:  # 5% chance of damage on late delivery
			_trigger_incident("cargo_damage", delivery, randf_range(1000.0, 5000.0))

func _on_traffic_incident(location: String, severity: String, delay: float) -> void:
	# Traffic incidents might cause accidents
	# This is just an example - actual implementation would be more sophisticated
	pass

func _trigger_incident(incident_type: String, related_data: Dictionary, damage_amount: float) -> void:
	# Trigger an incident that may result in an insurance claim
	var incident = {
		"id": _generate_id(),
		"type": incident_type,
		"day": GameManager.current_day,
		"damage_amount": damage_amount,
		"related_data": related_data,
		"description": _get_incident_description(incident_type)
	}

	# Check if we have coverage for this
	var has_coverage = false
	var coverage_type = ""

	match incident_type:
		"truck_accident", "truck_damage", "truck_breakdown":
			has_coverage = _has_policy("truck_basic") or _has_policy("truck_comprehensive")
			coverage_type = "truck_comprehensive" if _has_policy("truck_comprehensive") else "truck_basic"
		"cargo_damage", "cargo_loss":
			has_coverage = _has_policy("cargo_basic") or _has_policy("cargo_premium")
			coverage_type = "cargo_premium" if _has_policy("cargo_premium") else "cargo_basic"
		"liability_claim":
			has_coverage = _has_policy("liability")
			coverage_type = "liability"
		"business_loss":
			has_coverage = _has_policy("business_interruption")
			coverage_type = "business_interruption"

	# Auto-file claim if we have coverage
	if has_coverage:
		file_claim(coverage_type, incident_type, damage_amount, incident.description)
	else:
		# No insurance - pay out of pocket
		GameManager.company_money -= damage_amount
		EventBus.emit_signal("uninsured_loss", incident, damage_amount)

func _get_incident_description(incident_type: String) -> String:
	match incident_type:
		"truck_accident":
			return "Truck involved in traffic accident"
		"truck_damage":
			return "Truck sustained damage during delivery"
		"truck_breakdown":
			return "Major truck breakdown requiring repairs"
		"cargo_damage":
			return "Cargo damaged during transport"
		"cargo_loss":
			return "Cargo lost or stolen"
		"liability_claim":
			return "Third-party liability claim filed"
		"business_loss":
			return "Business interruption due to incident"
	return "Unknown incident"

func _has_policy(policy_type: String) -> bool:
	for policy in active_policies:
		if policy.type == policy_type:
			return true
	return false

func _generate_id() -> String:
	return str(randi()) + str(Time.get_ticks_msec())

# Public API

func purchase_policy(policy_type: String) -> bool:
	"""Purchase an insurance policy"""
	if _has_policy(policy_type):
		return false  # Already have this policy

	var policy_data = available_policies.get(policy_type, {})
	if policy_data.is_empty():
		return false

	var initial_cost = policy_data.monthly_cost

	if GameManager.company_money >= initial_cost:
		var policy = {
			"id": _generate_id(),
			"type": policy_type,
			"purchased_day": GameManager.current_day,
			"months_active": 0,
			"total_paid": 0.0,
			"claims_filed": 0
		}

		active_policies.append(policy)
		emit_signal("policy_purchased", policy_type, initial_cost)
		return true

	return false

func cancel_policy(policy_type: String) -> bool:
	"""Cancel an insurance policy"""
	for policy in active_policies:
		if policy.type == policy_type:
			active_policies.erase(policy)
			return true
	return false

func file_claim(policy_type: String, incident_type: String, damage_amount: float, description: String) -> bool:
	"""File an insurance claim"""
	var policy = _find_policy(policy_type)
	if policy.is_empty():
		return false

	var claim = {
		"id": _generate_id(),
		"policy_type": policy_type,
		"incident_type": incident_type,
		"damage_amount": damage_amount,
		"description": description,
		"filed_day": GameManager.current_day,
		"processing_time": randi_range(3, 10),  # 3-10 days to process
		"status": "pending"
	}

	pending_claims.append(claim)
	policy.claims_filed += 1

	emit_signal("claim_filed", claim)
	return true

func get_policy_quote(policy_type: String) -> Dictionary:
	"""Get a quote for an insurance policy"""
	var policy_data = available_policies.get(policy_type, {})
	if policy_data.is_empty():
		return {}

	var base_cost = policy_data.monthly_cost
	var quoted_cost = base_cost * (0.8 + company_risk_level * 0.4)

	return {
		"policy_type": policy_type,
		"name": policy_data.name,
		"description": policy_data.description,
		"monthly_premium": quoted_cost,
		"coverage": policy_data.coverage * 100.0,
		"deductible": policy_data.deductible,
		"max_payout": policy_data.max_payout,
		"risk_factor": company_risk_level
	}

func get_active_policies() -> Array:
	return active_policies.duplicate()

func get_claims_history() -> Array:
	return claims_history.duplicate()

func get_pending_claims() -> Array:
	return pending_claims.duplicate()

func get_risk_level() -> String:
	"""Get human-readable risk level"""
	if company_risk_level < 0.3:
		return "Low"
	elif company_risk_level < 0.6:
		return "Moderate"
	elif company_risk_level < 0.8:
		return "High"
	else:
		return "Very High"

func calculate_total_monthly_premiums() -> float:
	"""Calculate total monthly insurance costs"""
	var total = 0.0
	for policy in active_policies:
		var policy_data = available_policies.get(policy.type, {})
		total += policy_data.get("monthly_cost", 0.0) * (0.8 + company_risk_level * 0.4)
	return total

func is_adequately_insured() -> bool:
	"""Check if company has adequate insurance coverage"""
	var has_truck = _has_policy("truck_basic") or _has_policy("truck_comprehensive")
	var has_cargo = _has_policy("cargo_basic") or _has_policy("cargo_premium")
	var has_liability = _has_policy("liability")

	return has_truck and has_cargo and has_liability

func get_insurance_recommendations() -> Array:
	"""Get recommended insurance policies based on company state"""
	var recommendations = []

	if not _has_policy("truck_basic") and not _has_policy("truck_comprehensive"):
		recommendations.append({
			"policy": "truck_basic",
			"reason": "Protect your fleet from accidents and damage",
			"priority": "high"
		})

	if not _has_policy("cargo_basic") and not _has_policy("cargo_premium"):
		recommendations.append({
			"policy": "cargo_basic",
			"reason": "Cover cargo damage and loss during transport",
			"priority": "high"
		})

	if not _has_policy("liability"):
		recommendations.append({
			"policy": "liability",
			"reason": "Essential third-party liability protection",
			"priority": "critical"
		})

	if GameManager.trucks.size() >= 5 and not _has_policy("business_interruption"):
		recommendations.append({
			"policy": "business_interruption",
			"reason": "Large fleet should protect against business disruption",
			"priority": "medium"
		})

	return recommendations
