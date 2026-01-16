extends Control
## StationsDialog - Open and manage stations in other cities

signal closed

@onready var money_label = $Panel/VBox/Header/MoneyLabel
@onready var stations_container = $"Panel/VBox/TabContainer/Current Stations/StationsContainer"
@onready var cities_container = $"Panel/VBox/TabContainer/Open New Station/CitiesContainer"
@onready var info_label = $Panel/VBox/Footer/InfoLabel

var available_cities: Dictionary = {
	"Central Europe": [
		{"name": "Berlin", "cost": 0},
		{"name": "Hamburg", "cost": 40000},
		{"name": "Munich", "cost": 45000},
		{"name": "Frankfurt", "cost": 42000},
		{"name": "Cologne", "cost": 38000},
		{"name": "Amsterdam", "cost": 55000},
		{"name": "Brussels", "cost": 52000},
		{"name": "Paris", "cost": 65000},
		{"name": "Vienna", "cost": 50000},
		{"name": "Prague", "cost": 45000},
		{"name": "Zurich", "cost": 70000}
	],
	"Scandinavia": [
		{"name": "Copenhagen", "cost": 60000},
		{"name": "Stockholm", "cost": 65000},
		{"name": "Oslo", "cost": 70000},
		{"name": "Helsinki", "cost": 75000}
	],
	"Southern Europe": [
		{"name": "Milan", "cost": 55000},
		{"name": "Barcelona", "cost": 60000},
		{"name": "Rome", "cost": 58000},
		{"name": "Madrid", "cost": 62000}
	]
}

func _ready() -> void:
	_refresh_display()

func _refresh_display() -> void:
	money_label.text = "€%.0f" % GameManager.company_money
	_refresh_stations()
	_refresh_cities()

func _refresh_stations() -> void:
	for child in stations_container.get_children():
		child.queue_free()

	if GameManager.stations.is_empty():
		var label = Label.new()
		label.text = "No stations yet. Open your first station to start expanding!"
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		stations_container.add_child(label)
		return

	for station in GameManager.stations:
		var card = _create_station_card(station)
		stations_container.add_child(card)

func _create_station_card(station: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 70)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)

	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var city_label = Label.new()
	city_label.text = station.city
	city_label.add_theme_font_size_override("font_size", 18)
	info_vbox.add_child(city_label)

	var details_label = Label.new()
	details_label.text = "Region: %s | Capacity: %d trucks" % [station.region, station.capacity]
	details_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_vbox.add_child(details_label)

	hbox.add_child(info_vbox)

	var cost_label = Label.new()
	cost_label.text = "€%.0f/month" % station.monthly_cost
	cost_label.add_theme_color_override("font_color", Color(1, 0.7, 0.3))
	hbox.add_child(cost_label)

	return card

func _refresh_cities() -> void:
	for child in cities_container.get_children():
		child.queue_free()

	for region in available_cities:
		var region_label = Label.new()
		region_label.text = region
		region_label.add_theme_font_size_override("font_size", 18)
		region_label.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
		cities_container.add_child(region_label)

		for city_data in available_cities[region]:
			if city_data.name in GameManager.unlocked_cities:
				continue  # Skip already unlocked cities

			var card = _create_city_card(city_data, region)
			cities_container.add_child(card)

func _create_city_card(city_data: Dictionary, region: String) -> Control:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var name_label = Label.new()
	name_label.text = city_data.name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(name_label)

	var cost_label = Label.new()
	cost_label.text = "€%.0f" % city_data.cost
	cost_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	hbox.add_child(cost_label)

	var open_btn = Button.new()
	open_btn.text = "Open Station"
	open_btn.custom_minimum_size = Vector2(120, 30)
	open_btn.disabled = GameManager.company_money < city_data.cost
	open_btn.pressed.connect(func(): _open_station(city_data.name, region, city_data.cost))
	hbox.add_child(open_btn)

	return hbox

func _open_station(city: String, region: String, cost: float) -> void:
	AudioManager.play_sfx("stamp")

	# Custom implementation since GameManager.open_station has different logic
	if GameManager.company_money >= cost:
		GameManager.company_money -= cost
		GameManager.unlocked_cities.append(city)
		var station = {
			"id": str(randi()) + str(Time.get_ticks_msec()),
			"city": city,
			"region": region,
			"level": 1,
			"capacity": 5,
			"monthly_cost": 2000.0,
			"opened_day": GameManager.current_day
		}
		GameManager.stations.append(station)
		GameManager.emit_signal("money_changed", GameManager.company_money, GameManager.private_money)
		EventBus.emit_signal("station_opened", station)

		info_label.text = "New station opened in %s!" % city
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		_refresh_display()
	else:
		info_label.text = "Not enough money to open station."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
