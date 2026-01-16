extends Node
## CargoTypesDatabase - Detailed cargo types from Planer series
## Different requirements, pricing, and special handling

enum CargoCategory {
	GENERAL,
	PERISHABLE,
	FRAGILE,
	HAZARDOUS,
	VALUABLE,
	OVERSIZED,
	TEMPERATURE_CONTROLLED,
	EXPRESS
}

var cargo_types: Dictionary = {}

func _ready() -> void:
	_initialize_cargo_types()

func _initialize_cargo_types() -> void:
	# === GENERAL CARGO ===

	_add_cargo("General Freight", {
		"category": CargoCategory.GENERAL,
		"base_price": 1.0,  # €/km
		"weight_factor": 1.0,
		"time_sensitive": false,
		"special_requirements": [],
		"damage_risk": 0.05,
		"insurance_cost": 0.02,
		"description": "Standard freight - boxes, pallets, general goods"
	})

	_add_cargo("Furniture", {
		"category": CargoCategory.GENERAL,
		"base_price": 1.2,
		"weight_factor": 1.1,
		"time_sensitive": false,
		"special_requirements": ["careful_handling"],
		"damage_risk": 0.15,
		"insurance_cost": 0.05,
		"description": "Household and office furniture"
	})

	_add_cargo("Textiles", {
		"category": CargoCategory.GENERAL,
		"base_price": 1.1,
		"weight_factor": 0.8,
		"time_sensitive": false,
		"special_requirements": [],
		"damage_risk": 0.03,
		"insurance_cost": 0.02,
		"description": "Clothing, fabrics, and textiles"
	})

	# === PERISHABLE ===

	_add_cargo("Food Products", {
		"category": CargoCategory.PERISHABLE,
		"base_price": 1.5,
		"weight_factor": 1.0,
		"time_sensitive": true,
		"special_requirements": ["refrigeration", "quick_delivery"],
		"damage_risk": 0.25,
		"insurance_cost": 0.08,
		"max_delay_hours": 24,
		"description": "Fresh food requiring refrigeration"
	})

	_add_cargo("Frozen Goods", {
		"category": CargoCategory.PERISHABLE,
		"base_price": 1.8,
		"weight_factor": 1.0,
		"time_sensitive": true,
		"special_requirements": ["freezer", "continuous_cooling"],
		"damage_risk": 0.30,
		"insurance_cost": 0.10,
		"max_delay_hours": 12,
		"temperature_range": [-18, -15],
		"description": "Frozen food products"
	})

	_add_cargo("Dairy Products", {
		"category": CargoCategory.PERISHABLE,
		"base_price": 1.6,
		"weight_factor": 1.0,
		"time_sensitive": true,
		"special_requirements": ["refrigeration"],
		"damage_risk": 0.20,
		"insurance_cost": 0.07,
		"max_delay_hours": 18,
		"temperature_range": [2, 6],
		"description": "Milk, cheese, yogurt, etc."
	})

	# === FRAGILE ===

	_add_cargo("Electronics", {
		"category": CargoCategory.FRAGILE,
		"base_price": 2.0,
		"weight_factor": 0.9,
		"time_sensitive": false,
		"special_requirements": ["careful_handling", "climate_controlled"],
		"damage_risk": 0.20,
		"insurance_cost": 0.12,
		"description": "Computers, phones, TVs, etc."
	})

	_add_cargo("Glassware", {
		"category": CargoCategory.FRAGILE,
		"base_price": 1.8,
		"weight_factor": 1.2,
		"time_sensitive": false,
		"special_requirements": ["very_careful_handling", "secured_loading"],
		"damage_risk": 0.35,
		"insurance_cost": 0.15,
		"description": "Glass products, mirrors, ceramics"
	})

	_add_cargo("Medical Equipment", {
		"category": CargoCategory.FRAGILE,
		"base_price": 2.5,
		"weight_factor": 1.0,
		"time_sensitive": true,
		"special_requirements": ["careful_handling", "climate_controlled", "certified_driver"],
		"damage_risk": 0.15,
		"insurance_cost": 0.20,
		"description": "Sensitive medical devices"
	})

	# === HAZARDOUS ===

	_add_cargo("Chemicals", {
		"category": CargoCategory.HAZARDOUS,
		"base_price": 3.0,
		"weight_factor": 1.3,
		"time_sensitive": false,
		"special_requirements": ["hazmat_license", "special_vehicle", "safety_equipment"],
		"damage_risk": 0.10,
		"insurance_cost": 0.25,
		"regulatory_paperwork": true,
		"description": "Industrial chemicals and compounds"
	})

	_add_cargo("Hazardous Materials", {
		"category": CargoCategory.HAZARDOUS,
		"base_price": 3.5,
		"weight_factor": 1.5,
		"time_sensitive": false,
		"special_requirements": ["hazmat_license", "special_vehicle", "safety_equipment", "certified_driver"],
		"damage_risk": 0.08,
		"insurance_cost": 0.30,
		"regulatory_paperwork": true,
		"description": "Dangerous goods requiring special handling"
	})

	_add_cargo("Flammable Liquids", {
		"category": CargoCategory.HAZARDOUS,
		"base_price": 3.2,
		"weight_factor": 1.4,
		"time_sensitive": false,
		"special_requirements": ["hazmat_license", "special_vehicle", "fire_suppression"],
		"damage_risk": 0.12,
		"insurance_cost": 0.28,
		"regulatory_paperwork": true,
		"description": "Fuels, solvents, and flammable substances"
	})

	# === VALUABLE ===

	_add_cargo("Pharmaceuticals", {
		"category": CargoCategory.VALUABLE,
		"base_price": 2.8,
		"weight_factor": 0.7,
		"time_sensitive": true,
		"special_requirements": ["climate_controlled", "security", "certified_driver"],
		"damage_risk": 0.08,
		"insurance_cost": 0.22,
		"description": "Medicines and pharmaceutical products"
	})

	_add_cargo("Jewelry", {
		"category": CargoCategory.VALUABLE,
		"base_price": 4.0,
		"weight_factor": 0.5,
		"time_sensitive": false,
		"special_requirements": ["security", "armored_vehicle", "armed_guard"],
		"damage_risk": 0.05,
		"insurance_cost": 0.35,
		"description": "Precious jewelry and gems"
	})

	_add_cargo("Art & Antiques", {
		"category": CargoCategory.VALUABLE,
		"base_price": 3.5,
		"weight_factor": 0.8,
		"time_sensitive": false,
		"special_requirements": ["careful_handling", "climate_controlled", "security", "certified_driver"],
		"damage_risk": 0.10,
		"insurance_cost": 0.30,
		"description": "Valuable art pieces and antiques"
	})

	# === OVERSIZED ===

	_add_cargo("Machinery", {
		"category": CargoCategory.OVERSIZED,
		"base_price": 2.2,
		"weight_factor": 2.0,
		"time_sensitive": false,
		"special_requirements": ["heavy_vehicle", "special_permits"],
		"damage_risk": 0.12,
		"insurance_cost": 0.10,
		"description": "Industrial machinery and equipment"
	})

	_add_cargo("Construction Materials", {
		"category": CargoCategory.OVERSIZED,
		"base_price": 1.4,
		"weight_factor": 2.5,
		"time_sensitive": false,
		"special_requirements": ["heavy_vehicle"],
		"damage_risk": 0.08,
		"insurance_cost": 0.05,
		"description": "Building materials, steel, concrete"
	})

	_add_cargo("Vehicles", {
		"category": CargoCategory.OVERSIZED,
		"base_price": 2.5,
		"weight_factor": 1.8,
		"time_sensitive": false,
		"special_requirements": ["car_carrier", "secured_loading"],
		"damage_risk": 0.15,
		"insurance_cost": 0.12,
		"description": "Cars, trucks, and other vehicles"
	})

	# === TEMPERATURE CONTROLLED ===

	_add_cargo("Medical Supplies", {
		"category": CargoCategory.TEMPERATURE_CONTROLLED,
		"base_price": 2.6,
		"weight_factor": 0.9,
		"time_sensitive": true,
		"special_requirements": ["temperature_monitoring", "refrigeration", "certified_driver"],
		"damage_risk": 0.10,
		"insurance_cost": 0.18,
		"temperature_range": [2, 8],
		"max_delay_hours": 12,
		"description": "Temperature-sensitive medical supplies"
	})

	_add_cargo("Vaccines", {
		"category": CargoCategory.TEMPERATURE_CONTROLLED,
		"base_price": 3.8,
		"weight_factor": 0.6,
		"time_sensitive": true,
		"special_requirements": ["cold_chain", "temperature_monitoring", "backup_cooling", "certified_driver"],
		"damage_risk": 0.08,
		"insurance_cost": 0.25,
		"temperature_range": [2, 8],
		"max_delay_hours": 6,
		"description": "Vaccines requiring strict cold chain"
	})

	# === EXPRESS ===

	_add_cargo("Express Documents", {
		"category": CargoCategory.EXPRESS,
		"base_price": 2.0,
		"weight_factor": 0.3,
		"time_sensitive": true,
		"special_requirements": ["express_vehicle", "direct_route"],
		"damage_risk": 0.02,
		"insurance_cost": 0.05,
		"max_delay_hours": 4,
		"description": "Urgent documents and packages"
	})

	_add_cargo("Automotive Parts", {
		"category": CargoCategory.GENERAL,
		"base_price": 1.7,
		"weight_factor": 1.1,
		"time_sensitive": true,
		"special_requirements": [],
		"damage_risk": 0.10,
		"insurance_cost": 0.08,
		"max_delay_hours": 24,
		"description": "Car and truck parts"
	})

	_add_cargo("Raw Materials", {
		"category": CargoCategory.GENERAL,
		"base_price": 1.3,
		"weight_factor": 2.0,
		"time_sensitive": false,
		"special_requirements": [],
		"damage_risk": 0.05,
		"insurance_cost": 0.03,
		"description": "Unprocessed materials for manufacturing"
	})

	_add_cargo("Consumer Goods", {
		"category": CargoCategory.GENERAL,
		"base_price": 1.4,
		"weight_factor": 1.0,
		"time_sensitive": false,
		"special_requirements": [],
		"damage_risk": 0.08,
		"insurance_cost": 0.06,
		"description": "Retail products and consumer goods"
	})

