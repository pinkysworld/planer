extends Control
## TruckDealerDialog - Buy and sell trucks

signal closed

@onready var money_label = $Panel/VBox/Header/MoneyLabel
@onready var buy_container = $"Panel/VBox/TabContainer/Buy Trucks/BuyContainer"
@onready var sell_container = $"Panel/VBox/TabContainer/Sell Trucks/SellContainer"
@onready var info_label = $Panel/VBox/Footer/InfoLabel
@onready var tab_container = $Panel/VBox/TabContainer

# Available trucks for purchase (modernized fleet)
var trucks_for_sale: Array = [
	{
		"model": "EuroHauler 420",
		"price": 45000.0,
		"fuel_type": "diesel",
		"capacity": 18.0,
		"fuel_efficiency": 28.0,
		"max_speed": 85.0,
		"description": "Reliable workhorse for regional deliveries"
	},
	{
		"model": "TransMaster Pro",
		"price": 65000.0,
		"fuel_type": "diesel",
		"capacity": 24.0,
		"fuel_efficiency": 32.0,
		"max_speed": 90.0,
		"description": "High-capacity long-haul truck"
	},
	{
		"model": "EcoFreight Electric",
		"price": 95000.0,
		"fuel_type": "electric",
		"capacity": 16.0,
		"fuel_efficiency": 1.2,  # kWh/km
		"max_speed": 80.0,
		"description": "Zero-emission electric truck for eco-friendly deliveries"
	},
	{
		"model": "HydroPower H2",
		"price": 120000.0,
		"fuel_type": "hydrogen",
		"capacity": 22.0,
		"fuel_efficiency": 8.0,  # kg/100km
		"max_speed": 85.0,
		"description": "Cutting-edge hydrogen fuel cell truck"
	},
	{
		"model": "SpeedCargo Express",
		"price": 75000.0,
		"fuel_type": "diesel",
		"capacity": 15.0,
		"fuel_efficiency": 25.0,
		"max_speed": 100.0,
		"description": "Fast delivery truck for urgent shipments"
	},
	{
		"model": "MegaHaul XL",
		"price": 110000.0,
		"fuel_type": "diesel",
		"capacity": 30.0,
		"fuel_efficiency": 38.0,
		"max_speed": 80.0,
		"description": "Maximum capacity for heavy cargo"
	},
	{
		"model": "CityRunner Compact",
		"price": 35000.0,
		"fuel_type": "diesel",
		"capacity": 10.0,
		"fuel_efficiency": 18.0,
		"max_speed": 90.0,
		"description": "Nimble city delivery truck"
	},
	{
		"model": "GreenWay Hybrid",
		"price": 80000.0,
		"fuel_type": "diesel",
		"capacity": 20.0,
		"fuel_efficiency": 22.0,
		"max_speed": 88.0,
		"description": "Hybrid diesel-electric for fuel savings"
	}
]

func _ready() -> void:
	_update_money_display()
	_refresh_buy_list()
	_refresh_sell_list()
	tab_container.tab_changed.connect(_on_tab_changed)

func _update_money_display() -> void:
	money_label.text = "Company: €%.0f" % GameManager.company_money

func _on_tab_changed(tab: int) -> void:
	if tab == 1:
		_refresh_sell_list()

func _refresh_buy_list() -> void:
	for child in buy_container.get_children():
		child.queue_free()

	for truck_data in trucks_for_sale:
		var card = _create_buy_card(truck_data)
		buy_container.add_child(card)

func _refresh_sell_list() -> void:
	for child in sell_container.get_children():
		child.queue_free()

	var available_trucks = GameManager.trucks.filter(func(t): return t.is_available)

	if available_trucks.is_empty():
		var label = Label.new()
		label.text = "No trucks available to sell.\nAll trucks are on delivery or you don't own any."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		sell_container.add_child(label)
		return

	for truck in available_trucks:
		var card = _create_sell_card(truck)
		sell_container.add_child(card)

