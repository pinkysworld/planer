extends Node
## LuxuryItemsDatabase - Lifestyle items and status symbols from Planer series
## Cars, watches, jewelry, hobbies, and more

enum ItemCategory {
	VEHICLES,
	WATCHES,
	JEWELRY,
	ELECTRONICS,
	HOBBIES,
	HOME_DECOR,
	FASHION,
	EXPERIENCES
}

var luxury_items: Dictionary = {}

func _ready() -> void:
	_initialize_luxury_items()

func _initialize_luxury_items() -> void:
	# === VEHICLES (PERSONAL CARS) ===

	_add_item("Used Volkswagen Golf", {
		"category": ItemCategory.VEHICLES,
		"price": 15000,
		"status_boost": 5,
		"happiness_boost": 10.0,
		"relationship_boost": 5.0,
		"description": "A reliable and practical family car.",
		"maintenance_cost": 100  # monthly
	})

	_add_item("BMW 3 Series", {
		"category": ItemCategory.VEHICLES,
		"price": 45000,
		"status_boost": 15,
		"happiness_boost": 20.0,
		"relationship_boost": 10.0,
		"description": "Premium German engineering and comfort.",
		"maintenance_cost": 250
	})

	_add_item("Mercedes-Benz E-Class", {
		"category": ItemCategory.VEHICLES,
		"price": 65000,
		"status_boost": 25,
		"happiness_boost": 25.0,
		"relationship_boost": 15.0,
		"description": "Luxury and prestige in automotive form.",
		"maintenance_cost": 350
	})

	_add_item("Porsche 911", {
		"category": ItemCategory.VEHICLES,
		"price": 120000,
		"status_boost": 40,
		"happiness_boost": 35.0,
		"relationship_boost": 20.0,
		"description": "The ultimate sports car icon.",
		"maintenance_cost": 500
	})

	_add_item("Ferrari F8 Tributo", {
		"category": ItemCategory.VEHICLES,
		"price": 250000,
		"status_boost": 60,
		"happiness_boost": 45.0,
		"relationship_boost": 25.0,
		"description": "Italian supercar excellence. The pinnacle of success.",
		"maintenance_cost": 1200
	})

	_add_item("Rolls-Royce Ghost", {
		"category": ItemCategory.VEHICLES,
		"price": 350000,
		"status_boost": 80,
		"happiness_boost": 50.0,
		"relationship_boost": 30.0,
		"description": "The epitome of luxury and refinement.",
		"maintenance_cost": 1500
	})

	# === WATCHES ===

	_add_item("Casio Digital Watch", {
		"category": ItemCategory.WATCHES,
		"price": 50,
		"status_boost": 0,
		"happiness_boost": 2.0,
		"relationship_boost": 0.0,
		"description": "Practical and functional timepiece.",
		"maintenance_cost": 0
	})

	_add_item("Seiko Automatic", {
		"category": ItemCategory.WATCHES,
		"price": 500,
		"status_boost": 2,
		"happiness_boost": 5.0,
		"relationship_boost": 2.0,
		"description": "Quality Japanese craftsmanship.",
		"maintenance_cost": 5
	})

	_add_item("Omega Seamaster", {
		"category": ItemCategory.WATCHES,
		"price": 5000,
		"status_boost": 8,
		"happiness_boost": 12.0,
		"relationship_boost": 5.0,
		"description": "Swiss precision and elegance.",
		"maintenance_cost": 15
	})

	_add_item("Rolex Submariner", {
		"category": ItemCategory.WATCHES,
		"price": 12000,
		"status_boost": 15,
		"happiness_boost": 18.0,
		"relationship_boost": 8.0,
		"description": "The iconic luxury dive watch.",
		"maintenance_cost": 25
	})

	_add_item("Patek Philippe Calatrava", {
		"category": ItemCategory.WATCHES,
		"price": 35000,
		"status_boost": 30,
		"happiness_boost": 25.0,
		"relationship_boost": 12.0,
		"description": "Horological perfection. An investment piece.",
		"maintenance_cost": 50
	})

	# === JEWELRY ===

	_add_item("Gold Chain", {
		"category": ItemCategory.JEWELRY,
		"price": 800,
		"status_boost": 3,
		"happiness_boost": 5.0,
		"relationship_boost": 3.0,
		"description": "Classic gold jewelry.",
		"maintenance_cost": 0
	})

	_add_item("Diamond Ring", {
		"category": ItemCategory.JEWELRY,
		"price": 3500,
		"status_boost": 10,
		"happiness_boost": 15.0,
		"relationship_boost": 20.0,
		"description": "A symbol of love and commitment.",
		"maintenance_cost": 0
	})

	_add_item("Diamond Necklace", {
		"category": ItemCategory.JEWELRY,
		"price": 8000,
		"status_boost": 18,
		"happiness_boost": 20.0,
		"relationship_boost": 25.0,
		"description": "Exquisite diamond jewelry.",
		"maintenance_cost": 5
	})

	_add_item("Designer Watch & Ring Set", {
		"category": ItemCategory.JEWELRY,
		"price": 15000,
		"status_boost": 25,
		"happiness_boost": 25.0,
		"relationship_boost": 30.0,
		"description": "Luxury jewelry set for special occasions.",
		"maintenance_cost": 10
	})

	# === ELECTRONICS ===

	_add_item("Basic Laptop", {
		"category": ItemCategory.ELECTRONICS,
		"price": 800,
		"status_boost": 1,
		"happiness_boost": 8.0,
		"relationship_boost": 2.0,
		"description": "For work and entertainment.",
		"maintenance_cost": 0
	})

	_add_item("High-End Gaming PC", {
		"category": ItemCategory.ELECTRONICS,
		"price": 3500,
		"status_boost": 5,
		"happiness_boost": 15.0,
		"relationship_boost": 5.0,
		"description": "Ultimate gaming and productivity setup.",
		"maintenance_cost": 10
	})

	_add_item("Home Theater System", {
		"category": ItemCategory.ELECTRONICS,
		"price": 5000,
		"status_boost": 8,
		"happiness_boost": 18.0,
		"relationship_boost": 12.0,
		"description": "Cinema-quality entertainment at home.",
		"maintenance_cost": 15
	})

	_add_item("Smart Home System", {
		"category": ItemCategory.ELECTRONICS,
		"price": 8000,
		"status_boost": 12,
		"happiness_boost": 20.0,
		"relationship_boost": 10.0,
		"description": "Automated luxury living.",
		"maintenance_cost": 20
	})

	# === HOBBIES ===

	_add_item("Fishing Equipment", {
		"category": ItemCategory.HOBBIES,
		"price": 1200,
		"status_boost": 2,
		"happiness_boost": 12.0,
		"relationship_boost": 3.0,
		"description": "Relaxing hobby for stress relief.",
		"stress_reduction": 5.0,
		"maintenance_cost": 5
	})

	_add_item("Golf Club Membership", {
		"category": ItemCategory.HOBBIES,
		"price": 5000,
		"status_boost": 15,
		"happiness_boost": 15.0,
		"relationship_boost": 8.0,
		"description": "Network with business elite.",
		"stress_reduction": 8.0,
		"maintenance_cost": 150
	})

	_add_item("Sailing Yacht", {
		"category": ItemCategory.HOBBIES,
		"price": 85000,
		"status_boost": 45,
		"happiness_boost": 40.0,
		"relationship_boost": 25.0,
		"description": "Freedom on the open sea.",
		"stress_reduction": 15.0,
		"maintenance_cost": 500
	})

	_add_item("Private Pilot License", {
		"category": ItemCategory.HOBBIES,
		"price": 15000,
		"status_boost": 25,
		"happiness_boost": 30.0,
		"relationship_boost": 15.0,
		"description": "Take to the skies!",
		"stress_reduction": 10.0,
		"maintenance_cost": 200
	})

	# === HOME DECOR ===

	_add_item("Expensive Painting", {
		"category": ItemCategory.HOME_DECOR,
		"price": 8000,
		"status_boost": 12,
		"happiness_boost": 10.0,
		"relationship_boost": 8.0,
		"description": "Fine art for your home.",
		"maintenance_cost": 0
	})

	_add_item("Designer Furniture Set", {
		"category": ItemCategory.HOME_DECOR,
		"price": 15000,
		"status_boost": 15,
		"happiness_boost": 18.0,
		"relationship_boost": 15.0,
		"description": "Luxurious Italian furniture.",
		"maintenance_cost": 0
	})

	_add_item("Indoor Swimming Pool", {
		"category": ItemCategory.HOME_DECOR,
		"price": 50000,
		"status_boost": 35,
		"happiness_boost": 35.0,
		"relationship_boost": 25.0,
		"description": "Ultimate home luxury.",
		"stress_reduction": 12.0,
		"maintenance_cost": 300
	})

	_add_item("Wine Cellar Collection", {
		"category": ItemCategory.HOME_DECOR,
		"price": 25000,
		"status_boost": 20,
		"happiness_boost": 20.0,
		"relationship_boost": 15.0,
		"description": "Rare wines and spirits collection.",
		"maintenance_cost": 50
	})

	# === FASHION ===

	_add_item("Designer Suit", {
		"category": ItemCategory.FASHION,
		"price": 3000,
		"status_boost": 8,
		"happiness_boost": 8.0,
		"relationship_boost": 5.0,
		"description": "Look professional and successful.",
		"maintenance_cost": 20
	})

	_add_item("Luxury Wardrobe", {
		"category": ItemCategory.FASHION,
		"price": 8000,
		"status_boost": 15,
		"happiness_boost": 12.0,
		"relationship_boost": 10.0,
		"description": "Complete designer wardrobe.",
		"maintenance_cost": 50
	})

	# === EXPERIENCES ===

	_add_item("Weekend Spa Package", {
		"category": ItemCategory.EXPERIENCES,
		"price": 2000,
		"status_boost": 3,
		"happiness_boost": 15.0,
		"relationship_boost": 12.0,
		"description": "Relaxation and rejuvenation.",
		"stress_reduction": 20.0,
		"one_time": true
	})

	_add_item("Luxury Cruise", {
		"category": ItemCategory.EXPERIENCES,
		"price": 10000,
		"status_boost": 12,
		"happiness_boost": 30.0,
		"relationship_boost": 25.0,
		"description": "Mediterranean cruise vacation.",
		"stress_reduction": 30.0,
		"one_time": true
	})

	_add_item("Private Island Vacation", {
		"category": ItemCategory.EXPERIENCES,
		"price": 25000,
		"status_boost": 25,
		"happiness_boost": 45.0,
		"relationship_boost": 35.0,
		"description": "The ultimate luxury getaway.",
		"stress_reduction": 40.0,
		"one_time": true
	})

