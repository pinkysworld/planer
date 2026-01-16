extends Node
## ResearchSystem - Research & Development for new technologies and upgrades
## Unlock new capabilities, improve efficiency, and gain competitive advantages

signal research_started(project: Dictionary)
signal research_progress(project_id: String, progress: float)
signal research_completed(project: Dictionary)
signal technology_unlocked(tech_id: String, tech_name: String)

# Active research projects
var active_research: Array = []
var completed_research: Array = []
var unlocked_technologies: Array = []

# Research points (accumulated through various means)
var research_points: float = 0.0
var daily_research_generation: float = 0.0

# Available research projects
var research_projects: Dictionary = {
	# Efficiency Technologies
	"fuel_efficiency_1": {
		"name": "Fuel Efficiency I",
		"description": "Improve fuel consumption by 10%",
		"category": "efficiency",
		"cost": 5000.0,
		"research_points_required": 100.0,
		"duration_days": 30,
		"prerequisites": [],
		"benefits": {"fuel_efficiency": 0.10}
	},
	"fuel_efficiency_2": {
		"name": "Advanced Fuel Management",
		"description": "Further improve fuel consumption by 15%",
		"category": "efficiency",
		"cost": 10000.0,
		"research_points_required": 200.0,
		"duration_days": 45,
		"prerequisites": ["fuel_efficiency_1"],
		"benefits": {"fuel_efficiency": 0.15}
	},
	"route_optimization": {
		"name": "AI Route Optimization",
		"description": "AI-powered route planning reduces travel time by 12%",
		"category": "ai",
		"cost": 15000.0,
		"research_points_required": 250.0,
		"duration_days": 60,
		"prerequisites": [],
		"benefits": {"route_efficiency": 0.12, "delivery_speed": 0.12}
	},
	"predictive_maintenance": {
		"name": "Predictive Maintenance",
		"description": "AI predicts maintenance needs, reducing breakdowns by 30%",
		"category": "ai",
		"cost": 12000.0,
		"research_points_required": 180.0,
		"duration_days": 50,
		"prerequisites": [],
		"benefits": {"breakdown_reduction": 0.30, "maintenance_cost": -0.15}
	},

	# Electric Vehicle Tech
	"ev_charging_network": {
		"name": "EV Charging Network",
		"description": "Establish fast-charging stations for electric trucks",
		"category": "electric",
		"cost": 20000.0,
		"research_points_required": 150.0,
		"duration_days": 40,
		"prerequisites": [],
		"benefits": {"ev_availability": 1.0, "charging_speed": 0.50}
	},
	"battery_tech_1": {
		"name": "Advanced Battery Technology",
		"description": "Increase electric truck range by 25%",
		"category": "electric",
		"cost": 18000.0,
		"research_points_required": 220.0,
		"duration_days": 55,
		"prerequisites": ["ev_charging_network"],
		"benefits": {"ev_range": 0.25, "ev_efficiency": 0.10}
	},
	"ultra_fast_charging": {
		"name": "Ultra-Fast Charging",
		"description": "Reduce charging time by 60%",
		"category": "electric",
		"cost": 25000.0,
		"research_points_required": 300.0,
		"duration_days": 70,
		"prerequisites": ["ev_charging_network", "battery_tech_1"],
		"benefits": {"charging_time": -0.60}
	},

	# Hydrogen Technology
	"hydrogen_infrastructure": {
		"name": "Hydrogen Infrastructure",
		"description": "Build hydrogen refueling stations",
		"category": "hydrogen",
		"cost": 30000.0,
		"research_points_required": 200.0,
		"duration_days": 50,
		"prerequisites": [],
		"benefits": {"hydrogen_availability": 1.0}
	},
	"hydrogen_efficiency": {
		"name": "Fuel Cell Optimization",
		"description": "Improve hydrogen fuel cell efficiency by 20%",
		"category": "hydrogen",
		"cost": 22000.0,
		"research_points_required": 250.0,
		"duration_days": 60,
		"prerequisites": ["hydrogen_infrastructure"],
		"benefits": {"hydrogen_efficiency": 0.20}
	},

	# Automation
	"autonomous_driving_1": {
		"name": "Driver Assistance Systems",
		"description": "Level 2 automation reduces driver fatigue and accidents by 20%",
		"category": "automation",
		"cost": 35000.0,
		"research_points_required": 350.0,
		"duration_days": 90,
		"prerequisites": ["route_optimization"],
		"benefits": {"accident_reduction": 0.20, "driver_productivity": 0.15}
	},
	"autonomous_driving_2": {
		"name": "Semi-Autonomous Trucks",
		"description": "Level 3 automation allows highway self-driving",
		"category": "automation",
		"cost": 50000.0,
		"research_points_required": 500.0,
		"duration_days": 120,
		"prerequisites": ["autonomous_driving_1"],
		"benefits": {"accident_reduction": 0.40, "driver_cost": -0.25, "delivery_speed": 0.20}
	},

	# Management
	"fleet_management": {
		"name": "Advanced Fleet Management",
		"description": "Sophisticated fleet tracking and optimization",
		"category": "management",
		"cost": 8000.0,
		"research_points_required": 120.0,
		"duration_days": 35,
		"prerequisites": [],
		"benefits": {"fleet_efficiency": 0.15, "maintenance_cost": -0.10}
	},
	"supply_chain_ai": {
		"name": "Supply Chain AI",
		"description": "AI predicts demand and optimizes contract selection",
		"category": "ai",
		"cost": 20000.0,
		"research_points_required": 280.0,
		"duration_days": 65,
		"prerequisites": ["fleet_management"],
		"benefits": {"contract_value": 0.15, "route_efficiency": 0.10}
	},
	"employee_training": {
		"name": "Advanced Training Program",
		"description": "Accelerate employee skill development by 30%",
		"category": "management",
		"cost": 10000.0,
		"research_points_required": 150.0,
		"duration_days": 40,
		"prerequisites": [],
		"benefits": {"skill_gain_rate": 0.30, "employee_satisfaction": 0.10}
	},

	# Specialized
	"hazmat_certification": {
		"name": "Hazardous Materials Certification",
		"description": "Unlock high-paying hazmat contracts",
		"category": "specialized",
		"cost": 12000.0,
		"research_points_required": 100.0,
		"duration_days": 30,
		"prerequisites": [],
		"benefits": {"hazmat_access": 1.0, "hazmat_bonus": 0.50}
	},
	"refrigerated_transport": {
		"name": "Cold Chain Logistics",
		"description": "Enable refrigerated cargo transport",
		"category": "specialized",
		"cost": 15000.0,
		"research_points_required": 130.0,
		"duration_days": 35,
		"prerequisites": [],
		"benefits": {"refrigerated_access": 1.0, "food_contract_bonus": 0.30}
	},
	"express_service": {
		"name": "Express Delivery Service",
		"description": "Specialize in time-critical deliveries with 25% premium",
		"category": "specialized",
		"cost": 10000.0,
		"research_points_required": 140.0,
		"duration_days": 40,
		"prerequisites": ["route_optimization"],
		"benefits": {"express_bonus": 0.25, "reputation_gain": 0.20}
	}
}

