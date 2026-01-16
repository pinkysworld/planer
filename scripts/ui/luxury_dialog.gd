extends Control
## LuxuryDialog - Buy luxury items to increase social status

signal closed

@onready var money_label = $Panel/VBox/Header/MoneyLabel
@onready var status_label = $Panel/VBox/Header/StatusLabel
@onready var items_container = $Panel/VBox/ItemsList/ItemsContainer
@onready var owned_label = $Panel/VBox/OwnedSection/OwnedLabel
@onready var info_label = $Panel/VBox/Footer/InfoLabel

# Luxury items available for purchase
var luxury_items: Array = [
	{
		"name": "Smart TV 65\"",
		"price": 2000.0,
		"status_bonus": 3.0,
		"description": "Premium 4K smart television"
	},
	{
		"name": "Designer Watch",
		"price": 5000.0,
		"status_bonus": 5.0,
		"description": "Swiss-made luxury timepiece"
	},
	{
		"name": "Home Theater System",
		"price": 8000.0,
		"status_bonus": 6.0,
		"description": "Surround sound cinema experience"
	},
	{
		"name": "Electric Sports Car",
		"price": 85000.0,
		"status_bonus": 15.0,
		"description": "High-performance electric vehicle"
	},
	{
		"name": "Luxury Sedan",
		"price": 60000.0,
		"status_bonus": 12.0,
		"description": "Executive class automobile"
	},
	{
		"name": "Designer Furniture Set",
		"price": 15000.0,
		"status_bonus": 8.0,
		"description": "Italian designer living room set"
	},
	{
		"name": "Swimming Pool",
		"price": 45000.0,
		"status_bonus": 10.0,
		"description": "In-ground heated pool for your home"
	},
	{
		"name": "Art Collection",
		"price": 25000.0,
		"status_bonus": 8.0,
		"description": "Curated modern art pieces"
	},
	{
		"name": "Yacht Share",
		"price": 100000.0,
		"status_bonus": 18.0,
		"description": "Fractional ownership of a luxury yacht"
	},
	{
		"name": "Vacation Home",
		"price": 200000.0,
		"status_bonus": 25.0,
		"description": "Beach house on the Mediterranean"
	},
	{
		"name": "Football Club Sponsorship",
		"price": 500000.0,
		"status_bonus": 35.0,
		"description": "Become a major sponsor of a football club"
	}
]

func _ready() -> void:
	_refresh_display()

func _refresh_display() -> void:
	money_label.text = "Private: €%.0f" % GameManager.private_money
	status_label.text = "Status: %.0f%%" % GameManager.social_status

	_refresh_items_list()
	_refresh_owned_list()

func _refresh_items_list() -> void:
	for child in items_container.get_children():
		child.queue_free()

	# Get list of already owned items
	var owned_names = []
	for item in GameManager.luxury_items:
		owned_names.append(item.name)

	for item in luxury_items:
		# Skip already owned items
		if item.name in owned_names:
			continue

		var card = _create_item_card(item)
		items_container.add_child(card)

func _refresh_owned_list() -> void:
	if GameManager.luxury_items.is_empty():
		owned_label.text = "None yet - start shopping!"
	else:
		var names = []
		for item in GameManager.luxury_items:
			names.append(item.name)
		owned_label.text = ", ".join(names)

func _create_item_card(item: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 70)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)

	# Item info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = item.name
	name_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = item.description
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.add_theme_font_size_override("font_size", 13)
	info_vbox.add_child(desc_label)

	hbox.add_child(info_vbox)

	# Status bonus
	var bonus_label = Label.new()
	bonus_label.text = "+%.0f%% Status" % item.status_bonus
	bonus_label.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
	hbox.add_child(bonus_label)

	# Price and buy button
	var buy_vbox = VBoxContainer.new()
	buy_vbox.add_theme_constant_override("separation", 3)

	var price_label = Label.new()
	price_label.text = "€%.0f" % item.price
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	buy_vbox.add_child(price_label)

	var buy_btn = Button.new()
	buy_btn.text = "Buy"
	buy_btn.custom_minimum_size = Vector2(70, 30)
	buy_btn.disabled = GameManager.private_money < item.price
	buy_btn.pressed.connect(func(): _buy_item(item))
	buy_vbox.add_child(buy_btn)

	hbox.add_child(buy_vbox)

	return card

func _buy_item(item: Dictionary) -> void:
	AudioManager.play_sfx("cash_register")

	if GameManager.buy_luxury_item(item):
		info_label.text = "Purchased %s! Status increased by %.0f%%!" % [item.name, item.status_bonus]
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		_refresh_display()
	else:
		info_label.text = "Not enough private money for this item."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