func _add_cargo(name: String, data: Dictionary) -> void:
	data.name = name
	cargo_types[name] = data

# Public API
func get_all_cargo_types() -> Dictionary:
	return cargo_types.duplicate()

func get_cargo_by_category(category: CargoCategory) -> Array:
	var result = []
	for name in cargo_types.keys():
		if cargo_types[name].category == category:
			result.append(cargo_types[name].duplicate())
	return result

func get_cargo_type(name: String) -> Dictionary:
	return cargo_types.get(name, {}).duplicate()

func calculate_delivery_price(cargo_name: String, distance: float, weight: float, urgency: String = "normal") -> float:
	"""Calculate the price for a delivery"""
	var cargo = get_cargo_type(cargo_name)
	if cargo.is_empty():
		return 0.0

	# Base price per km
	var price = cargo.base_price * distance

	# Weight factor
	price *= 1.0 + (weight * cargo.weight_factor * 0.05)

	# Urgency multiplier
	match urgency:
		"express":
			price *= 1.5
		"urgent":
			price *= 1.3
		"normal":
			price *= 1.0
		"economy":
			price *= 0.8

	# Time sensitive cargo costs more
	if cargo.time_sensitive:
		price *= 1.2

	# Special requirements increase cost
	price *= 1.0 + (cargo.special_requirements.size() * 0.15)

	# Market demand (from MarketAI)
	if has_node("/root/MarketAI"):
		var demand = MarketAI.get_cargo_demand_multiplier(cargo_name)
		price *= demand

	return price

