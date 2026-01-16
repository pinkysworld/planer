extends Control
## ContractsDialog - View and accept delivery contracts

signal closed

@onready var contracts_container = $Panel/VBox/ContractsList/ContractsContainer
@onready var info_label = $Panel/VBox/Footer/InfoLabel

func _ready() -> void:
	_refresh_contracts()

func _refresh_contracts() -> void:
	# Clear existing contract cards
	for child in contracts_container.get_children():
		child.queue_free()

	# Add contract cards for available contracts
	var available_contracts = GameManager.contracts.filter(func(c): return c.status == "available")

	if available_contracts.is_empty():
		var no_contracts = Label.new()
		no_contracts.text = "No contracts available. Check back later."
		no_contracts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		contracts_container.add_child(no_contracts)
		return

	for contract in available_contracts:
		var card = _create_contract_card(contract)
		contracts_container.add_child(card)

func _create_contract_card(contract: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 100)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)

	# Contract info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var client_label = Label.new()
	client_label.text = contract.client
	client_label.add_theme_font_size_override("font_size", 18)
	info_vbox.add_child(client_label)

	var route_label = Label.new()
	route_label.text = "%s → %s (%.0f km)" % [contract.origin, contract.destination, contract.distance]
	info_vbox.add_child(route_label)

	var cargo_label = Label.new()
	cargo_label.text = "%s - %.1f tons" % [contract.cargo_type, contract.cargo_weight]
	cargo_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_vbox.add_child(cargo_label)

	hbox.add_child(info_vbox)

	# Deadline and urgency
	var deadline_vbox = VBoxContainer.new()

	var urgency_label = Label.new()
	urgency_label.text = contract.urgency.to_upper()
	match contract.urgency:
		"urgent":
			urgency_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		"express":
			urgency_label.add_theme_color_override("font_color", Color(1, 0.7, 0.3))
		_:
			urgency_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
	deadline_vbox.add_child(urgency_label)

	var days_left = contract.deadline_day - GameManager.current_day
	var deadline_label = Label.new()
	deadline_label.text = "%d days left" % days_left
	if days_left <= 1:
		deadline_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	deadline_vbox.add_child(deadline_label)

	hbox.add_child(deadline_vbox)

	# Payment
	var payment_vbox = VBoxContainer.new()
	payment_vbox.add_theme_constant_override("separation", 5)

	var payment_label = Label.new()
	payment_label.text = "€%.0f" % contract.payment
	payment_label.add_theme_font_size_override("font_size", 20)
	payment_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	payment_vbox.add_child(payment_label)

	var penalty_label = Label.new()
	penalty_label.text = "Penalty: €%.0f" % contract.penalty
	penalty_label.add_theme_font_size_override("font_size", 12)
	penalty_label.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	payment_vbox.add_child(penalty_label)

	hbox.add_child(payment_vbox)

	# Accept button
	var accept_btn = Button.new()
	accept_btn.text = "Accept"
	accept_btn.custom_minimum_size = Vector2(80, 50)
	accept_btn.pressed.connect(func(): _accept_contract(contract))
	hbox.add_child(accept_btn)

	return card

func _accept_contract(contract: Dictionary) -> void:
	AudioManager.play_sfx("stamp")
	if GameManager.accept_contract(contract.id):
		info_label.text = "Contract accepted! Go to Dispatch to assign a truck and driver."
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		_refresh_contracts()
	else:
		info_label.text = "Failed to accept contract."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
