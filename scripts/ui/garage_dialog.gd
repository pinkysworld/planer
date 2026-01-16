extends Control
## GarageDialog - Truck maintenance and repairs

signal closed

@onready var trucks_container = $Panel/VBox/TrucksList/TrucksContainer
@onready var info_label = $Panel/VBox/Footer/InfoLabel
@onready var repair_all_btn = $Panel/VBox/Footer/RepairAllButton

func _ready() -> void:
	_refresh_trucks()

func _refresh_trucks() -> void:
	for child in trucks_container.get_children():
		child.queue_free()

	if GameManager.trucks.is_empty():
		var label = Label.new()
		label.text = "No trucks owned. Visit the Truck Dealer to purchase trucks."
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		trucks_container.add_child(label)
		repair_all_btn.disabled = true
		return

	var any_need_repair = false

	for truck in GameManager.trucks:
		var card = _create_truck_card(truck)
		trucks_container.add_child(card)
		if truck.condition < 100:
			any_need_repair = true

	repair_all_btn.disabled = not any_need_repair

func _create_truck_card(truck: Dictionary) -> Control:
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
	model_label.text = truck.model
	model_label.add_theme_font_size_override("font_size", 18)
	info_vbox.add_child(model_label)

	var mileage_label = Label.new()
	mileage_label.text = "Mileage: %.0f km" % truck.mileage
	info_vbox.add_child(mileage_label)

	var status_label = Label.new()
	if truck.is_available:
		status_label.text = "Available"
		status_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	else:
		status_label.text = "On delivery"
		status_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	info_vbox.add_child(status_label)

	hbox.add_child(info_vbox)

	# Condition display
	var condition_vbox = VBoxContainer.new()
	condition_vbox.add_theme_constant_override("separation", 5)

	var condition_label = Label.new()
	condition_label.text = "Condition"
	condition_label.add_theme_font_size_override("font_size", 14)
	condition_vbox.add_child(condition_label)

	var progress = ProgressBar.new()
	progress.custom_minimum_size = Vector2(150, 25)
	progress.max_value = 100.0
	progress.value = truck.condition
	progress.show_percentage = true

	# Color based on condition
	if truck.condition < 30:
		progress.modulate = Color(1, 0.3, 0.3)
	elif truck.condition < 60:
		progress.modulate = Color(1, 0.8, 0.3)
	else:
		progress.modulate = Color(0.3, 1, 0.5)

	condition_vbox.add_child(progress)

	hbox.add_child(condition_vbox)

	# Repair section
	var repair_vbox = VBoxContainer.new()
	repair_vbox.add_theme_constant_override("separation", 5)

	var repair_cost = (100.0 - truck.condition) * truck.value * 0.002
	var cost_label = Label.new()
	if truck.condition < 100:
		cost_label.text = "Repair: €%.0f" % repair_cost
		cost_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	else:
		cost_label.text = "Perfect condition"
		cost_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	repair_vbox.add_child(cost_label)

	var repair_btn = Button.new()
	repair_btn.text = "Repair"
	repair_btn.custom_minimum_size = Vector2(80, 35)
	repair_btn.disabled = truck.condition >= 100 or not truck.is_available
	var truck_id = truck.id
	repair_btn.pressed.connect(func(): _repair_truck(truck_id))
	repair_vbox.add_child(repair_btn)

	hbox.add_child(repair_vbox)

	return card

func _repair_truck(truck_id: String) -> void:
	AudioManager.play_sfx("cash_register")

	if GameManager.repair_truck(truck_id):
		info_label.text = "Truck repaired to perfect condition!"
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
		_refresh_trucks()
	else:
		info_label.text = "Not enough money for repairs or truck unavailable."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

func _on_repair_all_pressed() -> void:
	AudioManager.play_sfx("cash_register")

	var repaired = 0
	var failed = 0

	for truck in GameManager.trucks:
		if truck.condition < 100 and truck.is_available:
			if GameManager.repair_truck(truck.id):
				repaired += 1
			else:
				failed += 1

	if repaired > 0:
		info_label.text = "Repaired %d truck(s)!" % repaired
		info_label.add_theme_color_override("font_color", Color(0.3, 1, 0.5))
	else:
		info_label.text = "Could not repair any trucks (insufficient funds or unavailable)."
		info_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

	_refresh_trucks()

func _on_close_pressed() -> void:
	AudioManager.play_sfx("click")
	emit_signal("closed")