func meets_requirements(cargo_name: String, truck: Dictionary, driver: Dictionary) -> Dictionary:
	"""Check if truck and driver meet cargo requirements"""
	var cargo = get_cargo_type(cargo_name)
	if cargo.is_empty():
		return {"meets": false, "missing": ["Cargo type not found"]}

	var missing = []

	for req in cargo.special_requirements:
		match req:
			"refrigeration":
				if not truck.has("refrigeration") or not truck.refrigeration:
					missing.append("Refrigerated truck required")
			"freezer":
				if not truck.has("freezer") or not truck.freezer:
					missing.append("Freezer truck required")
			"hazmat_license":
				if not driver.has("hazmat_certified") or not driver.hazmat_certified:
					missing.append("HazMat certified driver required")
			"certified_driver":
				if driver.skill < 70:
					missing.append("Experienced driver required (70+ skill)")
			"heavy_vehicle":
				if truck.get("class", 0) < 2:  # Less than heavy truck
					missing.append("Heavy truck required")
			"special_vehicle":
				if not truck.has("hazmat_equipped") or not truck.hazmat_equipped:
					missing.append("Hazmat-equipped vehicle required")

	return {
		"meets": missing.is_empty(),
		"missing": missing
	}

func get_category_name(category: CargoCategory) -> String:
	match category:
		CargoCategory.GENERAL:
			return "General Freight"
		CargoCategory.PERISHABLE:
			return "Perishable Goods"
		CargoCategory.FRAGILE:
			return "Fragile Items"
		CargoCategory.HAZARDOUS:
			return "Hazardous Materials"
		CargoCategory.VALUABLE:
			return "High Value"
		CargoCategory.OVERSIZED:
			return "Oversized/Heavy"
		CargoCategory.TEMPERATURE_CONTROLLED:
			return "Temperature Controlled"
		CargoCategory.EXPRESS:
			return "Express Delivery"
	return "Unknown"

func get_high_paying_cargo() -> Array:
	"""Get cargo types that pay well"""
	var all_cargo = []
	for name in cargo_types.keys():
		var cargo = cargo_types[name].duplicate()
		all_cargo.append(cargo)

	all_cargo.sort_custom(func(a, b): return a.base_price > b.base_price)

	return all_cargo.slice(0, 5)

func requires_special_equipment(cargo_name: String) -> bool:
	var cargo = get_cargo_type(cargo_name)
	if cargo.is_empty():
		return false

	return not cargo.special_requirements.is_empty()