func _ready() -> void:
	GameManager.day_changed.connect(_on_day_changed)

func _on_day_changed(day: int) -> void:
	_update_research_progress()
	_generate_research_points()
	_check_completed_research()

func _update_research_progress() -> void:
	for project in active_research:
		# Add daily progress
		project.progress += 1.0 / project.duration_days

		# Add research points if available
		if research_points > 0:
			var points_needed = project.research_points_required * (1.0 - project.research_progress)
			var points_to_apply = min(research_points, points_needed, daily_research_generation)

			if points_to_apply > 0:
				research_points -= points_to_apply
				project.research_progress += points_to_apply / project.research_points_required

		emit_signal("research_progress", project.id, project.progress)

func _generate_research_points() -> void:
	# Generate research points based on various factors
	daily_research_generation = 0.0

	# Base generation
	daily_research_generation += 1.0

	# Accountants generate research points
	for employee in GameManager.employees:
		if employee.role == "Accountant":
			daily_research_generation += employee.skill / 50.0

	# Reputation bonus
	daily_research_generation += GameManager.company_reputation / 100.0

	# Add to pool
	research_points += daily_research_generation

func _check_completed_research() -> void:
	var completed = []

	for project in active_research:
		if project.progress >= 1.0 and project.research_progress >= 1.0:
			_complete_research(project)
			completed.append(project)

	for project in completed:
		active_research.erase(project)

func _complete_research(project: Dictionary) -> void:
	# Apply benefits
	_apply_research_benefits(project.tech_id, project.benefits)

	# Mark as unlocked
	unlocked_technologies.append(project.tech_id)
	completed_research.append(project)

	emit_signal("research_completed", project)
	emit_signal("technology_unlocked", project.tech_id, project.name)

