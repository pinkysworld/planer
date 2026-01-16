extends Node
## TruckDatabase - Comprehensive truck models inspired by Planer series
## Realistic truck specs, manufacturers, and detailed management

# Truck manufacturers
enum Manufacturer {
	MERCEDES,
	VOLVO,
	SCANIA,
	MAN,
	DAF,
	IVECO,
	RENAULT
}

# Truck classes
enum TruckClass {
	LIGHT,      # Up to 7.5 tons
	MEDIUM,     # Up to 12 tons
	HEAVY,      # Up to 18 tons
	SEMI        # 18+ tons with trailer
}

# Engine types
enum EngineType {
	DIESEL,
	DIESEL_TURBO,
	ELECTRIC,
	HYBRID,
	HYDROGEN
}

# Complete truck database
var truck_models: Dictionary = {}

func _ready() -> void:
	_initialize_truck_database()

func _initialize_truck_database() -> void:
	# === MERCEDES-BENZ ===

	_add_truck("Mercedes Sprinter 316", {
		"manufacturer": Manufacturer.MERCEDES,
		"class": TruckClass.LIGHT,
		"engine_type": EngineType.DIESEL,
		"year": 2024,
		"price": 45000,
		"max_cargo": 3.5,  # tons
		"fuel_capacity": 70,  # liters
		"fuel_consumption": 8.5,  # L/100km
		"max_speed": 120,  # km/h
		"reliability": 90,
		"comfort": 75,
		"power": 163,  # HP
		"maintenance_cost": 150,  # per service
		"resale_value": 0.65,  # % of original after 3 years
		"insurance_group": 2
	})

	_add_truck("Mercedes Atego 1218", {
		"manufacturer": Manufacturer.MERCEDES,
		"class": TruckClass.MEDIUM,
		"engine_type": EngineType.DIESEL,
		"year": 2024,
		"price": 75000,
		"max_cargo": 12.0,
		"fuel_capacity": 200,
		"fuel_consumption": 18.0,
		"max_speed": 100,
		"reliability": 88,
		"comfort": 70,
		"power": 175,
		"maintenance_cost": 300,
		"resale_value": 0.60,
		"insurance_group": 4
	})

	_add_truck("Mercedes Actros 1843", {
		"manufacturer": Manufacturer.MERCEDES,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 125000,
		"max_cargo": 25.0,
		"fuel_capacity": 400,
		"fuel_consumption": 28.0,
		"max_speed": 90,
		"reliability": 92,
		"comfort": 85,
		"power": 421,
		"maintenance_cost": 500,
		"resale_value": 0.55,
		"insurance_group": 6
	})

	_add_truck("Mercedes Actros 1851 BigSpace", {
		"manufacturer": Manufacturer.MERCEDES,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 145000,
		"max_cargo": 28.0,
		"fuel_capacity": 450,
		"fuel_consumption": 29.5,
		"max_speed": 90,
		"reliability": 93,
		"comfort": 95,
		"power": 510,
		"maintenance_cost": 550,
		"resale_value": 0.58,
		"insurance_group": 7
	})

	_add_truck("Mercedes eActros Electric", {
		"manufacturer": Manufacturer.MERCEDES,
		"class": TruckClass.HEAVY,
		"engine_type": EngineType.ELECTRIC,
		"year": 2024,
		"price": 180000,
		"max_cargo": 18.0,
		"fuel_capacity": 420,  # kWh battery
		"fuel_consumption": 1.2,  # kWh/km
		"max_speed": 85,
		"reliability": 85,
		"comfort": 88,
		"power": 400,
		"maintenance_cost": 200,
		"resale_value": 0.50,
		"insurance_group": 5,
		"charging_time": 2.5  # hours
	})

	# === VOLVO ===

	_add_truck("Volvo FL 250", {
		"manufacturer": Manufacturer.VOLVO,
		"class": TruckClass.MEDIUM,
		"engine_type": EngineType.DIESEL,
		"year": 2024,
		"price": 72000,
		"max_cargo": 11.0,
		"fuel_capacity": 190,
		"fuel_consumption": 17.5,
		"max_speed": 95,
		"reliability": 87,
		"comfort": 75,
		"power": 250,
		"maintenance_cost": 290,
		"resale_value": 0.62,
		"insurance_group": 4
	})

	_add_truck("Volvo FH16 750", {
		"manufacturer": Manufacturer.VOLVO,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 155000,
		"max_cargo": 30.0,
		"fuel_capacity": 500,
		"fuel_consumption": 30.0,
		"max_speed": 90,
		"reliability": 94,
		"comfort": 92,
		"power": 750,
		"maintenance_cost": 600,
		"resale_value": 0.60,
		"insurance_group": 8
	})

	_add_truck("Volvo FH Globetrotter", {
		"manufacturer": Manufacturer.VOLVO,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 140000,
		"max_cargo": 26.0,
		"fuel_capacity": 450,
		"fuel_consumption": 28.5,
		"max_speed": 90,
		"reliability": 91,
		"comfort": 93,
		"power": 540,
		"maintenance_cost": 520,
		"resale_value": 0.58,
		"insurance_group": 7
	})

	# === SCANIA ===

	_add_truck("Scania P280", {
		"manufacturer": Manufacturer.SCANIA,
		"class": TruckClass.HEAVY,
		"engine_type": EngineType.DIESEL,
		"year": 2024,
		"price": 85000,
		"max_cargo": 15.0,
		"fuel_capacity": 300,
		"fuel_consumption": 22.0,
		"max_speed": 90,
		"reliability": 90,
		"comfort": 72,
		"power": 280,
		"maintenance_cost": 380,
		"resale_value": 0.63,
		"insurance_group": 5
	})

	_add_truck("Scania R450", {
		"manufacturer": Manufacturer.SCANIA,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 135000,
		"max_cargo": 27.0,
		"fuel_capacity": 450,
		"fuel_consumption": 28.0,
		"max_speed": 90,
		"reliability": 92,
		"comfort": 88,
		"power": 450,
		"maintenance_cost": 510,
		"resale_value": 0.59,
		"insurance_group": 7
	})

	_add_truck("Scania S650", {
		"manufacturer": Manufacturer.SCANIA,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 160000,
		"max_cargo": 29.0,
		"fuel_capacity": 500,
		"fuel_consumption": 29.0,
		"max_speed": 90,
		"reliability": 93,
		"comfort": 94,
		"power": 650,
		"maintenance_cost": 580,
		"resale_value": 0.61,
		"insurance_group": 8
	})

	# === MAN ===

	_add_truck("MAN TGL 12.220", {
		"manufacturer": Manufacturer.MAN,
		"class": TruckClass.MEDIUM,
		"engine_type": EngineType.DIESEL,
		"year": 2024,
		"price": 68000,
		"max_cargo": 10.5,
		"fuel_capacity": 180,
		"fuel_consumption": 16.5,
		"max_speed": 95,
		"reliability": 86,
		"comfort": 70,
		"power": 220,
		"maintenance_cost": 280,
		"resale_value": 0.61,
		"insurance_group": 4
	})

	_add_truck("MAN TGX 18.480", {
		"manufacturer": Manufacturer.MAN,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 138000,
		"max_cargo": 27.0,
		"fuel_capacity": 460,
		"fuel_consumption": 28.2,
		"max_speed": 90,
		"reliability": 90,
		"comfort": 87,
		"power": 480,
		"maintenance_cost": 520,
		"resale_value": 0.57,
		"insurance_group": 7
	})

	_add_truck("MAN eTGM Electric", {
		"manufacturer": Manufacturer.MAN,
		"class": TruckClass.MEDIUM,
		"engine_type": EngineType.ELECTRIC,
		"year": 2024,
		"price": 165000,
		"max_cargo": 12.0,
		"fuel_capacity": 185,  # kWh
		"fuel_consumption": 1.1,
		"max_speed": 80,
		"reliability": 84,
		"comfort": 85,
		"power": 264,
		"maintenance_cost": 180,
		"resale_value": 0.48,
		"insurance_group": 4,
		"charging_time": 1.5
	})

	# === DAF ===

	_add_truck("DAF LF 210", {
		"manufacturer": Manufacturer.DAF,
		"class": TruckClass.MEDIUM,
		"engine_type": EngineType.DIESEL,
		"year": 2024,
		"price": 70000,
		"max_cargo": 11.0,
		"fuel_capacity": 185,
		"fuel_consumption": 17.0,
		"max_speed": 95,
		"reliability": 85,
		"comfort": 72,
		"power": 210,
		"maintenance_cost": 275,
		"resale_value": 0.60,
		"insurance_group": 4
	})

	_add_truck("DAF XF 480", {
		"manufacturer": Manufacturer.DAF,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 142000,
		"max_cargo": 28.0,
		"fuel_capacity": 470,
		"fuel_consumption": 28.5,
		"max_speed": 90,
		"reliability": 91,
		"comfort": 90,
		"power": 480,
		"maintenance_cost": 530,
		"resale_value": 0.58,
		"insurance_group": 7
	})

	_add_truck("DAF XF Super Space Cab", {
		"manufacturer": Manufacturer.DAF,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 148000,
		"max_cargo": 28.0,
		"fuel_capacity": 480,
		"fuel_consumption": 28.8,
		"max_speed": 90,
		"reliability": 92,
		"comfort": 96,
		"power": 530,
		"maintenance_cost": 545,
		"resale_value": 0.59,
		"insurance_group": 7
	})

	# === IVECO ===

	_add_truck("Iveco Daily 35C", {
		"manufacturer": Manufacturer.IVECO,
		"class": TruckClass.LIGHT,
		"engine_type": EngineType.DIESEL,
		"year": 2024,
		"price": 42000,
		"max_cargo": 3.3,
		"fuel_capacity": 75,
		"fuel_consumption": 8.0,
		"max_speed": 115,
		"reliability": 83,
		"comfort": 68,
		"power": 146,
		"maintenance_cost": 140,
		"resale_value": 0.58,
		"insurance_group": 2
	})

	_add_truck("Iveco Eurocargo 120E", {
		"manufacturer": Manufacturer.IVECO,
		"class": TruckClass.MEDIUM,
		"engine_type": EngineType.DIESEL,
		"year": 2024,
		"price": 66000,
		"max_cargo": 10.0,
		"fuel_capacity": 175,
		"fuel_consumption": 16.0,
		"max_speed": 95,
		"reliability": 84,
		"comfort": 70,
		"power": 190,
		"maintenance_cost": 265,
		"resale_value": 0.57,
		"insurance_group": 4
	})

	_add_truck("Iveco S-WAY 510", {
		"manufacturer": Manufacturer.IVECO,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 136000,
		"max_cargo": 27.0,
		"fuel_capacity": 450,
		"fuel_consumption": 27.8,
		"max_speed": 90,
		"reliability": 89,
		"comfort": 86,
		"power": 510,
		"maintenance_cost": 515,
		"resale_value": 0.56,
		"insurance_group": 7
	})

	# === RENAULT ===

	_add_truck("Renault Master", {
		"manufacturer": Manufacturer.RENAULT,
		"class": TruckClass.LIGHT,
		"engine_type": EngineType.DIESEL,
		"year": 2024,
		"price": 40000,
		"max_cargo": 3.1,
		"fuel_capacity": 80,
		"fuel_consumption": 7.8,
		"max_speed": 120,
		"reliability": 82,
		"comfort": 70,
		"power": 150,
		"maintenance_cost": 135,
		"resale_value": 0.56,
		"insurance_group": 2
	})

	_add_truck("Renault T High 520", {
		"manufacturer": Manufacturer.RENAULT,
		"class": TruckClass.SEMI,
		"engine_type": EngineType.DIESEL_TURBO,
		"year": 2024,
		"price": 139000,
		"max_cargo": 27.5,
		"fuel_capacity": 460,
		"fuel_consumption": 28.0,
		"max_speed": 90,
		"reliability": 90,
		"comfort": 89,
		"power": 520,
		"maintenance_cost": 525,
		"resale_value": 0.57,
		"insurance_group": 7
	})

	# === SPECIALTY/VINTAGE ===

	_add_truck("Classic Mercedes 1980 Restored", {
		"manufacturer": Manufacturer.MERCEDES,
		"class": TruckClass.MEDIUM,
		"engine_type": EngineType.DIESEL,
		"year": 1980,
		"price": 35000,
		"max_cargo": 8.0,
		"fuel_capacity": 150,
		"fuel_consumption": 22.0,
		"max_speed": 80,
		"reliability": 65,
		"comfort": 40,
		"power": 170,
		"maintenance_cost": 450,
		"resale_value": 0.75,  # Collector value
		"insurance_group": 5,
		"special": "vintage"
	})