func _create_buy_card(truck_data: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 100)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)

	# Truck info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var model_label = Label.new()
	model_label.text = truck_data.model
	model_label.add_theme_font_size_override("font_size", 18)
	info_vbox.add_child(model_label)

	var desc_label = Label.new()
	desc_label.text = truck_data.description
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_vbox.add_child(desc_label)

	hbox.add_child(info_vbox)

	# Stats
	var stats_vbox = VBoxContainer.new()

	var fuel_label = Label.new()
	var fuel_text = ""
	match truck_data.fuel_type:
		"diesel":
			fuel_text = "Diesel | %.0f L/100km" % truck_data.fuel_efficiency
		"electric":
			fuel_text = "Electric | %.1f kWh/km" % truck_data.fuel_efficiency
		"hydrogen":
			fuel_text = "Hydrogen | %.0f kg/100km" % truck_data.fuel_efficiency
	fuel_label.text = fuel_text
	stats_vbox.add_child(fuel_label)

	var capacity_label = Label.new()
	capacity_label.text = "Capacity: %.0f tons | Speed: %.0f km/h" % [truck_data.capacity, truck_data.max_speed]
	stats_vbox.add_child(capacity_label)

	hbox.add_child(stats_vbox)

	# Price and buy button
	var buy_vbox = VBoxContainer.new()
	buy_vbox.add_theme_constant_override("separation", 5)

	var price_label = Label.new()
	price_label.text = "€%.0f" % truck_data.price
	price_label.add_theme_font_size_override("font_size", 20)
	price_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	buy_vbox.add_child(price_label)

	var buy_btn = Button.new()
	buy_btn.text = "Buy"
	buy_btn.custom_minimum_size = Vector2(80, 35)
	buy_btn.disabled = GameManager.company_money < truck_data.price
	buy_btn.pressed.connect(func(): _buy_truck(truck_data))
	buy_vbox.add_child(buy_btn)

	hbox.add_child(buy_vbox)

	return card

func _create_sell_card(truck: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)

	# Truck info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var model_label = Label.new()
	model_label.text = truck.model
	model_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(model_label)

	var stats_label = Label.new()
	stats_label.text = "Condition: %.0f%% | Mileage: %.0f km" % [truck.condition, truck.mileage]
	if truck.condition < 50:
		stats_label.add_theme_color_override("font_color", Color(1, 0.5, 0.3))
	info_vbox.add_child(stats_label)

	hbox.add_child(info_vbox)

	# Sell price and button
	var sell_price = truck.value * (truck.condition / 100.0) * 0.7
	var sell_vbox = VBoxContainer.new()

	var price_label = Label.new()
	price_label.text = "€%.0f" % sell_price
	price_label.add_theme_font_size_override("font_size", 18)
	price_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	sell_vbox.add_child(price_label)

	var sell_btn = Button.new()
	sell_btn.text = "Sell"
	sell_btn.custom_minimum_size = Vector2(80, 35)
	var truck_id = truck.id
	sell_btn.pressed.connect(func(): _sell_truck(truck_id))
	sell_vbox.add_child(sell_btn)

	hbox.add_child(sell_vbox)

	return card

func _buy_truck(truck_data: Dictionary) -> void:
	AudioManager.play_sfx("cash_register")

	if GameManager.buy_truck(truck_data.model, truck_data.price, truck_data.fuel_type):
		info_label.text = "Purchased %s for €%.0f!" % [truck_data.model, truck_data.price]
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		_update_money_display()
		_refresh_buy_list()
		_refresh_sell_list()
	else:
		info_label.text = "Not enough money to purchase this truck."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _sell_truck(truck_id: String) -> void:
	AudioManager.play_sfx("cash_register")

	if GameManager.sell_truck(truck_id):
		info_label.text = "Truck sold successfully!"
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		_update_money_display()
		_refresh_sell_list()
	else:
		info_label.text = "Failed to sell truck."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