func _apply_research_benefits(tech_id: String, benefits: Dictionary) -> void:
	# Benefits are stored globally and applied when relevant
	# For example, fuel_efficiency benefits would be checked when calculating fuel costs

	for benefit_key in benefits.keys():
		var benefit_value = benefits[benefit_key]

		match benefit_key:
			"fuel_efficiency":
				# This would modify fuel consumption calculations
				pass
			"route_efficiency":
				# This would improve route calculation
				pass
			"delivery_speed":
				# This would increase truck speed
				pass
			"accident_reduction":
				# This would reduce accident probability
				pass
			# ... etc for all benefit types

func _can_research(project_id: String) -> bool:
	# Check if project can be researched
	var project_data = research_projects.get(project_id, {})
	if project_data.is_empty():
		return false

	# Check if already unlocked
	if project_id in unlocked_technologies:
		return false

	# Check if already being researched
	for active in active_research:
		if active.tech_id == project_id:
			return false

	# Check prerequisites
	for prereq in project_data.prerequisites:
		if prereq not in unlocked_technologies:
			return false

	# Check if can afford
	if GameManager.company_money < project_data.cost:
		return false

	return true

# Public API

func start_research(project_id: String) -> bool:
	"""Start a research project"""
	if not _can_research(project_id):
		return false

	var project_data = research_projects.get(project_id, {})

	# Deduct cost
	GameManager.company_money -= project_data.cost
	GameManager.emit_signal("money_changed", GameManager.company_money, GameManager.private_money)

	# Create active research project
	var project = {
		"id": _generate_id(),
		"tech_id": project_id,
		"name": project_data.name,
		"description": project_data.description,
		"category": project_data.category,
		"started_day": GameManager.current_day,
		"duration_days": project_data.duration_days,
		"progress": 0.0,
		"research_points_required": project_data.research_points_required,
		"research_progress": 0.0,
		"benefits": project_data.benefits
	}

	active_research.append(project)
	emit_signal("research_started", project)
	return true

func cancel_research(project_id: String) -> bool:
	"""Cancel an active research project (50% refund)"""
	for project in active_research:
		if project.tech_id == project_id:
			var project_data = research_projects.get(project_id, {})
			var refund = project_data.cost * 0.5

			GameManager.company_money += refund
			GameManager.emit_signal("money_changed", GameManager.company_money, GameManager.private_money)

			active_research.erase(project)
			return true
	return false

func is_technology_unlocked(tech_id: String) -> bool:
	"""Check if a technology is unlocked"""
	return tech_id in unlocked_technologies

func get_available_projects() -> Array:
	"""Get list of projects that can be researched"""
	var available = []

	for project_id in research_projects.keys():
		if _can_research(project_id):
			var data = research_projects[project_id].duplicate()
			data.id = project_id
			available.append(data)

	return available

func get_active_research() -> Array:
	"""Get list of active research projects"""
	return active_research.duplicate()

func get_completed_research() -> Array:
	"""Get list of completed research"""
	return completed_research.duplicate()

func get_research_categories() -> Array:
	"""Get list of all research categories"""
	var categories = []
	for project_data in research_projects.values():
		if project_data.category not in categories:
			categories.append(project_data.category)
	return categories

func get_projects_by_category(category: String) -> Array:
	"""Get all projects in a category"""
	var projects = []
	for project_id in research_projects.keys():
		var data = research_projects[project_id]
		if data.category == category:
			var project = data.duplicate()
			project.id = project_id
			project.unlocked = is_technology_unlocked(project_id)
			project.can_research = _can_research(project_id)
			projects.append(project)
	return projects

func get_benefit_multiplier(benefit_type: String) -> float:
	"""Get total multiplier for a specific benefit type"""
	var total = 0.0

	for tech_id in unlocked_technologies:
		var project_data = research_projects.get(tech_id, {})
		var benefits = project_data.get("benefits", {})

		if benefits.has(benefit_type):
			total += benefits[benefit_type]

	return total

func has_benefit(benefit_key: String) -> bool:
	"""Check if any unlocked tech provides a specific benefit"""
	for tech_id in unlocked_technologies:
		var project_data = research_projects.get(tech_id, {})
		var benefits = project_data.get("benefits", {})

		if benefits.has(benefit_key):
			return true

	return false

func get_research_points() -> float:
	return research_points

func get_daily_research_generation() -> float:
	return daily_research_generation

func _generate_id() -> String:
	return str(randi()) + str(Time.get_ticks_msec())

func get_research_tree_visualization() -> Dictionary:
	"""Get data for visualizing the research tree"""
	var tree = {}

	for project_id in research_projects.keys():
		var data = research_projects[project_id]
		tree[project_id] = {
			"name": data.name,
			"category": data.category,
			"unlocked": is_technology_unlocked(project_id),
			"can_research": _can_research(project_id),
			"prerequisites": data.prerequisites,
			"cost": data.cost
		}

	return tree