func _add_truck(model_name: String, specs: Dictionary) -> void:
	truck_models[model_name] = specs

# Public API
func get_all_trucks() -> Dictionary:
	return truck_models.duplicate()

func get_trucks_by_manufacturer(manufacturer: Manufacturer) -> Array:
	var result = []
	for model_name in truck_models.keys():
		if truck_models[model_name].manufacturer == manufacturer:
			var truck = truck_models[model_name].duplicate()
			truck.model_name = model_name
			result.append(truck)
	return result

func get_trucks_by_class(truck_class: TruckClass) -> Array:
	var result = []
	for model_name in truck_models.keys():
		if truck_models[model_name].class == truck_class:
			var truck = truck_models[model_name].duplicate()
			truck.model_name = model_name
			result.append(truck)
	return result

func get_trucks_by_price_range(min_price: float, max_price: float) -> Array:
	var result = []
	for model_name in truck_models.keys():
		var price = truck_models[model_name].price
		if price >= min_price and price <= max_price:
			var truck = truck_models[model_name].duplicate()
			truck.model_name = model_name
			result.append(truck)
	return result

func get_electric_trucks() -> Array:
	var result = []
	for model_name in truck_models.keys():
		if truck_models[model_name].engine_type == EngineType.ELECTRIC:
			var truck = truck_models[model_name].duplicate()
			truck.model_name = model_name
			result.append(truck)
	return result