func _add_item(name: String, data: Dictionary) -> void:
	data.name = name
	luxury_items[name] = data

# Public API
func get_all_items() -> Dictionary:
	return luxury_items.duplicate()

func get_items_by_category(category: ItemCategory) -> Array:
	var result = []
	for item_name in luxury_items.keys():
		if luxury_items[item_name].category == category:
			result.append(luxury_items[item_name].duplicate())
	return result

func get_items_by_price_range(min_price: float, max_price: float) -> Array:
	var result = []
	for item_name in luxury_items.keys():
		var price = luxury_items[item_name].price
		if price >= min_price and price <= max_price:
			result.append(luxury_items[item_name].duplicate())
	return result

func get_item(name: String) -> Dictionary:
	return luxury_items.get(name, {}).duplicate()

func get_category_name(category: ItemCategory) -> String:
	match category:
		ItemCategory.VEHICLES:
			return "Personal Vehicles"
		ItemCategory.WATCHES:
			return "Watches"
		ItemCategory.JEWELRY:
			return "Jewelry"
		ItemCategory.ELECTRONICS:
			return "Electronics"
		ItemCategory.HOBBIES:
			return "Hobbies"
		ItemCategory.HOME_DECOR:
			return "Home Decor"
		ItemCategory.FASHION:
			return "Fashion"
		ItemCategory.EXPERIENCES:
			return "Experiences"
	return "Unknown"

func calculate_monthly_maintenance() -> float:
	"""Calculate total monthly maintenance for all owned luxury items"""
	var total = 0.0

	if has_node("/root/FamilyLifeSystem"):
		for item in FamilyLifeSystem.luxury_items:
			total += item.get("maintenance_cost", 0)

	return total

func get_recommended_items(budget: float, priority: String = "happiness") -> Array:
	"""Get recommended items based on budget and priority"""
	var affordable = get_items_by_price_range(0, budget)

	# Sort by priority
	match priority:
		"happiness":
			affordable.sort_custom(func(a, b): return a.happiness_boost > b.happiness_boost)
		"status":
			affordable.sort_custom(func(a, b): return a.status_boost > b.status_boost)
		"relationship":
			affordable.sort_custom(func(a, b): return a.relationship_boost > b.relationship_boost)

	return affordable.slice(0, min(5, affordable.size()))