func get_truck_specs(model_name: String) -> Dictionary:
	return truck_models.get(model_name, {}).duplicate()

func calculate_running_costs(model_name: String, km_per_month: float) -> Dictionary:
	var specs = get_truck_specs(model_name)
	if specs.is_empty():
		return {}

	var fuel_price = GameManager.fuel_price_diesel if GameManager else 1.85
	if specs.engine_type == EngineType.ELECTRIC:
		fuel_price = GameManager.fuel_price_electric if GameManager else 0.30

	var fuel_cost = (km_per_month / 100.0) * specs.fuel_consumption * fuel_price
	var maintenance = specs.maintenance_cost * (km_per_month / 10000.0)  # Service every 10k km
	var insurance = specs.insurance_group * 150.0  # Monthly insurance

	return {
		"fuel_monthly": fuel_cost,
		"maintenance_monthly": maintenance,
		"insurance_monthly": insurance,
		"total_monthly": fuel_cost + maintenance + insurance
	}

func get_manufacturer_name(manufacturer: Manufacturer) -> String:
	match manufacturer:
		Manufacturer.MERCEDES:
			return "Mercedes-Benz"
		Manufacturer.VOLVO:
			return "Volvo"
		Manufacturer.SCANIA:
			return "Scania"
		Manufacturer.MAN:
			return "MAN"
		Manufacturer.DAF:
			return "DAF"
		Manufacturer.IVECO:
			return "Iveco"
		Manufacturer.RENAULT:
			return "Renault"
	return "Unknown"

func get_class_name(truck_class: TruckClass) -> String:
	match truck_class:
		TruckClass.LIGHT:
			return "Light Delivery (up to 7.5t)"
		TruckClass.MEDIUM:
			return "Medium Truck (up to 12t)"
		TruckClass.HEAVY:
			return "Heavy Truck (up to 18t)"
		TruckClass.SEMI:
			return "Semi Truck (18t+)"
	return "Unknown"
